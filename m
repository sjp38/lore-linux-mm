Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id BEA0C6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 00:45:39 -0500 (EST)
Received: by qabg40 with SMTP id g40so2193273qab.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:45:38 -0800 (PST)
Date: Wed, 21 Dec 2011 14:45:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
Message-ID: <20111221054531.GB28505@barrios-laptop.redhat.com>
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <1324445481.20505.7.camel@joe2Laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324445481.20505.7.camel@joe2Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 20, 2011 at 09:31:21PM -0800, Joe Perches wrote:
> On Wed, 2011-12-21 at 14:17 +0900, Minchan Kim wrote:
> > We don't like function body which include #ifdef.
> []
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> []
> > @@ -505,6 +505,7 @@ static void unmap_vmap_area(struct vmap_area *va)
> >  	vunmap_page_range(va->va_start, va->va_end);
> >  }
> >  
> > +#ifdef CONFIG_DEBUG_PAGEALLOC
> >  static void vmap_debug_free_range(unsigned long start, unsigned long end)
> >  {
> >  	/*
> > @@ -520,11 +521,15 @@ static void vmap_debug_free_range(unsigned long start, unsigned long end)
> >  	 * debugging doesn't do a broadcast TLB flush so it is a lot
> >  	 * faster).
> >  	 */
> > -#ifdef CONFIG_DEBUG_PAGEALLOC
> >  	vunmap_page_range(start, end);
> >  	flush_tlb_kernel_range(start, end);
> > -#endif
> >  }
> > +#else
> > +static inline void vmap_debug_free_range(unsigned long start,
> > +					unsigned long end)
> > +{
> > +}
> > +#endif
> 
> I don't like this change.
> I think it's perfectly good style to use:

I feel it's no problem as it is because it's very short function now
but it's not style we prefer. 

> 
> 1	void foo(args...)
> 2	{
> 3	#ifdef CONFIG_FOO
> 4		...
> 5	#endif
> 6	}
> 
> instead of
> 
> 1	#ifdef CONFIG_FOO
> 2	void foo(args...)
> 3	{
> 4		...
> 5	}
> 6	#else
> 7	void foo(args...)
> 8	{
> 9	}
> 10	#endif
> 
> The first version is shorter and gcc optimizes
> away the void func just fine.  It also means

Agree but if function would be long(but I convice
it's not long in future :)), it would be messy.

> that 2 function prototypes don't need to be
> kept in agreement when someone changes one
> without testing CONFIG_FOO=y and CONFIG_FOO=n.

The goal is not for making test easily.
Patch author should keep it consistent.

This patch is just trivial so I don't mind if who have
against this patch strongly. What I want to say is 
it's not style we prefer. 

> 
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
