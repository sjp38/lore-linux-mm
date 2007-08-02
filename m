Date: Thu, 2 Aug 2007 03:36:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070802013631.GA15595@wotan.suse.de>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de> <46B0C8A3.8090506@mbligh.org> <1185993169.5059.79.camel@localhost> <46B10E9B.2030907@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46B10E9B.2030907@mbligh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 03:52:11PM -0700, Martin Bligh wrote:
> 
> >And so forth.  Initial forks will balance.  If the children refuse to
> >die, forks will continue to balance.  If the parent starts seeing short
> >lived children, fork()s will eventually start to stay local.  
> 
> Fork without exec is much more rare than without. Optimising for
> the uncommon case is the Wrong Thing to Do (tm). What we decided

It's only the wrong thing to do if it hurts the common case too
much. Considering we _already_ balance on exec, then adding another
balance on fork is not going to introduce some order of magnitude
problem -- at worst it would be 2x but it really isn't too slow
anyway (at least nobody complained when we added it).

One place where we found it helps is clone for threads.

If we didn't do such a bad job at keeping tasks together with their
local memory, then we might indeed reduce some of the balance-on-crap
and increase the aggressiveness of periodic balancing.

Considering we _already_ balance on fork/clone, I don't know what
your argument is against this patch is? Doing the balance earlier
and allocating more stuff on the local node is surely not a bad
idea.


> the last time(s) this came up was to allow userspace to pass
> a hint in if they wanted to fork and not exec.
> 
> >I believe that this solved the pathological behavior we were seeing with
> >shell scripts taking way longer on the larger, supposedly more powerful,
> >platforms.
> >
> >Of course, that OS could migrate the equivalent of task structs and
> >kernel stack [the old Unix user struct that was traditionally swappable,
> >so fairly easy to migrate].  On Linux, all bets are off, once the
> >scheduler starts migrating tasks away from the node that contains their
> >task struct, ...  [Remember Eric Focht's "NUMA Affine Scheduler" patch
> >with it's "home node"?]
> 
> Task migration doesn't work well at all without userspace hints.
> SGI tried for ages (with IRIX) and failed. There's long discussions
> of all of these things back in the days when we merged the original
> NUMA scheduler in late 2.5 ...

Task migration? Automatic memory migration you mean? I think it deserves
another look regardless of what SGI could or could not do, and Lee and I
are slowly getting things in place. We'll see what happens...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
