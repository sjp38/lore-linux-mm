Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4F26B00A0
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:31 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so898412pdi.3
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:31 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id g12si3109161pat.237.2014.11.05.06.50.18
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/19] futex, thp: remove special case for THP in get_futex_key
Date: Wed,  5 Nov 2014 16:49:50 +0200
Message-Id: <1415198994-15252-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new THP refcounting, we don't need tricks to stabilize huge page.
If we've got reference to tail page, it can't split under us.

This patch effectively reverts a5b338f2b0b1.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 kernel/futex.c | 61 ++++++++++++----------------------------------------------
 1 file changed, 12 insertions(+), 49 deletions(-)

diff --git a/kernel/futex.c b/kernel/futex.c
index d3a9d946d0b7..fb71ccba683b 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -391,7 +391,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct page *page, *page_head;
+	struct page *page;
 	int err, ro = 0;
 
 	/*
@@ -434,46 +434,9 @@ again:
 	else
 		err = 0;
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	page_head = page;
-	if (unlikely(PageTail(page))) {
-		put_page(page);
-		/* serialize against __split_huge_page_splitting() */
-		local_irq_disable();
-		if (likely(__get_user_pages_fast(address, 1, !ro, &page) == 1)) {
-			page_head = compound_head(page);
-			/*
-			 * page_head is valid pointer but we must pin
-			 * it before taking the PG_lock and/or
-			 * PG_compound_lock. The moment we re-enable
-			 * irqs __split_huge_page_splitting() can
-			 * return and the head page can be freed from
-			 * under us. We can't take the PG_lock and/or
-			 * PG_compound_lock on a page that could be
-			 * freed from under us.
-			 */
-			if (page != page_head) {
-				get_page(page_head);
-				put_page(page);
-			}
-			local_irq_enable();
-		} else {
-			local_irq_enable();
-			goto again;
-		}
-	}
-#else
-	page_head = compound_head(page);
-	if (page != page_head) {
-		get_page(page_head);
-		put_page(page);
-	}
-#endif
-
-	lock_page(page_head);
-
+	lock_page(page);
 	/*
-	 * If page_head->mapping is NULL, then it cannot be a PageAnon
+	 * If page->mapping is NULL, then it cannot be a PageAnon
 	 * page; but it might be the ZERO_PAGE or in the gate area or
 	 * in a special mapping (all cases which we are happy to fail);
 	 * or it may have been a good file page when get_user_pages_fast
@@ -485,12 +448,12 @@ again:
 	 *
 	 * The case we do have to guard against is when memory pressure made
 	 * shmem_writepage move it from filecache to swapcache beneath us:
-	 * an unlikely race, but we do need to retry for page_head->mapping.
+	 * an unlikely race, but we do need to retry for page->mapping.
 	 */
-	if (!page_head->mapping) {
-		int shmem_swizzled = PageSwapCache(page_head);
-		unlock_page(page_head);
-		put_page(page_head);
+	if (!page->mapping) {
+		int shmem_swizzled = PageSwapCache(page);
+		unlock_page(page);
+		put_page(page);
 		if (shmem_swizzled)
 			goto again;
 		return -EFAULT;
@@ -503,7 +466,7 @@ again:
 	 * it's a read-only handle, it's expected that futexes attach to
 	 * the object not the particular process.
 	 */
-	if (PageAnon(page_head)) {
+	if (PageAnon(page)) {
 		/*
 		 * A RO anonymous page will never change and thus doesn't make
 		 * sense for futex operations.
@@ -518,15 +481,15 @@ again:
 		key->private.address = address;
 	} else {
 		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
-		key->shared.inode = page_head->mapping->host;
+		key->shared.inode = page->mapping->host;
 		key->shared.pgoff = basepage_index(page);
 	}
 
 	get_futex_key_refs(key); /* implies MB (B) */
 
 out:
-	unlock_page(page_head);
-	put_page(page_head);
+	unlock_page(page);
+	put_page(page);
 	return err;
 }
 
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
