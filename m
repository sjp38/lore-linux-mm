Message-ID: <3B0238EB.DF435099@mindspring.com>
Date: Wed, 16 May 2001 01:23:07 -0700
From: Terry Lambert <tlambert2@mindspring.com>
Reply-To: tlambert2@mindspring.com
MIME-Version: 1.0
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva> <3B00CECF.9A3DEEFA@mindspring.com> <200105151724.f4FHOYt54576@earth.backplane.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

Matt Dillon wrote:
> :> So we should not allow just one single large job to take all
> :> of memory, but we should allow some small jobs in memory too.
> :
> :Historically, this problem is solved with a "working set
> :quota".
> 
>     We have a process-wide working set quota.  It's called
>     the 'memoryuse' resource.

It's not terrifically useful for limiting pageout as a
result of excessive demand pagein operations.


> :A per vnode working set quota with a per use count adjust
> :would resolve most load thrashing issues.  Programs with
> 
>     It most certainly would not.  Limiting the number of pages
>     you allow to be 'cached' on a vnode by vnode basis would
>     be a disaster.

I don't know whether to believe you, or Dave Cutler... 8-).


>     It has absolutely nothing whatsoever to do with thrashing
>     or thrash-management.  It would simply be an artificial
>     limitation based on artificial assumptions that are as
>     likely to be wrong as right.

I have a lot of problems with most of FreeBSD's anti-thrash
"protection"; I don't think many people are really running
it at a very high load.

I think a lot of the "administrative limits" are stupid;
in particular, I think it's really dumb to have 70% free
resources, and yet enforce administrative limits as if all
machines were shell account servers at an ISP where the
customers are just waiting for the operators to turn their
heads for a second so they can run 10,000 IRC "bots".

I also have a problem with the preallocation of contiguous
pageable regions of real memory via zalloci() in order to
support inpcb and tcpcb structures, which inherently mean
that I have to statically preallocate structures for IPs,
TCP structures, and sockets, as well as things like file
descriptors.   In other words, I have to guess the future
characteristics of my load, rather than having the OS do
the best it can in any given situation.

Not to mention the allocation of an entire mbuf per socket.


>     If I've learned anything working on the FreeBSD VM
>     system, it's that the number of assumptions you make
>     in regards to what programs do, how they do it, how
>     much data they should be able to cache, and so forth
>     is directly proportional to how badly you fuck up the
>     paging algorithms.

I've personally experienced thrash from a moronic method
of implementing "ld", which mmap's all the .o files, and
then seeks all over heck, randomly, in order to perform
the actual link.  It makes that specific operation very
fast, at the expense of the rest of the system.

The result of this is that everything else on the system
gets thrashed out of core, including the X server, and the
very simple and intuitive "move mouse, wiggle cursor"
breaks, which then breaks the entire paradigm.

FreeBSD is succeptible to this problem.  So was SVR4 UNIX.

The way SVR4 "repaired" the problem was to invent a new
scheduling class, "fixed", which would guarantee time
slices to the X server.  Thus, as fast as "ld" thrashed
pages it wasn't interested in out, "X" thrashed them
back in.  The interactive experience was degraded by the
excessive paging.

I implemented a different approach in UnixWare 2.x; it
didn't end up making it into the main UnixWare source tree
(I was barely able to get my /procfs based rfork() into
the thing, with the help of some good engineers from NJ);
but it was a per vnode working set quota approach.  It
operated in much the way I described, and it fixed the
problem: the only program that got thrashed by "ld" was
"ld": everything else on the system had LRU pages present
when the needed to run.  The "ld" program wasn't affected
itself until you started running low on buffer cache.

IMO, anything that results in the majority of programs
remaining reasonably runnable, and penalizes only the
programs making life hell for everyone else, and only
kicks in when life is truly starting to go to hell, is a
good approach.  I really don't care that I got the idea
from Dave Cutler's work in VMS, instead of arriving at
it on my own (those the per-vnode nature of mine is, I
think, an historically unique approach).


>     I implemented a special page-recycling algorithm in
>     4.1/4.2 (which is still there in 4.3).  Basically it
>     tries predict when it is possible to throw away pages
>     'behind' a sequentially accessed file, so as not to
>     allow that file to blow away your cache.  E.G. if you
>     have 128M of ram and you are sequentially accessing a
>     200MB file, obviously there is not much point in trying
>     to cache the data as you read it.

