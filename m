Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DD598D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 09:15:47 -0400 (EDT)
Date: Mon, 1 Nov 2010 20:07:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/4] writeback: quit background/periodic work when
 other works are enqueued
Message-ID: <20101101120733.GA9006@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100914124033.GA4874@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Jan,

Sorry for the long delay!

On Tue, Sep 14, 2010 at 08:40:33PM +0800, Jan Kara wrote:
>   Hi,
> 
> On Mon 13-09-10 20:31:12, Wu Fengguang wrote:
> >  From: Jan Kara <jack@suse.cz>
> > 
> > Background writeback and kupdate-style writeback are easily livelockable
> > (from a definition of their target). This is inconvenient because it can
> > make sync(1) stall forever waiting on its queued work to be finished.
> > Fix the problem by interrupting background and kupdate writeback if there
> > is some other work to do. We can return to them after completing all the
> > queued work.
>   I actually have a slightly updated version with a better changelog:
> 
> Background writeback are easily livelockable (from a definition of their
> target). This is inconvenient because it can make sync(1) stall forever waiting
> on its queued work to be finished. Generally, when a flusher thread has
> some work queued, someone submitted the work to achieve a goal more specific
> than what background writeback does. So it makes sense to give it a priority
> over a generic page cleaning.
> 
> Thus we interrupt background writeback if there is some other work to do. We
> return to the background writeback after completing all the queued work.
> 
>   Could you please update it? Thanks.
> 								Honza
> 
> PS: I've also attached the full patch if that's more convenient for you.

You patches are more complete than mine, so let's use them. However I
do prefer to have a standalone wb_check_background_flush() that is
called _after_ wb_check_old_data_flush(). This helps make the writeout
a bit more ordered and the separation itself looks a bit more clean to
me.

Followed are the slightly updated patches. IMHO they are straightforward
fixes that could be merged before other writeback changes.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
