Date: Mon, 2 Oct 2000 16:06:25 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001003001834.A25467@athlon.random>
Message-ID: <Pine.LNX.4.10.10010021559120.2206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Tue, 3 Oct 2000, Andrea Arcangeli wrote:

> On Mon, Oct 02, 2000 at 07:08:20PM -0300, Rik van Riel wrote:
> > Yes it has. The write order in flush_dirty_buffers() is the order
> > in which the pages were written. This may be different from the
> > LRU order and could give us slightly better IO performance.
> 
> And it will forbid us to use barriers in software elevator and in SCSI hardware
> to avoid having to wait I/O completation every time a journaling fs needs to do
> ordered writes. The write ordering must remain irrelevant to the page-LRU
> order.

Note that ordered writes are going to change how we do things _anyway_,
regardless of whether we have flush_dirty_buffers() or use the LRU list.

So that's a non-argument: neither of the two routines can handle ordered
writes at this point.

You could argue that the simple single ordered queue that is currently in
use by flush_dirty_buffers() might be easier to adopt to ordering. 

I can tell you already that you'd be wrong to argue that. Exactly because
of the fact that we _need_ the page-oriented flushing regardless of what
we do. So we need to solve the page case anyway. Which means that it will
obviously be easiest to solve just _one_ problem (the page case) than to
solve two problems (the page case _and_ the flush_dirty_buffers() case).

Basically the ordered write case will need extra logic, and we might as
well put the effort in just one place anyway. Note that the page case
isn't necessarily any harder in the end - the simple solution might be
something like just adding a generation count to the buffer head, and
having try_to_free_buffers() just refuse to write stuff out before that
generation has come to pass.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
