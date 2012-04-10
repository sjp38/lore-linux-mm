Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 439966B004D
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 04:32:06 -0400 (EDT)
Date: Tue, 10 Apr 2012 09:32:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/2] Removal of lumpy reclaim
Message-ID: <20120410083201.GB3789@suse.de>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de>
 <20120406123439.d2ba8920.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120406123439.d2ba8920.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On Fri, Apr 06, 2012 at 12:34:39PM -0700, Andrew Morton wrote:
> On Wed, 28 Mar 2012 17:06:21 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > (cc'ing active people in the thread "[patch 68/92] mm: forbid lumpy-reclaim
> > in shrink_active_list()")
> > 
> > In the interest of keeping my fingers from the flames at LSF/MM, I'm
> > releasing an RFC for lumpy reclaim removal.
> 
> I grabbed them, thanks.
> 

There probably will be a V2 as Ying pointed out a problem with patch 1.

> >
> > ...
> >
> > MMTests Statistics: vmstat
> > Page Ins                                     5426648     2840348     2695120
> > Page Outs                                    7206376     7854516     7860408
> > Swap Ins                                       36799           0           0
> > Swap Outs                                      76903           4           0
> > Direct pages scanned                           31981       43749      160647
> > Kswapd pages scanned                        26658682     1285341     1195956
> > Kswapd pages reclaimed                       2248583     1271621     1178420
> > Direct pages reclaimed                          6397       14416       94093
> > Kswapd efficiency                                 8%         98%         98%
> > Kswapd velocity                            22134.225    1127.205    1051.316
> > Direct efficiency                                20%         32%         58%
> > Direct velocity                               26.553      38.367     141.218
> > Percentage direct scans                           0%          3%         11%
> > Page writes by reclaim                       6530481           4           0
> > Page writes file                             6453578           0           0
> > Page writes anon                               76903           4           0
> > Page reclaim immediate                        256742       17832       61576
> > Page rescued immediate                             0           0           0
> > Slabs scanned                                1073152      971776      975872
> > Direct inode steals                                0      196279      205178
> > Kswapd inode steals                           139260       70390       64323
> > Kswapd skipped wait                            21711           1           0
> > THP fault alloc                                    1         126         143
> > THP collapse alloc                               324         294         224
> > THP splits                                        32           8          10
> > THP fault fallback                                 0           0           0
> > THP collapse fail                                  5           6           7
> > Compaction stalls                                364        1312        1324
> > Compaction success                               255         343         366
> > Compaction failures                              109         969         958
> > Compaction pages moved                        265107     3952630     4489215
> > Compaction move failure                         7493       26038       24739
> >
> > ...
> >
> > Success rates are completely hosed for 3.4-rc1 which is almost certainly
> > due to [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. I
> > expected this would happen for kswapd and impair allocation success rates
> > (https://lkml.org/lkml/2012/1/25/166) but I did not anticipate this much
> > a difference: 95% less scanning, 43% less reclaim by kswapd
> > 
> > In comparison, reclaim/compaction is not aggressive and gives up easily
> > which is the intended behaviour. hugetlbfs uses __GFP_REPEAT and would be
> > much more aggressive about reclaim/compaction than THP allocations are. The
> > stress test above is allocating like neither THP or hugetlbfs but is much
> > closer to THP.
> 
> We seem to be thrashing around a bit with the performance, and we
> aren't tracking this closely enough.
> 

Yes.

> What is kswapd efficiency?  pages-relclaimed/pages-scanned? 

pages_reclaimed*100/pages_scanned

> Why did it
> increase so much? 

Lumpy reclaim increases the number of pages scanned in
isolate_lru_pages() and that is what I was attributing it to.

> Are pages which were reclaimed via prune_icache_sb()
> included?  If so, they can make a real mess of the scanning efficiency
> metric.
> 

I don't think so. For Kswapd efficiency, I'm using "kswapd_steal" from
vmstat and that is updated by shrink_inactive_list and not the slab
shrinker

> The increase in PGINODESTEAL is remarkable.  It seems to largely be a
> transfer from kswapd inode stealing.  Bad from a latency POV, at least.
> What would cause this change?

I'm playing catch-up at the moment and right now, I do not have a good
explanation as to why it changed like this. The most likely explanation
is that we are reclaiming fewer pages leading to more slab reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
