Date: Tue, 3 Oct 2000 01:20:39 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001003012039.B27493@athlon.random>
References: <20001003001834.A25467@athlon.random> <Pine.LNX.4.10.10010021559120.2206-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010021559120.2206-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Oct 02, 2000 at 04:06:25PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 04:06:25PM -0700, Linus Torvalds wrote:
> So that's a non-argument: neither of the two routines can handle ordered
> writes at this point.

Correct.

> You could argue that the simple single ordered queue that is currently in
> use by flush_dirty_buffers() might be easier to adopt to ordering. 

Right.

> I can tell you already that you'd be wrong to argue that. Exactly because
> of the fact that we _need_ the page-oriented flushing regardless of what
> we do. So we need to solve the page case anyway. Which means that it will

page oriented flushing isn't my point (that happens when we start to have
pressure, I wasn't talking about low on memory scenario). My point is that the
fs can do:

	write to the log and mark it dirty and queue it into the FIFO lru
	queue the barrier into the LRU
	write to the page and mark it dirty and queue it into the same FIFO lru

Now the fs can forget about that and after 30 second kupdate will do both I/O
in one single scsi command doing the I/O in order by respecting the software
and hardware I/O barrier. That would speed up things.

> isn't necessarily any harder in the end - the simple solution might be
> something like just adding a generation count to the buffer head, and
> having try_to_free_buffers() just refuse to write stuff out before that
> generation has come to pass.

This looks worthwhile idea to be able to do the sync_page_buffers thing even
while handling ordered writes.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
