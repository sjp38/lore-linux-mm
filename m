Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA05638
	for <linux-mm@kvack.org>; Mon, 8 Dec 1997 12:09:56 -0500
Date: Mon, 8 Dec 1997 13:23:30 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: VM ideas (was: Re: TTY changes to 2.1.65)
In-Reply-To: <m0xdhY3-000PukC@petz>
Message-ID: <Pine.LNX.3.91.971208130002.553F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joerg Rade <jr@petz.han.de>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Dec 1997, Joerg Rade wrote:

> How about something like a garbage collection for interpreted
> languages, i.e. GNU-Smalltalk or Java?  As Paul Wilson in his article
> below pointed out, linux would be a suitable platform.

How does Linux know what is garbage and what isn't :)
The purpose of garbage collection is to avoid making loads
of syscalls, and doing stuff yourself (because only you know
what memory is being used for. 'process privacy policy' :)

[snip]

> My own vote for "most worthwhile hardware for memory management"
> is sub-page protections in the TLB, e.g., 1-KB independently-protectable
> units withing 4KB or 8KB pages, like the ARM 6xx series.  

Why?

> And VERY FAST traps.  

Of course, everything should be as fast as possible.

The two above suggestions actually contradict eachother,
you can't make the system more complex and faster at the
same time. The "no-free-lunch" principle is ever-present!

> And please don't make the pages bigger.  (And get the OS kernel
> people to support querying which pages are dirty, and VERY FAST USER-LEVEL
> TRAPS.)

Swapping is mainly slowed down by _latency_ problems. The
page size isn't that much of an issue any more, because:
- current PCs have large memory (>4000 pages) for which
  fine-grained management will COST performance (too complex)
- small pages will have HUGE latency problems
- large pages will be more easily manageable, but waste more space
- 4k seems to be 'just right' (optimal Goldylocks size)
- the demand for VSPM has shown that 4k isn't big enough for some cases
- in a VM system with more than 64k of pages, it is 'difficult' to
  select the best page to swap out, instead you swap out a good
  page... If you were to swap out a 16k unit at once, latency
  problems would be less, and performance might be better ???
- 1k units just are too complex when it's about disk swapping
  (for non-swappable memory it would/could be nice however)

> These features are desirable for a lot of things, including:
> 
>   1. persistence (pointer swizzling at page fault time)
nice.
>   2. checkpointing dirty pages (for fault-tolerance, process migration 
>      persistence, and time-travel debugging),
>   3. distributed virtual memory, 
DIPC is out... check your favorite web site...
>   4. GC read and write barriers, 
?
>   5. redzoning to detect array overruns in debugging mallocs and buffer
>      overruns in networking software,
?
>   6. compressed caching virtual memory,
VM is a latency based problem, during the wait period another
process can run... Wasting CPU time on VM is (IMHO) counterproductive.
Some people have reported _degraded_ performance with my vhand
patch...
>   7. adaptive clustering of VM pages,
this would be a Good Thing
>   8. overlapping protection domains (e.g., in single-address-space OS's,
>      or runtime systems with protection and sharing, or for fast
>      path communications software that avoids unnecessary copies),
?
>   9. pagewise incremental translation of code from bytecodes (or existing
>      ISA's) to VLIW or whatever,
nice when we get Linux to run on VLIW architectures
(but why don't we just recompile the programs?)
>   10. incremental changing of data formats for sharing data across
>       multicomputers (switching endianness, pointer size, etc.) or
>       networks,
this would be an awful lot of work, I wish you success :)
>   11. memory tracing and profiling,
nice.
>   12. incremental materialization of database query results in
>       a representation normal programs can handle
????
>   13. copy-on-write, lazy messaging, etc.
COW over network works counterproductive... It might save bandwidth,
but the latency problem it introduces isn't compensated by the
initial savings...
>   14. remote paging against distributed RAM caches
OK, this would be very nice. So nice that already people might
be working on it (not sure though).

> (Papers on some of these topics are available from our web site too.)

Hmm, I'll have a look.
> 
> I view the TLB as a very general-purpose piece of parallel hardware.
> You can really make it do lots of tricks for you to implement
> fancy memory abstractions cheaply.  There are lots of things for
> which a TLB can give you zero-cost checking in the common
> case, and trap to software in the uncommon cases.

abusing the TLB can be a very nice thing, but doesn't Linux
run on too many different types of architectures to make it
_really_ work... (or we'd have to do it on a per-arch level)

> I'm not a CPU design expert, though, so I'm not clear on
> how hairy this would be.

doing it (via software) on _existing_ architectures could be
_very_ _very_ hairy. An interesting project for a CS major though :))

> This is definitely due in part to the lack of benchmarks that stress
> these aspects of a system.  Some OS's (e.g., Linux) are several times
> faster than some others (e.g., Solaris), and some kernels (e.g., L4)
> are much faster still.  This doesn't show up in SPECmarks.

These functions aren't used _that_ often in real-life...

> I think it's time that everybody realized that the TLB they already
> have can support much more sophisticated software, and do it
> efficiently---and then started banging on their OS vendors to realize
> that TLB's aren't just for disk paging anymore.  Concurrently, TLB's

Great, using the TLB in a more flexible way.

> should get better to support finer-grained uses than current TLB's 
> can.

How can you improve the TLB from software??? I think this is
up to the hardware vendors (but I might be wrong)

grtz,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
