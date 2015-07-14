Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id C715428024D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:13:19 -0400 (EDT)
Received: by iggf3 with SMTP id f3so21982417igg.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:13:19 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id m17si2400407icr.79.2015.07.14.14.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:13:19 -0700 (PDT)
Received: by ietj16 with SMTP id j16so20477153iet.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:13:19 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:13:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
In-Reply-To: <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com> <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
 <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com> <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org> <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 9 Jul 2015, Mikulas Patocka wrote:

> > > Index: linux-4.2-rc1/mm/util.c
> > > ===================================================================
> > > --- linux-4.2-rc1.orig/mm/util.c	2015-07-07 15:58:11.000000000 +0200
> > > +++ linux-4.2-rc1/mm/util.c	2015-07-08 19:22:26.000000000 +0200
> > > @@ -316,6 +316,61 @@ unsigned long vm_mmap(struct file *file,
> > >  }
> > >  EXPORT_SYMBOL(vm_mmap);
> > >  
> > > +void *kvmalloc_node(size_t size, gfp_t gfp, int node)
> > > +{
> > > +	void *p;
> > > +	unsigned uninitialized_var(noio_flag);
> > > +
> > > +	/* vmalloc doesn't support no-wait allocations */
> > > +	WARN_ON_ONCE(!(gfp & __GFP_WAIT));
> > > +
> > > +	if (likely(size <= KMALLOC_MAX_SIZE)) {
> > > +		/*
> > > +		 * Use __GFP_NORETRY so that we don't loop waiting for the
> > > +		 *	allocation - we don't have to loop here, if the memory
> > > +		 *	is too fragmented, we fallback to vmalloc.
> > 
> > I'm not sure about this decision.  The direct reclaim retry code is the
> > normal default behaviour and becomes more important with larger allocation
> > attempts.  So why turn it off, and make it more likely that we return
> > vmalloc memory?
> 
> It can avoid triggering the OOM killer in case of fragmented memory.
> 
> This is general question - if the code can handle allocation failure 
> gracefully, what gfp flags should it use? Maybe add some flag 
> __GFP_MAYFAIL instead of __GFP_NORETRY that changes the behavior in 
> desired way?
> 

There's a misunderstanding in regards to the comment: __GFP_NORETRY 
doesn't turn direct reclaim or compaction off, it is still attempted and 
with the same priority as any other allocation.  This only stops the page 
allocator from calling the oom killer, which will free memory or panic the 
system, and looping when memory is available.

In regards to the proposal in general, I think it's unnecessary because we 
are still left behind with other users who open code their call to 
vmalloc.  I was interested in commit 058504edd026 ("fs/seq_file: fallback 
to vmalloc allocation") since it solved an issue with high memory 
fragmentation.  Note how it falls back to vmalloc(): _without_ this 
__GFP_NORETRY.  That's because we only want to fallback when high-order 
allocations fail and the page allocator doesn't implicitly loop due to the 
order.  ext4_kvmalloc(), ext4_kzmalloc() does the same.

The differences in implementations between those that do kmalloc() and 
fallback to vmalloc() are different enough that I don't think we need this 
addition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
