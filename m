Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 854216B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 13:03:13 -0400 (EDT)
Received: by qkbp67 with SMTP id p67so6197932qkb.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:03:13 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id l125si11425825qhl.27.2015.08.31.10.03.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 10:03:12 -0700 (PDT)
Received: by qkdv1 with SMTP id v1so6315067qkd.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:03:12 -0700 (PDT)
Date: Mon, 31 Aug 2015 13:03:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831170309.GF2271@mtj.duckdns.org>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
 <20150831151814.GC13814@esperanza>
 <20150831154756.GE2271@mtj.duckdns.org>
 <20150831165131.GD15420@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831165131.GD15420@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Aug 31, 2015 at 07:51:32PM +0300, Vladimir Davydov wrote:
...
> If we want to allow slab/slub implementation to invoke try_charge
> wherever it wants, we need to introduce an asynchronous thread doing
> reclaim when a memcg is approaching its limit (or teach kswapd do that).

In the long term, I think this is the way to go.

> That's a way to go, but what's the point to complicate things
> prematurely while it seems we can fix the problem by using the technique
> similar to the one behind memory.high?

Cuz we're now scattering workarounds to multiple places and I'm sure
we'll add more try_charge() users (e.g. we want to fold in tcp memcg
under the same knobs) and we'll have to worry about the same problem
all over again and will inevitably miss some cases leading to subtle
failures.

> Nevertheless, even if we introduced such a thread, it'd be just insane
> to allow slab/slub blindly insert try_charge. Let me repeat the examples
> of SLAB/SLUB sub-optimal behavior caused by thoughtless usage of
> try_charge I gave above:
> 
>  - memcg knows nothing about NUMA nodes, so what's the point in failing
>    !__GFP_WAIT allocations used by SLAB while inspecting NUMA nodes?
>  - memcg knows nothing about high order pages, so what's the point in
>    failing !__GFP_WAIT allocations used by SLUB to try to allocate a
>    high order page?

Both are optimistic speculative actions and as long as memcg can
guarantee that those requests will succeed under normal circumstances,
as does the system-wide mm does, it isn't a problem.

In general, we want to make sure inside-cgroup behaviors as close to
system-wide behaviors as possible, scoped but equivalent in kind.
Doing things differently, while inevitable in certain cases, is likely
to get messy in the long term.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
