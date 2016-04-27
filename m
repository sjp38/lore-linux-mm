Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A65BB6B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 20:55:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so61833371pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:55:11 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id kx15si1868680pab.97.2016.04.26.17.55.10
        for <linux-mm@kvack.org>;
        Tue, 26 Apr 2016 17:55:10 -0700 (PDT)
Date: Wed, 27 Apr 2016 09:55:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4] mm: SLAB freelist randomization
Message-ID: <20160427005505.GA6336@js1304-P5Q-DELUXE>
References: <1461687670-47585-1-git-send-email-thgarnie@google.com>
 <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Garnier <thgarnie@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Kees Cook <keescook@chromium.org>, gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 26, 2016 at 04:17:43PM -0700, Andrew Morton wrote:
> On Tue, 26 Apr 2016 09:21:10 -0700 Thomas Garnier <thgarnie@google.com> wrote:
> 
> > Provides an optional config (CONFIG_FREELIST_RANDOM) to randomize the
> > SLAB freelist. The list is randomized during initialization of a new set
> > of pages. The order on different freelist sizes is pre-computed at boot
> > for performance. Each kmem_cache has its own randomized freelist. Before
> > pre-computed lists are available freelists are generated
> > dynamically. This security feature reduces the predictability of the
> > kernel SLAB allocator against heap overflows rendering attacks much less
> > stable.
> > 
> > For example this attack against SLUB (also applicable against SLAB)
> > would be affected:
> > https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/
> > 
> > Also, since v4.6 the freelist was moved at the end of the SLAB. It means
> > a controllable heap is opened to new attacks not yet publicly discussed.
> > A kernel heap overflow can be transformed to multiple use-after-free.
> > This feature makes this type of attack harder too.
> > 
> > To generate entropy, we use get_random_bytes_arch because 0 bits of
> > entropy is available in the boot stage. In the worse case this function
> > will fallback to the get_random_bytes sub API. We also generate a shift
> > random number to shift pre-computed freelist for each new set of pages.
> > 
> > The config option name is not specific to the SLAB as this approach will
> > be extended to other allocators like SLUB.
> > 
> > Performance results highlighted no major changes:
> > 
> > Hackbench (running 90 10 times):
> > 
> > Before average: 0.0698
> > After average: 0.0663 (-5.01%)
> > 
> > slab_test 1 run on boot. Difference only seen on the 2048 size test
> > being the worse case scenario covered by freelist randomization. New
> > slab pages are constantly being created on the 10000 allocations.
> > Variance should be mainly due to getting new pages every few
> > allocations.
> > 
> > ...
> >
> > --- a/include/linux/slab_def.h
> > +++ b/include/linux/slab_def.h
> > @@ -80,6 +80,10 @@ struct kmem_cache {
> >  	struct kasan_cache kasan_info;
> >  #endif
> >  
> > +#ifdef CONFIG_FREELIST_RANDOM
> > +	void *random_seq;
> > +#endif
> > +
> >  	struct kmem_cache_node *node[MAX_NUMNODES];
> >  };
> >  
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 0c66640..73453d0 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -1742,6 +1742,15 @@ config SLOB
> >  
> >  endchoice
> >  
> > +config FREELIST_RANDOM
> > +	default n
> > +	depends on SLAB
> > +	bool "SLAB freelist randomization"
> > +	help
> > +	  Randomizes the freelist order used on creating new SLABs. This
> > +	  security feature reduces the predictability of the kernel slab
> > +	  allocator against heap overflows.
> 
> Against the v2 patch I didst observe:
> 
> : CONFIG_FREELIST_RANDOM bugs me a bit - "freelist" is so vague.
> : CONFIG_SLAB_FREELIST_RANDOM would be better.  I mean, what Kconfig
> : identifier could be used for implementing randomisation in
> : slub/slob/etc once CONFIG_FREELIST_RANDOM is used up?
> 
> but this pearl appeared to pass unnoticed.
> 
> >  config SLUB_CPU_PARTIAL
> >  	default y
> >  	depends on SLUB && SMP
> > diff --git a/mm/slab.c b/mm/slab.c
> > index b82ee6b..0ed728a 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -1230,6 +1230,61 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
> >  	}
> >  }
> >  
> > +#ifdef CONFIG_FREELIST_RANDOM
> > +static void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
> > +			size_t count)
> > +{
> > +	size_t i;
> > +	unsigned int rand;
> > +
> > +	for (i = 0; i < count; i++)
> > +		list[i] = i;
> > +
> > +	/* Fisher-Yates shuffle */
> > +	for (i = count - 1; i > 0; i--) {
> > +		rand = prandom_u32_state(state);
> > +		rand %= (i + 1);
> > +		swap(list[i], list[rand]);
> > +	}
> > +}
> > +
> > +/* Create a random sequence per cache */
> > +static int cache_random_seq_create(struct kmem_cache *cachep)
> > +{
> > +	unsigned int seed, count = cachep->num;
> > +	struct rnd_state state;
> > +
> > +	if (count < 2)
> > +		return 0;
> > +
> > +	/* If it fails, we will just use the global lists */
> > +	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
> > +	if (!cachep->random_seq)
> > +		return -ENOMEM;
> 
> OK, no BUG.  If this happens, kmem_cache_init_late() will go BUG
> instead ;)
> 
> Questions for slab maintainers:
> 
> What's going on with the gfp_flags in there?  kmem_cache_init_late()
> passes GFP_NOWAIT into enable_cpucache().
> 
> a) why the heck does it do that?  It's __init code!

Until some boot-up point, we should not enable interrupt.
In slab subsystem, If we use __GFP_DIRECT_RECLAIM, it will cause to
enable interrupt when allocating new slab page. GFP_NOWAIT is to
prevent that situation.

Anyway, I audit the code and kmem_cache_init_late() could use
__GFP_DIRECT_RECLAIM because it is called after interrupt is enabled
which means that that's safe time to manipulate interrupt. (See
kmem_cache_init_late() in start_kernel()).

> 
> b) if there's a legit reason then your new cache_random_seq_create()
> should be getting its gfp_t from its caller, rather than blindly
> assuming GFP_KERNEL.

In any case, ignoring provided gfp argument isn't good practice.

> c) kmem_cache_init_late() goes BUG on ENOMEM.  Generally that's OK in
> __init code: we assume infinite memory during bootup.  But it's really
> quite weird to use GFP_NOWAIT and then to go BUG if GFP_NOWAIT had its
> predictable outcome (ie: failure).

I don't think BUG() here is weird code. It just means that if we can't
initialize slab subsystem properly, machine cannot run properly so
BUG().

> Finally, all callers of enable_cpucache() (and hence of
> cache_random_seq_create()) are __init, so we're unnecessarily bloating
> up vmlinux.  Could someone please take a look at this as a separate
> thing?

That's not true. It is called whenever new kmem_cache is created.
I don't know concrete reason why setup_cpu_cache() is defined with
__init_refok tag but looks like it needs to be fixed.

I will look at it soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
