Date: Mon, 23 Jun 2008 10:53:10 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 2/2] hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma splits
Message-ID: <20080623095310.GH29804@shadowen.org>
References: <1213989474-5586-1-git-send-email-apw@shadowen.org> <1213989474-5586-3-git-send-email-apw@shadowen.org> <20080623080048.GJ21597@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080623080048.GJ21597@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 23, 2008 at 09:00:48AM +0100, Mel Gorman wrote:
> Typical. I spotted this after I pushed send.....
> 
> > <SNIP>
> 
> > @@ -266,14 +326,19 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
> >  		 * private mappings.
> >  		 */
> >  		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> > -			unsigned long flags, reserve;
> > +			unsigned long idx = vma_pagecache_offset(h,
> > +							vma, address);
> > +			struct resv_map *reservations = vma_resv_map(vma);
> > +
> >  			h->resv_huge_pages--;
> > -			flags = (unsigned long)vma->vm_private_data &
> > -							HPAGE_RESV_MASK;
> > -			reserve = (unsigned long)vma->vm_private_data - 1;
> > -			vma->vm_private_data = (void *)(reserve | flags);
> > +
> > +			/* Mark this page used in the map. */
> > +			if (region_chg(&reservations->regions, idx, idx + 1) < 0)
> > +				return -1;
> > +			region_add(&reservations->regions, idx, idx + 1);
> >  		}
> 
> decrement_hugepage_resv_vma() is called with hugetlb_lock held and region_chg
> calls kmalloc(GFP_KERNEL).  Hence it's possible we would sleep with that
> spinlock held which is a bit uncool. The allocation needs to happen outside
> the lock. Right?

Yes, good spot.  Luckily this pair of calls can be separated, as the
first is a prepare and the second a commit.  So I can trivially pull
the allocation outside the lock.

Had a quick go at this and it looks like I can move both out of the lock
to a much more logical spot and clean the patch up significantly.  Will
fold in your other comments and post up a V2 once it has been tested.

Thanks.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
