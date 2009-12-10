Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7271C6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:30:45 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7UgPK023420
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:30:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A7E0445DE51
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:30:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D9F345DE53
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:30:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4728C1DB805E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:30:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D0CD11DB8040
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:30:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  2/8] Introduce __page_check_address
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210162947.2556.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:30:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>


page_check_address() need to take ptelock. but it might be contended.
Then we need trylock version and this patch introduce new helper function.

it will be used latter patch.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/rmap.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 278cd27..1b50425 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -268,44 +268,80 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
  * the page table lock when the pte is not present (helpful when reclaiming
  * highly shared pages).
  *
- * On success returns with pte mapped and locked.
+ * if @noblock is true, page_check_address may return -EAGAIN if lock is
+ * contended.
+ *
+ * Returns valid pte pointer if success.
+ * Returns -EFAULT if address seems invalid.
+ * Returns -EAGAIN if trylock failed.
  */
-pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
+static pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
+				   unsigned long address, spinlock_t **ptlp,
+				   int sync, int noblock)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int err = -EFAULT;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		return NULL;
+		goto out;
 
 	pud = pud_offset(pgd, address);
 	if (!pud_present(*pud))
-		return NULL;
+		goto out;
 
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
-		return NULL;
+		goto out;
 
 	pte = pte_offset_map(pmd, address);
 	/* Make a quick check before getting the lock */
-	if (!sync && !pte_present(*pte)) {
-		pte_unmap(pte);
-		return NULL;
-	}
+	if (!sync && !pte_present(*pte))
+		goto out_unmap;
 
 	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	if (noblock) {
+		if (!spin_trylock(ptl)) {
+			err = -EAGAIN;
+			goto out_unmap;
+		}
+	} else
+		spin_lock(ptl);
+
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;
 	}
-	pte_unmap_unlock(pte, ptl);
-	return NULL;
+
+	spin_unlock(ptl);
+ out_unmap:
+	pte_unmap(pte);
+ out:
+	return ERR_PTR(err);
+}
+
+/*
+ * Check that @page is mapped at @address into @mm.
+ *
+ * If @sync is false, page_check_address may perform a racy check to avoid
+ * the page table lock when the pte is not present (helpful when reclaiming
+ * highly shared pages).
+ *
+ * On success returns with pte mapped and locked.
+ */
+pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+			  unsigned long address, spinlock_t **ptlp, int sync)
+{
+	pte_t *pte;
+
+	pte = __page_check_address(page, mm, address, ptlp, sync, 0);
+	if (IS_ERR(pte))
+		return NULL;
+	return pte;
 }
 
 /**
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
