Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D6AE06B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:49:27 -0400 (EDT)
Date: Tue, 17 Mar 2009 09:43:41 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090317121900.GD20555@random.random>
Message-ID: <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Andrea Arcangeli wrote:
> 
> Think if the anon page is added to swapcache and the pte is unmapped
> by the VM and set non present after GUP taken the page for a O_DIRECT
> read (write to memory). If a thread writes to the page while the
> O_DIRECT read is running in another thread (or aio), then do_wp_page
> will make a copy of the swapcache under O_DIRECT read, and part of the
> read operation will get lost.

In that case, you aren't getting to the "do_wp_page()" case at all, you're 
getting the "do_swap_page()" case. Which does its own reuse_swap_page() 
thing (and that one I didn't touch - on purpose).

But you're right - it only does that for writes. If we _first_ do a read 
(to swap it back in), it will mark it read-only and _then_ we can get a 
"do_wp_page()" that splits it.

So yes - I had expected our VM to be sane, and have a writable private 
page _stay_ writable (in the absense of fork() it should never turn into a 
COW page), but the swapout+swapin code can result in a rw page that turns 
read-only in order to catch a swap cache invalidation.

Good catch. Let me think about it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
