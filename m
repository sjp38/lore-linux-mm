Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA056B0062
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:33:38 -0400 (EDT)
Date: Thu, 25 Jun 2009 06:34:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <20090625043432.GA23949@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090619145913.GA1389@ucw.cz> <1245450449.16880.10.camel@pasglop> <20090619232336.GA2442@elf.ucw.cz> <1245455409.16880.15.camel@pasglop> <20090620002817.GA2524@elf.ucw.cz> <1245463809.16880.18.camel@pasglop> <20090621061847.GB1474@ucw.cz> <1245576665.16880.24.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245576665.16880.24.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pavel Machek <pavel@ucw.cz>, Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 07:31:05PM +1000, Benjamin Herrenschmidt wrote:
> 
> > > Right, that might be something to look into, though we haven't yet
> > > applied the technique for suspend & resume. My main issue with it at the
> > > moment is how do I synchronize with allocations that are already
> > > sleeping when changing the gfp flag mask without bloating the normal
> > 
> > Well, but the problem already exists, no? If someone is already
> > sleeping due to __GFP_WAIT, he'll probably sleep till the resume.
> 
> Yes. In fact, without the masking, a driver that hasn't been suspended
> yet could well start sleeping in GFP_KERNEL after the disk driver has
> suspended. It may do so while holding a mutex or similar, which might
> deadlock its own suspend() callback. It's not something that drivers can
> trivially address by having a pre-suspend hook, and avoid allocations,
> since allocations may be done by subsystems on behalf of the driver or
> such. It's a can of worms, which is why I believe the only sane approach
> is to stop allocators from doing IOs once we start suspend.

Maybe so. Masking off __GFP_WAIT up in slab and page allocator
isn't really needed though (or necessarily a good idea to throw
out that information far from where it is used).

Checking for suspend active and avoiding writeout from reclaim
for example might be a better idea.

 
> So yes, just applying the mask would help, but wouldn't completely fix
> it unless we also find a way to synchronize.

You could potentially use srcu or something like that in page
reclaim in order to have a way to be able to kick everyone
out. page reclaim entry/exit from the page allocator isn't such
a fastpath though, so even a simple mutex or something may be
possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
