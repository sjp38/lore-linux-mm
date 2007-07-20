Date: Fri, 20 Jul 2007 14:57:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
In-Reply-To: <20070720210610.GA148@tv-sign.ru>
Message-ID: <alpine.LFD.0.999.0707201454560.27249@woody.linux-foundation.org>
References: <20070720210610.GA148@tv-sign.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Hugh Dickins <hugh@veritas.com>, Mel Gorman <mel@skynet.ie>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 21 Jul 2007, Oleg Nesterov wrote:
> 
> Linus Torvalds wrote:
> >
> > A full lock/unlock *pair* should (as far as I know) always be equivalent 
> > to a full memory barrier.
> 
> Is it so? I am not arguing, I am trying to understand.

Yeah, no, I think you're right, and I'm wrong.

I think unlock+lock is a complete barrier, but lock+unlock isn't. Funny.

> This means that unlock + lock is a full barrier,

Indeed. If nothing else, because on the same lock it obviously had better 
be (you have two critical regions, and the whole *point* of the lock is to 
keep them clear of each others).

> > However, neither a "lock" nor an "unlock" on *its*own* is a barrier at 
> > all, at most they are semi-permeable barriers for some things, where 
> > different architectures can be differently semi-permeable.
> 
> and this means that lock + unlock is not.
> 
> 	A;
> 	lock();
> 	unlock();
> 	B;
> 
> If both A and B can leak into the critical section, they could be reordered
> inside this section, so we can have
> 
> 	lock();
> 	B;
> 	A;
> 	unlock();
> 
> Yes?

Yes, I think you're right.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
