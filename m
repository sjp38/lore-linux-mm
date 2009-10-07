Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D50266B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 08:08:30 -0400 (EDT)
Date: Wed, 7 Oct 2009 13:08:17 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc()  invocation
In-Reply-To: <4ACC62DC0200007800018690@vpn.id2.novell.com>
Message-ID: <Pine.LNX.4.64.0910071300330.28844@sister.anvils>
References: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
 <Pine.LNX.4.64.0910062241500.21409@sister.anvils> <4ACC62DC0200007800018690@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Oct 2009, Jan Beulich wrote:
> >>> Hugh Dickins <hugh.dickins@tiscali.co.uk> 06.10.09 23:58 >>>
> >On Mon, 5 Oct 2009, Jan Beulich wrote:
> >
> >> - fix a latent bug resulting from blindly or-ing in __GFP_ZERO, since
> >>   the combination of this and __GFP_HIGHMEM (possibly passed into the
> >>   function) is forbidden in interrupt context
> >> - avoid wasting more precious resources (DMA or DMA32 pools), when
> >>   being called through vmalloc_32{,_user}()
> >> - explicitly allow using high memory here even if the outer allocation
> >>   request doesn't allow it, unless is collides with __GFP_ZERO
> >> 
> >> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> >
> >I thought vmalloc.c was a BUG_ON(in_interrupt()) zone?
> >The locking is all spin_lock stuff, not spin_lock_irq stuff.
> >That's probably why your "bug" has remained "latent".
> 
> Then you probably mean BUG_ON(irqs_disabled()), which would seem
> correct.

I'm relieved you came to see that remark as bogus.

> But if the gfp mask massaging was needed for calling kmalloc(),
> it would seem odd that the same shouldn't be needed for calling
> vmalloc() recursively...
> 
> >Using HIGHMEM for internal arrays looks reasonable to me; but if
> >__GFP_ZERO were a problem, wouldn't it be much cleaner to skip the
> >"unless it collides" and #ifdef CONFIG_HIGHMEM !in_interrupt() stuff,
> >just memset the array returned from __vmalloc_node()?
> 
> The main goal was to change the existing code as little as possible - I
> did consider this alternative, but wasn't sure that would be accepted.
> If you view this as the better alternative, I'll certainly modify the
> patch to do it that way.

Well, now we've accepted that this code cannot be used in_interrupt(),
there's no need for your #ifdef CONFIG_HIGHMEM nor for my memset: just
use __GFP_ZERO as it was before, and your patch would amount to or'ing
__GFP_HIGHMEM into gfp_mask for the __vmalloc_node case - wouldn't it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
