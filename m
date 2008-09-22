Date: Mon, 22 Sep 2008 17:17:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080922161705.GA7716@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie> <1222047492-27622-2-git-send-email-mel@csn.ul.ie> <20080922013053.39fd367a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080922013053.39fd367a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (22/09/08 01:30), Andrew Morton didst pronounce:
> On Mon, 22 Sep 2008 02:38:11 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +		   vma_page_size(vma) >> 10);
> >  
> >  	return ret;
> >  }
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 32e0ef0..0c83445 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -231,6 +231,19 @@ static inline unsigned long huge_page_size(struct hstate *h)
> >  	return (unsigned long)PAGE_SIZE << h->order;
> >  }
> >  
> > +static inline unsigned long vma_page_size(struct vm_area_struct *vma)
> > +{
> > +	struct hstate *hstate;
> > +
> > +	if (!is_vm_hugetlb_page(vma))
> > +		return PAGE_SIZE;
> > +
> > +	hstate = hstate_vma(vma);
> > +	VM_BUG_ON(!hstate);
> > +
> > +	return 1UL << (hstate->order + PAGE_SHIFT);
> > +}
> > +
> 
> CONFIG_HUGETLB_PAGE=n?
> 

Fails miserably.

> What did you hope to gain by inlining this?
> 

Inclusion with similar helper functions in the header but it's the wrong thing
to do in this case, obvious when pointed out. It's too large and called from
multiple places. I'll revise the patch

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
