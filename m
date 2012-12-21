Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 37E316B0069
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:28:41 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz11so3061564pad.31
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:28:40 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2 1/3] mm: Explicitly track when the page dirty bit is transferred from a pte
Date: Fri, 21 Dec 2012 13:28:26 -0800
Message-Id: <c8d9fc72eefd6611d5c8546d5449585f8643e627.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
In-Reply-To: <cover.1356124965.git.luto@amacapital.net>
References: <cover.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>

This is a slight cleanup, but, more importantly, it will let us
easily detect writes via mmap when the process is done writing
(e.g. munmaps, msyncs, fsyncs, or dies).

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 include/linux/mm.h  |  1 +
 mm/memory-failure.c |  4 +---
 mm/page-writeback.c | 16 ++++++++++++++--
 mm/rmap.c           |  9 ++++++---
 4 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a44aa00..4c7e49b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1037,6 +1037,7 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_writeback(struct page *page);
 int set_page_dirty(struct page *page);
+int set_page_dirty_from_pte(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8b20278..ab5c3f4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -892,9 +892,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	mapping = page_mapping(hpage);
 	if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
 	    mapping_cap_writeback_dirty(mapping)) {
-		if (page_mkclean(hpage)) {
-			SetPageDirty(hpage);
-		} else {
+		if (!page_mkclean(hpage)) {
 			kill = 0;
 			ttu |= TTU_IGNORE_HWPOISON;
 			printk(KERN_INFO
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 830893b..cdea11a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2109,6 +2109,19 @@ int set_page_dirty(struct page *page)
 EXPORT_SYMBOL(set_page_dirty);
 
 /*
+ * Dirty a page due to the page table dirty bit.
+ *
+ * For pages with a mapping this should be done under the page lock.
+ * This does set_page_dirty plus extra work to account for the fact that
+ * the kernel was not notified when the actual write was done.
+ */
+int set_page_dirty_from_pte(struct page *page)
+{
+	/* Doesn't do anything interesting yet. */
+	return set_page_dirty(page);
+}
+
+/*
  * set_page_dirty() is racy if the caller has no reference against
  * page->mapping->host, and if the page is unlocked.  This is because another
  * CPU could truncate the page off the mapping and then free the mapping.
@@ -2175,8 +2188,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * as a serialization point for all the different
 		 * threads doing their things.
 		 */
-		if (page_mkclean(page))
-			set_page_dirty(page);
+		page_mkclean(page);
 		/*
 		 * We carefully synchronise fault handlers against
 		 * installing a dirty pte and marking the page dirty
diff --git a/mm/rmap.c b/mm/rmap.c
index 2ee1ef0..b8fe00e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -931,6 +931,9 @@ int page_mkclean(struct page *page)
 			ret = page_mkclean_file(mapping, page);
 	}
 
+	if (ret)
+		set_page_dirty_from_pte(page);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
@@ -1151,7 +1154,7 @@ void page_remove_rmap(struct page *page)
 	 */
 	if (mapping && !mapping_cap_account_dirty(mapping) &&
 	    page_test_and_clear_dirty(page_to_pfn(page), 1))
-		set_page_dirty(page);
+		set_page_dirty_from_pte(page);
 	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
@@ -1229,7 +1232,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
-		set_page_dirty(page);
+		set_page_dirty_from_pte(page);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -1423,7 +1426,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			set_page_dirty_from_pte(page);
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
