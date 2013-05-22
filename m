Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7FF106B004D
	for <linux-mm@kvack.org>; Wed, 22 May 2013 04:49:05 -0400 (EDT)
Date: Wed, 22 May 2013 09:48:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-ID: <20130522083722.GU11497@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <20130521231358.GV29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130521231358.GV29466@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 22, 2013 at 09:13:58AM +1000, Dave Chinner wrote:
> On Mon, May 13, 2013 at 09:12:31AM +0100, Mel Gorman wrote:
> > This series does not fix all the current known problems with reclaim but
> > it addresses one important swapping bug when there is background IO.
> 
> ....
> > 
> >                             3.10.0-rc1  3.10.0-rc1
> >                                vanilla lessdisrupt-v4
> > Page Ins                       1234608      101892
> > Page Outs                     12446272    11810468
> > Swap Ins                        283406           0
> > Swap Outs                       698469       27882
> > Direct pages scanned                 0      136480
> > Kswapd pages scanned           6266537     5369364
> > Kswapd pages reclaimed         1088989      930832
> > Direct pages reclaimed               0      120901
> > Kswapd efficiency                  17%         17%
> > Kswapd velocity               5398.371    4635.115
> > Direct efficiency                 100%         88%
> > Direct velocity                  0.000     117.817
> > Percentage direct scans             0%          2%
> > Page writes by reclaim         1655843     4009929
> > Page writes file                957374     3982047
> 
> Lots more file pages are written by reclaim. Is this from kswapd
> or direct reclaim? If it's direct reclaim, what happens when you run
> on a filesystem that doesn't allow writeback from direct reclaim?
> 

It's from kswapd. There is a check in shrink_page_list that prevents direct
reclaim writing pages out for exactly the reason that some filesystems
ignore it.

> Also, what does this do to IO patterns and allocation? This tends
> to indicate that the background flusher thread is not doing the
> writeback work fast enough when memory is low - can you comment on
> this at all, Mel?
> 

There are two aspects to it. As processes are not longer being pushed
to swap but kswapd is still reclaiming a similar number of pages, it is
scanning through the file LRUs faster before flushers have a chance to
flush pages. kswapd starts writing pages if the zone gets marked "reclaim
dirty" which happens if enough dirty pages are encountered at the end of
the LRU that are !PageWriteback. If this flag is set too early then more
writes from kswapd context occur -- I'll look into it.

On a related note, I've found with Jan Kara that the PageWriteback check
does not work in all cases. Some filesystems will have buffer pages that
are PageDirty with all clean buffers or with buffers locked for IO that are
!PageWriteback which will also confuse when "reclaim dirty" gets set. The
patches are still being a work in progress.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
