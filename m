Date: Fri, 6 Apr 2001 22:03:41 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406220341.A935@athlon.random>
References: <20010406211416.B785@athlon.random> <Pine.LNX.4.21.0104061954470.1407-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0104061954470.1407-100000@localhost.localdomain>; from hugh@veritas.com on Fri, Apr 06, 2001 at 08:03:08PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 06, 2001 at 08:03:08PM +0100, Hugh Dickins wrote:
> On Fri, 6 Apr 2001, Andrea Arcangeli wrote:
> > On Fri, Apr 06, 2001 at 09:09:08PM +0200, Andrea Arcangeli wrote:
> > > We always overstimate anyways, we have to because we don't have information
> > > about the really freeable memory (think at the buffer cache pinned in the
> > 
> > ah, and btw, even if we would have information about the really freeable memory
> > in the cache and swap cache that would still useless in real life because we
> > don't reserve memory for the previous malloc calls (endless overcommit
> > discussion), so allocation could still fail during page fault and process will
> > have to be killed the linux way.
> 
> How indelicate you are!  I've been careful to avoid all mention of that...
> Seriously, there's good debate to have there, but it's another issue

This is not another issue. It is the same issue. If you don't do reservation
for the userspace memory you can only overstimate, if you understimate you are
wrong because you are not even able to use all the resources in your machine
and that is the current bug (while overstimating and overcommit may allow you
to better optimize the memory usage with the downside that you can have to kill
a task during a page fault and that is why it should be optional behaviour).

So I repeat: if you don't reserve the memory to make sure you will always be
able to allocate the malloced memory you just overstimate, and so the
vm_enough_memory automatically become a very imprecise guess, it's an heuristic
that is only meant to avoid ridicolous big allocations and that must _never_
understimate.

This is my last email about this issue.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
