Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7966B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 15:19:03 -0400 (EDT)
Date: Wed, 11 Mar 2009 12:01:56 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random>
 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Linus Torvalds wrote:
> 
> It's never been written down, but it's obvious to anybody who looks at how 
> COW works for even five seconds. The fact is, the person doing the COW 
> after a fork() is the person who no longer has the same physical page 
> (because he got a new page).

Btw, I think your patch has a race. Admittedly a really small one.

When you look up the page in gup.c, and then set the GUP flag on the 
"struct page", in between the lookup and the setting of the flag, another 
thread can come in and do that same fork+write thing.

	CPU0:			CPU1

	gup:			fork:
	 - look up page
	 - it's read-write
	...
				set_wr_protect
				test GUP bit - not set, good
				done

	- Mark it GUP
				tlb_flush

				write to it from user space - COW

since there is no lockng on the GUP side (there's the TLB flush that will 
wait for interrupts being enabled again on CPU0, but that's later in the 
fork sequence).

Maybe I'm missing something. The race is certainly very unlikely to ever 
happen in practice, but it looks real.

Also, having to set the PG_GUP bit means that the "fast" gup is likely not 
much faster than the slow one. It now has two atomics per page it looks 
up, afaik, which sounds like it would delete any advantage it had over the 
slow version that needed locking.
							
What we _could_ try to do is to always make the COW breaking be a 
_directed_ event - we'd make sure that we always break COW in the 
direction of the first owner (going to the rmap chains). That might solve 
everything, and be purely local to the logic in mm/memory.c (do_wp_page).

I dunno. I have not looked at how horrible that would be.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
