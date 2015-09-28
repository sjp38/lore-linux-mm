Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0E76B0254
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 07:49:36 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so100169452wic.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 04:49:36 -0700 (PDT)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id q18si21369627wik.96.2015.09.28.04.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Sep 2015 04:49:35 -0700 (PDT)
Received: from /spool/local
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 28 Sep 2015 12:49:34 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D5CCC219005E
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:49:00 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8SBnUTO36831456
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:49:30 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8SBnT7r026855
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:49:30 -0600
Date: Mon, 28 Sep 2015 13:49:28 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC] futex: prevent endless loop on s390x with emulated
 hugepages
Message-ID: <20150928134928.2214dae2@mschwide>
In-Reply-To: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
References: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yong Sun <yosun@suse.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Zhang Yi <wetpzy@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On Thu, 24 Sep 2015 17:05:48 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> Yong Sun has reported the LTP futex_wake04 test to hang a s390x with our
> kernel based on 3.12. This is reproducible on upstream 4.1.8 as well. 4.2+
> is OK thanks to removal of emulated hugepages, but we should do something
> about the stable kernels here.
> 
> The LTP test is a regression test for commit 13d60f4b6a ("futex: Take
> hugepages into account when generating futex_key"), but it turns out that it's
> sufficient to just attempt to wait for a single futex on a tail page of a
> hugetlbfs page:

The software emulated large pages always have been a bit fragile.
 
> The problem is an endless loop in get_futex_key() when
> CONFIG_TRANSPARENT_HUGEPAGE is enabled and the s390x machine has emulated
> hugepages. The code tries to serialize against __split_huge_page_splitting(),
> but __get_user_pages_fast() fails on the hugetlbfs tail page. This happens
> because pmd_large() is false for emulated hugepages, so the code will proceed
> into gup_pte_range() and fail page_cache_get_speculative() through failing
> get_page_unless_zero() as the tail page count is zero. Failing __gup_fast is
> supposed to be temporary due to a race, so get_futex_key() will try again
> endlessly.
> 
> This attempt for a fix is a bandaid solution and probably incomplete.
> Hopefully something better will emerge from the discussion. Fully fixing
> emulated hugepages just for stable backports is unlikely due to them being
> removed. Also THP refcounting redesign should soon remove the trickery from
> get_futex_key().
> 
> This patch relies on the fact that s390x with emulated hugepages returns false
> in has_transparent_hugepage(), so we don't need to do the serialization
> trickery and just use the code for !CONFIG_TRANSPARENT_HUGEPAGE. We just need
> an extra variable to cache the result of has_transparent_hugepage(), which is
> __init and potentially expensive on some architectures.
> 
> However, __get_user_pages_fast() is still broken. The get_user_pages_fast()
> wrapper will hide this in the common case. The other user of the __ variant
> is kvm, which is mentioned as the reason for removal of emulated hugepages.
> The call of page_cache_get_speculative() looks also broken in this scenario
> on debug builds because of VM_BUG_ON_PAGE(PageTail(page), page). With
> CONFIG_TINY_RCU enabled, there's plain atomic_inc(&page->_count) which also
> probably shouldn't happen for a tail page...

It boils down to __get_user_pages_fast being broken for emulated large pages,
doesn't it? My preferred fix would be to get __get_user_page_fast to work
in this case. For 3.12 a patch would look like this (needs more testing
though):
--
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index bb0c157..5948b7f 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -370,7 +370,7 @@ static inline int is_module_addr(void *addr)
 #define _SEGMENT_ENTRY_EMPTY	(_SEGMENT_ENTRY_INVALID)
 
 #define _SEGMENT_ENTRY_LARGE	0x400	/* STE-format control, large page   */
-#define _SEGMENT_ENTRY_CO	0x100	/* change-recording override   */
+#define _SEGMENT_ENTRY_SWLARGE	0x100	/* SW large page bit */
 #define _SEGMENT_ENTRY_SPLIT	0x001	/* THP splitting bit */
 #define _SEGMENT_ENTRY_YOUNG	0x002	/* SW segment young bit */
 #define _SEGMENT_ENTRY_NONE	_SEGMENT_ENTRY_YOUNG
@@ -391,8 +391,8 @@ static inline int is_module_addr(void *addr)
 #define _SEGMENT_ENTRY_SPLIT_BIT 0	/* THP splitting bit number */
 
 /* Set of bits not changed in pmd_modify */
-#define _SEGMENT_CHG_MASK	(_SEGMENT_ENTRY_ORIGIN | _SEGMENT_ENTRY_LARGE \
-				 | _SEGMENT_ENTRY_SPLIT | _SEGMENT_ENTRY_CO)
+#define _SEGMENT_CHG_MASK (_SEGMENT_ENTRY_ORIGIN | _SEGMENT_ENTRY_LARGE \
+			   | _SEGMENT_ENTRY_SPLIT | _SEGMENT_ENTRY_SWLARGE)
 
 /* Page status table bits for virtualization */
 #define PGSTE_ACC_BITS	0xf000000000000000UL
