Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA26289
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 07:27:39 -0500
Date: Wed, 25 Nov 1998 12:27:25 GMT
Message-Id: <199811251227.MAA00808@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <Pine.LNX.3.96.981125073253.30767B-100000@mirkwood.dummy.home>
References: <19981124214432.2922.qmail@sidney.remcomp.fr>
	<Pine.LNX.3.96.981125073253.30767B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: jfm2@club-internet.fr, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 07:41:41 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> When the mythical swapin readahead will be merged, we can
> gain some ungodly amount of speed almost for free. I don't
> know if we'll ever implement the scheduling tricks...

Agreed: usage patterns these days are very different.  We simply don't
expect to run parallel massive processes whose combined working sets
exceed physical memory these days.  Making sure that we don't thrash to
death is still an important point, but we can achieve that by
guaranteeing processes a minimum rss quota (so that only those processes
exceeding that quota compete for the remaining physical memory).

> I do have a few ideas for the scheduling stuff though, with
> RSS limits (we can safely implement those when the swap cache
> trick is implemented) and the keeping of a few statistics,
> we will be able to implement the swapping tricks.

Rick, get real: when will you work out how the VM works?  We can safely
implement RSS limits *today*, and have been able to since 2.1.89.
<grin>  It's just a matter of doing a vmscan on the current process
whenever it exceeds its own RSS limit.  The mechanism is all there.

> Without swapin readahead, we'll be unable to implement them
> properly however :(

No, we don't need readahead (although the swap cache itself already
includes all of the necessary mechanism: rw_swap_page(READ, nowait) will
do it).  The only extra functionality we might want is extra control
over when we write swap-cached pages: right now, all dirty pages need to
be in the RSS, and we write them to disk when we evict them to the swap
cache.  Thus, only clean pages can be in the swap cache.  If we want to
support processes with a dirty working set > RSS, we'd need to extend
this.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
