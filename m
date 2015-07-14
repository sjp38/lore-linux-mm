Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 08885280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:54:31 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so12384933pdj.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:54:30 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ek5si3838859pdb.242.2015.07.14.14.54.28
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 14:54:30 -0700 (PDT)
Date: Wed, 15 Jul 2015 07:54:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
Message-ID: <20150714215413.GP3902@dastard>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
 <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
 <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com>
 <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
 <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
 <20150714211918.GC7915@redhat.com>
 <alpine.DEB.2.10.1507141420350.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507141420350.16182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Edward Thornber <thornber@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Alasdair G. Kergon" <agk@redhat.com>

On Tue, Jul 14, 2015 at 02:24:24PM -0700, David Rientjes wrote:
> On Tue, 14 Jul 2015, Mike Snitzer wrote:
> 
> > > > > > Index: linux-4.2-rc1/mm/util.c
> > > > > > ===================================================================
> > > > > > --- linux-4.2-rc1.orig/mm/util.c	2015-07-07 15:58:11.000000000 +0200
> > > > > > +++ linux-4.2-rc1/mm/util.c	2015-07-08 19:22:26.000000000 +0200
> > > > > > @@ -316,6 +316,61 @@ unsigned long vm_mmap(struct file *file,
> > > > > >  }
> > > > > >  EXPORT_SYMBOL(vm_mmap);
> > > > > >  
> > > > > > +void *kvmalloc_node(size_t size, gfp_t gfp, int node)
> > > > > > +{
> > > > > > +	void *p;
> > > > > > +	unsigned uninitialized_var(noio_flag);
> > > > > > +
> > > > > > +	/* vmalloc doesn't support no-wait allocations */
> > > > > > +	WARN_ON_ONCE(!(gfp & __GFP_WAIT));
> > > > > > +
> > > > > > +	if (likely(size <= KMALLOC_MAX_SIZE)) {
> > > > > > +		/*
> > > > > > +		 * Use __GFP_NORETRY so that we don't loop waiting for the
> > > > > > +		 *	allocation - we don't have to loop here, if the memory
> > > > > > +		 *	is too fragmented, we fallback to vmalloc.
> > > > > 
> > > > > I'm not sure about this decision.  The direct reclaim retry code is the
> > > > > normal default behaviour and becomes more important with larger allocation
> > > > > attempts.  So why turn it off, and make it more likely that we return
> > > > > vmalloc memory?
> > > > 
> > > > It can avoid triggering the OOM killer in case of fragmented memory.
> > > > 
> > > > This is general question - if the code can handle allocation failure 
> > > > gracefully, what gfp flags should it use? Maybe add some flag 
> > > > __GFP_MAYFAIL instead of __GFP_NORETRY that changes the behavior in 
> > > > desired way?
> > > > 
> > > 
> > > There's a misunderstanding in regards to the comment: __GFP_NORETRY 
> > > doesn't turn direct reclaim or compaction off, it is still attempted and 
> > > with the same priority as any other allocation.  This only stops the page 
> > > allocator from calling the oom killer, which will free memory or panic the 
> > > system, and looping when memory is available.
> > > 
> > > In regards to the proposal in general, I think it's unnecessary because we 
> > > are still left behind with other users who open code their call to 
> > > vmalloc.  I was interested in commit 058504edd026 ("fs/seq_file: fallback 
> > > to vmalloc allocation") since it solved an issue with high memory 
> > > fragmentation.  Note how it falls back to vmalloc(): _without_ this 
> > > __GFP_NORETRY.  That's because we only want to fallback when high-order 
> > > allocations fail and the page allocator doesn't implicitly loop due to the 
> > > order.  ext4_kvmalloc(), ext4_kzmalloc() does the same.
> > > 
> > > The differences in implementations between those that do kmalloc() and 
> > > fallback to vmalloc() are different enough that I don't think we need this 
> > > addition.
> > 
> > Wouldn't mm benefit from acknowledging the pattern people are
> > open-coding and switching existing code over to official methods for
> > accomplishing the same?
> > 
> 
> Sure, but it's not accomplishing the same thing: things like 
> ext4_kvmalloc() only want to fallback to vmalloc() when high-order 
> allocations fail: the function is used for different sizes.  This cannot 
> be converted to kvmalloc_node() since it fallsback immediately when 
> reclaim fails.  Same issue with single_file_open() for the seq_file code.  
> We could go through every kmalloc() -> vmalloc() fallback for more 
> examples in the code, but those two instances were the first I looked at 
> and couldn't be converted to kvmalloc_node() without work.
> 
> > It is always easier to shoehorn utility functions locally within a
> > subsystem (be it ext4, dm, etc) but once enough do something in a
> > similar but different way it really should get elevated.
> > 
> 
> I would argue that
> 
> void *ext4_kvmalloc(size_t size, gfp_t flags)
> {
> 	void *ret;
> 
> 	ret = kmalloc(size, flags | __GFP_NOWARN);
> 	if (!ret)
> 		ret = __vmalloc(size, flags, PAGE_KERNEL);
> 	return ret;
> }
> 
> is simple enough that we don't need to convert it to anything.

Except that it will have problems with GFP_NOFS context when the pte
code inside vmalloc does a GFP_KERNEL allocation. Hence we have
stuff in other subsystems (such as XFS) where we've noticed lockdep
whining about this:

void *
kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
{
        unsigned noio_flag = 0;
        void    *ptr;
        gfp_t   lflags;

        ptr = kmem_zalloc(size, flags | KM_MAYFAIL);
        if (ptr)
                return ptr;

        /*
         * __vmalloc() will allocate data pages and auxillary structures (e.g.
         * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
         * here. Hence we need to tell memory reclaim that we are in such a
         * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
         * the filesystem here and potentially deadlocking.
         */
        if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
                noio_flag = memalloc_noio_save();

        lflags = kmem_flags_convert(flags);
        ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);

        if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
                memalloc_noio_restore(noio_flag);

        return ptr;
}

This allocation context issue needs to be fixed before making
generic kvmalloc() functions available for general use....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
