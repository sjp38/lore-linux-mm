Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id C95526B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:27:02 -0400 (EDT)
Received: by lbdc10 with SMTP id c10so43715416lbd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:27:02 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id dx5si18640032wib.57.2015.03.30.08.27.00
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 08:27:01 -0700 (PDT)
Date: Mon, 30 Mar 2015 18:26:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page
 counts on split
Message-ID: <20150330152652.GC5849@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
 <87h9t2le07.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h9t2le07.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 30, 2015 at 08:38:08PM +0530, Aneesh Kumar K.V wrote:
> ....
> ....
>  +static void freeze_page(struct anon_vma *anon_vma, struct page *page)
> > +{
> > +	struct anon_vma_chain *avc;
> > +	struct vm_area_struct *vma;
> > +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> 
> So this get called only with head page, We also do
> BUG_ON(PageTail(page)) in the caller.  But
> 
> 
> > +	unsigned long addr, haddr;
> > +	unsigned long mmun_start, mmun_end;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pte_t *start_pte, *pte;
> > +	spinlock_t *ptl;
> ......
> 
> 
> > +
> > +static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
> > +{
> > +	struct anon_vma_chain *avc;
> > +	pgoff_t pgoff = page_to_pgoff(page);
> 
> Why ? Can this get called for tail pages ?

It cannot. pgoff is offset of head page (and therefore whole compound
page) within rmapping.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
