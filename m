Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DCC7A6B0088
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:14:29 -0400 (EDT)
Date: Wed, 22 May 2013 09:13:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-ID: <20130521231358.GV29466@dastard>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368432760-21573-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 13, 2013 at 09:12:31AM +0100, Mel Gorman wrote:
> This series does not fix all the current known problems with reclaim but
> it addresses one important swapping bug when there is background IO.

....
> 
>                             3.10.0-rc1  3.10.0-rc1
>                                vanilla lessdisrupt-v4
> Page Ins                       1234608      101892
> Page Outs                     12446272    11810468
> Swap Ins                        283406           0
> Swap Outs                       698469       27882
> Direct pages scanned                 0      136480
> Kswapd pages scanned           6266537     5369364
> Kswapd pages reclaimed         1088989      930832
> Direct pages reclaimed               0      120901
> Kswapd efficiency                  17%         17%
> Kswapd velocity               5398.371    4635.115
> Direct efficiency                 100%         88%
> Direct velocity                  0.000     117.817
> Percentage direct scans             0%          2%
> Page writes by reclaim         1655843     4009929
> Page writes file                957374     3982047

Lots more file pages are written by reclaim. Is this from kswapd
or direct reclaim? If it's direct reclaim, what happens when you run
on a filesystem that doesn't allow writeback from direct reclaim?

Also, what does this do to IO patterns and allocation? This tends
to indicate that the background flusher thread is not doing the
writeback work fast enough when memory is low - can you comment on
this at all, Mel?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
