Date: Mon, 27 Dec 1999 17:31:58 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9912271708240.335-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 1999, Benjamin C.R. LaHaise wrote:

>The buffer dirty lists are the wrong place to be dealing with this.  We

The only reason for not using buffer.c is to make sure to not insert bugs
in such file.

>need a lightweight, fast way of monitoring the system's dirty buffer/page

The lightweight/fastway is a counter and we just have it. You only want to
split it in two parts.

Actually I am not completly against splitting into two parts. Note that my
reply was just to make clear that there is _just_ this "monitoring"
counter. The "need of two filesystem" to exploit the problem showed you at
least partially misunderstood the current code and so I explained how
thing works right now.

>thresholds -- one that can be called for every write to a page or on the
>write faults for cow pages.

The cow write faults have really nothing to do with this. In a cow both
the old page is clean and can be unmapped and the copy is anonymous and
can be swapped out so nothing is unfreeable there.

>I don't agree, both for the reasons above and because doing a
>balance_dirty in mark_buffer_dirty tends to result in stalls in the
>*wrong* place, because it tends to stall in the middle of an operation,

It's always the *wrong* place because every balance_dirty tends to stall
in the middle of an operation.

Try to copy data in 2.3.x and you'll stall in the middle of the
block_*write* stuff. Do you suggest to remove the balance_dirty() from
there as well so the code won't stall?

>not before it has begun.  You end up stalling on metadata operations that
>shouldn't stall.  The stall thresholds for data vs metadata have to be

If you don't want to stall there then buy a faster harddisk so all the
metadata writes will be done async.

If you generate 1 gigabyte of dirty data in 1 sec and you only have
10mbyte of RAM, then you _must_ stall or you'll go OOM. You choose to go
OOM and that's definitely a very bad design bug.

>different in order to make the system 'feel' right.  This is easily
>accomplished by trying to "allocate" the dirty buffers before you actually
>dirty them (by checking if there's enough slack in the dirty buffer

How can you make a buffer dirty without first allocate it? I'd like to
know.

>margins before doing the operation).

This make no sense at all to me. Sorry.

The only two reasons for not calling balance_dirty() inside
mark_buffer_dirty() are:

o	it was not possible to call balance_dirty() at mark_buffer_dirty()
	time, because it happened inside an atomical critical section.

o	you are going to mark a couple of buffer dirty at the same time
	(see block_write_full_page for example) and so you want to
	coalesce four balance_dirty() in one balance_dirty() to improve
	performances.

Both cases make perfect sense and I sure agree we need to be able to do
that. But (silenty) breaking all old fs to do the above two things is very
silly IMHO.

I am not doing a new patch because the first one is just been rejected
(with explicit commentary) some month ago.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
