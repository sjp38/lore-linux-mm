Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18337
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 12:56:14 -0500
Date: Wed, 13 Jan 1999 17:55:56 GMT
Message-Id: <199901131755.RAA06476@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: [PATCH] Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990113144203.284C-100000@laser.bogus>
References: <Pine.LNX.4.03.9901122245090.4656-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.990113144203.284C-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 13 Jan 1999 14:45:09 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Tue, 12 Jan 1999, Rik van Riel wrote:
>> IIRC this facility was in the original swapin readahead
>> implementation. That only leaves the question who removed
>> it and why :))

> There's another thing I completly disagree and that I just removed here. 
> It's the alignment of the offset field. I see no one point in going back
> instead of only doing real read_ahead_. 

> Maybe I am missing something?

Yes, very much so.

When paging in binaries, you often have locality of reference in both
directions --- a set of functions compiled from a single source file
will occupy adjacent pages in VM, but you are as likely to call a
function at the end of the region first as one at the beginning.  It
is very common to get backwards locality as a result.

The big advantage of doing aligned clusters for readin is twofold:
first, it means that you get as much of a readahead advantage for
these backwards access patterns as for forward accesses.  Secondly, it
means that you are reading in complete tiles which are guaranteed to
have no gaps between them, so any two accesses in adjacent tiles are
sufficient to read in the complete set of nearby pages without missing
any gaps between them: it avoids having to do yet another IO to fill
in the few pages missed by a strictly forward-looking readahead
function.

> +		  /* don't block on I/O for doing readahead -arca */
> +		  atomic_read(&nr_async_pages) > pager_daemon.max_async_pages)
>  		      return;

I think this is the wrong solution: far better to do the patch below,
which simply exempts reads from nr_async_pages altogether.  I
originally added nr_async_pages to serve two functions: to allow
kswapd to determine how much memory it was already in the process of
freeing, and to act as a throttle on the number of write IOs submitted
when swapping.

We don't need a similar throttling action for reads, because every
place where we do VM readahead, each readahead IO cluster is followed
by a synchronous read on one page.  We don't throttle the async
readaheads on normal file IO, for example.

--Stephen

----------------------------------------------------------------
--- mm/page_io.c~	Mon Dec 28 21:56:29 1998
+++ mm/page_io.c	Tue Jan 12 16:45:55 1999
@@ -58,7 +58,8 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
+	if (rw == WRITE &&
+	    atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
@@ -170,7 +171,7 @@
 		atomic_dec(&page->count);
 		return;
 	}
- 	if (!wait) {
+ 	if (rw == WRITE && !wait) {
  		set_bit(PG_decr_after, &page->flags);
  		atomic_inc(&nr_async_pages);
  	}
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
