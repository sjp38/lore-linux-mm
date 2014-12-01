Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 82C1C6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 17:58:10 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so15560815wgh.41
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 14:58:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u2si32224432wjx.169.2014.12.01.14.58.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 14:58:09 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memory: merge shared-writable dirtying branches in do_wp_page()
Date: Mon,  1 Dec 2014 17:58:02 -0500
Message-Id: <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Whether there is a vm_ops->page_mkwrite or not, the page dirtying is
pretty much the same.  Make sure the page references are the same in
both cases, then merge the two branches.

It's tempting to go even further and page-lock the !page_mkwrite case,
to get it in line with everybody else setting the page table and thus
further simplify the model.  But that's not quite compelling enough to
justify dropping the pte lock, then relocking and verifying the entry
for filesystems without ->page_mkwrite, which notably includes tmpfs.
Leave it for now and lock the page late in the !page_mkwrite case.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory.c | 46 ++++++++++++++++------------------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 2a2e3648ed65..ff92abfa5303 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2046,7 +2046,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t entry;
 	int ret = 0;
 	int page_mkwrite = 0;
-	struct page *dirty_page = NULL;
+	bool dirty_shared = false;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2097,6 +2097,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
+		page_cache_get(old_page);
 		/*
 		 * Only catch write-faults on shared writable pages,
 		 * read-only shared pages can get COWed by
@@ -2104,7 +2105,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 			int tmp;
-			page_cache_get(old_page);
+
 			pte_unmap_unlock(page_table, ptl);
 			tmp = do_page_mkwrite(vma, old_page, address);
 			if (unlikely(!tmp || (tmp &
@@ -2124,11 +2125,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unlock_page(old_page);
 				goto unlock;
 			}
-
 			page_mkwrite = 1;
 		}
-		dirty_page = old_page;
-		get_page(dirty_page);
+
+		dirty_shared = true;
 
 reuse:
 		/*
@@ -2147,42 +2147,28 @@ reuse:
 		pte_unmap_unlock(page_table, ptl);
 		ret |= VM_FAULT_WRITE;
 
-		if (!dirty_page)
-			return ret;
-
-		if (!page_mkwrite) {
+		if (dirty_shared) {
 			struct address_space *mapping;
 			int dirtied;
 
-			lock_page(dirty_page);
-			dirtied = set_page_dirty(dirty_page);
-			mapping = dirty_page->mapping;
-			unlock_page(dirty_page);
+			if (!page_mkwrite)
+				lock_page(old_page);
 
-			if (dirtied && mapping) {
-				/*
-				 * Some device drivers do not set page.mapping
-				 * but still dirty their pages
-				 */
-				balance_dirty_pages_ratelimited(mapping);
-			}
+			dirtied = set_page_dirty(old_page);
+			mapping = old_page->mapping;
+			unlock_page(old_page);
+			page_cache_release(old_page);
 
-			file_update_time(vma->vm_file);
-		}
-		put_page(dirty_page);
-		if (page_mkwrite) {
-			struct address_space *mapping = dirty_page->mapping;
-
-			set_page_dirty(dirty_page);
-			unlock_page(dirty_page);
-			page_cache_release(dirty_page);
-			if (mapping)	{
+			if ((dirtied || page_mkwrite) && mapping) {
 				/*
 				 * Some device drivers do not set page.mapping
 				 * but still dirty their pages
 				 */
 				balance_dirty_pages_ratelimited(mapping);
 			}
+
+			if (!page_mkwrite)
+				file_update_time(vma->vm_file);
 		}
 
 		return ret;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
