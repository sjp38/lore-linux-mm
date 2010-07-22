Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E16A36B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:13:49 -0400 (EDT)
Date: Thu, 22 Jul 2010 09:13:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100722011342.GB5154@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20100719142145.GD12510@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 10:21:45PM +0800, Christoph Hellwig wrote:
> On Mon, Jul 19, 2010 at 02:11:29PM +0100, Mel Gorman wrote:
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > A background flush work may run for ever. So it's reasonable for it to
> > mimic the kupdate behavior of syncing old/expired inodes first.
> > 
> > This behavior also makes sense from the perspective of page reclaim.
> > File pages are added to the inactive list and promoted if referenced
> > after one recycling. If not referenced, it's very easy for pages to be
> > cleaned from reclaim context which is inefficient in terms of IO. If
> > background flush is cleaning pages, it's best it cleans old pages to
> > help minimise IO from reclaim.
> 
> Yes, we absolutely do this.  Wu, do you have an improved version of the
> pending or should we put it in this version for now?

Sorry for the delay! The code looks a bit hacky, and there is a problem:
it only decrease expire_interval and never increase/reset it.
So it's possible when dirty workload first goes light then goes heavy,
expire_interval may be reduced to 0 and never be able to grow up again.
In the end we revert to the old behavior of ignoring dirtied_when totally.

A more complete solution would be to make use of older_than_this not
only for the kupdate case, but also for the background and sync cases.
The policies can be most cleanly carried out in move_expired_inodes().

- kupdate: older_than_this = jiffies - 30s
- background: older_than_this = TRY FROM (jiffies - 30s) TO (jiffies),
                                UNTIL get some inodes to sync
- sync: older_than_this = start time of sync

I'll post an untested RFC patchset for the kupdate and background
cases. The sync case will need two more patch series due to other
problems.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
