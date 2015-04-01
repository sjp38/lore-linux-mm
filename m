Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC016B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 09:19:19 -0400 (EDT)
Received: by widdi4 with SMTP id di4so44600931wid.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 06:19:18 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id a2si3273465wjs.97.2015.04.01.06.19.17
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 06:19:17 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:19:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page
 counts on split
Message-ID: <20150401131907.GE17153@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
 <87h9t2le07.fsf@linux.vnet.ibm.com>
 <20150330152652.GC5849@node.dhcp.inet.fi>
 <87bnjalc9g.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bnjalc9g.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 30, 2015 at 09:15:47PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > On Mon, Mar 30, 2015 at 08:38:08PM +0530, Aneesh Kumar K.V wrote:
> >> ....
> >> ....
> >>  +static void freeze_page(struct anon_vma *anon_vma, struct page *page)
> >> > +{
> >> > +	struct anon_vma_chain *avc;
> >> > +	struct vm_area_struct *vma;
> >> > +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> >> 
> >> So this get called only with head page, We also do
> >> BUG_ON(PageTail(page)) in the caller.  But
> >> 
> >> 
> >> > +	unsigned long addr, haddr;
> >> > +	unsigned long mmun_start, mmun_end;
> >> > +	pgd_t *pgd;
> >> > +	pud_t *pud;
> >> > +	pmd_t *pmd;
> >> > +	pte_t *start_pte, *pte;
> >> > +	spinlock_t *ptl;
> >> ......
> >> 
> >> 
> >> > +
> >> > +static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
> >> > +{
> >> > +	struct anon_vma_chain *avc;
> >> > +	pgoff_t pgoff = page_to_pgoff(page);
> >> 
> >> Why ? Can this get called for tail pages ?
> >
> > It cannot. pgoff is offset of head page (and therefore whole compound
> > page) within rmapping.
> >
> 
> This we can use 
> 
> 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>         
> similar to what we do in freeze_page(). The difference between
> freeze/unfreeze confused me.

Fair enough. Will fix.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
