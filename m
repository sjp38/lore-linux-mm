Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5531D6B006E
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 03:07:40 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so36139385pab.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 00:07:40 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m4si9068644pdd.9.2015.01.29.00.07.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 00:07:39 -0800 (PST)
Date: Thu, 29 Jan 2015 11:07:26 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Message-ID: <20150129080726.GB11463@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
 <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150128135752.afcb196d6ded7c16a79ed6fd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 01:57:52PM -0800, Andrew Morton wrote:
> On Wed, 28 Jan 2015 19:22:49 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> > @@ -3375,51 +3376,56 @@ int __kmem_cache_shrink(struct kmem_cache *s)
> >  	struct kmem_cache_node *n;
> >  	struct page *page;
> >  	struct page *t;
> > -	int objects = oo_objects(s->max);
> > -	struct list_head *slabs_by_inuse =
> > -		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
> > +	LIST_HEAD(discard);
> > +	struct list_head promote[SHRINK_PROMOTE_MAX];
> 
> 512 bytes of stack.  The call paths leading to __kmem_cache_shrink()
> are many and twisty.  How do we know this isn't a problem?

Because currently __kmem_cache_shrink is only called just from a couple
of places, each of which isn't supposed to have a great stack depth
AFAIU, namely:

- slab_mem_going_offline_callback - MEM_GOING_OFFLINE handler
- shrink_store - invoked upon write to /sys/kernel/slab/cache/shrink
- acpi_os_purge_cache - only called on acpi init
- memcg_deactivate_kmem_caches - called from cgroup_destroy_wq

> The logic behind choosing "32" sounds rather rubbery.  What goes wrong
> if we use, say, "4"?

We could, but kmem_cache_shrink would cope with fragmentation less
efficiently.

Come to think of it, do we really need to optimize slab placement in
kmem_cache_shrink? None of its users except shrink_store expects it -
they just want to purge the cache before destruction, that's it. May be,
we'd better move slab placement optimization to a separate SLUB's
private function that would be called only by shrink_store, where we can
put up with kmalloc failures? Christoph, what do you think?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
