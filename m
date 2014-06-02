Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA62E6B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:24:12 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so10760190qge.8
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:24:12 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id 39si17750378qga.14.2014.06.02.08.24.11
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:24:12 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:24:09 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
In-Reply-To: <20140531111922.GD25076@esperanza>
Message-ID: <alpine.DEB.2.10.1406021019350.2987@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405300957390.11943@gentwo.org> <20140531111922.GD25076@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 31 May 2014, Vladimir Davydov wrote:

> > You can use a similar approach than in SLUB. Reduce the size of the per
> > cpu array objects to zero. Then SLAB will always fall back to its slow
> > path in cache_flusharray() where you may be able to do something with less
> > of an impact on performace.
>
> In contrast to SLUB, for SLAB this will slow down kfree significantly.

But that is only when you want to destroy a cache. This is similar.

> Fast path for SLAB is just putting an object to a per cpu array, while
> the slow path requires taking a per node lock, which is much slower even
> with no contention. There still can be lots of objects in a dead memcg
> cache (e.g. hundreds of megabytes of dcache), so such performance
> degradation is not acceptable, IMO.

I am not sure that there is such a stark difference to SLUB. SLUB also
takes the per node lock if necessary to handle freeing especially if you
zap the per cpu partial slab pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
