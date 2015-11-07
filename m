Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 88ADB82F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:26:07 -0500 (EST)
Received: by lbces9 with SMTP id es9so7701636lbc.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:26:06 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id u1si4539064lbg.130.2015.11.07.12.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 12:26:06 -0800 (PST)
Date: Sat, 7 Nov 2015 23:25:48 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151107202548.GO29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
 <20151105153756.1115.41409.stgit@firesoul>
 <20151105162514.GI29259@esperanza>
 <20151107175338.12a0368b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151107175338.12a0368b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Sat, Nov 07, 2015 at 05:53:38PM +0100, Jesper Dangaard Brouer wrote:
> On Thu, 5 Nov 2015 19:25:14 +0300
> Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > On Thu, Nov 05, 2015 at 04:38:06PM +0100, Jesper Dangaard Brouer wrote:
> > > Initial implementation missed support for kmem cgroup support
> > > in kmem_cache_free_bulk() call, add this.
> > > 
> > > If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> > > be smart enough to not add any asm code.
> > > 
> > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > > 
> > > ---
> > > V2: Fixes according to input from:
> > >  Vladimir Davydov <vdavydov@virtuozzo.com>
> > >  and Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > >  mm/slub.c |    3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 8e9e9b2ee6f3..bc64514ad1bb 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2890,6 +2890,9 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> > >  	do {
> > >  		struct detached_freelist df;
> > >  
> > > +		/* Support for memcg */
> > > +		s = cache_from_obj(s, p[size - 1]);
> > > +
> > 
> > AFAIU all objects in the array should come from the same cache (should
> > they?), so it should be enough to call this only once:
> 
> Can we be sure all objects in the array come from same cache?
> 
> Imagine my use case:
>  1. application send packet alloc a SKB (from a slab)
>  2. packet TX to NIC via DMA
>  3. TX DMA completion cleans up 256 packets and kmem free SKBs
> 
> I don't know enough about mem cgroups... but I can imagine two
> applications belonging to different mem-cgroups sending packet out same
> NIC and later getting their SKB (pkt-metadata struct) free'ed during
> the same TX completion (TX softirq) cycle, as a bulk free.

Hmm, I thought that a bunch of objects allocated using
kmem_cache_alloc_bulk must be freed using kmem_cache_free_bulk. If it
does not hold, i.e. if one can allocate an array of objects one by one
using kmem_cache_alloc and then batch-free them using
kmem_cache_free_bulk, then my proposal is irrelevant.

> 
> With my limited mem cgroups, it looks like memcg works on the slab-page
> level? 

Yes, a memcg has its private copy of each global kmem cache it attempted
to use, which implies that all objects on the same slab-page must belong
to the same memcg.

> And what I'm doing in this code is to group object together
> belonging to the same slab-page.

Yeah, after inspecting build_detached_freelist more closely, I see your
patch is correct. Feel free to add

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
