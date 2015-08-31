Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7694A6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:51:51 -0400 (EDT)
Received: by lbvd4 with SMTP id d4so27759149lbv.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:51:50 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oc2si13625137lbb.76.2015.08.31.09.51.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 09:51:49 -0700 (PDT)
Date: Mon, 31 Aug 2015 19:51:32 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831165131.GD15420@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
 <20150831151814.GC13814@esperanza>
 <20150831154756.GE2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831154756.GE2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 11:47:56AM -0400, Tejun Heo wrote:
> On Mon, Aug 31, 2015 at 06:18:14PM +0300, Vladimir Davydov wrote:
> > We have to be cautious about placing memcg_charge in slab/slub. To
> > understand why, consider SLAB case, which first tries to allocate from
> > all nodes in the order of preference w/o __GFP_WAIT and only if it fails
> > falls back on an allocation from any node w/ __GFP_WAIT. This is its
> > internal algorithm. If we blindly put memcg_charge to alloc_slab method,
> > then, when we are near the memcg limit, we will go over all NUMA nodes
> > in vain, then finally fall back to __GFP_WAIT allocation, which will get
> > a slab from a random node. Not only we do more work than necessary due
> > to walking over all NUMA nodes for nothing, but we also break SLAB
> > internal logic! And you just can't fix it in memcg, because memcg knows
> > nothing about the internal logic of SLAB, how it handles NUMA nodes.
> > 
> > SLUB has a different problem. It tries to avoid high-order allocations
> > if there is a risk of invoking costly memory compactor. It has nothing
> > to do with memcg, because memcg does not care if the charge is for a
> > high order page or not.
> 
> Maybe I'm missing something but aren't both issues caused by memcg
> failing to provide headroom for NOWAIT allocations when the
> consumption gets close to the max limit? 

That's correct.

> Regardless of the specific usage, !__GFP_WAIT means "give me memory if
> it can be spared w/o inducing direct time-consuming maintenance work"
> and the contract around it is that such requests will mostly succeed
> under nominal conditions.  Also, slab/slub might not stay as the only
> user of try_charge().

Indeed, there might be other users trying GFP_NOWAIT before falling back
to GFP_KERNEL, but they are not doing that constantly and hence cause no
problems. If SLAB/SLUB plays such tricks, the problem becomes massive:
under certain conditions *every* try_charge may be invoked w/o
__GFP_WAIT, resulting in memory.high breaching and hitting memory.max.

Generally speaking, handing over reclaim responsibility to task_work
won't help, because there might be cases when a process spends quite a
lot of time in kernel invoking lots of GFP_KERNEL allocations before
returning to userspace. Without fixing slab/slub, such a process will
charge w/o __GFP_WAIT and therefore can exceed memory.high and reach
memory.max. If there are no other active processes in the cgroup, the
cgroup can stay with memory.high excess for a relatively long time
(suppose the process was throttled in kernel), possibly hurting the rest
of the system. What is worse, if the process happens to invoke a real
GFP_NOWAIT allocation when it's about to hit the limit, it will fail.

If we want to allow slab/slub implementation to invoke try_charge
wherever it wants, we need to introduce an asynchronous thread doing
reclaim when a memcg is approaching its limit (or teach kswapd do that).
That's a way to go, but what's the point to complicate things
prematurely while it seems we can fix the problem by using the technique
similar to the one behind memory.high?

Nevertheless, even if we introduced such a thread, it'd be just insane
to allow slab/slub blindly insert try_charge. Let me repeat the examples
of SLAB/SLUB sub-optimal behavior caused by thoughtless usage of
try_charge I gave above:

 - memcg knows nothing about NUMA nodes, so what's the point in failing
   !__GFP_WAIT allocations used by SLAB while inspecting NUMA nodes?
 - memcg knows nothing about high order pages, so what's the point in
   failing !__GFP_WAIT allocations used by SLUB to try to allocate a
   high order page?

Thanks,
Vladimir

> I still think solving this from memcg side is the right direction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
