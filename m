Date: Tue, 7 Nov 2000 11:17:14 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001107111714.B1384@redhat.com>
References: <20001102134021.B1876@redhat.com> <20001103232721.D27034@athlon.random> <20001106150539.A19112@redhat.com> <20001106171204.B22626@athlon.random> <20001106165416.A27036@redhat.com> <20001106233457.A1276@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001106233457.A1276@inspiron.random>; from andrea@suse.de on Mon, Nov 06, 2000 at 11:34:57PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Nov 06, 2000 at 11:34:57PM +0100, Andrea Arcangeli wrote:
> On Mon, Nov 06, 2000 at 04:54:16PM +0000, Stephen C. Tweedie wrote:
> 
> About the implementation of the missing VM infrastructure for handling page
> dirty at the physical pagecache layer, I'd suggest to change ramfs to use a new
> PG_protected bitfield with the current semantics of PG_dirty, and to use
> PG_dirty for the stuff that we must flush to disk.

PG_dirty works for some cases.  In particular, it works for any
filesystems which can safely ignore the struct file * in the writepage
address_space operation.  However, for things like NFS, we cannot ever
to arbitrary writeback to a file from the page cache --- we need the
user context of the original write in order to establish the
credentials for the server operation.

That's why my current bug-fix patch just does the writepage at the end
of the raw IO: it's a general fix which works for all mmap types.
Once that is in place, we can think about extending it so that
filesystems can provide a separate method for "flush" which honurs
PG_dirty.  For filesystems with such a flush method, marking a kiobuf
dirty would simply involve setting PG_dirty, but for others (such as
NFS) the mark_kiobuf_dirty would still have to do the full early
writepage.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
