Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A9B036B009C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:22:25 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1317702pdb.27
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:22:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kv14si6260418pab.22.2014.11.06.07.22.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 07:22:21 -0800 (PST)
Date: Thu, 6 Nov 2014 18:22:09 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 8/8] slab: recharge slab pages to the allocating
 memory cgroup
Message-ID: <20141106152209.GF4839@esperanza>
References: <cover.1415046910.git.vdavydov@parallels.com>
 <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1411051242410.28485@gentwo.org>
 <20141106091749.GB4839@esperanza>
 <alpine.DEB.2.11.1411060858530.4639@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1411060858530.4639@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 06, 2014 at 09:01:52AM -0600, Christoph Lameter wrote:
> On Thu, 6 Nov 2014, Vladimir Davydov wrote:
> 
> > I call memcg_kmem_recharge_slab only on alloc path. Free path isn't
> > touched. The overhead added is one function call. The function only
> > reads and compares two pointers under RCU most of time. This is
> > comparable to the overhead introduced by memcg_kmem_get_cache, which is
> > called in slab_alloc/slab_alloc_node earlier.
> 
> Right maybe remove those too? Things seem to be accumulating in the hot
> path which is bad. There is a slow path where these things can be added
> and also a page based even slower path for statistics keeping.
> 
> The approach in SLUB is to do accounting on a slab page basis. Also memory
> policies are applied at page granularity not object granularity.
> 
> > Anyways, if you think this is unacceptable, I don't mind dropping the
> > whole patch set and thinking more on how to fix this per-memcg caches
> > trickery. What do you think?
> 
> Maybe its possible to just use slab page accounting instead of object
> accounting? Reduces overhead significantly. There may be some fuzz here
> with occasional object accounted in the wrong way (which is similar to how
> memory policies and other methods work) but it has been done before and
> works ok.

Actually, it's not about mis-accounting. The problem is a newly
allocated object can pin a charge of a dead cgroup that used the cache
before. May be, it wouldn't be a problem though.

Anyways, I think I need more time to brood over the whole approach, so
I've asked Andrew to drop the patch set.

Thank you for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
