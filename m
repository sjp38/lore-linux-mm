Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA01874
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 22:09:01 -0500
Date: Tue, 8 Dec 1998 04:00:10 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <366C9447.2B4E9693@thrillseeker.net>
Message-ID: <Pine.LNX.3.96.981208035549.9425A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Billy Harvey <Billy.Harvey@thrillseeker.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Billy Harvey wrote:
> Rik van Riel wrote:
> > 
> > On Mon, 7 Dec 1998, Billy Harvey wrote:
> > 
> > > Has anyone ever looked at the following concept?  In addition to a
> > > swap-in read-ahead, have a swap-out write-ahead.  The idea is to use
> > > all the avaialble swap space as a mirror of memory.
> > 
> > We do something a bit like this in 2.1.130+. Writing out all
> > pages to swap will use far too much I/O bandwidth though, so
> > we will never do that...
> 
> That's my point though about not taking I/O time away from other
> tasks.  Only mirror pages to swap if there's nothing else blocked
> for I/O - put any free time to work, and mirror pages if swap memory
> allows in anticipation that it may be swapped out later. 

Write-ahead only makes sense when we can cluster the extra
I/O with the operation we were already going to do.

> I suppose a least-recently-used approach on the pages would have the
> highest payback. 

LRU would be a very bad strategy since it wastes too much CPU
and it prevents us from writing the blocks to disk in such a
way that it makes swapin readahead efficient.

Remember that disk seek time is about 10 times as expensive
as transfer time. This means that we've got to optimize our
I/O patterns mainly for seek time -- transferring a few
blocks extra in one big I/O sweep isn't really costing us
anything. And once we do that, expensive schemes like LRU
really don't matter any more, do they?

regards,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
