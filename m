Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9EDC36B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 16:55:37 -0400 (EDT)
Date: Wed, 11 Mar 2009 21:55:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311205529.GR27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 01:33:17PM -0700, Linus Torvalds wrote:
> Btw, if we don't do that, then there are better alternatives. One is:
> 
>  - fork already always takes the write lock on mmap_sem (and f*ck no, I 
>    doubt anybody will ever care one whit how "parallel" you can do forks 
>    from threads, so I don't think this is an issue)
> 
>  - Just make the rule be that people who use get_user_pages() always 
>    have to have the read-lock on mmap_sem until they've used the pages.

How do you handle pages where gup already returned and I/O still in
flight? Forcing gup-fast to be called with mmap_sem already hold (like
gup used to require) only avoids the need of changes in gup-fast
AFAICT. You'll still get pages that are pinned and calling gup-fast
under mmap_sem (no matter if read or even write mode) won't make a
difference, still those pages will be pinned while fork runs and with
dma going to them (by O_DIRECT or some driver using gup, as long as
PageReserved isn't set on them).

> We already take the read-lock for the lookup (well, not for the gup, but 
> for all the slow cases), but I'm saying that we could go one step further 
> - just read-lock over the _whole_ O_DIRECT read or write. That way you 
> literally protect against concurrent fork()s.

Releasing the mmap_sem read mode in the irq-completion handler context
should be possible, however fork will end up throttled blocking for
I/O which isn't very nice behavior. BTW, direct-io.c is a total mess,
I couldn't even figure out where to release those locks in the I/O
completion handlers when I tried something like this with PG_lock
instead of the mmap_sem...  Eventually I gave it up because this isn't
just about O_DIRECT but all gup users have this trouble with fork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