IMO, the ability to stream data like this is why Sun, in
Solaris 2.8, felt the need to "invent" seperate VM and
buffer caches once again -- "everything old is new again".

Also, IMO, I feel that the rationale used to justify this
decision was poorly defended, and that there are much
better implementations one could have -- including simple
red queueing for large data sets.  It was a cop out on
their part, having to do with not setting up simple high
and low water marks to keep things like a particular FS
or networking subsystem from monopolizing memory.  Instead,
they now have this artificial divide, where under typical
workloads, one pool lies largely fallow (which one depends
on the server role).  I guess that's not a problem, if your
primary after market marked up revenue generation sale item
is DRAM...

If the code you are referring to is the code that I think
it is, I don't think it's useful, except for something
like a web server with large objects to serve.  Even then,
discarding the entire concept of locality of reference
when you notice sequential access seems bogus.  Realize
that average web server service objects are on the order
of 10k, not 200M.  Realize also the _absolutely disasterous_
effect that code kicking in would have on, for example, an
FTP server immediately after the release of FreeBSD ISO
images to the net.  You would basically not cache that data
which is your primary hottest content -- turning virtually
assured cache hits into cache misses.


>     But being able to predict something like this is
>     extremely difficult.  In fact, nearly impossible.

I would say that it could be reduced to a stochiastic and
iterative process, but (see above), that it would be a
terrible idea for all but something like a popular MP3
server... even then, you start discarding useful data
under burst loads, and we're back to cache missing.


>     And without being able to make the prediction
>     accurately you simply cannot determine how much data
>     you should try to cache before you begin recycling it.

I should think that would be obvious: nearly everything
you can, based on locality and number of concurrent
references.  It's only when you attempt prefetch that it
actually becomes complicated; deciding to throw away a
clean page later instead of _now_ costs you practically
nothing.


>     So the jist of the matter is that FreeBSD (1) already
>     has process-wide working set limitations which are
>     activated when the system is under load,

They are largely useless, since they are also active even
when the system is not under load, so they act as preemptive
drags on performance.  They are also (as was pointed out in
an earlier thread) _not_ applied to mmap() and other regions,
so they are easily subverted.


>     and (2) already has a heuristic that attempts to predict
>     when not to cache pages.  Actually several heuristics (a
>     number of which were in place in the original CSRG code).

I would argue that the CPU vs. memory vs. disk speed
pendulum is moving back the other way, and that it's time
to reconsider these algorithms once again.  If it's done
correctly, they would be adaptive based on knowing the
data rate for each given subsystem.  We have gigabit NICs
these days, which can fully monopolize a PCI bus very
easily with few cards -- doing noting but network I/O at
burst rate on a 66MHz 64 bit PCI bus, thing max out at 4
cards -- and that's if you can get them to transfer the
data directly to each other, with no host intervention
being required, which you can't.

The fastest memory bus I've seen in Intel calls hardware
is 133MHz; at 64 bits, that's twice as fast as the 64bit
66MHz PCI bus.

Disks are pig-slow comparatively; in all cases, they're
going to be limited to the I/O bus speed anyway, and as
rotational speeds have gone up, seek latency has failed
to keep pace.  Most fast IDE ("multimedia") drives still
turn off thermal recalibration in order to keep streaming.

I think you need to stress a system -- really stress it,
so that you are hitting some hardware limit because of
the way FreeBSD uses the hardware -- in order to understand
where the real problems in FreeBSD lie.  Otherwise, it's
just like profiling a program over a tiny workload: the
actual cost of servicing real work get lost in the costs
associated with initialization.

It's pretty obvious from some of the recent bugs I've
run into that no one has attempted to open more than
32767 sockets in a production environment using a FreeBSD
system.  It's also obvious that no one has attempted to
have more than 65535 client connections open on a FreeBSD
box.  There are similar (obvious in retrospect) problems
in the routing and other code (what is with the alias
requirement for a 255.255.255.255 netmask, for example?
Has no one heard of VLANs, without explicit VLAN code?).

The upshot is that things are failing to scale under a
number of serious stress loads, and rather than defending
the past, we should be looking at fixing the problems.

I'm personally very happy to have the Linux geeks interested
in covering this territory cooperatively with the FreeBSD
geeks.  We need to be clever about causing scaling problems,
and more clever about fixing them, IMO.

-- Terry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
