Date: Sun, 23 Apr 2000 02:52:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <yttem7xstk2.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0004230234590.447-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Apr 2000, Juan J. Quintela wrote:

>swap.  Without this line, my systems BUG always running this
>application.
>
>I tested also to put something like:
>
>	if (!PageLocked(page))
>		BUG();
>
>
>but with that the kernel doesn't boot.  It BUG.

That's normal, a new allocated page is not locked (you should BUG if the
page was locked instead).

Before hashing the page, the page is not visible and we can do whatever we
want with it and it's also not locked since it doesn't need to be locked
in first place. Locking a page make sense only as far as the page can be
shared by more than one user. The point of setting the locked bit there is
to give visibility to the page only _after_ we set the page lock on it to
make sure nobody will play with it before we finished. It doesn't matter
how we set the page locked as far as we set the page locked before hashing
it.

The thing I'm not 100% sure about previous Linus's email (not about
add_to_page_cache but about not needing the lock on the bus to change the
other bitflags while we're holding the page lock) is if we can be sure
that the other atomic trylock can't run from under us and invalidate our
nonatomic clearbit. If that's not the case (so if the other atomic trylock
keep us away while it's running) I fully agree we don't need the lock on
the bus to change the other bitflags while we're holding the page lock. I
want to try a little userspace simulation to make sure we're safe that
way. I want to make sure we don't need the lock on the bus too to avoid to
mess with the other trylock that tries to run from under us.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
