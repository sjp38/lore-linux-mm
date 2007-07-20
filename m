Date: Sat, 21 Jul 2007 01:06:11 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070720210610.GA148@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Mel Gorman <mel@skynet.ie>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Off-topic)

Linus Torvalds wrote:
>
> A full lock/unlock *pair* should (as far as I know) always be equivalent 
> to a full memory barrier.

Is it so? I am not arguing, I am trying to understand.

> Because, by definition, no reads or writes 
> inside the locked region may escape outside it, and that in turn implies 
> that no access _outside_ the locked region may escape to the other side of 
> it.

This means that unlock + lock is a full barrier,

> However, neither a "lock" nor an "unlock" on *its*own* is a barrier at 
> all, at most they are semi-permeable barriers for some things, where 
> different architectures can be differently semi-permeable.

and this means that lock + unlock is not.

	A;
	lock();
	unlock();
	B;

If both A and B can leak into the critical section, they could be reordered
inside this section, so we can have

	lock();
	B;
	A;
	unlock();

Yes?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
