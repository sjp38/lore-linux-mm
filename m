Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0966B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 11:18:40 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so12821048wid.3
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:18:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v10si22598644wif.101.2014.12.16.08.18.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 08:18:38 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memory: merge shared-writable dirtying branches in do_wp_page()
Date: Tue, 16 Dec 2014 11:18:11 -0500
Message-Id: <1418746691-326-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
References: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 48 +++++++++++++++++-------------------------------
 1 file changed, 17 insertions(+), 31 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d5a303cf2901..a26f30b6abd1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2033,7 +2033,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t entry;
 	int ret = 0;
 	int page_mkwrite = 0;
-	struct page *dirty_page = NULL;
+	bool dirty_shared = false;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2084,6 +2084,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
+		page_cache_get(old_page);
 		/*
 		 * Only catch write-faults on shared writable pages,
 		 * read-only shared pages can get COWed by
@@ -2091,7 +2092,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 			int tmp;
-			page_cache_get(old_page);
+
 			pte_unmap_unlock(page_table, ptl);
 			tmp = do_page_mkwrite(vma, old_page, address);
 			if (unlikely(!tmp || (tmp &
@@ -2111,11 +2112,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -2134,43 +2134,29 @@ reuse:
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
-			VM_BUG_ON_PAGE(PageAnon(dirty_page), dirty_page);
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
+			VM_BUG_ON_PAGE(PageAnon(old_page), old_page);
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
