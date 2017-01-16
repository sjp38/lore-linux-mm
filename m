Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6E66B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:47:23 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so7166693wjd.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:47:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h65si11722473wmh.70.2017.01.16.00.47.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 00:47:21 -0800 (PST)
Date: Mon, 16 Jan 2017 09:47:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
Message-ID: <20170116084717.GA13641@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-2-mhocko@kernel.org>
 <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Sun 15-01-17 20:34:13, John Hubbard wrote:
> 
> 
> On 01/12/2017 07:37 AM, Michal Hocko wrote:
[...]
> > diff --git a/mm/util.c b/mm/util.c
> > index 3cb2164f4099..7e0c240b5760 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -324,6 +324,48 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
> >  }
> >  EXPORT_SYMBOL(vm_mmap);
> > 
> > +/**
> > + * kvmalloc_node - allocate contiguous memory from SLAB with vmalloc fallback
> 
> Hi Michal,
> 
> How about this wording instead:
> 
> kvmalloc_node - attempt to allocate physically contiguous memory, but upon
> failure, fall back to non-contiguous (vmalloc) allocation.

OK, why not.
 
> > + * @size: size of the request.
> > + * @flags: gfp mask for the allocation - must be compatible (superset) with GFP_KERNEL.
> > + * @node: numa node to allocate from
> > + *
> > + * Uses kmalloc to get the memory but if the allocation fails then falls back
> > + * to the vmalloc allocator. Use kvfree for freeing the memory.
> > + *
> > + * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
> 
> Is that "Reclaim modifiers" line still true, or is it a leftover from an
> earlier approach? I am having trouble reconciling it with rest of the
> patchset, because:
> 
> a) the flags argument below is effectively passed on to either kmalloc_node
> (possibly adding, but not removing flags), or to __vmalloc_node_flags.

The above only says thos are _unsupported_ - in other words the behavior
is not defined. Even if flags are passed down to kmalloc resp. vmalloc
it doesn't mean they are used that way.  Remember that vmalloc uses
some hardcoded GFP_KERNEL allocations.  So while I could be really
strict about this and mask away these flags I doubt this is worth the
additional code.
 
> b) In patch 6/6, you are in fact passing in __GFP_REPEAT to the wrappers
> (kvzalloc, for example), and again, only adding, not removing flags.

Patch 2 adds a support for __GFP_REPEAT and updates the above line as
well.
 
> > + */
> > +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > +{
> > +	gfp_t kmalloc_flags = flags;
> > +	void *ret;
> > +
> > +	/*
> > +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> > +	 * so the given set of flags has to be compatible.
> > +	 */
> > +	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> > +
> > +	/*
> > +	 * Make sure that larger requests are not too disruptive - no OOM
> > +	 * killer and no allocation failure warnings as we have a fallback
> > +	 */
> > +	if (size > PAGE_SIZE)
> > +		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> > +
> > +	ret = kmalloc_node(size, kmalloc_flags, node);
> 
> Along those lines (dealing with larger requests), is there any value in
> picking some threshold value, and going straight to vmalloc if size is
> greater than that threshold?

I am not a fan of thresholds. PAGE_ALLOC_COSTLY_ORDER which is
internally used by the page allocator has turned out to be a major pain.
I do not want to repeat the same mistake again here. Besides that you
could hard find a "one suits all" value so it would have to be a part of
the API. If we ever grow users who would really like to do something
like that then a specialized API should be added.

> It's less flexible and might even require
> occasional maintenance over the years, but it would save some time on *some*
> systems in some cases...OK, I think I just talked myself out of the whole
> idea. But I still want to put the question out there, because I think others
> may also ask it, and I'd like to hear a more experienced opinion.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
