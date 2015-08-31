Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id A7C4E6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:47:59 -0400 (EDT)
Received: by qkbp67 with SMTP id p67so2473684qkb.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:47:59 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id u79si8997518qgd.88.2015.08.31.08.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 08:47:58 -0700 (PDT)
Received: by qkct7 with SMTP id t7so2560766qkc.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:47:58 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:47:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831154756.GE2271@mtj.duckdns.org>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
 <20150831151814.GC13814@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831151814.GC13814@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Aug 31, 2015 at 06:18:14PM +0300, Vladimir Davydov wrote:
> We have to be cautious about placing memcg_charge in slab/slub. To
> understand why, consider SLAB case, which first tries to allocate from
> all nodes in the order of preference w/o __GFP_WAIT and only if it fails
> falls back on an allocation from any node w/ __GFP_WAIT. This is its
> internal algorithm. If we blindly put memcg_charge to alloc_slab method,
> then, when we are near the memcg limit, we will go over all NUMA nodes
> in vain, then finally fall back to __GFP_WAIT allocation, which will get
> a slab from a random node. Not only we do more work than necessary due
> to walking over all NUMA nodes for nothing, but we also break SLAB
> internal logic! And you just can't fix it in memcg, because memcg knows
> nothing about the internal logic of SLAB, how it handles NUMA nodes.
> 
> SLUB has a different problem. It tries to avoid high-order allocations
> if there is a risk of invoking costly memory compactor. It has nothing
> to do with memcg, because memcg does not care if the charge is for a
> high order page or not.

Maybe I'm missing something but aren't both issues caused by memcg
failing to provide headroom for NOWAIT allocations when the
consumption gets close to the max limit?  Regardless of the specific
usage, !__GFP_WAIT means "give me memory if it can be spared w/o
inducing direct time-consuming maintenance work" and the contract
around it is that such requests will mostly succeed under nominal
conditions.  Also, slab/slub might not stay as the only user of
try_charge().  I still think solving this from memcg side is the right
direction.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
