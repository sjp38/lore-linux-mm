Date: Wed, 14 Jun 2000 14:33:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006141858500.15011-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006141424350.6887-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> On Wed, 14 Jun 2000, Rik van Riel wrote:
> >On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> >> On Wed, 14 Jun 2000, Rik van Riel wrote:
> >> 
> >> >So if the ZONE_DMA is filled by mlock()ed memory, classzone
> >> >will *not* try to balance it? Will classzone *only* try to
> >> 
> >> It will try but it won't succeed.
> >> 
> >> >balance the big classzone containing zone_dma, and not the
> >> >dma zone itself?  (since the dma zone doesn't contain any
> >> 
> >> No, I definitely try to balance the DMA zone itself. But in such
> >> case (all DMA zone mlocked) kswapd will just spend CPU trying to
> >> balance the zone but it _can't_ succeed because mlocked just
> >> means we can't even attempt to move such memory elsewhere in the
> >> physical space or we'll break userspace critical latency needs.
> >
> >I fully agree with this, this is the obviously right thing to
> 
> Ok. [1]

Ermmm, I mean that trying to _balance_ the zone is the right
thing to do. Consuming infinite CPU time when we can't succeed
is a clear bug we want to fix.

> >do. Would you be surprised to know that the code in the last
> >2.4.0-ac kernels does exactly this?
> 
> I'm not surprised. I know what the current code does and infact
> I didn't took that case as the testcase. That was _your_
> testcase that you invented changing the text of the problem in
> something that is handled correctly by the current code and I'm
> not interested about it (as far as the kernel continues to
> handle it correctly as now ;).
> 
> _My_ testcase (first mlocked and then cache) is instead handled
> wrong by the latest kernels and that's the only thing I'm
> interested about at this moment.

The only difference between your test case and my test case
is that the allocations happen in another order.

In most cases _both_ classzone and the zoned VM will break
down horribly, only when the allocations happen in the lucky
order of your example will classzone deal with the situation
better than the normal kernel.

> >So classzone and the normal zoned VM behave in the same way here
> >except that classzone doesn't show the bad effects when the
> >allocations happen in a certain lucky order.
> >
> >I think the differences between classzone and the zoned vm are
> >pretty small at this moment, with most of classzone's benefits
> >being theoretical ones that rely on memory zones being inclusive
> >rather than numa-like...
> 
> You got it. Exactly.
> 
> However don't mix numa with the internal of a node. We have the
> pgdat and each one is a node in a NUMA system. All the zones
> internal to a pgdat have to belong to the some node or it will
> become impossible to shrink cache only from one zone and to do
> smart decisions in NUMA systems.

I'll send you the POWER4 document I have here so you can
see what I meant. This machine will be somewhere halfway
between NUMA and SMP ... having non-inclusive zones in the
same node seems to make quite a lot of sense in that
architecture.

And since the behaviour of classzone and normal zoned vm
is just about the same, I'd really like it if we chose the
more generic abstraction here.

> >Owww, so classzone kswapd will get into an infinite loop with
> >the disaster scenario too?
> 
> Yes. If I understood well from the first line of your email you
> agree that's the right behaviour (see [1]). Since in the
> disaster scenario the ZONE_DMA classzone is low on memory kswapd
> will continue to spend CPU to try to free some page there.

Nono. As I corrected above, I think it is good that we try to
balance the zone, but we shouldn't do so in an infinite loop ;)

I'll prepare a bugfix for both potential infinite loops in
2.4.0-ac18 right now...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
