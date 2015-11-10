Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB6F6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:55:42 -0500 (EST)
Received: by iofh3 with SMTP id h3so5007138iof.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:55:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si17255301igq.91.2015.11.10.07.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 07:55:41 -0800 (PST)
Date: Tue, 10 Nov 2015 16:55:34 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
Message-ID: <20151110165534.6154082e@redhat.com>
In-Reply-To: <20151110084633.GT31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
	<20151109181703.8231.66384.stgit@firesoul>
	<20151109191335.GM31308@esperanza>
	<20151109212522.6b38988c@redhat.com>
	<20151110084633.GT31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Tue, 10 Nov 2015 11:46:33 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Mon, Nov 09, 2015 at 09:25:22PM +0100, Jesper Dangaard Brouer wrote:
> > On Mon, 9 Nov 2015 22:13:35 +0300
> > Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > 
> > > On Mon, Nov 09, 2015 at 07:17:31PM +0100, Jesper Dangaard Brouer wrote:
> > > ...
> > > > @@ -2556,7 +2563,7 @@ redo:
> > > >  	if (unlikely(gfpflags & __GFP_ZERO) && object)
> > > >  		memset(object, 0, s->object_size);
> > > >  
> > > > -	slab_post_alloc_hook(s, gfpflags, object);
> > > > +	slab_post_alloc_hook(s, gfpflags, 1, object);
> > > 
> > > I think it must be &object
> > 
> > The object is already a void ** type.
> 
> Let's forget about types for a second. object contains an address to the
> newly allocated object, while slab_post_alloc_hook expects an array of
> addresses to objects. Simple test. Suppose an allocation failed. Then
> object equals 0. Passing 0 to slab_post_alloc_hook as @p and 1 as @size
> will result in NULL ptr dereference.

Argh, that is not good :-(
I tested memory exhaustion and NULL ptr deref does happen in this case.

 BUG: unable to handle kernel NULL pointer dereference at           (null)
 IP: [<ffffffff8113dea2>] kmem_cache_alloc+0x92/0x1d0

(gdb) list *(kmem_cache_alloc)+0x92
0xffffffff8113dea2 is in kmem_cache_alloc (mm/slub.c:1302).
1297	{
1298		size_t i;
1299	
1300		flags &= gfp_allowed_mask;
1301		for (i = 0; i < size; i++) {
1302			void *object = p[i];
1303	
1304			kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
1305			kmemleak_alloc_recursive(object, s->object_size, 1,
1306						 s->flags, flags);
(gdb) quit

I changed:

diff --git a/mm/slub.c b/mm/slub.c
index 2eab115e18c5..c5a62fd02321 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2484,7 +2484,7 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 static __always_inline void *slab_alloc_node(struct kmem_cache *s,
                gfp_t gfpflags, int node, unsigned long addr)
 {
-       void **object;
+       void *object;
        struct kmem_cache_cpu *c;
        struct page *page;
        unsigned long tid;
@@ -2563,7 +2563,7 @@ redo:
        if (unlikely(gfpflags & __GFP_ZERO) && object)
                memset(object, 0, s->object_size);
 
-       slab_post_alloc_hook(s, gfpflags, 1, object);
+       slab_post_alloc_hook(s, gfpflags, 1, &object);
 
        return object;
 }

But then the kernel cannot correctly boot?!?! (It dies in
x86_perf_event_update+0x15.)  What did I miss???

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
