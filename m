Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60B9F6B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:08:10 -0400 (EDT)
Date: Mon, 16 Mar 2009 10:02:02 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170350.13665.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903160955490.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903170323.45917.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903160927240.3675@localhost.localdomain> <200903170350.13665.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> Hmm, I see what you mean there; it can be used to solve Andrea's race
> instead of using set_bit/memory barriers. But I think then you would
> still need to put this lock in fork and get_user_pages[_fast], *and*
> still do most of the other stuff required in Andrea's patch.

Well, yes and no. 

What if we just did the caller get the lock? And then leave it entirely to 
the caller to decide how it wants to synchronize with fork?

In particular, we really _could_ just say "hold the lock for reading for 
as long as you hold the reference count to the page" - since now the lock 
only matters for fork(), nothing else.

And make the forking part use "down_write_killable()", so that you can 
kill the process if it does something bad.

Now you can make vmsplice literally get a read-lock for the whole IO 
operation. The process that does "vmsplice()" will not be able to fork 
until the IO is done, but let's be honest here: if you're doing 
vmsplice(), that is damn well what you WANT!

splice() already has a callback for releasing the pages, so it's doable.

O_DIRECT has similar issues - by the time we return from an O_DIRECT 
write, the pages had better already be written out, so we could just take 
the read-lock over the whole operation.

So don't take the lock in the low level get_user_pages(). Take it as high 
as you want to.

And if some user doesn't want that serialization (maybe ptrace?), don't 
take the lock at all, or take it just over the get_user_pages() call.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
