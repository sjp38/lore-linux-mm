Date: Tue, 21 Dec 1999 20:21:05 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
Message-ID: <Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 1999, Andrea Arcangeli wrote:

> On Tue, 21 Dec 1999, Stephen C. Tweedie wrote:
> 
> >    refile_buffer() checks in buffer.c.  Ideally there should be a
> >    system-wide upper bound on dirty data: if each different filesystem
> >    starts to throttle writes at 50% of physical memory then you only
> >    need two different filesystems to overcommit your memory badly.
> 
> If all FSes shares the dirty list of buffer.c that's not true. All normal
> filesystems are using the mark_buffer_dirty() in buffer.c so currently the
> 40% setting of bdflush is a system-wide number and not a per-fs number.

The buffer dirty lists are the wrong place to be dealing with this.  We
need a lightweight, fast way of monitoring the system's dirty buffer/page
thresholds -- one that can be called for every write to a page or on the
write faults for cow pages.

> >    same time.  Making the refile_buffer() checks honour that global
> >    threshold would be trivial.  
> 
> If both ext3 and reiserfs are using refile_buffer and both are using
> balance_dirty in the right places as Linus wants, all seems just fine to
> me.
> 
> I disagree since 2.3.10 (or similar) about mark_buffer_dirty not including
> the balance_dirty() check (and I just provided patches to fix that some
> month ago IIRC). Last time I checked ext2 was harmed by this, and we'll
> have to add the proper balance_dirty() in the ext2 mknod path and check
> the rest.

> I completly agree to change mark_buffer_dirty() to call balance_dirty()
> before returning. But if you add the balance_dirty() calls all over the
> right places all should be _just_ fine as far I can tell.

I don't agree, both for the reasons above and because doing a
balance_dirty in mark_buffer_dirty tends to result in stalls in the
*wrong* place, because it tends to stall in the middle of an operation,
not before it has begun.  You end up stalling on metadata operations that
shouldn't stall.  The stall thresholds for data vs metadata have to be
different in order to make the system 'feel' right.  This is easily
accomplished by trying to "allocate" the dirty buffers before you actually
dirty them (by checking if there's enough slack in the dirty buffer
margins before doing the operation).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
