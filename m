Date: Tue, 21 Dec 1999 11:18:03 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <14430.51369.57387.224846@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 1999, Stephen C. Tweedie wrote:

>    refile_buffer() checks in buffer.c.  Ideally there should be a
>    system-wide upper bound on dirty data: if each different filesystem
>    starts to throttle writes at 50% of physical memory then you only
>    need two different filesystems to overcommit your memory badly.

If all FSes shares the dirty list of buffer.c that's not true. All normal
filesystems are using the mark_buffer_dirty() in buffer.c so currently the
40% setting of bdflush is a system-wide number and not a per-fs number.

>    same time.  Making the refile_buffer() checks honour that global
>    threshold would be trivial.  

If both ext3 and reiserfs are using refile_buffer and both are using
balance_dirty in the right places as Linus wants, all seems just fine to
me.

I disagree since 2.3.10 (or similar) about mark_buffer_dirty not including
the balance_dirty() check (and I just provided patches to fix that some
month ago IIRC). Last time I checked ext2 was harmed by this, and we'll
have to add the proper balance_dirty() in the ext2 mknod path and check
the rest.

I completly agree to change mark_buffer_dirty() to call balance_dirty()
before returning. But if you add the balance_dirty() calls all over the
right places all should be _just_ fine as far I can tell.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
