Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 13F116B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 21:11:15 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KG900I66NAO1240@VL-MH-MR002.ip.videotron.ca> for
 linux-mm@kvack.org; Mon, 09 Mar 2009 21:11:14 -0400 (EDT)
Date: Mon, 09 Mar 2009 21:11:12 -0400 (EDT)
From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] atomic highmem kmap page pinning
In-reply-to: <20090309133121.eab3bbd9.akpm@linux-foundation.org>
Message-id: <alpine.LFD.2.00.0903092107240.30483@xanadu.home>
References: <alpine.LFD.2.00.0903071731120.30483@xanadu.home>
 <20090309133121.eab3bbd9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, minchan.kim@gmail.com, linux@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Mon, 9 Mar 2009, Andrew Morton wrote:

> On Sat, 07 Mar 2009 17:42:44 -0500 (EST)
> Nicolas Pitre <nico@cam.org> wrote:
> 
> > 
> > Discussion about this patch is settling, so I'd like to know if there 
> > are more comments, or if official ACKs could be provided.  If people 
> > agree I'd like to carry this patch in my ARM highmem patch series since 
> > a couple things depend on this.
> > 
> > Andrew: You seemed OK with the original one.  Does this one pass your 
> > grottiness test?
> > 
> > Anyone else?
> 
> OK by me.

Thanks.

> > +/*
> > + * Most architectures have no use for kmap_high_get(), so let's abstract
> > + * the disabling of IRQ out of the locking in that case to save on a
> > + * potential useless overhead.
> > + */
> > +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> > +#define spin_lock_kmap()             spin_lock_irq(&kmap_lock)
> > +#define spin_unlock_kmap()           spin_unlock_irq(&kmap_lock)
> > +#define spin_lock_kmap_any(flags)    spin_lock_irqsave(&kmap_lock, flags)
> > +#define spin_unlock_kmap_any(flags)  spin_unlock_irqrestore(&kmap_lock, flags)
> > +#else
> > +#define spin_lock_kmap()             spin_lock(&kmap_lock)
> > +#define spin_unlock_kmap()           spin_unlock(&kmap_lock)
> > +#define spin_lock_kmap_any(flags)    \
> > +	do { spin_lock(&kmap_lock); (void)(flags); } while (0)
> > +#define spin_unlock_kmap_any(flags)  \
> > +	do { spin_unlock(&kmap_lock); (void)(flags); } while (0)
> > +#endif
> 
> It's a little bit misleading to discover that a "function" called
> spin_lock_kmap() secretly does an irq_disable().  Perhaps just remove
> the "spin_" from all these identifiers?

OK, done.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
