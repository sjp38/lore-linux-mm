Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1396B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:48:53 -0400 (EDT)
Date: Mon, 16 Mar 2009 10:42:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170419.38988.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903170350.13665.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903160955490.3675@localhost.localdomain> <200903170419.38988.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> Well that in theory should close the race in one direction (writing into
> the wrong page).
> 
> I don't think it closes it in the other direction (reading the wrong data
> from the page).

Why?

If somebody does a COW while we have a get_user_pages() page frame cached, 
the get_user_pages() will have increased the page count, so regardless of 
_who_ writes to the page, the writer will always get a new page. No?

So reading data from the page will always get the old pre-cow data. 

[ goes to reading code ]

Oh, damn. That's how it used to work a long time ago when we looked at the 
page count. Now we just look at the page *map* count, we don't look at any 
other counts. So the COW logic won't see that somebody else has a copy.

Maybe we could go back to also looking at page counts?

> BTW. have you looked at my approach yet? I've tried to solve the fork
> vs gup race in yet another way. Don't know if you think it is palatable.

I really think we should be able to fix this without _anything_ like that 
at all. Just the lock (and some reuse_swap_page() logic changes).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
