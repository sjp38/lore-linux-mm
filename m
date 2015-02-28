Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 263A96B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 22:21:55 -0500 (EST)
Received: by igkb16 with SMTP id b16so5346647igk.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:21:54 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id z191si4996391iod.86.2015.02.27.19.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 19:21:54 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so35809919iec.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:21:54 -0800 (PST)
Date: Fri, 27 Feb 2015 19:21:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
In-Reply-To: <alpine.DEB.2.11.1502271649060.20876@gentwo.org>
Message-ID: <alpine.DEB.2.10.1502271905280.22682@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <alpine.DEB.2.11.1502271649060.20876@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On Fri, 27 Feb 2015, Christoph Lameter wrote:

> > +/*
> > + * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> > + * or warn about failures.
> > + */
> 
> We should be triggering reclaim from slab allocations. Why would we not do
> this?
> 
> Otherwise we will be going uselessly off node for slab allocations.
> 
> > +static inline gfp_t gfp_exact_node(gfp_t flags)
> > +{
> > +	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> > +}
> >  #endif
> 
> Reclaim needs to be triggered. In particular zone reclaim was made to be
> triggered from slab allocations to create more room if needed.
> 

This illustrates the precise need for a patch like this that removes 
GFP_THISNODE entirely: notice there's no functional change with this 
patch.

GFP_THISNODE is __GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY.

The calls to ____cache_alloc_node() and cache_grow() modified by this 
patch in mm/slab.c that pass GFP_THISNODE get caught in the page allocator 
slowpath by this:

	if (IS_ENABLED(CONFIG_NUMA) &&
	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
		goto nopage;

with today's kernel.  In fact, there is no way for the slab allocator to 
currently allocate exactly on one node, allow reclaim, and avoid looping 
forever while suppressing the page allocation failure warning.  The reason 
is because of how GFP_THISNODE is defined above.

With this patch, it would be possible to modify gfp_exact_node() so that 
instead of doing

	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;

which has no functional change from today, it could be

	return flags | __GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY;

so that we _can_ do reclaim for that node and avoid looping forever when 
the allocation fails.  These three flags are the exact same bits set in 
today's GFP_THISNODE and it is, I agree, what the slab allocator really 
wants to do in cache_grow().  But the conditional above is what 
short-circuits such an allocation and needs to be removed, which is what 
this patch does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
