Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30096
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 10:17:11 -0500
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
References: <Pine.LNX.3.96.981222114610.538B-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Dec 1998 09:32:47 -0600
In-Reply-To: Andrea Arcangeli's message of "Tue, 22 Dec 1998 11:49:54 +0100 (CET)"
Message-ID: <m1pv9cqjj4.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 22 Dec 1998, Eric W. Biederman wrote:
>> To date I have only studied one very specific case,  what happens when
>> a process dirties pages faster then the system can handle. 

AA> Me too.

>> 3) The vm I was playing with had no way to limit the total vm size.
>> So process that are thrashing will slow other processes as well.
>> So we have a potential worst case scenario, the only solution to 
>> would be to implement RLIMIT_RSS.  

AA> Hmm, no limiting the resident size is a workaround I think...

Not totally, though there may be another way.

The worst case is very simple, a program eating pages at the maximum
possible rate, and out competing every other program for pages.

The goal is to keep one single rogue program from outcompeting all of the others.
With implementing a RSS limit this is accomplished by at some point forcing free
pages to come from the program that needs the memory, (via swap_out) instead of directly.

What currently happens is when such a program starts thrashing, is whenever it wakes
up it steals all of the memory, and sleeps until it can steel some more.  Because
the program is a better competitor, than the others.  With a RSS limit we would
garantee that there is some memory left over for other programs to run in.

Eventually we should attempt to autotune a programs RSS by it's workload, and
if giving a program a larger RSS doesn't help (that is the program continues to thrash with
an RSS we give it) we should scale back it's RSS, so as not to compete with other programs.

Implementing simple RSS limits is a first aproximation of the above.

Implementing arbitrary RSS limits should have little effect on
performance because all of the pages go simply to the swap_cache.

Implementing RSS limits is only a means of preventing a denial of
service attack, and it should not be a case we autotune for.

AA> I agree that the fact that swapout returns 1 and really has not freed a
AA> page is a bit messy though. Should we always do a shrink_mmap()  after
AA> every succesfully swapout? 

No.  That doesn't buy you anything, let the routines have different
semantics and stop trying to treat them the same.

This is simply one reason why everyone's trick of calling shrink_mmap at
strange times worked.  

My suggestion (again) would be to not call shrink_mmap in the swapper
(unless we are endangering atomic allocations).  And to never call
swap_out in the memory allocator (just wake up kswapd).

Since we are into getting the architecture right.  Let's stop trying
to force square pegs through round holes.  It's o.k. to make a square
hole too.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
