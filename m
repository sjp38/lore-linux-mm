Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 973446B0256
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:18:33 -0400 (EDT)
Received: by lbvd4 with SMTP id d4so26207217lbv.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:18:33 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kw7si13373210lac.136.2015.08.31.08.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 08:18:32 -0700 (PDT)
Date: Mon, 31 Aug 2015 18:18:14 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831151814.GC13814@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831143939.GC2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 10:39:39AM -0400, Tejun Heo wrote:
> On Mon, Aug 31, 2015 at 05:30:08PM +0300, Vladimir Davydov wrote:
> > slab/slub can issue alloc_pages() any time with any flags they want and
> > it won't be accounted to memcg, because kmem is accounted at slab/slub
> > layer, not in buddy.
> 
> Hmmm?  I meant the eventual calling into try_charge w/ GFP_NOWAIT.
> Speculative usage of GFP_NOWAIT is bound to increase and we don't want
> to put on extra restrictions from memcg side. 

We already put restrictions on slab/slub from memcg side, because kmem
accounting is a part of slab/slub. They have to cooperate in order to
get things working. If slab/slub wants to make a speculative allocation
for some reason, it should just put memcg_charge out of this speculative
alloc section. This is what this patch set does.

We have to be cautious about placing memcg_charge in slab/slub. To
understand why, consider SLAB case, which first tries to allocate from
all nodes in the order of preference w/o __GFP_WAIT and only if it fails
falls back on an allocation from any node w/ __GFP_WAIT. This is its
internal algorithm. If we blindly put memcg_charge to alloc_slab method,
then, when we are near the memcg limit, we will go over all NUMA nodes
in vain, then finally fall back to __GFP_WAIT allocation, which will get
a slab from a random node. Not only we do more work than necessary due
to walking over all NUMA nodes for nothing, but we also break SLAB
internal logic! And you just can't fix it in memcg, because memcg knows
nothing about the internal logic of SLAB, how it handles NUMA nodes.

SLUB has a different problem. It tries to avoid high-order allocations
if there is a risk of invoking costly memory compactor. It has nothing
to do with memcg, because memcg does not care if the charge is for a
high order page or not.

Thanks,
Vladimir

> For memory.high,
> punting to the return path is a pretty stright-forward solution which
> should make the problem go away almost entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
