Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 175506B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 05:06:37 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so3269326lbi.13
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 02:06:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ee6si19566734lad.116.2014.06.03.02.06.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jun 2014 02:06:36 -0700 (PDT)
Date: Tue, 3 Jun 2014 13:06:26 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 5/8] slab: remove kmem_cache_shrink retval
Message-ID: <20140603090623.GC6013@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <d2bbd28ae0f0c1807f9fe72d0443eccb739b8aa6.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300947170.11943@gentwo.org>
 <20140531102740.GB25076@esperanza>
 <alpine.DEB.2.10.1406021014140.2987@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406021014140.2987@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 10:16:03AM -0500, Christoph Lameter wrote:
> On Sat, 31 May 2014, Vladimir Davydov wrote:
> 
> > > Well slub returns an error code if it fails
> >
> > ... to sort slabs by the nubmer of objects in use, which is not even
> > implied by the function declaration. Why can *shrinking*, which is what
> > kmem_cache_shrink must do at first place, ever fail?
> 
> Because there is a memory allocation failure. Or there may be other
> processes going on that prevent shrinking. F.e. We may want to merge a
> patchset that does defragmentation of slabs at some point.

Fair enough.

Still, I really want to evict all empty slabs from cache on memcg
offline for sure. Handling failures there means introducing a worker
that will retry shrinking, but that seems to me as an unnecessary
complication, because there's nothing that can prevent us from shrinking
empty slabs from the cache, even if we merge slab defragmentation, isn't
it?

May be, it's worth introducing a special function, say kmem_cache_zap(),
that will only evict empty slabs from the cache, plus disable empty
slabs caching? This function would be called only from memcg offline for
dead memcg caches.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
