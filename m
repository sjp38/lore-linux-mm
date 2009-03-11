Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 605286B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 17:30:46 -0400 (EDT)
Date: Wed, 11 Mar 2009 14:28:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311205529.GR27823@random.random>
Message-ID: <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random>
 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
 <20090311205529.GR27823@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Andrea Arcangeli wrote:

> On Wed, Mar 11, 2009 at 01:33:17PM -0700, Linus Torvalds wrote:
> > Btw, if we don't do that, then there are better alternatives. One is:
> > 
> >  - fork already always takes the write lock on mmap_sem (and f*ck no, I 
> >    doubt anybody will ever care one whit how "parallel" you can do forks 
> >    from threads, so I don't think this is an issue)
> > 
> >  - Just make the rule be that people who use get_user_pages() always 
> >    have to have the read-lock on mmap_sem until they've used the pages.
> 
> How do you handle pages where gup already returned and I/O still in
> flight?

The rule is:
 - either keep the mmap_sem for reading until the IO is done
 - admit the fact that IO is asynchronous, and has visible async behavior.

> Forcing gup-fast to be called with mmap_sem already hold (like
> gup used to require) only avoids the need of changes in gup-fast
> AFAICT. You'll still get pages that are pinned and calling gup-fast
> under mmap_sem (no matter if read or even write mode) won't make a
> difference, still those pages will be pinned while fork runs and with
> dma going to them (by O_DIRECT or some driver using gup, as long as
> PageReserved isn't set on them).

The point I'm trying to make is that anybody who thinks that pages are 
stable over various behavior that runs in another thread - be it a fork, a 
mmap/munmap, or anything else, is just fooling themselves. The pages are 
going to show up in "random" places. 

The fact that the non-fast "get_user_pages()" takes the mmap semaphore for 
reading doesn't even protect that. It just means that the pages made sense 
at the time the get_user_pages() happened, not necessarily at the time 
when the actual use of them did. 

> Releasing the mmap_sem read mode in the irq-completion handler context
> should be possible, however fork will end up throttled blocking for
> I/O which isn't very nice behavior. BTW, direct-io.c is a total mess,
> I couldn't even figure out where to release those locks in the I/O
> completion handlers when I tried something like this with PG_lock
> instead of the mmap_sem...  Eventually I gave it up because this isn't
> just about O_DIRECT but all gup users have this trouble with fork.

O_DIRECT is actually the _simple_ case, since we won't be returning until 
it is done (ie it's not actually a async interface). So no, O_DIRECT 
doesn't need any interrupt handler games. It would just need to hold the 
sem over the actual call to the filesystem (ie just over the ->direct_IO() 
call).

Of course, I suspect that all users of O_DIRECT would be _very_ unhappy if 
they cannot do mmap/unmap/brk on other areas while O_DIRECT is going on, 
so it's almost certainly not reasonable.

People want the relaxed synchronization we give them, and that's literally 
why get_user_pages_fast exists - because people don't want _more_ 
synchronization, they want _less_.

But the thing is, with less synchronization, the behavior really is 
surprising in the edge cases. Which is why I think "threaded fork" plus 
"get_user_pages_fast" just doesn't make sense to even _worry_ about. If 
you use O_DIRECT and mix it with fork, you get what you get, and it's 
random - exactly because people who want O_DIRECT don't want any locking. 

It's a user-space issue, not a kernel issue.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
