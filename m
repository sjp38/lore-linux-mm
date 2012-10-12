Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0E6916B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 00:12:13 -0400 (EDT)
Date: Fri, 12 Oct 2012 07:13:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 07/10] thp: implement splitting pmd for huge zero page
Message-ID: <20121012041305.GA16854@shutemov.name>
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1349191172-28855-8-git-send-email-kirill.shutemov@linux.intel.com>
 <50778D39.1000102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50778D39.1000102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Fri, Oct 12, 2012 at 11:23:37AM +0800, Ni zhan Chen wrote:
> On 10/02/2012 11:19 PM, Kirill A. Shutemov wrote:
> >From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> >We can't split huge zero page itself, but we can split the pmd which
> >points to it.
> >
> >On splitting the pmd we create a table with all ptes set to normal zero
> >page.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> >---
> >  mm/huge_memory.c |   32 ++++++++++++++++++++++++++++++++
> >  1 files changed, 32 insertions(+), 0 deletions(-)
> >
> >diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >index 95032d3..3f1c59c 100644
> >--- a/mm/huge_memory.c
> >+++ b/mm/huge_memory.c
> >@@ -1600,6 +1600,7 @@ int split_huge_page(struct page *page)
> >  	struct anon_vma *anon_vma;
> >  	int ret = 1;
> >+	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
> >  	BUG_ON(!PageAnon(page));
> >  	anon_vma = page_lock_anon_vma(page);
> >  	if (!anon_vma)
> >@@ -2503,6 +2504,32 @@ static int khugepaged(void *none)
> >  	return 0;
> >  }
> >+static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> >+		unsigned long haddr, pmd_t *pmd)
> >+{
> >+	pgtable_t pgtable;
> >+	pmd_t _pmd;
> >+	int i;
> >+
> >+	pmdp_clear_flush_notify(vma, haddr, pmd);
> 
> why I can't find function pmdp_clear_flush_notify in kernel source
> code? Do you mean pmdp_clear_flush_young_notify or something like
> that?

It was changed recently. See commit
2ec74c3 mm: move all mmu notifier invocations to be done outside the PT lock

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
