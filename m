Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 371616B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:09:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o9so2820280pgv.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:09:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8si9406978pgr.419.2018.04.16.06.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 06:09:41 -0700 (PDT)
Date: Mon, 16 Apr 2018 06:09:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180416130936.GC26022@bombadil.infradead.org>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
 <20180413143716.GA5378@cmpxchg.org>
 <20180416114144.GK17484@dhcp22.suse.cz>
 <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Apr 16, 2018 at 02:06:21PM +0200, Vlastimil Babka wrote:
> On 04/16/2018 01:41 PM, Michal Hocko wrote:
> > On Fri 13-04-18 10:37:16, Johannes Weiner wrote:
> >> On Fri, Apr 13, 2018 at 04:28:21PM +0200, Michal Hocko wrote:
> >>> On Fri 13-04-18 16:20:00, Vlastimil Babka wrote:
> >>>> We would need kmalloc-reclaimable-X variants. It could be worth it,
> >>>> especially if we find more similar usages. I suspect they would be more
> >>>> useful than the existing dma-kmalloc-X :)
> >>>
> >>> I am still not sure why __GFP_RECLAIMABLE cannot be made work as
> >>> expected and account slab pages as SLAB_RECLAIMABLE
> >>
> >> Can you outline how this would work without separate caches?
> > 
> > I thought that the cache would only maintain two sets of slab pages
> > depending on the allocation reuquests. I am pretty sure there will be
> > other details to iron out and
> 
> For example the percpu (and other) array caches...
> 
> > maybe it will turn out that such a large
> > portion of the chache would need to duplicate the state that a
> > completely new cache would be more reasonable.
> 
> I'm afraid that's the case, yes.

I'm not sure it'll be so bad, at least for SLUB ... I think everything
we need to duplicate is already percpu, and if we combine GFP_DMA
and GFP_RECLAIMABLE into this, we might even get more savings.  Also,
we only need to do this for the kmalloc slabs; currently 13 of them.
So we eliminate 13 caches and in return allocate 13 * 2 * NR_CPU pointers.
That'll be a win on some machines and a loss on others, but the machines
where it's consuming more memory should have more memory to begin with,
so I'd count it as a win.

The node partial list probably wants to be trebled in size to have one
list per memory type.  But I think the allocation path only changes
like this:

@@ -2663,10 +2663,13 @@ static __always_inline void *slab_alloc_node(struct kmem
_cache *s,
        struct kmem_cache_cpu *c;
        struct page *page;
        unsigned long tid;
+       unsigned int offset = 0;
 
        s = slab_pre_alloc_hook(s, gfpflags);
        if (!s)
                return NULL;
        if (s->flags & SLAB_KMALLOC)
                offset = flags_to_slab_id(gfpflags);
 redo:
        /*
         * Must read kmem_cache cpu data via this cpu ptr. Preemption is
@@ -2679,8 +2682,8 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
         * to check if it is matched or not.
         */
        do {
-               tid = this_cpu_read(s->cpu_slab->tid);
-               c = raw_cpu_ptr(s->cpu_slab);
+               tid = this_cpu_read((&s->cpu_slab[offset])->tid);
+               c = raw_cpu_ptr(&s->cpu_slab[offset]);
        } while (IS_ENABLED(CONFIG_PREEMPT) &&
                 unlikely(tid != READ_ONCE(c->tid)));
 

> > Is this worth exploring
> > at least? I mean something like this should help with the fragmentation
> > already AFAIU. Accounting would be just free on top.
> 
> Yep. It could be also CONFIG_urable so smaller systems don't need to
> deal with the memory overhead of this.
> 
> So do we put it on LSF/MM agenda?

We have an agenda?  :-)
