Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id AE6AE28034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:50 -0400 (EDT)
Received: by ietj16 with SMTP id j16so83168750iet.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 24si9922729iok.157.2015.07.17.11.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:50 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 09/15] HMM: add mm page table iterator helpers.
Date: Fri, 17 Jul 2015 14:52:19 -0400
Message-Id: <1437159145-6548-10-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Because inside the mmu_notifier callback we do not have access to the
vma nor do we know which lock we are holding (the mmap semaphore or
the i_mmap_lock) we can not rely on the regular page table walk (nor
do we want as we have to be carefull to not split huge page).

So this patch introduce an helper to iterate of the cpu page table
content in an efficient way for the situation we are in. Which is we
know that none of the page table entry might vanish from below us
and thus it is safe to walk the page table.

The only added value of the iterator is that it keeps the page table
entry level map accross call which fit well with the HMM mirror page
table update code.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index a9e3dc5..826080b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -403,6 +403,101 @@ static struct mmu_notifier_ops hmm_notifier_ops = {
 };
 
 
+struct mm_pt_iter {
+	struct mm_struct	*mm;
+	pte_t			*ptep;
+	unsigned long		addr;
+};
+
+static void mm_pt_iter_init(struct mm_pt_iter *pt_iter, struct mm_struct *mm)
+{
+	pt_iter->mm = mm;
+	pt_iter->ptep = NULL;
+	pt_iter->addr = -1UL;
+}
+
+static void mm_pt_iter_fini(struct mm_pt_iter *pt_iter)
+{
+	pte_unmap(pt_iter->ptep);
+	pt_iter->ptep = NULL;
+	pt_iter->addr = -1UL;
+	pt_iter->mm = NULL;
+}
+
+static inline bool mm_pt_iter_in_range(struct mm_pt_iter *pt_iter,
+				       unsigned long addr)
+{
+	return (addr >= pt_iter->addr && addr < (pt_iter->addr + PMD_SIZE));
+}
+
+static struct page *mm_pt_iter_page(struct mm_pt_iter *pt_iter,
+				    unsigned long addr)
+{
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+
+again:
+	/*
+	 * What we are doing here is only valid if we old either the mmap
+	 * semaphore or the i_mmap_lock of vma->address_space the address
+	 * belongs to. Sadly because we can not easily get the vma struct
+	 * we can not sanity test that either of those lock is taken.
+	 *
+	 * We have to rely on people using this code knowing what they do.
+	 */
+	if (mm_pt_iter_in_range(pt_iter, addr) && likely(pt_iter->ptep)) {
+		pte_t pte = *(pt_iter->ptep + pte_index(addr));
+		unsigned long pfn;
+
+		if (pte_none(pte) || !pte_present(pte))
+			return NULL;
+		if (unlikely(pte_special(pte)))
+			return NULL;
+
+		pfn = pte_pfn(pte);
+		if (is_zero_pfn(pfn))
+			return NULL;
+		return pfn_to_page(pfn);
+	}
+
+	if (pt_iter->ptep) {
+		pte_unmap(pt_iter->ptep);
+		pt_iter->ptep = NULL;
+		pt_iter->addr = -1UL;
+	}
+
+	pgdp = pgd_offset(pt_iter->mm, addr);
+	if (pgd_none_or_clear_bad(pgdp))
+		return NULL;
+	pudp = pud_offset(pgdp, addr);
+	if (pud_none_or_clear_bad(pudp))
+		return NULL;
+	pmdp = pmd_offset(pudp, addr);
+	/*
+	 * Because we either have the mmap semaphore or the i_mmap_lock we know
+	 * that pmd can not vanish from under us, thus if pmd exist then it is
+	 * either a huge page or a valid pmd. It might also be in the splitting
+	 * transitory state.
+	 */
+	if (pmd_none(*pmdp) || unlikely(pmd_bad(*pmdp)))
+		return NULL;
+	if (pmd_trans_splitting(*pmdp))
+		/*
+		 * FIXME idealy we would wait but we have no easy mean to get a
+		 * hold of the vma. So for now busy loop until the splitting is
+		 * done.
+		 */
+		goto again;
+	if (pmd_huge(*pmdp))
+		return pmd_page(*pmdp) + pte_index(addr);
+	/* Regular pmd and it can not morph. */
+	pt_iter->ptep = pte_offset_map(pmdp, addr & PMD_MASK);
+	pt_iter->addr = addr & PMD_MASK;
+	goto again;
+}
+
+
 /* hmm_mirror - per device mirroring functions.
  *
  * Each device that mirror a process has a uniq hmm_mirror struct. A process
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
