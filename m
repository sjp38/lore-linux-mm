Date: Tue, 25 Jan 2000 01:01:34 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: GFP_XXX semantics (was: Re: [PATCH] 2.2.1{3,4,5} VM fix)
In-Reply-To: <Pine.LNX.4.10.10001241428440.11695-100000@Wotan.suse.de>
Message-ID: <Pine.LNX.4.10.10001250053470.467-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2000, Andrea Arcangeli wrote:

> >GFP_KERNEL
> 
> GFP kernel should be used for all normal kernel allocations where you can
> sleep.
> 
> >GFP_NFS
> 
> Equal to GFP_KERNEL but supposed to have more priority (actually they have
> the same prio).

Do I smell a deadlock here? :)

HINT: deadlocks of this kind have been observed in 2.2.13
and 2.2.14. GFP_KERNEL allocations had eaten into the last
free pages (below freepages.min) and seriously confused
some algorithms that depend on the emergency pages.

(yeah, I know that's broken but it's all we've got)

> I understood that the argument for the 2.2.15pre4 differences is
> that they want to disallow GFP_BUFFER and GFP_KERNEL to eat all
> the free memory to left such memory for the PF_MEMALLOC path.

Indeed. If you cannot rely on PF_MEMALLOC any more, you're
bust.

> But the whole point is that during the PF_MEMALLOC path everybody
> can ping flood the machine and eat such last memory from
> interrupts anyway (or GFP_NFS could be used as well).

Of course it can. Now think about likelyhood...

> If the machine deadlocks inside the PG_MEMALLOC path that's plain
> a bug in the PF_MEMALLOC path and not something that can be fixed
> inside GFP in any way.

Indeed, the real solution is to fix the buggy code.

> And during OOM it make sense to me that we allow the system to use
> the last memory available (unless it's an USER allocation that we
> want to kill immediatly before nr_free_pages goes to zero so we'll
> have more changes that the kernel-stuff won't be affected by the
> temporary memory shortage).

I'm now running my system (and NL.linux.org) with a
temporary kludge. I only allow __GFP_MED allocations
to eat into the first half of freepages.min.

I hope this will (for now) avoid the worst crashes
from both sides. Again, this is not the solution. We
should search for the buggy code and try to fix as
much as possible before 2.2.15...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
