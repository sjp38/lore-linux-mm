Date: Tue, 8 Aug 2000 12:21:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM 
In-Reply-To: <200008080048.RAA13326@eng2.sequent.com>
Message-ID: <Pine.LNX.4.21.0008081216090.5200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: chucklever@bigfoot.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Aug 2000 Gerrit.Huizenga@us.ibm.com wrote:
> > On Mon, 7 Aug 2000, Rik van Riel wrote:
> > The idea is that the memory_pressure variable indicates how
> > much page stealing is going on (on average) so every time
> > kswapd wakes up it knows how much pages to steal. That way
> > it should (if we're "lucky") free enough pages to get us
> > along until the next time kswapd wakes up.
>  
>  Seems like you could signal kswapd when either the page fault
>  rate increases or the rate of (memory allocations / memory
>  frees) hits a tuneable? ratio

We will. Each page steal and each allocation will increase
the memory_pressure variable, and because of that, also the
inactive_target.

Whenever either 
- one zone gets low on free memory *OR* 
- all zones get more or less low on free+inactive_clean pages *OR*
- we get low on inactive pages (inactive_shortage > inactive_target/2),
THEN kswapd gets woken up immediately.

We do this both from the page allocation code and from
__find_page_nolock (which gets hit every time we reclaim
an inactive page back for its original purpose).

> > About NUMA scalability: we'll have different memory pools
> > per NUMA node. So if you have a 32-node, 64GB NUMA machine,
> > it'll partly function like 32 independant 2GB machines.
>  
>  One lesson we learned early on is that anything you can
>  possibly do on a per-CPU basis helps both SMP and NUMA
>  activity.  This includes memory management, scheduling,
>  TCP performance counters, any kind of system counters, etc.
>  Once you have the basic SMP hierarchy in place, adding a NUMA
>  hierarchy (or more than one for architectures that need it)
>  is much easier.
> 
>  Also, is there a kswapd per pool?  Or does one kswapd oversee
>  all of the pools (in the NUMA world, that is)?

Currently we have none of this, but once 2.5 is forked
off, I'll submit a patch which shuffles all variables
into per-node (per pgdat) structures.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
