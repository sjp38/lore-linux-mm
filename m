Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA28613
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 04:24:38 -0500
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
References: <Pine.LNX.3.95.981221095438.6187B-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Dec 1998 01:56:40 -0600
In-Reply-To: Linus Torvalds's message of "Mon, 21 Dec 1998 09:58:10 -0800 (PST)"
Message-ID: <m11zlssj7r.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On Mon, 21 Dec 1998, Stephen C. Tweedie wrote:
>> 
>> pre2 works OK on low memory for me but its performance on 64MB sucks
>> here.  pre3 works fine on 64MB but its performance on 8MB sucks even
>> more.

LT> I'm testing it now - the problem is probably just due to my mixing up the
LT> pre-2 and pre-3 patches, and pre-3 got the "timid" memory freeing
LT> parameters even though the whole point of the pre-3 approach is that it
LT> isn't needed any more.

>> You simply CANNOT tell from looking at the code that it "will
>> work well for everybody out there on every hardware".  

LT> Agreed.

LT> However, I very much believe that tweaking comes _after_ the basic
LT> arhictecture is right. Before the basic architecture is correct, any
LT> tweaking is useful only to (a) try to make do with a bad setup and (b) 
LT> give hints as to what makes a difference, and what the basic architecture
LT> _should_ be. 

LT> As such, your "current != kswapd" tweak gave a whopping good hint about
LT> what the architecture _should_ be. And we'll be zeroing in on something
LT> that has both the performance and the architecture right. 

In getting the architecture right,  Let's make it clear why the
foreground task should be more aggressive with shrink_mmap than the
background task. 

The semantics of shrink_mmap, & swap_out are no longer the same,
and they should not be treated equally.

shrink_mmap actually free's memory.
swap_out never free's memory.

The background task doesn't really ever need to free memory unless memory
starts getting too low for atomic allocations, so only then should it call
shrink_mmap.

The foreground task always really want's memory so it should never call swap_out
unless it needs to accellerate the swapping process (so it could also wake up or 
whatever the daemon).

To date I have only studied one very specific case,  what happens when
a process dirties pages faster then the system can handle. 

The results I have are:
1) Using the stated logic and staying with swap_out (and never calling
   shrink_mmap) locks the machine until all dirty pages are cleaned.

2) Calling shrink_mmap anytime during a swap_out cycle gives slow
   performance but the machine doesn't lock.

3) The vm I was playing with had no way to limit the total vm size.
   So process that are thrashing will slow other processes as well.
   So we have a potential worst case scenario, the only solution to 
   would be to implement RLIMIT_RSS.  
   If I can find enough time I'm going to look at implementing
   RLIMIT_RSS in handle_pte_fault, it should be fairly simple.

Eric





--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
