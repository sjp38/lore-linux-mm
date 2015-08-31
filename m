Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2A56B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:26:34 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so66443580lbb.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:26:34 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id br8si14203364lbb.117.2015.08.31.12.26.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 12:26:31 -0700 (PDT)
Date: Mon, 31 Aug 2015 22:26:12 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831192612.GE15420@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
 <20150831151814.GC13814@esperanza>
 <20150831154756.GE2271@mtj.duckdns.org>
 <20150831165131.GD15420@esperanza>
 <20150831170309.GF2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831170309.GF2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 01:03:09PM -0400, Tejun Heo wrote:
> On Mon, Aug 31, 2015 at 07:51:32PM +0300, Vladimir Davydov wrote:
> ...
> > If we want to allow slab/slub implementation to invoke try_charge
> > wherever it wants, we need to introduce an asynchronous thread doing
> > reclaim when a memcg is approaching its limit (or teach kswapd do that).
> 
> In the long term, I think this is the way to go.

Quite probably, or we can use task_work, or direct reclaim instead. It's
not that obvious to me yet which one is the best.

> 
> > That's a way to go, but what's the point to complicate things
> > prematurely while it seems we can fix the problem by using the technique
> > similar to the one behind memory.high?
> 
> Cuz we're now scattering workarounds to multiple places and I'm sure
> we'll add more try_charge() users (e.g. we want to fold in tcp memcg
> under the same knobs) and we'll have to worry about the same problem
> all over again and will inevitably miss some cases leading to subtle
> failures.

I don't think we will need to insert try_charge_kmem anywhere else,
because all kmem users either allocate memory using kmalloc and friends
or using alloc_pages. kmalloc is accounted. For those who prefer
alloc_pages, there is alloc_kmem_pages helper.

> 
> > Nevertheless, even if we introduced such a thread, it'd be just insane
> > to allow slab/slub blindly insert try_charge. Let me repeat the examples
> > of SLAB/SLUB sub-optimal behavior caused by thoughtless usage of
> > try_charge I gave above:
> > 
> >  - memcg knows nothing about NUMA nodes, so what's the point in failing
> >    !__GFP_WAIT allocations used by SLAB while inspecting NUMA nodes?
> >  - memcg knows nothing about high order pages, so what's the point in
> >    failing !__GFP_WAIT allocations used by SLUB to try to allocate a
> >    high order page?
> 
> Both are optimistic speculative actions and as long as memcg can
> guarantee that those requests will succeed under normal circumstances,
> as does the system-wide mm does, it isn't a problem.
> 
> In general, we want to make sure inside-cgroup behaviors as close to
> system-wide behaviors as possible, scoped but equivalent in kind.
> Doing things differently, while inevitable in certain cases, is likely
> to get messy in the long term.

I totally agree that we should strive to make a kmem user feel roughly
the same in memcg as if it were running on a host with equal amount of
RAM. There are two ways to achieve that:

 1. Make the API functions, i.e. kmalloc and friends, behave inside
    memcg roughly the same way as they do in the root cgroup.
 2. Make the internal memcg functions, i.e. try_charge and friends,
    behave roughly the same way as alloc_pages.

I find way 1 more flexible, because we don't have to blindly follow
heuristics used on global memory reclaim and therefore have more
opportunities to achieve the same goal.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
