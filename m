Received: from mail.ccr.net (ccr@alogconduit1ab.ccr.net [208.130.159.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22382
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 14:52:57 -0500
Subject: Re: Why don't shared anonymous mappings work?
References: <199901061523.IAA14788@nyx10.nyx.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 06 Jan 1999 13:51:00 -0600
In-Reply-To: Colin Plumb's message of "Wed, 6 Jan 1999 08:23:35 -0700 (MST)"
Message-ID: <m1d84sgoyj.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Colin Plumb <colin@nyx.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "CP" == Colin Plumb <colin@nyx.net> writes:

>> Take a page map it into two processes.
>> Swap the page out from both processes to disk.
>> The swap address is now in the pte's.
>> Bring that page into process 1.
>> Dirty the page, thus causing a new swap entry to be allocated.
>> ( The write once rule)
>> Swap the page out of process 1.
>> 
>> Oops process 1 and process 2 have different pte's for the same
>> page.
>> 
>> Since we don't have any form of reverse page table entry
>> preventing that last case is difficult to do effciently.

CP> Um, but what if, as I was suggesting, we *don't* allocate a new swap
CP> entry when the page is dirtied?  That is, when do_wp_page sees that the
CP> page is in the swap cache, it looks at swap_map, sees that is greater
CP> than 2, and leaves it as a writeable swap-cached page.

Sorry I must have misread that part.

I guess the final trick would be to make sure we always bring a shared
memory area into a processes address space because so that we can ensure
it will get swapped out, and the pte put in the processes address space.

Currently vma's won't merge unless your offsets are contigous, which 
we can't garantee for swap space, and having multiple vmas would be a real pain.

Handling /proc/self/mem mappings into the same process correctly
could be interesting however. Because the definition of private and
shared gets a little muddled.... 

The only reason remaining that I can think of why it isn't there
is that
a) no one wrote the code
b) It is very close to 2.2

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
