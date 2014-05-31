Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id B92C56B0035
	for <linux-mm@kvack.org>; Sat, 31 May 2014 07:19:38 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id l4so1536212lbv.6
        for <linux-mm@kvack.org>; Sat, 31 May 2014 04:19:38 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z2si9231119lae.17.2014.05.31.04.19.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 May 2014 04:19:37 -0700 (PDT)
Date: Sat, 31 May 2014 15:19:23 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
Message-ID: <20140531111922.GD25076@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300957390.11943@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405300957390.11943@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 30, 2014 at 10:01:26AM -0500, Christoph Lameter wrote:
> On Fri, 30 May 2014, Vladimir Davydov wrote:
> 
> > We don't disable free objects caching for SLAB, because it would force
> > kfree to always take a spin lock, which would degrade performance
> > significantly.
> 
> You can use a similar approach than in SLUB. Reduce the size of the per
> cpu array objects to zero. Then SLAB will always fall back to its slow
> path in cache_flusharray() where you may be able to do something with less
> of an impact on performace.

In contrast to SLUB, for SLAB this will slow down kfree significantly.
Fast path for SLAB is just putting an object to a per cpu array, while
the slow path requires taking a per node lock, which is much slower even
with no contention. There still can be lots of objects in a dead memcg
cache (e.g. hundreds of megabytes of dcache), so such performance
degradation is not acceptable, IMO.

OTOH, we already have cache_reap running periodically for each cache.
Making it drain all free objects in dead caches won't impact performance
at all, neither will it complicate the code. The only downside is a dead
cache won't be destroyed immediately after it becomes unused, but since
cache_reap runs pretty often (each several secs), it shouldn't result in
any problems, I guess.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
