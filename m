Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA32190
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 16:46:23 -0500
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
References: <Pine.LNX.3.95.981222082256.8438C-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Dec 1998 13:55:03 -0600
In-Reply-To: Linus Torvalds's message of "Tue, 22 Dec 1998 08:26:39 -0800 (PST)"
Message-ID: <m167b4q7e0.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On Tue, 22 Dec 1998, Andrea Arcangeli wrote:
>> 
>> On 22 Dec 1998, Eric W. Biederman wrote:
>> 
>> >My suggestion (again) would be to not call shrink_mmap in the swapper
>> >(unless we are endangering atomic allocations).  And to never call
>> >swap_out in the memory allocator (just wake up kswapd).
>> 
>> Ah, I just had your _same_ _exactly_ idea yesterday but there' s a good
>> reason I nor proposed/tried it. The point are Real time tasks. kswapd is
>> not realtime and a realtime task must be able to swapout a little by
>> itself in try_to_free_pages() when there's nothing to free on the cache
>> anymore. 

LT> There's another one: if you never call shrink_mmap() in the swapper, the
LT> swapper at least currently won't ever really know when it should finish.

Unless there are foreground allocations, that free a little too much memory.

With respect to real time tasks. 
A) they don't generally swap.
B) If there is code in __get_free_pages to put the real time task to sleep if it
   must while waiting for memory.
C) We are currently examining all of the code and seeing if it is comprehensible.
   Do we want to free memory to freepages.high in kswapd.

>> Linus's pre-4 seems to work well here though...

LT> I'm still trying to integrate some of the stuff from Stephen in there: the
LT> pre-4 contained some re-writes to shrink_mmap() to make Stephens
LT> PG_referenced stuff cleaner, but it didn't yet take it into account for
LT> "count", for example. The aim certainly is to have something clean that
LT> essentially does what Stephen was trying to do. 

If the aim is to make Stephen's code comprehensible I won't push too
hard.  But I will push to make sure that the code is comprehensible.
And with the change to swap_out to only half free memory there is code
that used to make sense but no longer does. 

As for pre-4 I am still baffled by treating swap_out the same as
as shrink_mmap, they aren't the same.

swap_out is an investment in free memory to come, and shrink_mmap
capitializes on that investment.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
