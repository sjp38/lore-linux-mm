Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA32281
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 16:51:55 -0500
Date: Tue, 22 Dec 1998 21:03:17 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <m1pv9cqjj4.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.03.9812222057210.397-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On 22 Dec 1998, Eric W. Biederman wrote:

> The goal is to keep one single rogue program from outcompeting all
> of the others. With implementing a RSS limit this is accomplished
> by at some point forcing free pages to come from the program that
> needs the memory, (via swap_out) instead of directly.
> 
> What currently happens is when such a program starts thrashing, is
> whenever it wakes up it steals all of the memory, and sleeps until
> it can steel some more.  Because the program is a better
> competitor, than the others.  With a RSS limit we would garantee
> that there is some memory left over for other programs to run in.
> 
> Eventually we should attempt to autotune a programs RSS by it's
> workload, and if giving a program a larger RSS doesn't help (that
> is the program continues to thrash with an RSS we give it) we
> should scale back it's RSS, so as not to compete with other
> programs.

I have a better idea:

if (current->mm->rss > hog_pct && total_mapped > syshog_pct) {
    ... swap_out_process(current, GFP)  swap_cluster pages ...
}

We can easily do something like this because swap_out() only
unmaps the pages and they can easily be mapped in again.

I know we tried it before and it horribly failed back then,
but now pages are not freed on swap_out(). Things have changed
in such a way that it could probably work now...

We want the above routine in one of the functions surrounding
mm/page_alloc.c::swap_in() -- this way we 'throttle at the
source'.

I know some of you think throttling at the source is a bad
thing (even for buffer cache), but you'll have to throttle
eventually and not doing it will mean you also 'throttle'
the (innocent) rest of the system...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
