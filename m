Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C2E286B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:09:08 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:06:18 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311215721.GS27823@random.random>
Message-ID: <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain>
References: <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
 <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain> <20090311205529.GR27823@random.random> <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
 <20090311215721.GS27823@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Andrea Arcangeli wrote:
> 
> > People want the relaxed synchronization we give them, and that's literally 
> > why get_user_pages_fast exists - because people don't want _more_ 
> > synchronization, they want _less_.
> > 
> > But the thing is, with less synchronization, the behavior really is 
> > surprising in the edge cases. Which is why I think "threaded fork" plus 
> > "get_user_pages_fast" just doesn't make sense to even _worry_ about. If 
> > you use O_DIRECT and mix it with fork, you get what you get, and it's 
> > random - exactly because people who want O_DIRECT don't want any locking. 
> > 
> > It's a user-space issue, not a kernel issue.
> 
> I think your point of view is clear, I sure can write userland code
> that copes it the currently altered memory protection semantics of
> read vs fork if fd is opened with O_DIRECT or drivers using gup, so
> I'll let the userland folks comment on it, some are in CC.

Btw, we could make it easier for people to not screw up.

In particular, "fork()" in a threaded program is almost always wrong. If 
you want to exec another program from a threaded one, you should either 
just do execve() (which kills all threads) or you should do vfork+execve 
(which has none of the COW issues).

An we could add a warning for it. Something like "if this is a threaded 
program, and it has ever used get_user_pages(), and it does a fork(), warn 
about it once". Maybe people would realize what a stupid thing they are 
doing, and that there is a simple fix (vfork).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
