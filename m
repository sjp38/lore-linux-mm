Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA31239
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 04:24:52 -0400
Date: Mon, 17 Aug 1998 19:33:48 +0100
Message-Id: <199808171833.TAA03492@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory overcommitment
In-Reply-To: <Pine.SOL.3.96.980817103420.26929A-100000@opus3>
References: <Pine.SOL.3.96.980817103420.26929A-100000@opus3>
Sender: owner-linux-mm@kvack.org
To: Nicolas Devillard <ndevilla@mygale.org>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 17 Aug 1998 10:46:24 +0200 (MET DST), Nicolas Devillard
<ndevilla@mygale.org> said:

> Dear all:
> I can allocate up to 2 gigs of memory on a Linux box with 256 megs of
> actual RAM + swap. Having browsed through pages and pages of linux-kernel
> mailing-lists archives, I found out a thread discussing that with the
> usual pros and cons, but could not find anything done about it. Ah, and I
> know the standard answer: ulimit or limit would do the job, but they do
> not apply system-wide.

> The usual story of over-commitment compares memory allocation to
> airplane companies, but in this case something goes wrong: the kernel
> actually knows that it has only 256 megs, why does it commit itself to
> promise more than 8 times this amount to any normal user requesting it??
> A company selling 100 tickets for a 12-seat plane would have serious
> problems I guess. It is Ok to overbook, but what are you doing exactly
> when all passengers show up at the counter, especially when you have
> overbooked by a factor 8 or so?

The short answer is "don't do that, then"!  

Preventing overbooking is not actually possible given Linux's unified
memory model.  Even if the memory commitment fits into combined
ram+swap, future non-pageable memory allocations can overrun.
Networking, the filesystem, the VM and so on all take up non-pageable
memory.  Forking a process takes memory; mmaping() a file takes memory,
both for the internal descriptors and for the page tables, even though
there is no accounting for that memory against committed resources.

The only way we can make the commitment guarantee is to limit total
allocated memory to the size of swap space.  That's just contrary to the
Linux way of doing things, as we have users with less swap space than
physical memory, without any swap at all, or with programs which
internally overallocate enormously but which then fail to use all of the
allocated space.  Fortran codes are notorious for having huge default
arrays of which only a tiny proportion gets used, but there are many
other examples too.

Finally, even if we _do_ enforce memory commitments, that's still a
denial-of-service attack, since a user which grabs all memory is still
preventing other users or other system processes from getting more.

> In this case, I found out that once I start touching the 2 generously
> allocated gigs of memory, RAM goes away, then swap, then daemons start
> dying one by one and the machine freezes to the point of unusability. More
> than a single memory allocation problem or policy, it is a serious threat
> to security, because it allows to kill dameons for any user.

Exactly.  For all of the reasons above, I don't think we _can_ prevent
memory overcommit.  The real issue is how to deal with it: letting
normal daemons get anihilated because of a runaway user process is not a
good thing.  Rik has already posted an out-of-memory patch to this list
which attempts to do more intelligent killing of processes, and Alan Cox 
has implemented the basis of a per-user resource limiting feature which
will allow us to more rigorously enforce the limiting of intangible,
non-pageable data structures implicitly requested by a user.

> Anything done about it? Some references I may have missed about this
> point? Someone working on it? An easy quickfix maybe??

If you can suggest a good algorithm for selecting processes to kill,
we'd love to hear about it.  The best algorithm will not be the same for
all users.

--Stephen
 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
