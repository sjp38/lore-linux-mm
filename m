Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 771366B0123
	for <linux-mm@kvack.org>; Wed, 20 May 2015 10:38:59 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so55262864wgb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 07:38:58 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id vf7si29673781wjc.127.2015.05.20.07.38.57
        for <linux-mm@kvack.org>;
        Wed, 20 May 2015 07:38:57 -0700 (PDT)
Date: Wed, 20 May 2015 17:38:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 22/28] thp: implement split_huge_pmd()
Message-ID: <20150520143843.GB13921@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-23-git-send-email-kirill.shutemov@linux.intel.com>
 <555AF37A.2060709@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555AF37A.2060709@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 19, 2015 at 10:25:30AM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >Original split_huge_page() combined two operations: splitting PMDs into
> >tables of PTEs and splitting underlying compound page. This patch
> >implements split_huge_pmd() which split given PMD without splitting
> >other PMDs this page mapped with or underlying compound page.
> >
> >Without tail page refcounting, implementation of split_huge_pmd() is
> >pretty straight-forward.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> >---
> >  include/linux/huge_mm.h |  11 ++++-
> >  mm/huge_memory.c        | 108 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 118 insertions(+), 1 deletion(-)
> >
> >diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> >index 0382230b490f..b7844c73b7db 100644
> >--- a/include/linux/huge_mm.h
> >+++ b/include/linux/huge_mm.h
> >@@ -94,7 +94,16 @@ extern unsigned long transparent_hugepage_flags;
> >
> >  #define split_huge_page_to_list(page, list) BUILD_BUG()
> >  #define split_huge_page(page) BUILD_BUG()
> >-#define split_huge_pmd(__vma, __pmd, __address) BUILD_BUG()
> >+
> >+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >+		unsigned long address);
> >+
> >+#define split_huge_pmd(__vma, __pmd, __address)				\
> >+	do {								\
> >+		pmd_t *____pmd = (__pmd);				\
> >+		if (unlikely(pmd_trans_huge(*____pmd)))			\
> 
> Given that most of calls to split_huge_pmd() appear to be in
> if (pmd_trans_huge(...)) branches, this unlikely() seems counter-productive.

Fair enough.

> >+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >+		unsigned long address)
> >+{
> >+	spinlock_t *ptl;
> >+	struct mm_struct *mm = vma->vm_mm;
> >+	unsigned long haddr = address & HPAGE_PMD_MASK;
> >+
> >+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
> >+	ptl = pmd_lock(mm, pmd);
> >+	if (likely(pmd_trans_huge(*pmd)))
> 
> This likely is likely useless :)
 
No, it's not. We check the pmd with pmd_trans_huge() under ptl for the
first time. And __split_huge_pmd_locked() assumes pmd is huge.

> >+		__split_huge_pmd_locked(vma, pmd, haddr);
> >+	spin_unlock(ptl);
> >+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
> >+}
> >+
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