@@ -563,12 +563,25 @@ static inline int pmd_none(pmd_t pmd)
 static inline int pmd_large(pmd_t pmd)
 {
 #ifdef CONFIG_64BIT
-	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
+	return (pmd_val(pmd) &
+		(_SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_SWLARGE)) != 0;
 #else
 	return 0;
 #endif
 }
 
+static inline pmd_t pmd_swlarge_deref(pmd_t pmd)
+{
+	unsigned long origin;
+
+	if (pmd_val(pmd) & _SEGMENT_ENTRY_SWLARGE) {
+		origin = pmd_val(pmd) & _SEGMENT_ENTRY_ORIGIN;
+		pmd_val(pmd) &= ~_SEGMENT_ENTRY_ORIGIN;
+		pmd_val(pmd) |= *(unsigned long *) origin;
+	}
+	return pmd;
+}
+
 static inline int pmd_prot_none(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_INVALID) &&
@@ -578,8 +591,10 @@ static inline int pmd_prot_none(pmd_t pmd)
 static inline int pmd_bad(pmd_t pmd)
 {
 #ifdef CONFIG_64BIT
-	if (pmd_large(pmd))
+	if (pmd_large(pmd)) {
+		pmd = pmd_swlarge_deref(pmd);
 		return (pmd_val(pmd) & ~_SEGMENT_ENTRY_BITS_LARGE) != 0;
+	}
 #endif
 	return (pmd_val(pmd) & ~_SEGMENT_ENTRY_BITS) != 0;
 }
@@ -1495,8 +1510,6 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 			      pmd_t *pmdp, pmd_t entry)
 {
-	if (!(pmd_val(entry) & _SEGMENT_ENTRY_INVALID) && MACHINE_HAS_EDAT1)
-		pmd_val(entry) |= _SEGMENT_ENTRY_CO;
 	*pmdp = entry;
 }
 
diff --git a/arch/s390/mm/dump_pagetables.c b/arch/s390/mm/dump_pagetables.c
index 46d517c..e159735 100644
--- a/arch/s390/mm/dump_pagetables.c
+++ b/arch/s390/mm/dump_pagetables.c
@@ -129,7 +129,7 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st,
 }
 
 #ifdef CONFIG_64BIT
-#define _PMD_PROT_MASK (_SEGMENT_ENTRY_PROTECT | _SEGMENT_ENTRY_CO)
+#define _PMD_PROT_MASK (_SEGMENT_ENTRY_PROTECT)
 #else
 #define _PMD_PROT_MASK 0
 #endif
