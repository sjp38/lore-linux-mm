Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 802ED6B00B7
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:45:33 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so640017wib.1
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:33 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id g4si5999070wje.83.2014.06.13.03.45.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 03:45:32 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so629537wiw.17
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:31 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [RFC v3 7/7] shm: isolate pinned pages when sealing files
Date: Fri, 13 Jun 2014 12:36:59 +0200
Message-Id: <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, David Herrmann <dh.herrmann@gmail.com>

When setting SEAL_WRITE, we must make sure nobody has a writable reference
to the pages (via GUP or similar). We currently check references and wait
some time for them to be dropped. This, however, might fail for several
reasons, including:
 - the page is pinned for longer than we wait
 - while we wait, someone takes an already pinned page for read-access

Therefore, this patch introduces page-isolation. When sealing a file with
SEAL_WRITE, we copy all pages that have an elevated ref-count. The newpage
is put in place atomically, the old page is detached and left alone. It
will get reclaimed once the last external user dropped it.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 mm/shmem.c | 218 +++++++++++++++++++++++++++++--------------------------------
 1 file changed, 105 insertions(+), 113 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ddc3998..34b14fb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1237,6 +1237,110 @@ unlock:
 	return error;
 }
 
+static int shmem_isolate_page(struct inode *inode, struct page *oldpage)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct page *newpage;
+	int error;
+
+	if (oldpage->mapping != mapping)
+		return 0;
+	if (page_count(oldpage) - page_mapcount(oldpage) <= 2)
+		return 0;
+
+	if (page_mapped(oldpage))
+		unmap_mapping_range(mapping,
+				    (loff_t)oldpage->index << PAGE_CACHE_SHIFT,
+				    PAGE_CACHE_SIZE, 0);
+
+	VM_BUG_ON_PAGE(PageWriteback(oldpage), oldpage);
+	VM_BUG_ON_PAGE(page_has_private(oldpage), oldpage);
+
+	newpage = shmem_alloc_page(mapping_gfp_mask(mapping), info,
+				   oldpage->index);
+	if (!newpage)
+		return -ENOMEM;
+
+	__set_page_locked(newpage);
+	copy_highpage(newpage, oldpage);
+	flush_dcache_page(newpage);
+
+	page_cache_get(newpage);
+	SetPageUptodate(newpage);
+	SetPageSwapBacked(newpage);
+	newpage->mapping = mapping;
+	newpage->index = oldpage->index;
+
+	cancel_dirty_page(oldpage, PAGE_CACHE_SIZE);
+
+	spin_lock_irq(&mapping->tree_lock);
+	error = shmem_radix_tree_replace(mapping, oldpage->index,
+					 oldpage, newpage);
+	if (!error) {
+		__inc_zone_page_state(newpage, NR_FILE_PAGES);
+		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	if (error) {
+		newpage->mapping = NULL;
+		unlock_page(newpage);
+		page_cache_release(newpage);
+		page_cache_release(newpage);
+		return error;
+	}
+
+	mem_cgroup_replace_page_cache(oldpage, newpage);
+	lru_cache_add_anon(newpage);
+
+	oldpage->mapping = NULL;
+	page_cache_release(oldpage);
+	unlock_page(newpage);
+	page_cache_release(newpage);
+
+	return 1;
+}
+
+static int shmem_isolate_pins(struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct pagevec pvec;
+	pgoff_t indices[PAGEVEC_SIZE];
+	pgoff_t index;
+	int i, ret, error;
+
+	pagevec_init(&pvec, 0);
+	index = 0;
+	error = 0;
+	while ((pvec.nr = find_get_entries(mapping, index, PAGEVEC_SIZE,
+					   pvec.pages, indices))) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			index = indices[i];
+			if (radix_tree_exceptional_entry(page))
+				continue;
+			if (page->mapping != mapping)
+				continue;
+			if (page_count(page) - page_mapcount(page) <= 2)
+				continue;
+
+			lock_page(page);
+			ret = shmem_isolate_page(inode, page);
+			if (ret < 0)
+				error = ret;
+			unlock_page(page);
+		}
+		pagevec_remove_exceptionals(&pvec);
+		pagevec_release(&pvec);
+		cond_resched();
+		index++;
+	}
+
+	return error;
+}
+
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vma->vm_file);
@@ -1734,118 +1838,6 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	return offset;
 }
 
-/*
- * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
- * so reuse a tag which we firmly believe is never set or cleared on shmem.
- */
-#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
-#define LAST_SCAN               4       /* about 150ms max */
-
-static void shmem_tag_pins(struct address_space *mapping)
-{
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
-	struct page *page;
-
-	start = 0;
-	rcu_read_lock();
-
-restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		page = radix_tree_deref_slot(slot);
-		if (!page || radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
-		} else if (page_count(page) - page_mapcount(page) > 1) {
-			spin_lock_irq(&mapping->tree_lock);
-			radix_tree_tag_set(&mapping->page_tree, iter.index,
-					   SHMEM_TAG_PINNED);
-			spin_unlock_irq(&mapping->tree_lock);
-		}
-
-		if (need_resched()) {
-			cond_resched_rcu();
-			start = iter.index + 1;
-			goto restart;
-		}
-	}
-	rcu_read_unlock();
-}
-
-/*
- * Setting SEAL_WRITE requires us to verify there's no pending writer. However,
- * via get_user_pages(), drivers might have some pending I/O without any active
- * user-space mappings (eg., direct-IO, AIO). Therefore, we look at all pages
- * and see whether it has an elevated ref-count. If so, we tag them and wait for
- * them to be dropped.
- * The caller must guarantee that no new user will acquire writable references
- * to those pages to avoid races.
- */
-static int shmem_wait_for_pins(struct address_space *mapping)
-{
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
-	struct page *page;
-	int error, scan;
-
-	shmem_tag_pins(mapping);
-
-	error = 0;
-	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
-			break;
-
-		if (!scan)
-			lru_add_drain_all();
-		else if (schedule_timeout_killable((HZ << scan) / 200))
-			scan = LAST_SCAN;
-
-		start = 0;
-		rcu_read_lock();
-restart:
-		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
-					   start, SHMEM_TAG_PINNED) {
-
-			page = radix_tree_deref_slot(slot);
-			if (radix_tree_exception(page)) {
-				if (radix_tree_deref_retry(page))
-					goto restart;
-
-				page = NULL;
-			}
-
-			if (page &&
-			    page_count(page) - page_mapcount(page) != 1) {
-				if (scan < LAST_SCAN)
-					goto continue_resched;
-
-				/*
-				 * On the last scan, we clean up all those tags
-				 * we inserted; but make a note that we still
-				 * found pages pinned.
-				 */
-				error = -EBUSY;
-			}
-
-			spin_lock_irq(&mapping->tree_lock);
-			radix_tree_tag_clear(&mapping->page_tree,
-					     iter.index, SHMEM_TAG_PINNED);
-			spin_unlock_irq(&mapping->tree_lock);
-continue_resched:
-			if (need_resched()) {
-				cond_resched_rcu();
-				start = iter.index + 1;
-				goto restart;
-			}
-		}
-		rcu_read_unlock();
-	}
-
-	return error;
-}
-
 #define F_ALL_SEALS (F_SEAL_SEAL | \
 		     F_SEAL_SHRINK | \
 		     F_SEAL_GROW | \
@@ -1907,7 +1899,7 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 		if (error)
 			goto unlock;
 
-		error = shmem_wait_for_pins(file->f_mapping);
+		error = shmem_isolate_pins(inode);
 		if (error) {
 			mapping_allow_writable(file->f_mapping);
 			goto unlock;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
