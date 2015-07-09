Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 13F276B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 10:45:34 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so187407505qkh.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:45:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w65si7025389qgw.115.2015.07.09.07.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 07:45:33 -0700 (PDT)
Date: Thu, 9 Jul 2015 10:45:30 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
In-Reply-To: <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
Message-ID: <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com> <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
 <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com> <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>



On Wed, 8 Jul 2015, Andrew Morton wrote:

> On Wed, 8 Jul 2015 19:03:08 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > 
> > 
> > On Tue, 7 Jul 2015, Andrew Morton wrote:
> > 
> > > On Tue, 7 Jul 2015 11:10:09 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > 
> > > > Introduce the functions kvmalloc and kvmalloc_node. These functions
> > > > provide reliable allocation of object of arbitrary size. They attempt to
> > > > do allocation with kmalloc and if it fails, use vmalloc. Memory allocated
> > > > with these functions should be freed with kvfree.
> > > 
> > > Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
> > > thing, and we don't want to make it easy for people to do bad things.
> > > 
> > > And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
> > > allocations for page tables and c) it is susceptible to arena
> > > fragmentation.
> > 
> > This patch makes less use of vmalloc.
> > 
> > The typical pattern is that someone notices random failures due to memory 
> > fragmentation in some subsystem that uses large kmalloc - so he replaces 
> > kmalloc with vmalloc - and the code gets slower because of that. With this 
> > patch, you can replace many vmalloc users with kvmalloc - and vmalloc will 
> > be used only very rarely, when the memory is too fragmented for kmalloc.
> 
> Yes, I guess there is that.
> 
> > Here I'm sending next version of the patch with comments added.
> 
> You didn't like kvzalloc()?  We can always add those later...
> 
> > --- linux-4.2-rc1.orig/include/linux/mm.h	2015-07-07 15:58:11.000000000 +0200
> > +++ linux-4.2-rc1/include/linux/mm.h	2015-07-08 19:22:24.000000000 +0200
> > @@ -400,6 +400,11 @@ static inline int is_vmalloc_or_module_a
> >  }
> >  #endif
> >  
> > +extern void *kvmalloc_node(size_t size, gfp_t gfp, int node);
> > +static inline void *kvmalloc(size_t size, gfp_t gfp)
> > +{
> > +	return kvmalloc_node(size, gfp, NUMA_NO_NODE);
> > +}
> >  extern void kvfree(const void *addr);
> >  
> >  static inline void compound_lock(struct page *page)
> > Index: linux-4.2-rc1/mm/util.c
> > ===================================================================
> > --- linux-4.2-rc1.orig/mm/util.c	2015-07-07 15:58:11.000000000 +0200
> > +++ linux-4.2-rc1/mm/util.c	2015-07-08 19:22:26.000000000 +0200
> > @@ -316,6 +316,61 @@ unsigned long vm_mmap(struct file *file,
> >  }
> >  EXPORT_SYMBOL(vm_mmap);
> >  
> > +void *kvmalloc_node(size_t size, gfp_t gfp, int node)
> > +{
> > +	void *p;
> > +	unsigned uninitialized_var(noio_flag);
> > +
> > +	/* vmalloc doesn't support no-wait allocations */
> > +	WARN_ON_ONCE(!(gfp & __GFP_WAIT));
> > +
> > +	if (likely(size <= KMALLOC_MAX_SIZE)) {
> > +		/*
> > +		 * Use __GFP_NORETRY so that we don't loop waiting for the
> > +		 *	allocation - we don't have to loop here, if the memory
> > +		 *	is too fragmented, we fallback to vmalloc.
> 
> I'm not sure about this decision.  The direct reclaim retry code is the
> normal default behaviour and becomes more important with larger allocation
> attempts.  So why turn it off, and make it more likely that we return
> vmalloc memory?

It can avoid triggering the OOM killer in case of fragmented memory.

This is general question - if the code can handle allocation failure 
gracefully, what gfp flags should it use? Maybe add some flag 
__GFP_MAYFAIL instead of __GFP_NORETRY that changes the behavior in 
desired way?

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
