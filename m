Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA11101
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 04:30:27 -0500
Date: Sat, 9 Jan 1999 09:30:04 GMT
Message-Id: <199901090930.JAA05744@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.96.990109032305.805C-100000@laser.bogus>
References: <199901090213.CAA05306@dax.scot.redhat.com>
	<Pine.LNX.3.96.990109032305.805C-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 9 Jan 1999 03:34:56 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Hi Stephen!
> On Sat, 9 Jan 1999, Stephen C. Tweedie wrote:

>> deadlock.  The easiest way I can see of achieving something like this is
>> to set current->flags |= PF_MEMALLOC while we hold the superblock lock,

> Hmm, we must not avoid shrink_mmap() to run. So I see plain wrong to set
> the PF_MEMALLOC before call __get_free_pages(). Very cleaner to use
> GFP_ATOMIC to achieve the same effect btw ;).

No, there are about a squillion possible places where we might try to
allocate memory with the superblock lock; updating them all to make
the gfp parameter conditional is gross!

Anyway, the whole point of PF_MEMALLOC is that it says we are
currently in the middle of an operation which has subtle deadlock or
stack overflow semantics wrt allocations, so always try to make
allocations from the free list.  In this case, the number of such
allocations we expect is small, so this is reasonable.  And yes, using
a new flag as opposed to PF_MEMALLOC would allow us to continue to
shrink_mmap (and in fact also to unmap clean pages) while preventing
recursive IO.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
