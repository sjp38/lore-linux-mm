Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30390
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 10:57:35 -0500
Date: Tue, 22 Dec 1998 16:40:26 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <m1pv9cqjj4.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981222162525.8801A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On 22 Dec 1998, Eric W. Biederman wrote:

>My suggestion (again) would be to not call shrink_mmap in the swapper
>(unless we are endangering atomic allocations).  And to never call
>swap_out in the memory allocator (just wake up kswapd).

Ah, I just had your _same_ _exactly_ idea yesterday but there' s a good
reason I nor proposed/tried it. The point are Real time tasks. kswapd is
not realtime and a realtime task must be able to swapout a little by
itself in try_to_free_pages() when there's nothing to free on the cache
anymore. 

Since I agree with you to run mainly shrink_mmap() in the foreground
freeing I just proposed yesterday to use an higher priority in
try_to_free_pages (see my patch, it starts with priority = 4, Linus's now
start with prio = 5). This way we are pretty sure that the foreground
freeing will be done in shrink_mmap() and so that some memory will be
really freed some way (and this will avoid also tasks other than kswapd to
sleep waiting for slowww SYNC IO). 

I agree with you with the argument that it's a bogus architecture to use
in the same way the actual swap_out and shrink_mmap() since swap_out
doesn' t really free pages....

Linus's pre-4 seems to work well here though...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
