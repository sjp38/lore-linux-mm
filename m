Received: from mail.ccr.net (ccr@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA30531
	for <linux-mm@kvack.org>; Sat, 6 Feb 1999 16:43:09 -0500
Subject: Re: [PATCH] Fix for VM deadlock in 2.2.1
References: <199902051653.QAA01763@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 06 Feb 1999 14:07:16 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Fri, 5 Feb 1999 16:53:38 GMT"
Message-ID: <m190ebuwi3.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> The way to completely eliminate the problem is for the VM to avoid this
ST> recursion in the first place.  The patch below adds a new kpiod (page IO
ST> daemon) thread to augment kswapd.  All filemap page writes get queued to
ST> this thread for IO rather than being executed in the context of the
ST> caller, and the caller never blocks waiting for that IO to complete.  In
ST> other words, the caller can never fail eventually to release any vfs
ST> locks currently held, so the page write is guaranteed to succeed
ST> eventually.  Even recursive allocations within the kpiod thread are
ST> safe, since that just results in a queuing of the recursive page write:
ST> the actual IO is deferred until the kpiod thread loops to its next
ST> request.

When I was experimenting with something similiar, (but as a much more
common case) I had the problem of not waiting on pages that were being
written out if there was no other freable memory.   Which caused
programs that should have continued via mapping to die due to memory
allocation failure. 

This isn't likely to be an issue except for programs that use file
backed storage, exclusively, or nearly so.

I solved it with a wait_on_any_page routine that had a timeout, to
prevent any chance of deadlock.  Andreas work of adding a schedule_yield
appears to be a complementary common case fix, of making it likely the
i/o gets started.

Unless this becomes an issue we can probably just put this in the
queue of things to think about.  If the i/o queue was the common case
I'd be adapting my code right now.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
