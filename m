From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14432.6983.669104.707472@dukat.scot.redhat.com>
Date: Wed, 22 Dec 1999 00:28:55 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <Pine.LNX.4.21.9912211434320.26889-100000@Fibonacci.suse.de>
References: <14431.32449.832594.222614@dukat.scot.redhat.com>
	<Pine.LNX.4.21.9912211434320.26889-100000@Fibonacci.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 21 Dec 1999 14:57:29 +0100 (CET), Andrea Arcangeli
<andrea@suse.de> said:

> So you are talking about replacing this line:
> 	dirty = size_buffers_type[BUF_DIRTY] >> PAGE_SHIFT;
> with:
> 	dirty = (size_buffers_type[BUF_DIRTY]+size_buffers_type[BUF_PINNED]) >> PAGE_SHIFT;

Basically yes, but I was envisaging something slightly different from
the above.

There may well be data which is simply not in the buffer cache at all
but which needs to be accounted for as pinned memory.  A good example
would be if some filesystem wants to implement deferred allocation of
disk blocks: the corresponding pages in the page cache obviously cannot
be flushed to disk without generating extra filesystem activity for the
allocation of disk blocks to pages.  The pages must therefore be pinned,
but as they don't yet have disk mappings we can't assume that they are
in the buffer cache.

So we really need a pinned page threshold which can apply to general
pages, not necessarily to the buffer cache.


There's another issue, though.  BUF_DIRTY buffers do not necessarily
count as pinned in this context: they can always be flushed to disk
without generating any significant new memory allocation pressure.  We
still need to do write-throttling, so we need a threshold on dirty data
for that reason.  However, deferred allocation and transactions actually
have a more subtle and nastier property: you cannot necessarily flush
the pages from memory without first allocating more memory.

In the transaction case this is because you have to allow transactions
which are already in progress to complete before you can commit the
transaction (you cannot commit incomplete transactions because that
would defeat the entire point of a transactional system!).  In the case
of deferred disk block allocation, the problem is that flushing the
dirty data requires extra filesystem operations as we allocate disk
blocks to pages.

In these cases we need to be able to make sure that not only does pinned
memory never exceed a threshold, we also have to ensure that the
*future* allocations required to flush the existing allocated memory can
also be satisfied.  We need to allow filesystems to "reserve" such extra
memory, and we need a system-wide threshold on all such reservations.

The ext3 journaling code already has support for reservations, but
that's currently a per-filesystem parameter.  We still have need for a
global VM reservation to prevent memory starvation if multiple different
filesystems have this behaviour.


Note that what we need here isn't complex: it's no more than exporting
atomic_t counts of the number of dirty and reserved pages in the system
and supporting a maximum threshold on these values via /proc.  The
mechanism for observing these limits can be local to each filesystem: as
long as there is an agreed counter in the VM where they can register
their use of memory.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
