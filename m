Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA14799
	for <linux-mm@kvack.org>; Fri, 24 Jul 1998 18:12:58 -0400
Date: Fri, 24 Jul 1998 23:55:10 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87ww93dvyt.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.980724234821.31219A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 24 Jul 1998, Zlatko Calusic wrote:

> > There's also a 'soft limit', or borrow percentage. Ultimately
> > the minimum and maximum percentages should be 0 and 100 %
> > respectively.
> 
> Could you elaborate on "borrow" percentage? I have some trouble
> understanding what that could be.

It's an idea I stole from Digital Unix :)

Basically, the cache is allowed to grow boundless, but is
reclaimed until it reaches the borrow percentage when
memory is short.

The philosophy behind is that caching the disk doesn't make
much sense beyond a certain point.

It's a primitive idea, but it seems to have saved Andrea's
machine quite well (with the additional patch).

I admit your patch (multiple aging) should work even better,
but in order to do that, we probably want to make it auto-tuning
on the borrow percentage:

- if page_cache_size > borrow + 5%     --> add aging loop
- if loads_of_disk_io and almost thrashing [*] --> remove aging loop

[*] this thrashing can be measured by testing the cache hit/mis
rate; if it falls below (say) 50% we could consider thrashing.

(50% should be a good rate for an aging cache, and the amount
of loops is trimmed quickly enough when we grow anyway. This
mechanism could make a nice somewhat adjusting trimming
mechanism. Expect a patch soon...)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
