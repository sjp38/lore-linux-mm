Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBC56B00A2
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:05:23 -0400 (EDT)
Received: by pdea3 with SMTP id a3so28617770pde.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:05:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id eq8si14183765pac.187.2015.04.23.14.05.02
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:05:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 14/28] futex, thp: remove special case for THP in get_futex_key
Date: Fri, 24 Apr 2015 00:03:49 +0300
Message-Id: <1429823043-157133-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new THP refcounting, we don't need tricks to stabilize huge page.
If we've got reference to tail page, it can't split under us.

This patch effectively reverts a5b338f2b0b1.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 kernel/futex.c | 61 ++++++++++++----------------------------------------------
 1 file changed, 12 insertions(+), 49 deletions(-)

diff --git a/kernel/futex.c b/kernel/futex.c
index f4d8a85641ed..cf0192e60ef9 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -399,7 +399,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct page *page, *page_head;
+	struct page *page;
 	int err, ro = 0;
 
 	/*
@@ -442,46 +442,9 @@ again:
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
@@ -493,12 +456,12 @@ again:
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
@@ -511,7 +474,7 @@ again:
 	 * it's a read-only handle, it's expected that futexes attach to
 	 * the object not the particular process.
 	 */
-	if (PageAnon(page_head)) {
+	if (PageAnon(page)) {
 		/*
 		 * A RO anonymous page will never change and thus doesn't make
 		 * sense for futex operations.
@@ -526,15 +489,15 @@ again:
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
