Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 6C7A76B005A
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:14:49 -0500 (EST)
Date: Mon, 19 Dec 2011 17:14:36 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111219161436.GF1415@cmpxchg.org>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <20111216151703.GA12817@redhat.com>
 <20111216160728.GI3487@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111216160728.GI3487@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 16, 2011 at 04:07:28PM +0000, Mel Gorman wrote:
> On Fri, Dec 16, 2011 at 04:17:31PM +0100, Johannes Weiner wrote:
> > On Wed, Dec 14, 2011 at 03:41:33PM +0000, Mel Gorman wrote:
> > > It was observed that scan rates from direct reclaim during tests
> > > writing to both fast and slow storage were extraordinarily high. The
> > > problem was that while pages were being marked for immediate reclaim
> > > when writeback completed, the same pages were being encountered over
> > > and over again during LRU scanning.
> > > 
> > > This patch isolates file-backed pages that are to be reclaimed when
> > > clean on their own LRU list.
> > 
> > Excuse me if I sound like a broken record, but have those observations
> > of high scan rates persisted with the per-zone dirty limits patchset?
> > 
> 
> Unfortunately I wasn't testing that series. The focus of this series
> was primarily on THP-related stalls incurred by compaction which
> did not have a dependency on that series. Even with dirty balancing,
> similar stalls would be observed once dirty pages were in the zone
> at all.
> 
> > In my tests with pzd, the scan rates went down considerably together
> > with the immediate reclaim / vmscan writes.
> > 
> 
> I probably should know but what is pzd?

Oops.  Per-Zone Dirty limits.

> > Our dirty limits are pretty low - if reclaim keeps shuffling through
> > dirty pages, where are the 80% reclaimable pages?!  To me, this sounds
> > like the unfair distribution of dirty pages among zones again.  Is
> > there are a different explanation that I missed?
> > 
> 
> The alternative explanation is that the 20% dirty pages are all
> long-lived, at the end of the highest zone which is always scanned first
> so we continually have to scan over these dirty pages for prolonged
> periods of time.

That certainly makes sense to me and is consistent with your test case
having a fast producer of clean cache while the dirty cache is against
a slow backing device, so it may survive multiple full inactive cycles
before writeback finishes.

> > PS: It also seems a bit out of place in this series...?
> 
> Without the last path, the System CPU time was stupidly high. In part,
> this is because we are no longer calling ->writepage from direct
> reclaim. If we were, the CPU usage would be far lower but it would
> be a lot slower too. It seemed remiss to leave system CPU usage that
> high without some explanation or patch dealing with it.
> 
> The following replaces this patch with your series. dirtybalance-v7r1 is
> yours.
> 
>                    3.1.0-vanilla         rc5-vanilla       freemore-v6r1        isolate-v6r1   dirtybalance-v7r1
> System Time         1.22 (    0.00%)   13.89 (-1040.72%)   46.40 (-3709.20%)    4.44 ( -264.37%)   43.05 (-3434.81%)
> +/-                 0.06 (    0.00%)   22.82 (-37635.56%)    3.84 (-6249.44%)    6.48 (-10618.92%)    4.04 (-6581.33%)
> User Time           0.06 (    0.00%)    0.06 (   -6.90%)    0.05 (   17.24%)    0.05 (   13.79%)    0.05 (   20.69%)
> +/-                 0.01 (    0.00%)    0.01 (   33.33%)    0.01 (   33.33%)    0.01 (   39.14%)    0.01 (   -1.84%)
> Elapsed Time     10445.54 (    0.00%) 2249.92 (   78.46%)   70.06 (   99.33%)   16.59 (   99.84%)   73.71 (   99.29%)
> +/-               643.98 (    0.00%)  811.62 (  -26.03%)   10.02 (   98.44%)    7.03 (   98.91%)   17.90 (   97.22%)
> THP Active         15.60 (    0.00%)   35.20 (  225.64%)   65.00 (  416.67%)   70.80 (  453.85%)  102.60 (  657.69%)
> +/-                18.48 (    0.00%)   51.29 (  277.59%)   15.99 (   86.52%)   37.91 (  205.18%)   26.06 (  141.02%)
> Fault Alloc       121.80 (    0.00%)   76.60 (   62.89%)  155.40 (  127.59%)  181.20 (  148.77%)  214.80 (  176.35%)
> +/-                73.51 (    0.00%)   61.11 (   83.12%)   34.89 (   47.46%)   31.88 (   43.36%)   53.21 (   72.39%)
> Fault Fallback    881.20 (    0.00%)  926.60 (   -5.15%)  847.60 (    3.81%)  822.00 (    6.72%)  788.40 (   10.53%)
> +/-                73.51 (    0.00%)   61.26 (   16.67%)   34.89 (   52.54%)   31.65 (   56.94%)   53.41 (   27.35%)
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)       3540.88   1945.37    716.04     64.97    715.04
> Total Elapsed Time (seconds)              52417.33  11425.90    501.02    230.95    549.64
> 
> Your series does help the System CPU time begining it from 46.4 seconds
> to 43.05 seconds. That is within the noise but towards the edge of
> one standard deviation. With such a small reduction, elapsed time was
> not helped. However, it did help THP allocation success rates - still
> within the noise but again at the edge of the noise which indicates
> a solid improvement.
> 
> MMTests Statistics: vmstat
> Page Ins                                  3257266139  1111844061    17263623    10901575    20870385
> Page Outs                                   81054922    30364312     3626530     3657687     3665499
> Swap Ins                                        3294        2851        6560        4964        6598
> Swap Outs                                     390073      528094      620197      790912      604228
> Direct pages scanned                      1077581700  3024951463  1764930052   115140570  1796314840
> Kswapd pages scanned                        34826043     7112868     2131265     1686942     2093637
> Kswapd pages reclaimed                      28950067     4911036     1246044      966475     1319662
> Direct pages reclaimed                     805148398   280167837     3623473     2215044     4182274
> Kswapd efficiency                                83%         69%         58%         57%         63%
> Kswapd velocity                              664.399     622.521    4253.852    7304.360    3809.106
> Direct efficiency                                74%          9%          0%          1%          0%
> Direct velocity                            20557.737  264745.137 3522673.849  498551.938 3268166.145
> Percentage direct scans                          96%         99%         99%         98%         99%
> Page writes by reclaim                        722646      529174      620319      791018      604368
> Page writes file                              332573        1080         122         106         140
> Page writes anon                              390073      528094      620197      790912      604228
> Page reclaim immediate                             0  2552514720  1635858848   111281140  1661416934
> Page rescued immediate                             0           0           0       87848           0
> Slabs scanned                                  23552       23552        9216        8192        8192
> Direct inode steals                              231           0           0           0           0
> Kswapd inode steals                                0           0           0           0           0
> Kswapd skipped wait                            28076         786           0          61           1
> THP fault alloc                                  609         383         753         906        1074
> THP collapse alloc                                12           6           0           0           0
> THP splits                                       536         211         456         593         561
> THP fault fallback                              4406        4633        4263        4110        3942
> THP collapse fail                                120         127           0           0           0
> Compaction stalls                               1810         728         623         779         869
> Compaction success                               196          53          60          80          99
> Compaction failures                             1614         675         563         699         770
> Compaction pages moved                        193158       53545      243185      333457      409585
> Compaction move failure                         9952        9396       16424       23676       30668
> 
> The direct page scanned figure with your patch is still very high
> unfortunately.
> 
> Overall, I would say that your series is not a replacement for the last
> patch in this series. 

Agreed, thanks for clearing this up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
