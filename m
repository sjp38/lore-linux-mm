Date: Mon, 2 Oct 2000 19:23:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001003001834.A25467@athlon.random>
Message-ID: <Pine.LNX.4.21.0010021920260.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 02, 2000 at 07:08:20PM -0300, Rik van Riel wrote:
> > Yes it has. The write order in flush_dirty_buffers() is the order
> > in which the pages were written. This may be different from the
> > LRU order and could give us slightly better IO performance.
> 
> And it will forbid us to use barriers in software elevator and
> in SCSI hardware to avoid having to wait I/O completation every
> time a journaling fs needs to do ordered writes. The write
> ordering must remain irrelevant to the page-LRU order.

The solution to that is the page->mapping->flush() callback.

The VM doesn't write out any page themselves without going
through that (filesystem specific) function, where the
filesystem can do the following things:

1) do IO optimisations (IO clustering, delayed allocation)
2) check write ordering constraints
3) write out something else instead if write ordering means
   we can't flush this page yet

Note that the VM doesn't /really/ care if the page selected
doesn't become freeable immediately. There are always more
inactive pages around...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
