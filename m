Subject: Re: [patch v2] vmscan: protect zone rotation stats by lru lock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <49345B3B.30703@redhat.com>
References: <E1L6y5T-0003q3-M3@cmpxchg.org>
	 <20081201134112.24c647ff.akpm@linux-foundation.org>
	 <49345B3B.30703@redhat.com>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 17:09:45 -0500
Message-Id: <1228169385.18834.136.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@saeurebad.de>, torvalds@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 16:46 -0500, Rik van Riel wrote:
> Andrew Morton wrote:
> > On Mon, 01 Dec 2008 03:00:35 +0100
> > Johannes Weiner <hannes@saeurebad.de> wrote:
> > 
> >> The zone's rotation statistics must not be accessed without the
> >> corresponding LRU lock held.  Fix an unprotected write in
> >> shrink_active_list().
> >>
> > 
> > I don't think it really matters.  It's quite common in that code to do
> > unlocked, racy update to statistics such as this.  Because on those
> > rare occasions where a race does happen, there's a small glitch in the
> > reclaim logic which nobody will notice anyway.
> > 
> > Of course, this does need to be done with some care, to ensure the
> > glitch _will_ be small.
> 
> Processing at most SWAP_CLUSTER_MAX pages at once probably
> ensures that glitches will be small most of the time.
> 
> The only way this could be a big problem is if we end up
> racing with the divide-by-two logic in get_scan_ratio,
> leaving the rotated pages a factor two higher than they
> should be.
> 
> Putting all the writes to the stats under the LRU lock
> should ensure that never happens.

And he's not actually adding a lock.  Just moving the exiting one up to
include the stats update.  The intervening pagevec, pgmoved and lru
initializations don't need to be under the lock, but that's probably not
a big deal?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
