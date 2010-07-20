Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF27B6B02A3
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:06:00 -0400 (EDT)
Date: Wed, 21 Jul 2010 00:05:51 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100720220550.GF16031@cmpxchg.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-9-git-send-email-mel@csn.ul.ie>
 <20100719142349.GE12510@infradead.org>
 <20100719143737.GQ13117@csn.ul.ie>
 <20100719224838.GC16031@cmpxchg.org>
 <20100720141049.GV13117@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100720141049.GV13117@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 03:10:49PM +0100, Mel Gorman wrote:
> On Tue, Jul 20, 2010 at 12:48:39AM +0200, Johannes Weiner wrote:
> > On Mon, Jul 19, 2010 at 03:37:37PM +0100, Mel Gorman wrote:
> > > although the latter can get disabled too. Deleting the magic is an
> > > option which would trade IO efficiency for power efficiency but my
> > > current thinking is laptop mode preferred reduced power.
> > 
> > Maybe couple your wakeup with sc->may_writepage?  It is usually false
> > for laptop_mode but direct reclaimers enable it at one point in
> > do_try_to_free_pages() when it scanned more than 150% of the reclaim
> > target, so you could use existing disk spin-up points instead of
> > introducing new ones or disabling the heuristics in laptop mode.
> > 
> 
> How about the following?
> 
>         if (nr_dirty && sc->may_writepage)
>                 wakeup_flusher_threads(laptop_mode ? 0 :
>                                                 nr_dirty + nr_dirty / 2);
> 
> 
> 1. Wakup flusher threads if dirty pages are encountered
> 2. For direct reclaim, only wake them up if may_writepage is set
>    indicating that the system is ready to spin up disks and start
>    reclaiming
> 3. In laptop_mode, flush everything to reduce future spin-ups

Sounds like the sanest approach to me.  Thanks.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
