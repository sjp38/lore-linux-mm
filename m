Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id B6BC9280002
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:01:57 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h3so3514644igd.13
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:01:56 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id x18si11118377igr.11.2014.11.06.07.01.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 07:01:55 -0800 (PST)
Date: Thu, 6 Nov 2014 09:01:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 8/8] slab: recharge slab pages to the allocating
 memory cgroup
In-Reply-To: <20141106091749.GB4839@esperanza>
Message-ID: <alpine.DEB.2.11.1411060858530.4639@gentwo.org>
References: <cover.1415046910.git.vdavydov@parallels.com> <fe7c55a7ff9bb8a1ddff0256f5404196c10bfd08.1415046910.git.vdavydov@parallels.com> <alpine.DEB.2.11.1411051242410.28485@gentwo.org> <20141106091749.GB4839@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Nov 2014, Vladimir Davydov wrote:

> I call memcg_kmem_recharge_slab only on alloc path. Free path isn't
> touched. The overhead added is one function call. The function only
> reads and compares two pointers under RCU most of time. This is
> comparable to the overhead introduced by memcg_kmem_get_cache, which is
> called in slab_alloc/slab_alloc_node earlier.

Right maybe remove those too? Things seem to be accumulating in the hot
path which is bad. There is a slow path where these things can be added
and also a page based even slower path for statistics keeping.

The approach in SLUB is to do accounting on a slab page basis. Also memory
policies are applied at page granularity not object granularity.

> Anyways, if you think this is unacceptable, I don't mind dropping the
> whole patch set and thinking more on how to fix this per-memcg caches
> trickery. What do you think?

Maybe its possible to just use slab page accounting instead of object
accounting? Reduces overhead significantly. There may be some fuzz here
with occasional object accounted in the wrong way (which is similar to how
memory policies and other methods work) but it has been done before and
works ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
