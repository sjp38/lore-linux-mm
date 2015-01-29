Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5596B0082
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:17:53 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so40749320pab.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 08:17:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q5si10527342pdl.41.2015.01.29.08.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 08:17:51 -0800 (PST)
Date: Thu, 29 Jan 2015 19:17:39 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Message-ID: <20150129161739.GE11463@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
 <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org>
 <20150129080726.GB11463@esperanza>
 <alpine.DEB.2.11.1501290954230.7725@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501290954230.7725@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 29, 2015 at 09:55:56AM -0600, Christoph Lameter wrote:
> On Thu, 29 Jan 2015, Vladimir Davydov wrote:
> 
> > Come to think of it, do we really need to optimize slab placement in
> > kmem_cache_shrink? None of its users except shrink_store expects it -
> > they just want to purge the cache before destruction, that's it. May be,
> > we'd better move slab placement optimization to a separate SLUB's
> > private function that would be called only by shrink_store, where we can
> > put up with kmalloc failures? Christoph, what do you think?
> 
> The slabinfo tool invokes kmem_cache_shrink to optimize placement.
> 
> Run
> 
> 	slabinfo -s
> 
> which can then be used to reduce the fragmentation.

Yeah, but the tool just writes 1 to /sys/kernel/slab/cache/shrink, i.e.
invokes shrink_store(), and I don't propose to remove slab placement
optimization from there. What I propose is to move slab placement
optimization from kmem_cache_shrink() to shrink_store(), because other
users of kmem_cache_shrink() don't seem to need it at all - they just
want to release empty slabs. Such a change wouldn't affect the behavior
of `slabinfo -s` at all.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
