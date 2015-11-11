Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id B2B7E6B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 13:31:05 -0500 (EST)
Received: by igvg19 with SMTP id g19so75986888igv.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:31:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id rg7si11209338igc.46.2015.11.11.10.31.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 10:31:04 -0800 (PST)
Date: Wed, 11 Nov 2015 19:30:59 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
Message-ID: <20151111193059.5a9f5283@redhat.com>
In-Reply-To: <20151111162820.49fa8350@redhat.com>
References: <20151109181604.8231.22983.stgit@firesoul>
	<20151109181703.8231.66384.stgit@firesoul>
	<20151109191335.GM31308@esperanza>
	<20151109212522.6b38988c@redhat.com>
	<20151110084633.GT31308@esperanza>
	<20151110165534.6154082e@redhat.com>
	<20151110183246.GV31308@esperanza>
	<20151111162820.49fa8350@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Wed, 11 Nov 2015 16:28:20 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Tue, 10 Nov 2015 21:32:46 +0300
> Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > On Tue, Nov 10, 2015 at 04:55:34PM +0100, Jesper Dangaard Brouer wrote:
> > > On Tue, 10 Nov 2015 11:46:33 +0300
> > > Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > > 
> > > > On Mon, Nov 09, 2015 at 09:25:22PM +0100, Jesper Dangaard Brouer wrote:
> > > > > On Mon, 9 Nov 2015 22:13:35 +0300
> > > > > Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > > > > 
> > > > > > On Mon, Nov 09, 2015 at 07:17:31PM +0100, Jesper Dangaard Brouer wrote:
> > > > > > ...
> > > > > > > @@ -2556,7 +2563,7 @@ redo:
> > > > > > >  	if (unlikely(gfpflags & __GFP_ZERO) && object)
> > > > > > >  		memset(object, 0, s->object_size);
> > > > > > >  
> > > > > > > -	slab_post_alloc_hook(s, gfpflags, object);
> > > > > > > +	slab_post_alloc_hook(s, gfpflags, 1, object);
> > > > > > 
> > > > > > I think it must be &object
> > > > > 
> > > > > The object is already a void ** type.
> > > > 
> > > > Let's forget about types for a second. object contains an address to the
> > > > newly allocated object, while slab_post_alloc_hook expects an array of
> > > > addresses to objects. Simple test. Suppose an allocation failed. Then
> > > > object equals 0. Passing 0 to slab_post_alloc_hook as @p and 1 as @size
> > > > will result in NULL ptr dereference.
> > > 
> > > Argh, that is not good :-(
> > > I tested memory exhaustion and NULL ptr deref does happen in this case.
> > > 
> > >  BUG: unable to handle kernel NULL pointer dereference at           (null)
> > >  IP: [<ffffffff8113dea2>] kmem_cache_alloc+0x92/0x1d0
> > > 
> > > (gdb) list *(kmem_cache_alloc)+0x92
> > > 0xffffffff8113dea2 is in kmem_cache_alloc (mm/slub.c:1302).
> > > 1297	{
> > > 1298		size_t i;
> > > 1299	
> > > 1300		flags &= gfp_allowed_mask;
> > > 1301		for (i = 0; i < size; i++) {
> > > 1302			void *object = p[i];
> > > 1303	
> > > 1304			kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
> > > 1305			kmemleak_alloc_recursive(object, s->object_size, 1,
> > > 1306						 s->flags, flags);
> > > (gdb) quit
> > > 
> > > I changed:
> > > 
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 2eab115e18c5..c5a62fd02321 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -2484,7 +2484,7 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
> > >  static __always_inline void *slab_alloc_node(struct kmem_cache *s,
> > >                 gfp_t gfpflags, int node, unsigned long addr)
> > >  {
> > > -       void **object;
> > > +       void *object;
> > >         struct kmem_cache_cpu *c;
> > >         struct page *page;
> > >         unsigned long tid;
> > > @@ -2563,7 +2563,7 @@ redo:
> > >         if (unlikely(gfpflags & __GFP_ZERO) && object)
> > >                 memset(object, 0, s->object_size);
> > >  
> > > -       slab_post_alloc_hook(s, gfpflags, 1, object);
> > > +       slab_post_alloc_hook(s, gfpflags, 1, &object);
> > >  
> > >         return object;
> > >  }
> > > 
> > > But then the kernel cannot correctly boot?!?! (It dies in
> > > x86_perf_event_update+0x15.)  What did I miss???
> > 
> > Weird... I applied all your patches including the one above to
> > v4.3-rc6-mmotm-2015-10-21-14-41 and everything boots and works just fine
> > both inside a VM and on my x86 host. Are you sure the problem is caused
> > by your patches? Perhaps you updated the source tree in the meantime.
> 
> I didn't rebase, but I likely _should_ rebase my patchset.  It could be
> something different from my patch, I will investigate further.
>
> When you tested it, did you make sure the compiler didn't "remove" the
> code inside the for loop?
> 
> To put some code inside the for loop, I have enabled both
> CONFIG_KMEMCHECK and CONFIG_DEBUG_KMEMLEAK, plus CONFIG_SLUB_DEBUG_ON=y
> (but it seems SLUB_DEBUG gets somewhat removed when these gets enabled,
> didn't check the details).

Okay, there is nothing wrong with this change (it is actually more correct).

The problem was related to CONFIG_KMEMCHECK.  It was causing the system
to not boot (I have not look into why yet, don't have full console
output, but I can see it complains about PCI and ACPI init and then
dies in x86_perf_event_update+0x15, thus it could be system/HW specific).

I'm now running with CONFIG_DEBUG_KMEMLEAK, and is running tests with
exhausting memory.  And it works, e.g. when the alloc fails and @object
becomes NULL.

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
