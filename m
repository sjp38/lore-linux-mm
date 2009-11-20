Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5926B00C2
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 10:09:17 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4B067816.6070304@cs.helsinki.fi>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 20 Nov 2009 16:09:08 +0100
Message-ID: <1258729748.4104.223.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-11-20 at 13:05 +0200, Pekka Enberg wrote:
> Peter Zijlstra kirjoitti:
> > On Fri, 2009-11-20 at 12:38 +0200, Pekka Enberg wrote:
> >>
> >> On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >>>  2) propagate the nesting information and user spin_lock_nested(), given
> >>> that slab is already a rat's nest, this won't make it any less obvious.
> >> spin_lock_nested() doesn't really help us here because there's a
> >> _real_ possibility of a recursive spin lock here, right? 
> > 
> > Well, I was working under the assumption that your analysis of it being
> > a false positive was right ;-)
> > 
> > I briefly tried to verify that, but got lost and gave up, at which point
> > I started looking for ways to annotate.
> 
> Uh, ok, so apparently I was right after all. There's a comment in 
> free_block() above the slab_destroy() call that refers to the comment 
> above alloc_slabmgmt() function definition which explains it all.
> 
> Long story short: ->slab_cachep never points to the same kmalloc cache 
> we're allocating or freeing from. Where do we need to put the 
> spin_lock_nested() annotation? Would it be enough to just use it in 
> cache_free_alien() for alien->lock or do we need it in 
> cache_flusharray() as well?

You'd have to somehow push the nested state down from the
kmem_cache_free() call in slab_destroy() to all nc->lock sites below.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
