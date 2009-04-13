Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4145F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 16:27:34 -0400 (EDT)
Date: Mon, 13 Apr 2009 13:19:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [V4][PATCH 0/4]page fault retry with NOPAGE_RETRY
In-Reply-To: <alpine.LFD.2.00.0904131254480.26713@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0904131314090.26713@localhost.localdomain>
References: <604427e00904131244y68fa7e62x85d599f588776eee@mail.gmail.com> <alpine.LFD.2.00.0904131254480.26713@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-15?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>



On Mon, 13 Apr 2009, Linus Torvalds wrote:
> 
> Well, have you tried the obvious optimization of _not_ doing the RETRY 
> path when atomic_read(&mm->counter) == 1?
> 
> After all, if it's not a threaded app, and it doesn't have a possibility 
> of concurrent mmap/fault, then why release the lock?

Ok, so the counter is called 'mm_users', not 'counter'.

Anyway, I would try that in the arch patch, and just see what happens when 
you change the

	unsigned int fault_flags = FAULT_FLAG_RETRY;

into

	unsigned int fault_flags;

	..

	fault_flags = atomic_read(&mm->mm_users) > 1 ? FAULT_FLAG_RETRY : 0;

where you should probably do that mm dereference only after checking that 
you're not in atomic context or something like that (so move the 
assignment down).

The reason I'd suggest doing it in the caller of handle_mm_fault() rather 
than anywhere deeper in the call chain is that some callers _might_ really 
want to get the retry semantics even if they are the only ones. Imagine, 
for example, some kind of non-blocking "get_user_pages()" thing.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