@@ -138,7 +138,7 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st,
 			   pud_t *pud, unsigned long addr)
 {
 	unsigned int prot;
-	pmd_t *pmd;
+	pmd_t *pmd, pmd_val;
 	int i;
 
 	for (i = 0; i < PTRS_PER_PMD && addr < max_addr; i++) {
@@ -146,7 +146,8 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st,
 		pmd = pmd_offset(pud, addr);
 		if (!pmd_none(*pmd)) {
 			if (pmd_large(*pmd)) {
-				prot = pmd_val(*pmd) & _PMD_PROT_MASK;
+				pmd_val = pmd_swlarge_deref(*pmd);
+				prot = pmd_val(pmd_val) & _PMD_PROT_MASK;
 				note_page(m, st, prot, 3);
 			} else
 				walk_pte_level(m, st, pmd, addr);
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 5d758db..8dd86a5 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -48,8 +48,9 @@ static inline int gup_pte_range(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	return 1;
 }
 
-static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd_orig, pmd_t pmd,
+		unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
 {
 	unsigned long mask, result;
 	struct page *head, *page, *tail;
@@ -78,7 +79,7 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		return 0;
 	}
 
-	if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
+	if (unlikely(pmd_val(pmd_orig) != pmd_val(*pmdp))) {
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
@@ -103,7 +104,7 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long next;
-	pmd_t *pmdp, pmd;
+	pmd_t *pmdp, pmd, pmd_orig;
 
 	pmdp = (pmd_t *) pudp;
 #ifdef CONFIG_64BIT
@@ -112,7 +113,7 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
 	pmdp += pmd_index(addr);
 #endif
 	do {
-		pmd = *pmdp;
+		pmd = pmd_orig = *pmdp;
 		barrier();
 		next = pmd_addr_end(addr, end);
 		/*
@@ -127,8 +128,9 @@ static inline int gup_pmd_range(pud_t *pudp, pud_t pud, unsigned long addr,
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
-			if (!gup_huge_pmd(pmdp, pmd, addr, next,
-					  write, pages, nr))
+			if (!gup_huge_pmd(pmdp, pmd_orig,
+					  pmd_swlarge_deref(pmd),
+					  addr, next, write, pages, nr))
 				return 0;
 		} else if (!gup_pte_range(pmdp, pmd, addr, next,
 					  write, pages, nr))
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 99a68d5..d4a17d9 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -98,22 +98,18 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	if (!MACHINE_HAS_HPAGE) {
 		pmd_val(pmd) &= ~_SEGMENT_ENTRY_ORIGIN;
 		pmd_val(pmd) |= pte_page(pte)[1].index;
+		pmd_val(pmd) |= _SEGMENT_ENTRY_SWLARGE;
 	} else
-		pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_CO;
+		pmd_val(pmd) |= _SEGMENT_ENTRY_LARGE;
 	*(pmd_t *) ptep = pmd;
 }
 
 pte_t huge_ptep_get(pte_t *ptep)
 {
-	unsigned long origin;
 	pmd_t pmd;
 
 	pmd = *(pmd_t *) ptep;
-	if (!MACHINE_HAS_HPAGE && pmd_present(pmd)) {
-		origin = pmd_val(pmd) & _SEGMENT_ENTRY_ORIGIN;
-		pmd_val(pmd) &= ~_SEGMENT_ENTRY_ORIGIN;
-		pmd_val(pmd) |= *(unsigned long *) origin;
-	}
+	pmd = pmd_swlarge_deref(pmd);
 	return __pmd_to_pte(pmd);
 }
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index bcfb70b..a4f6f2f 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -235,8 +235,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 				if (!new_page)
 					goto out;
 				pmd_val(*pm_dir) = __pa(new_page) |
-					_SEGMENT_ENTRY | _SEGMENT_ENTRY_LARGE |
-					_SEGMENT_ENTRY_CO;
+					_SEGMENT_ENTRY | _SEGMENT_ENTRY_LARGE;
 				address = (address + PMD_SIZE) & PMD_MASK;
 				continue;
 			}

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
