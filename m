Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA23483
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 00:33:53 -0400
Subject: Re: Thread implementations...
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
	<199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 24 Jun 1998 23:45:52 -0500
In-Reply-To: Richard Gooch's message of Thu, 25 Jun 1998 09:41:18 +1000
Message-ID: <m1pvfy3x8f.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:

RG> Eric W. Biederman writes:
>> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:

>> With madvise(3) following the traditional format with only one
RG>                ^
RG> Don't you mean 2?

My suggestion:
madvise(2)(struct madvise_struct *, int number_of_structs);
madvise(3)(caddr_t addr, size_t len, size_t strategy);

madvise(3) being in libc...

>> advisement can be done easily.  The reason I suggest multiple
>> arguments is that for apps that have random but predictable access
>> patterns will want to use MADV_WILLNEED & MADV_DONTNEED to an optimum
>> swapping algorigthm.

RG> I'm not aware of madvise() being a POSIX standard. I've appended the
RG> man page from alpha_OSF1, which looks reasonable. It would be nice to
RG> be compatible with something.

According to the kernel source it is available on:
the alpha, mips, and sparc.  And the mips code thinks there is a posix
version somewhere.

Does someone have the Sun/sparc man page?  Besides what is in the
kernel source I mean.

> 	    MADV_WILLNEED
	This needs to start an asynchronouse pagein if necessary.

> 	    MADV_DONTNEED
> 		      Do not need these	pages

> 		      The system will free any resident	pages that are allo-
> 		      cated to the region.  All	modifications will be lost
> 		      and any swapped out pages	will be	discarded.  Subse-
> 		      quent access to the region will result in	a zero-fill-
> 		      on-demand	fault as though	it is being accessed for the
> 		      first time.  Reserved swap space is not affected by
> 		      this call.

This one is broken, for 3 reasons.
1) madvise should only give advise.
2) This can be done with mmap(start, len, PROT..., MAP_ANON, -1, 0)
3) There is a more reasonable interpretation from IRIX:


     MADV_DONTNEED    informs the system that the address range	from addr to
		      addr + len will likely not be referenced in the near
		      future.  The memory to which the indicated addresses are
		      mapped will be the first to be reclaimed when memory is
		      needed by	the system.

Which means that with a smart programmer you can implement the optimal
swapping algorithm for your process with MADV_DONTNEED and
MADV_WILLNEED and be relatively portable.

Of course MADV_SEQUENTIAL should handle the case of sending a file out
a socket, for a userspace sendfile.

> 	    MADV_SPACEAVAIL
> 		      Ensure that resources are	reserved

This one also does more than advise and for that reason I don't like it.

Anyhow this looks like something to keep in mind for 2.3.
Currently I have too many projects in the air to do more than think
the interface through.  The mapping type could easily be stored in the
vma as a hind though.  Perhaps it could be ready for 2.2 but I
couldn't do it.

Eric
