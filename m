Date: Mon, 24 Jan 2000 16:08:56 +0100 (MET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: GFP_XXX semantics (was: Re: [PATCH] 2.2.1{3,4,5} VM fix)
In-Reply-To: <Pine.LNX.4.10.10001241411310.24852-100000@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.10.10001241428440.11695-100000@Wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2000, Ingo Oeser wrote:

>ok, once we are about it here, could you please explain the
>_exact_ semantics for the GFP_XXX constants?

NOTE: this first explanation is relative to the semantics of the GFP_* in
2.2.14aa2.

>GFP_BUFFER

GFP_BUFFER is equal to GFP_KERNEL (see below), with the difference that
while trying to free memory it will never generate I/O on disk, so if you
are allocating memory with potential FS lock held you _must_ use
GFP_BUFFER to avoid deadlocking by recursing on the lock. This is used for
example to allocate buffer memory in the getblk code that gets recalled
also with the superblock locked.

>GFP_ATOMIC

GFP_ATOMIC has to be called if you can't afford sleeping (for example to
allocate memory within an IRQ or a BH handler).

There's also at least one subtle usage of GFP_ATOMIC that makes perfect
sense (the bigmem swap-bounce code) but that is a quite special case.

>GFP_BIGUSER

Equal to GFP_USER (see below) but it will try to return you BIGMEMORY if
possible. BIGMEMORY is memory that can't be used all over the place and
you should never use GFP_BIGUSER unless you know well what are you doing.
The kernel just try to allocate bigmemory where it knows he can handle it
(like while allocating userspace anonymous memory inside page faults or
for vmalloced memory).

BTW, GFP_BIGUSER in 2.2.14aa2 == GFP_HIGHUSER in 2.3.40.

>GFP_USER

GFP_USER fails just while the system is only going OOM. Going OOM means
that there's nothing of freeable anymore and at the same time the system
is low on memory.

GFP_USER should be used on all allocations that are triggered directly
from userspace and usually that by failing the allocation you'll be able
recover the out of memory condition (for example in the page fault handler
we use GFP_USER to kill ASAP the task that is making the system to go
OOM).

>GFP_KERNEL

GFP kernel should be used for all normal kernel allocations where you can
sleep.

>GFP_NFS

Equal to GFP_KERNEL but supposed to have more priority (actually they have
the same prio).

>GFP_KSWAPD

It simply tells kswapd that it should free all kinds of memory (in the
bigmem case only non-bigmem memory to not break atomic allocations
reliability). Only kswapd uses GFP_KSWAPD.

>So which steps are tried to allocate these pages (freeing
>process, freeing globally, waiting, failing, kswapd-wakeup)? 

Actually in 2.2.14aa2 it's something like that:

------------------------------------------
if (no GFP_ATOMIC && system low on memory)
{
	succeed = try_to_free_some_memory(do IO only if it's not GFP_BUFFER);

	if (!succeed)
		if GFP_USER then fail even there's still something in the freelist;
}

grab from the freelist and return the memory if there's still something available
------------------------------------------

In 2.2.15pre4 instead GFP_KERNEL is equal to the 2.2.14aa2 (above
described) GFP_USER. And in 2.2.15pre4 (and 2.2.14) GFP_BUFFER is equal to
GFP_USER too with the exception that GFP_BUFFER is not allowed to do I/O
to release memory as usual).

I understood that the argument for the 2.2.15pre4 differences is that they
want to disallow GFP_BUFFER and GFP_KERNEL to eat all the free memory to
left such memory for the PF_MEMALLOC path. But the whole point is that
during the PF_MEMALLOC path everybody can ping flood the machine and eat
such last memory from interrupts anyway (or GFP_NFS could be used as
well). So if the machine deadlocks with 2.2.14aa2 it will deadlock with
2.2.15pre4 too.

If the machine deadlocks inside the PG_MEMALLOC path that's plain a bug in
the PF_MEMALLOC path and not something that can be fixed inside GFP in any
way.

And during OOM it make sense to me that we allow the system to use the
last memory available (unless it's an USER allocation that we want to kill
immediatly before nr_free_pages goes to zero so we'll have more changes
that the kernel-stuff won't be affected by the temporary memory shortage).

Note that during OOM you are going to have all the swap space allocated
thus the PF_MEMALLOC path is not going to allocate memory or do I/O
anyway.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
