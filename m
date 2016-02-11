Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BD27D6B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:29:09 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so26723817pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 01:29:09 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c8si11490560pat.62.2016.02.11.01.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 01:29:08 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 1/2] mm,thp: refactor generic deposit/withdraw routines for wider usage
Date: Thu, 11 Feb 2016 14:58:26 +0530
Message-ID: <1455182907-15445-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
References: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>, Andrea Arcangeli <aarcange@redhat.com>

Generic pgtable_trans_huge_deposit()/pgtable_trans_huge_withdraw()
assume pgtable_t to be struct page * which is not true for all arches.
Thus arc, s390, sparch end up with their own copies despite no special
hardware requirements (unlike powerpc).

It seems massaging the code a bit can make it reusbale.

 - Use explicit casts to (struct page *). For existing users, this
   should be semantically no-op for existing users

 - The only addition is zero'ing out of page->lru which for arc leaves
   a stray entry in pgtable_t cause mm spew when such pgtable is freed.

  | huge_memory: BUG: failure at
  | ../mm/huge_memory.c:1858/__split_huge_page_map()!
  | CPU: 0 PID: 901 Comm: bw_mem Not tainted 4.4.0-00015-g0569c1459cfa-dirty
  |
  | Stack Trace:
  |  arc_unwind_core.constprop.1+0x94/0x104
  |  split_huge_page_to_list+0x5c0/0x920
  |  __split_huge_page_pmd+0xc8/0x1b4
  |  vma_adjust_trans_huge+0x104/0x1c8
  |  vma_adjust+0xf8/0x6d8
  |  __split_vma.isra.40+0xf8/0x174
  |  do_munmap+0x360/0x428
  |  SyS_munmap+0x28/0x44

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alex Thorlton <athorlton@sgi.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/pgtable-generic.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 75664ed7e3ab..c9f2f6f8c7bb 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -155,13 +155,17 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
+	struct page *new = (struct page *)pgtable;
+	struct page *head;
+
 	assert_spin_locked(pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
-	if (!pmd_huge_pte(mm, pmdp))
-		INIT_LIST_HEAD(&pgtable->lru);
+	head = (struct page *)pmd_huge_pte(mm, pmdp);
+	if (!head)
+		INIT_LIST_HEAD(&new->lru);
 	else
-		list_add(&pgtable->lru, &pmd_huge_pte(mm, pmdp)->lru);
+		list_add(&new->lru, &head->lru);
 	pmd_huge_pte(mm, pmdp) = pgtable;
 }
 #endif
@@ -170,20 +174,23 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 /* no "address" argument so destroys page coloring of some arch */
 pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
-	pgtable_t pgtable;
+	struct page *page;
 
 	assert_spin_locked(pmd_lockptr(mm, pmdp));
 
+	page = (struct page *)pmd_huge_pte(mm, pmdp);
+
 	/* FIFO */
-	pgtable = pmd_huge_pte(mm, pmdp);
-	if (list_empty(&pgtable->lru))
+	if (list_empty(&page->lru))
 		pmd_huge_pte(mm, pmdp) = NULL;
 	else {
-		pmd_huge_pte(mm, pmdp) = list_entry(pgtable->lru.next,
-					      struct page, lru);
-		list_del(&pgtable->lru);
+		pmd_huge_pte(mm, pmdp) = (pgtable_t) list_entry(page->lru.next,
+							struct page, lru);
+		list_del(&page->lru);
 	}
-	return pgtable;
+
+	memset(&page->lru, 0, sizeof(page->lru));
+	return (pgtable_t)page;
 }
 #endif
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
