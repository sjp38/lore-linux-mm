Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB5D6B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 11:01:29 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so2264464veb.13
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:01:29 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id um1si3241586veb.11.2014.05.30.08.01.28
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 08:01:28 -0700 (PDT)
Date: Fri, 30 May 2014 10:01:26 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
In-Reply-To: <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300957390.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> There is no use in keeping free objects/slabs on dead memcg caches,
> because they will never be allocated. So let's make cache_reap() shrink
> as many free objects from such caches as possible.
>
> Note the difference between SLAB and SLUB handling of dead memcg caches.
> For SLUB, dead cache destruction is scheduled as soon as the last object
> is freed, because dead caches do not cache free objects. For SLAB, dead
> caches can keep some free objects on per cpu arrays, so that an empty
> dead cache will be hanging around until cache_reap() drains it.

Calling kmem_cache_shrink() should drain all caches though. Reduce the
size of the queues to zero or so before calling shrink so that no new
caches are build up?

> We don't disable free objects caching for SLAB, because it would force
> kfree to always take a spin lock, which would degrade performance
> significantly.

You can use a similar approach than in SLUB. Reduce the size of the per
cpu array objects to zero. Then SLAB will always fall back to its slow
path in cache_flusharray() where you may be able to do something with less
of an impact on performace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
