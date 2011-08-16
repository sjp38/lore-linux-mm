Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1673A6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 10:06:58 -0400 (EDT)
Date: Tue, 16 Aug 2011 22:06:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/7] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-ID: <20110816140652.GC13391@localhost>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <1312973240-32576-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312973240-32576-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

Mel,

I tend to agree with the whole patchset except for this one.

The worry comes from the fact that there are always the very possible
unevenly distribution of dirty pages throughout the LRU lists. This
patch works on local information and may unnecessarily throttle page
reclaim when running into small spans of dirty pages.

One possible scheme of global throttling is to first tag the skipped
page with PG_reclaim (as you already do). And to throttle page reclaim
only when running into pages with both PG_dirty and PG_reclaim set,
which means we have cycled through the _whole_ LRU list (which is the
global and adaptive feedback we want) and run into that dirty page for
the second time.

One test scheme would be to read/write a sparse file fast with some
average 5:1 or 10:1 or whatever read:write ratio. This can effectively
spread dirty pages all over the LRU list. It's a practical test since
it mimics the typical file server workload with concurrent downloads
and uploads.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
