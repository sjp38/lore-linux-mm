Date: Fri, 6 Apr 2001 12:52:26 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.31.0104061245320.25931-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 6 Apr 2001, Hugh Dickins wrote:
>
> swapper_space.nrpages, that's neat, but I insist it's not right.

It's not "right", but I suspect it's actually good enough.

Also, note that when if get _really_ low on memory, the swap cache effect
should be going away: if we still have the swap cache pages in memory,
we've obviously not paged everything out yet. So the double accounting
should have a limit error of zero as we approach being truly low on
memory. And that, I suspect, is the most important thing - making sure
that we allow programs to run when they can, but at least having _some_
concept of "enough is enough".

Note that we should probably also have a small "negative" count: it might
not be a bad idea to say "we always want to have X MB free in _some_ form,
be it swap or RAM. So I don't think it would necessarily be wrong to say
something like

	free -= num_physpages >> 6;

to approximate the notion of "keep 1 percent slop" (remember, the 1% may
well be on the swap device, not actually kept as free memory).

vm_enough_memory() is a heuristic, nothing more. We want it to reflect
_some_ view of reality, but the Linux VM is _fundamentally_ based on the
notion of over-commit, and that won't change. vm_enough_memory() is only
meant to give a first-order appearance of not overcommitting wildly. It
has never been anything more than that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
