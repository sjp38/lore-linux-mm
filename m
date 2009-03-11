Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A8DF86B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 17:57:33 -0400 (EDT)
Date: Wed, 11 Mar 2009 22:57:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311215721.GS27823@random.random>
References: <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain> <20090311205529.GR27823@random.random> <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 02:28:08PM -0700, Linus Torvalds wrote:
> The fact that the non-fast "get_user_pages()" takes the mmap semaphore for 
> reading doesn't even protect that. It just means that the pages made sense 
> at the time the get_user_pages() happened, not necessarily at the time 
> when the actual use of them did. 

Indeed this is a generic problem, not specific to
get_user_pages_fast. get_user_pages_fast just adds a few complications
to serialize against.

> O_DIRECT is actually the _simple_ case, since we won't be returning until 
> it is done (ie it's not actually a async interface). So no, O_DIRECT 
> doesn't need any interrupt handler games. It would just need to hold the 
> sem over the actual call to the filesystem (ie just over the ->direct_IO() 
> call).

I don't see how you can solve the race by only holding the sem only
over the direct_IO call (and not until the I/O completion handler
fires). I think to solve the race using mmap_sem only, the bio I/O
completion handler that eventually calls into direct-io.c from irq
context would need to up_read(&mmap_sem).

The way my patch avoids to alter the I/O completion path running from
irq context is by ensuring no I/O is going on at all to the pages that
are being shared with the child, and by ensuring that any gup or
gup-fast will trigger cow before it can write to the shared
page. Pages simply can't be shared before I/O is complete.

> People want the relaxed synchronization we give them, and that's literally 
> why get_user_pages_fast exists - because people don't want _more_ 
> synchronization, they want _less_.
> 
> But the thing is, with less synchronization, the behavior really is 
> surprising in the edge cases. Which is why I think "threaded fork" plus 
> "get_user_pages_fast" just doesn't make sense to even _worry_ about. If 
> you use O_DIRECT and mix it with fork, you get what you get, and it's 
> random - exactly because people who want O_DIRECT don't want any locking. 
> 
> It's a user-space issue, not a kernel issue.

I think your point of view is clear, I sure can write userland code
that copes it the currently altered memory protection semantics of
read vs fork if fd is opened with O_DIRECT or drivers using gup, so
I'll let the userland folks comment on it, some are in CC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
