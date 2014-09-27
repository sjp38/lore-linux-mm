Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABB46B0038
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 05:56:45 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id z2so768811wiv.8
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 02:56:45 -0700 (PDT)
Received: from cpsmtpb-ews06.kpnxchange.com (cpsmtpb-ews06.kpnxchange.com. [213.75.39.9])
        by mx.google.com with ESMTP id az10si5527245wib.11.2014.09.27.02.56.44
        for <linux-mm@kvack.org>;
        Sat, 27 Sep 2014 02:56:44 -0700 (PDT)
Message-ID: <1411811803.15241.50.camel@x220>
Subject: Re: [PATCH] mm/slab: use IS_ENABLED() instead of ZONE_DMA_FLAG
From: Paul Bolle <pebolle@tiscali.nl>
Date: Sat, 27 Sep 2014 11:56:43 +0200
In-Reply-To: <20140925185047.GA21089@cmpxchg.org>
References: <1411667851.2020.6.camel@x41>
	 <20140925185047.GA21089@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Johannes,

On Thu, 2014-09-25 at 14:50 -0400, Johannes Weiner wrote:
> On Thu, Sep 25, 2014 at 07:57:31PM +0200, Paul Bolle wrote:
> > The Kconfig symbol ZONE_DMA_FLAG probably predates the introduction of
> > IS_ENABLED(). Remove it and replace its two uses with the equivalent
> > IS_ENABLED(CONFIG_ZONE_DMA).
> > 
> > Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> > ---
> > Build tested on x86_64 (on top of next-20140925).
> > 
> > Run tested on i686 (on top of v3.17-rc6). That test required me to
> > switch from SLUB (Fedora's default) to SLAB. That makes running this
> > patch both more scary and less informative. Besides, I have no idea how
> > to hit the codepaths I just changed. You'd expect this to not actually
> > change slab.o, but I'm not sure how to check that. So, in short: review
> > very much appreciated.
> > 
> >  mm/Kconfig | 5 -----
> >  mm/slab.c  | 4 ++--
> >  2 files changed, 2 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 886db21..8e860c7 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -273,11 +273,6 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
> >  config PHYS_ADDR_T_64BIT
> >  	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
> >  
> > -config ZONE_DMA_FLAG
> > -	int
> > -	default "0" if !ZONE_DMA
> > -	default "1"
> > -
> >  config BOUNCE
> >  	bool "Enable bounce buffers"
> >  	default y
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 628f2b5..766c90e 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -2243,7 +2243,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
> >  	cachep->freelist_size = freelist_size;
> >  	cachep->flags = flags;
> >  	cachep->allocflags = __GFP_COMP;
> > -	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
> > +	if (IS_ENABLED(CONFIG_ZONE_DMA) && (flags & SLAB_CACHE_DMA))
> >  		cachep->allocflags |= GFP_DMA;
> 
> GFP_DMA is actually safe to use even without CONFIG_ZONE_DMA, so you
> only need to check for SLAB_CACHE_DMA here.
> 
> > @@ -2516,7 +2516,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
> >  
> >  static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
> >  {
> > -	if (CONFIG_ZONE_DMA_FLAG) {
> > +	if (IS_ENABLED(CONFIG_ZONE_DMA)) {
> >  		if (flags & GFP_DMA)
> >  			BUG_ON(!(cachep->allocflags & GFP_DMA));
> >  		else
> 
> I think this assertion can be removed altogether and replaced by ORing
> the passed in flags with the cache gfp flags.  The page allocator will
> catch any contradictions, but the 3 callsites that actually do use DMA
> caches are well-behaved as of now.

Do your comments require the patch to be redone (partially or entirely)?
In that case someone else should probably take it and improve it, as I
hardly understand the issues you raise. Or is the patch already queued
somewhere, with Cristoph's Ack attached?

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
