Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA17042
	for <linux-mm@kvack.org>; Wed, 24 Jun 1998 19:32:27 -0400
Subject: Re: Thread implementations...
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 24 Jun 1998 17:00:59 -0500
In-Reply-To: Richard Gooch's message of Wed, 24 Jun 1998 22:13:57 +1000
Message-ID: <m1u35a4fz8.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Cc: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:

RG> If we get madvise(2) right, we don't need sendfile(2), correct?

It looks like it from here.  As far as madvise goes, I think we need
to implement madvise(2) as:

enum madvise_strategy {
        MADV_NORMAL,
        MADV_RANDOM,
        MADV_SEQUENTIAL,
        MADV_WILLNEED,
        MADV_DONTNEED,
}
struct madvise_struct {
	caddr_t addr;
	size_t size;
	size_t strategy;
};
int sys_madvise(struct madvise_struct *, int count);

With madvise(3) following the traditional format with only one
advisement can be done easily.  The reason I suggest multiple
arguments is that for apps that have random but predictable access
patterns will want to use MADV_WILLNEED & MADV_DONTNEED to an optimum
swapping algorigthm.

And for that you will probably need multiple address ranges.  The
clustering comunity has a similiar syscall implemented for programs
whose working set size exceeds avaiable memory.  Except it has
strategy hardwired to MADV_WILLNEED.

However someone needs to look at actuall programs to see which form
is more practical to implement, in the kernel.

Of course all I know about madvise I just read in the kernel source so
I may be totally off...

Eric
