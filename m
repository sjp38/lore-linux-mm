Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4NKme2Z026900
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:48:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4NKmedg155434
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:48:40 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4NKmdbP018856
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:48:39 -0400
Date: Fri, 23 May 2008 13:48:37 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 04/18] hugetlb: modular state
Message-ID: <20080523204837.GG23924@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.054070000@nick.local0.net> <20080425171346.GB9680@us.ibm.com> <20080523050246.GB13071@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523050246.GB13071@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.05.2008 [07:02:47 +0200], Nick Piggin wrote:
> On Fri, Apr 25, 2008 at 10:13:46AM -0700, Nishanth Aravamudan wrote:
> > On 23.04.2008 [11:53:06 +1000], npiggin@suse.de wrote:
> > > Large, but rather mechanical patch that converts most of the hugetlb.c
> > > globals into structure members and passes them around.
> > > 
> > > Right now there is only a single global hstate structure, but most of
> > > the infrastructure to extend it is there.
> > 
> > While going through the patches as I apply them to 2.6.25-mm1 (as none
> > will apply cleanly so far :), I have a few comments. I like this patch
> > overall.
> 
> Thanks for all the feedback, and sorry for the delay. I'm just
> rebasing things now and getting through all the feedback.
> 
> I really do appreciate the comments and have made a lot of changes
> that you've suggested...

Great, I'm looking forward to the new series and seeing it get some
wider testing in -mm. I'll throw Acks in, when they are posted.

Let me also reiterate that your and Andi's work really does make a world
of difference for the larger hugetlb userbase. The hstate idea and
implementation really do make hugepages a lot more flexible then we were
before, and I really applaud you both for the code.

<snip>

> > >  /*
> > >   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> > >   */
> > >  static DEFINE_SPINLOCK(hugetlb_lock);
> > 
> > Not sure if this makes sense or not, but would it be useful to make the
> > lock be per-hstate? It is designed to protect the counters and the
> > freelists, but those are per-hstate, right? Would need heavy testing,
> > but might be useful for varying apps both trying to use different size
> > hugepages simultaneously?
> 
> Hmm, sure we could do that. Although obviously it would be another
> patchset, and actually I'd be concerned about making hstate the
> unit of scalability in hugetlbfs -- a single hstate should be
> suffiicently scalable to handle workloads reasonably.
> 
> Good point, but at any rate I guess this patchset isn't the place
> to do it.

Agreed.

<snip>

> > >  int hugetlb_report_meminfo(char *buf)
> > >  {
> > > +	struct hstate *h = &global_hstate;
> > >  	return sprintf(buf,
> > >  			"HugePages_Total: %5lu\n"
> > >  			"HugePages_Free:  %5lu\n"
> > >  			"HugePages_Rsvd:  %5lu\n"
> > >  			"HugePages_Surp:  %5lu\n"
> > >  			"Hugepagesize:    %5lu kB\n",
> > > -			nr_huge_pages,
> > > -			free_huge_pages,
> > > -			resv_huge_pages,
> > > -			surplus_huge_pages,
> > > -			HPAGE_SIZE/1024);
> > > +			h->nr_huge_pages,
> > > +			h->free_huge_pages,
> > > +			h->resv_huge_pages,
> > > +			h->surplus_huge_pages,
> > > +			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> > 
> > "- 10"? I think this should be easier to get at then this? Oh I
> > guess it's to get it into kilobytes... Seems kind of odd, but I
> > guess it's fine.
> 
> I agree it's not perfect, but I might just leave all these for
> a subsequent patchset (or can stick improvements to the end of
> this patchset).

I can submit a sequence of cleanup patches myself, as well, they
shouldn't block your posting.

> > >  static inline int is_file_hugepages(struct file *file)
> > >  {
> > >  	if (file->f_op == &hugetlbfs_file_operations)
> > > @@ -199,4 +196,71 @@ unsigned long hugetlb_get_unmapped_area(
> > >  					unsigned long flags);
> > >  #endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
> > > 
> > > +#ifdef CONFIG_HUGETLB_PAGE
> > 
> > Why another block of HUGETLB_PAGE? Shouldn't this go at the end of the
> > other one? And the !HUGETLB_PAGE within the corresponding #else?
> 
> Hmm, possibly. As has been noted, the CONFIG_ things are a bit
> broken, and they should just get merged into one. I'll steer
> clear of that area for the moment, as everything is working now,
> but consolidating the options and cleaning things up would be
> a good idea.

Yep, I'll add this as a tail-cleanup. Perhaps part of the overarching
one of just getting rid of CONFIG_HUGETLBFS or CONFIG_HUGETLB_PAGE (have
one config option, not two, since they are mutually dependent).

> > > +
> > > +/* Defines one hugetlb page size */
> > > +struct hstate {
> > > +	int hugetlb_next_nid;
> > > +	unsigned int order;
> > 
> > Which is actually a shift, too, right? So why not just call it that? No
> > function should be direclty accessing these members, so the function
> > name indicates how the shift is being used?
> 
> I don't feel strongly. If you really do, then I guess it could be
> changed.
> 
> 
> > > +	unsigned long mask;
> > > +	unsigned long max_huge_pages;
> > > +	unsigned long nr_huge_pages;
> > > +	unsigned long free_huge_pages;
> > > +	unsigned long resv_huge_pages;
> > > +	unsigned long surplus_huge_pages;
> > > +	unsigned long nr_overcommit_huge_pages;
> > > +	struct list_head hugepage_freelists[MAX_NUMNODES];
> > > +	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> > > +	unsigned int free_huge_pages_node[MAX_NUMNODES];
> > > +	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> > > +};
> > > +
> > > +extern struct hstate global_hstate;
> > > +
> > > +static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> > > +{
> > > +	return &global_hstate;
> > > +}
> > 
> > After having looked at this functions while reviewing, it does seem like
> > it might be more intuitive to ready vma_hstate ("vma's hstate") rather
> > than hstate_vma ("hstate's vma"?). But your call.
> 
> Again I don't feel strongly. Hstate prefix has some upsides.

I think you can leave both as is.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
