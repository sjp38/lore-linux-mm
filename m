Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2806B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 05:21:05 -0500 (EST)
Received: by qkcb135 with SMTP id b135so20732053qkc.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 02:21:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 61si22132133qgz.37.2015.12.07.02.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 02:21:04 -0800 (PST)
Date: Mon, 7 Dec 2015 11:20:57 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/2] slab: implement bulk alloc in SLAB allocator
Message-ID: <20151207112057.1566dd5c@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1512041106410.21819@east.gentwo.org>
References: <20151203155600.3589.86568.stgit@firesoul>
	<20151203155637.3589.62609.stgit@firesoul>
	<alpine.DEB.2.20.1512041106410.21819@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Fri, 4 Dec 2015 11:10:05 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 3 Dec 2015, Jesper Dangaard Brouer wrote:
> 
> > +	size_t i;
> > +
> > +	flags &= gfp_allowed_mask;
> > +	lockdep_trace_alloc(flags);
> > +
> > +	if (slab_should_failslab(s, flags))
> > +		return 0;
> 
> Ok here is an overlap with slub;'s pre_alloc_hook() and that stuff is
> really not allocator specific. Could make it generic and move the hook
> calls into slab_common.c/slab.h? That also gives you the opportunity to
> get the array option in there.

Perhaps we could consolidate some code here. (This would also help code
SLAB elimination between slab_alloc_node() and slab_alloc())

A question: SLAB takes the "boot_cache" into account before calling
should_failslab(), but SLUB does not.  Should we also do so for SLUB?

SLAB code:
 static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
 {
	if (unlikely(cachep == kmem_cache))
		return false;

	return should_failslab(cachep->object_size, flags, cachep->flags);
 }



> > +	s = memcg_kmem_get_cache(s, flags);
> > +
> > +	cache_alloc_debugcheck_before(s, flags);
> > +
> > +	local_irq_disable();
> > +	for (i = 0; i < size; i++) {
> > +		void *objp = __do_cache_alloc(s, flags);
> > +
> > +		// this call could be done outside IRQ disabled section
> > +		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);
> > +
> > +		if (unlikely(!objp))
> > +			goto error;
> > +
> > +		prefetchw(objp);
> 
> Is the prefetch really useful here? Only if these objects are immediately
> used I would think.

I primarily have prefetch here because I'm mimicking the behavior of
slab_alloc().  We can remove it here.

 
> > +		p[i] = objp;
> > +	}
> > +	local_irq_enable();
> > +
> > +	/* Kmemleak and kmemcheck outside IRQ disabled section */
> > +	for (i = 0; i < size; i++) {
> > +		void *x = p[i];
> > +
> > +		kmemleak_alloc_recursive(x, s->object_size, 1, s->flags, flags);
> > +		kmemcheck_slab_alloc(s, flags, x, s->object_size);
> > +	}
> > +
> > +	/* Clear memory outside IRQ disabled section */
> > +	if (unlikely(flags & __GFP_ZERO))
> > +		for (i = 0; i < size; i++)
> > +			memset(p[i], 0, s->object_size);
> 
> Maybe make this one loop instead of two?

I kept it two loops to get the advantage of only needing to check the
__GFP_ZERO flag once.  (Plus, in case debugging is enabled, we might get
a small advantage of better instruction and pipeline usage, as erms
memset rep-stos operations flush the CPU pipeline).

I also wrote it this way to make it more obvious what code I want the
compiler to generate.  If no debugging is enabled to top loop should be
compiled out.  If I didn't pullout the flag check, the compiler should
be smart enough to realize this optimization itself, but can only
realize this in case the other code compiles out (case where loops were
combined).  Thus, compiler might already do this optimization, but I'm
making it explicit.


Besides, maybe we can consolidate first loop and replace it with
slab_post_alloc_hook()?


> > +// FIXME: Trace call missing... should we create a bulk variant?
> > +/*  Like:
> > +	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size,
> > s->size, flags); +*/
> 
> That trace call could be created when you do the genericization of the
> hooks() which also involve debugging stuff.

Should we call trace_kmem_cache_alloc() for each object?

Or should we create trace calls that are specific to bulk'ing?
(which would allow us to study/record bulk sizes)

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
