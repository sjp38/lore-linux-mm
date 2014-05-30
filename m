Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1546B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:57:13 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id lf12so2037166vcb.31
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:57:13 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id u4si3176458vcs.52.2014.05.30.07.57.12
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:57:12 -0700 (PDT)
Date: Fri, 30 May 2014 09:57:10 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs
 immediately
In-Reply-To: <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300955120.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> (3) is a bit more difficult, because slabs are added to per-cpu partial
> lists lock-less. Fortunately, we only have to handle the __slab_free
> case, because, as there shouldn't be any allocation requests dispatched
> to a dead memcg cache, get_partial_node() should never be called. In
> __slab_free we use cmpxchg to modify kmem_cache_cpu->partial (see
> put_cpu_partial) so that setting ->partial to a special value, which
> will make put_cpu_partial bail out, will do the trick.
>
> Note, this shouldn't affect performance, because keeping empty slabs on
> per node lists as well as using per cpu partials are only worthwhile if
> the cache is used for allocations, which isn't the case for dead caches.

This all sounds pretty good to me but we still have some pretty extensive
modifications that I would rather avoid.

In put_cpu_partial you can simply check that the memcg is dead right? This
would avoid all the other modifications I would think and will not require
a special value for the per cpu partial pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
