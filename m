Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 500546B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:06:26 -0400 (EDT)
Date: Tue, 17 Mar 2009 10:01:06 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random>
 <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Linus Torvalds wrote:
> 
> So yes - I had expected our VM to be sane, and have a writable private 
> page _stay_ writable (in the absense of fork() it should never turn into a 
> COW page), but the swapout+swapin code can result in a rw page that turns 
> read-only in order to catch a swap cache invalidation.
> 
> Good catch. Let me think about it.

Btw, I think this is actually a pre-existing bug regardless of my patch.

That same swapout+swapin problem seems to lose the dirty bit on a O_DIRECT 
write - exactly for the same reason. When swapin turns the page into a 
read-only page in order to keep the physical page in the swap cache, the 
write to the physical page (that was gotten by get_user_pages() earlier) 
will bypass all that.

So the get_user_pages() users will then write to the page, but the next 
time we swap things out, if nobody _else_ wrote to it, that write will be 
lost because we'll just drop the page (it was in the swap cache!) even 
though it had changed data on it.

My patch changed the schenario a bit (split page rather than dropped 
page), but the fundamental cause seems to be the same - the swap cache 
code very much depends on writes to the _virtual_ address.

Or am I missing something?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
