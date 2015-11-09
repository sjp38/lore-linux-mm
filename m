Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B4BDE6B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:38:34 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so207038136pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:38:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b1si23875115pat.193.2015.11.09.10.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:38:34 -0800 (PST)
Date: Mon, 9 Nov 2015 21:38:21 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151109183821.GK31308@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
 <20151105153756.1115.41409.stgit@firesoul>
 <20151105162514.GI29259@esperanza>
 <20151107175338.12a0368b@redhat.com>
 <20151107202548.GO29259@esperanza>
 <20151109173910.7a3c3a18@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109173910.7a3c3a18@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Mon, Nov 09, 2015 at 05:39:10PM +0100, Jesper Dangaard Brouer wrote:
> 
> On Sat, 7 Nov 2015 23:25:48 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > On Sat, Nov 07, 2015 at 05:53:38PM +0100, Jesper Dangaard Brouer wrote:
> > > On Thu, 5 Nov 2015 19:25:14 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > > 
> > > > On Thu, Nov 05, 2015 at 04:38:06PM +0100, Jesper Dangaard Brouer wrote:
> > > > > Initial implementation missed support for kmem cgroup support
> > > > > in kmem_cache_free_bulk() call, add this.
> > > > > 
> > > > > If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> > > > > be smart enough to not add any asm code.
> > > > > 
> > > > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > > > > 
> > > > > ---
> > > > > V2: Fixes according to input from:
> > > > >  Vladimir Davydov <vdavydov@virtuozzo.com>
> > > > >  and Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > > 
> [...]
> > > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > > index 8e9e9b2ee6f3..bc64514ad1bb 100644
> > > > > --- a/mm/slub.c
> > > > > +++ b/mm/slub.c
> > > > > @@ -2890,6 +2890,9 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> > > > >  	do {
> > > > >  		struct detached_freelist df;
> > > > >  
> > > > > +		/* Support for memcg */
> > > > > +		s = cache_from_obj(s, p[size - 1]);
> > > > > +
> [...]
> > 
> > Yeah, after inspecting build_detached_freelist more closely, I see your
> > patch is correct.
> 
> Actually, my patch is not correct... after spending most of my day
> debugging V3 of patch 1/2, I've just realized this patch it the culprit.
> 
> We cannot overwrite the original "s", as the second time around the
> loop, "s" will be a memcg slab cache.  And then slab_equal_or_root()
> cannot find  the "root_cache" (s->memcg_params.root_cache).

Yeah, you're right. Shame that I missed that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
