Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11799
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 09:34:19 -0500
Date: Fri, 4 Dec 1998 14:34:01 GMT
Message-Id: <199812041434.OAA04457@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981204150030.15134N-100000@mirkwood.dummy.home>
References: <199812041134.LAA01682@dax.scot.redhat.com>
	<Pine.LNX.3.96.981204150030.15134N-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 4 Dec 1998 15:02:56 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

>> One odd thing about the readahead: you don't start the readahead until
>> _after_ you have synchronously read in the first swap page of the
>> cluster.  Surely it is better to do the readahead first, so that you
>> are submitting one IO to disk, not two?

> This would severely suck when something else would be doing
> a run_taskqueue(&tq_disk). It would mean that we'd read
> n+1..n+15 before n itself.

No, not at all.  This is already the way we do all readahead
everywhere in the kernel.  

The idea is to do readahead for all the data you want, *including* the
bit you are going to need right away.  Once that is done, you just
wait for the IO to complete on that first item.  In this case, that
means doing a readahead on pages n to n+15 inclusive, and then after
that doing the synchronous read_swap_page on page n.  The kernel will
happily find that page in the swap cache, work out that IO is already
in progress and wait for that page to become available.

Even though the buffer IO request layer issues the entire sequential
IO as one IO to the device drivers, the buffers and pages involved in
the data transfer still get unlocked one by one as the IO completes.
After submitting the initial IO you can wait for that first page to
become unlocked without having to wait for the rest of the readahead
IO to finish.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
