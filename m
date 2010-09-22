Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6336B004A
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 04:37:47 -0400 (EDT)
Date: Wed, 22 Sep 2010 09:37:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/10] hugetlb: add allocate function for hugepage
	migration
Message-ID: <20100922083731.GB1382@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20100920105916.GH1998@csn.ul.ie> <20100922044151.GB2538@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100922044151.GB2538@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 22, 2010 at 01:41:51PM +0900, Naoya Horiguchi wrote:
> Hi,
> 
> Thank you for your review.
> 
> On Mon, Sep 20, 2010 at 11:59:16AM +0100, Mel Gorman wrote:
> > On Wed, Sep 08, 2010 at 10:19:33AM +0900, Naoya Horiguchi wrote:
> ...
> > > @@ -770,11 +776,10 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> > >  	return ret;
> > >  }
> > >  
> > > -static struct page *alloc_buddy_huge_page(struct hstate *h,
> > > -			struct vm_area_struct *vma, unsigned long address)
> > > +static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
> > >  {
> > >  	struct page *page;
> > > -	unsigned int nid;
> > > +	unsigned int r_nid;
> > >  
> > 
> > Why the rename, just to avoid changing the value of a function parameter?
> 
> I think it's better that a simple name is given to function parameter
> than to internal variable, because the former is paid more attention
> from other developers than the latter is.
> 

Ok.

> > >  	if (h->order >= MAX_ORDER)
> > >  		return NULL;
> > > @@ -812,9 +817,14 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
> > >  	}
> > >  	spin_unlock(&hugetlb_lock);
> > >  
> > > -	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
> > > -					__GFP_REPEAT|__GFP_NOWARN,
> > > -					huge_page_order(h));
> > > +	if (nid == NUMA_NO_NODE)
> > > +		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
> > > +				   __GFP_REPEAT|__GFP_NOWARN,
> > > +				   huge_page_order(h));
> > > +	else
> > > +		page = alloc_pages_exact_node(nid,
> > > +			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
> > > +			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
> > >  
> > 
> > Why not just call alloc_pages_node()?
> 
> Ah, we can bring together these two allocate functions.
> I'll do it.
> 
> Here is a revised patch.
> 
> Thanks,
> Naoya Horiguchi
> ---
> Date: Wed, 22 Sep 2010 13:18:54 +0900
> Subject: [PATCH 02/10] hugetlb: add allocate function for hugepage migration
> 
> We can't use existing hugepage allocation functions to allocate hugepage
> for page migration, because page migration can happen asynchronously with
> the running processes and page migration users should call the allocation
> function with physical addresses (not virtual addresses) as arguments.
> 
> ChangeLog since v3:
> - unify alloc_buddy_huge_page() and alloc_buddy_huge_page_node()
> - bring together branched allocate functions
> 
> ChangeLog since v2:
> - remove unnecessary get/put_mems_allowed() (thanks to David Rientjes)
> 
> ChangeLog since v1:
> - add comment on top of alloc_huge_page_no_vma()
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
