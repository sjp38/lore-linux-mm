Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 289E56B00AB
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:53:20 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so7876337pdb.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:53:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id b1si31539348pat.26.2015.06.23.06.47.18
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 14/36] futex, thp: remove special case for THP in get_futex_key
Date: Tue, 23 Jun 2015 16:46:24 +0300
Message-Id: <1435067206-92901-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 2a5e3830e953..1809371ebef8 100644
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
