Date: Sat, 22 Jan 2000 03:43:56 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.10.10001212016180.301-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001220309310.2341-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>On Fri, 21 Jan 2000, Andrea Arcangeli wrote:
>
>> Since 2.1.x all GFP_KERNEL allocations (not atomic) succeed too.
>
>Alan, I think we've located the bug that made 2.2 kernels
>run completely out of memory :)

Yes, the fix is to kill the meaningless 1 second polling loop and to
replace it with a proper wakeup. It has definitely nothing to do with
GFP_KERNEL semantics.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/atomic-allocations-2.gz

>Andrea, the last few pages are meant for ATOMIC and
>PF_MEMALLOC allocations only, otherwise you'll get
>deadlock situations.

Deadlock happens only due a bug in the caller. That has nothing to do with
failed atomic allocations or with the MM core.

About your proposed change (as I just said), the semantic you want to
change whith your diff that I am quoting here:

>-               if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
>+               if (!freed && !(gfp_mask & __GFP_HIGH))

makes a difference _only_ if the machine goes _OOM_ (so when
try_to_free_pages fails) and that's completly _unrelated_ with the
failed-atomic-allocation case we are talking about. If the machine is OOM
it's perfectly normal that atomic allocations fails. That's expected.

You are basically making GFP_KERNEL equal to GFP_USER and that's wrong. It
makes sense that allocation triggered by the kernel have access to the
whole free memory available: kernel allocations have the same privilegies
of atomic allocations. The reason atomic allocations are atomic is that
they can't sleep, that's all. If they could sleep they would be GFP_KERNEL
allocations instead. The only difference between the two, is that the
non-atomic allocations will free memory themselfs before accessing _all_
the free memory because they _can_ do that.

The reason GFP_USER allocations won't access the whole free memory is
_only_ that we want to kill userspace as soon as we detect OOM. It's not
because we want to reserve some memory for atomic allocations _during_
oom. During OOM we must try to kill userspace or eat the last memory free
if possible.

The problem we have now with atomic allcations is instead that they can
fail even if there's plenty of _freeable_unused_ cache allocated (_not_
during oom).

IMHO the problem we have is that atomic allocations only rely on the way
too slow 1 sec polling of kswapd, while they should wakeup kswapd
immediatly and my patch will address exactly that.

>GFP_KERNEL allocation fails. That same code would
>also crash if it were allowed to fill up freepages.min
>and then run really out of memory...

If something crashes when an allocation fails that's a caller bug and it's
unrelated with the VM core. If nr_free_pages == 0 the system must remains
stable. If the system crashes it's not an MM bug. Having nr_free_pages ==
0 is an expected condition.

NOTE: we actually have getblk a bit deadlock prone so getblk very much
prefer to succeed if possible. Fixing it it's not a 2.2.x thing IMHO also
considering I never succeed to reproduce that in RL. So we have to take in
mind this getblk thing while playing with the MM in 2.2.x. That's why I
said that your change could also harm getblk during oom, but nevertheless
it wasn't your change the source of the problem. Without your proposed
change instead getblk may get in troubles only if nr_free_pages == 0 that
rarely happens, but again: that's a getblk problem, and not an MM one.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
