Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BFD786B0055
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 12:45:55 -0400 (EDT)
Date: Fri, 19 Jun 2009 18:43:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] bootmem.c: Avoid c90 declaration warning
Message-ID: <20090619164359.GA2265@cmpxchg.org>
References: <1245355633.29927.16.camel@Joe-Laptop.home> <20090618132410.0b55cd90.akpm@linux-foundation.org> <20090618215744.GA10816@cmpxchg.org> <4A3ADB33.8060102@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A3ADB33.8060102@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 05:26:27PM -0700, Yinghai Lu wrote:
> Johannes Weiner wrote:
> > On Thu, Jun 18, 2009 at 01:24:10PM -0700, Andrew Morton wrote:
> >> Unrelatedly, I'm struggling a bit with bootmem_arch_preferred_node(). 
> >> It's only defined if CONFIG_X86_32=y && CONFIG_NEED_MULTIPLE_NODES=y,
> >> but it gets called if CONFIG_HAVE_ARCH_BOOTMEM=y.
> >>
> >> Is this correct, logical and as simple as we can make it??
> > 
> > x86_32 numa is the only setter of HAVE_ARCH_BOOTMEM.  I don't know why
> > this arch has a strict preference/requirement(?) for bootmem on node
> > 0.
> > 
> > I found this mail from Yinghai
> > 
> >   http://marc.info/?l=linux-kernel&m=123614990906256&w=2
> > 
> > where he says that it expects all bootmem on node zero but with the
> > current code and alloc_arch_preferred_bootmem() failing, we could fall
> > back to another node.  Won't this break?  Yinghai?
> 
> not sure it is the same problem. the fix was in mainline already.

I just wanted to know if the requirement for bootmem on node 0 is
strict or just a preference.  Do you perhaps happen to know? :)

> > Otherwise, could we perhaps use something as simple as this?
> > 
> > diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
> > index ede6998..b68a672 100644
> > --- a/arch/x86/include/asm/mmzone_32.h
> > +++ b/arch/x86/include/asm/mmzone_32.h
> > @@ -92,8 +92,7 @@ static inline int pfn_valid(int pfn)
> >  
> >  #ifdef CONFIG_NEED_MULTIPLE_NODES
> >  /* always use node 0 for bootmem on this numa platform */
> > -#define bootmem_arch_preferred_node(__bdata, size, align, goal, limit)	\
> > -	(NODE_DATA(0)->bdata)
> > +#define bootmem_arch_preferred_node (NODE(0)->bdata)
> >  #endif /* CONFIG_NEED_MULTIPLE_NODES */
> >  
> >  #endif /* _ASM_X86_MMZONE_32_H */
> > diff --git a/mm/bootmem.c b/mm/bootmem.c
> > index 282df0a..0097fa2 100644
> > --- a/mm/bootmem.c
> > +++ b/mm/bootmem.c
> > @@ -528,23 +528,6 @@ find_block:
> >  	return NULL;
> >  }
> >  
> > -static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
> > -					unsigned long size, unsigned long align,
> > -					unsigned long goal, unsigned long limit)
> > -{
> > -	if (WARN_ON_ONCE(slab_is_available()))
> > -		return kzalloc(size, GFP_NOWAIT);
> > -
> > -#ifdef CONFIG_HAVE_ARCH_BOOTMEM
> > -	bootmem_data_t *p_bdata;
> > -
> > -	p_bdata = bootmem_arch_preferred_node(bdata, size, align, goal, limit);
> > -	if (p_bdata)
> > -		return alloc_bootmem_core(p_bdata, size, align, goal, limit);
> > -#endif
> > -	return NULL;
> > -}
> > -
> >  static void * __init ___alloc_bootmem_nopanic(unsigned long size,
> >  					unsigned long align,
> >  					unsigned long goal,
> > @@ -553,11 +536,15 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
> >  	bootmem_data_t *bdata;
> >  	void *region;
> >  
> > +	if (WARN_ON_ONCE(slab_is_available()))
> > +		return kzalloc(size, GFP_NOWAIT);
> >  restart:
> > -	region = alloc_arch_preferred_bootmem(NULL, size, align, goal, limit);
> > +#ifdef bootmem_arch_preferred_node
> > +	region = alloc_bootmem_core(bootmem_arch_preferred_node,
> > +				size, align, goal, limit);
> >  	if (region)
> >  		return region;
> > -
> > +#endif
> >  	list_for_each_entry(bdata, &bdata_list, list) {
> >  		if (goal && bdata->node_low_pfn <= PFN_DOWN(goal))
> >  			continue;
> > @@ -636,13 +623,11 @@ static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
> >  {
> >  	void *ptr;
> >  
> > -	ptr = alloc_arch_preferred_bootmem(bdata, size, align, goal, limit);
> > -	if (ptr)
> > -		return ptr;
> > -
> > +#ifndef bootmem_arch_preferred_node
> >  	ptr = alloc_bootmem_core(bdata, size, align, goal, limit);
> >  	if (ptr)
> >  		return ptr;
> > +#endif
> >  
> >  	return ___alloc_bootmem(size, align, goal, limit);
> >  }
> 
> 
> any reason to kill alloc_arch_preferred_bootmem?

Yeah, I think the diffstat is convincing hehe.  And I think it looks
more straight forward, but no strong feelings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
