Date: Mon, 9 Sep 2002 10:10:02 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <3D7C6C0A.1BBEBB2D@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209091004200.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, Andrew Morton wrote:

> I fiddled with it a bit:  did you forget to move the write(2) pages
> to the inactive list?  I changed it to do that at IO completion.
> It had little effect.  Probably should be looking at the page state
> before doing that.

Hmmm indeed, I forgot this.  Note that IO completion state is
too late, since then you'll have already pushed other pages
out to the inactive list...

> The inactive list was smaller with this patch.  Around 10%
> of allocatable memory usually.

It should be a bit bigger than this, I think.  If it isn't
something may be going wrong ;)

> I like the way in which the patch improves the reclaim success rate.
> It went from 50% to 80 or 90%.

That should help reduce the randomizing of the inactive list ;)

> It worries me that the inactive list is so small.  But I need to
> test it more.

It's actually ok, though a larger inactive list might help with
some workloads (or make the system worse with some others?).

> (This patch looks a lot like NRU - what's the difference?)

For mapped pages, it basically is NRU.  For normal cache pages,
references while on the active list don't count, they will still
get evicted. Only references while on the inactive list can save
such a page.

What this means is that (in clock terminology) the handspread
for non-mapped cache pages is much smaller than for mapped pages.
With an inactive list size of 10%, the handspread for mapped pages
is about 10 times as wide as that for non-mapped pages, giving the
mapped pages a bit of an advantage over the cache...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
