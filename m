Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AAF5F6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 01:48:02 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so92342805pab.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 22:48:02 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xt17si1329713pac.212.2015.02.02.22.48.00
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 22:48:01 -0800 (PST)
Date: Tue, 3 Feb 2015 15:49:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/5] compaction: changing initial position of scanners
Message-ID: <20150203064941.GA9822@js1304-P5Q-DELUXE>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

On Mon, Jan 19, 2015 at 11:05:15AM +0100, Vlastimil Babka wrote:
> Even after all the patches compaction received in last several versions, it
> turns out that its effectivneess degrades considerably as the system ages
> after reboot. For example, see how success rates of stress-highalloc from
> mmtests degrades when we re-execute it several times, first time being after
> fresh reboot:
>                              3.19-rc4              3.19-rc4              3.19-rc4
>                             4-nothp-1             4-nothp-2             4-nothp-3
> Success 1 Min         25.00 (  0.00%)       13.00 ( 48.00%)        9.00 ( 64.00%)
> Success 1 Mean        36.20 (  0.00%)       23.40 ( 35.36%)       16.40 ( 54.70%)
> Success 1 Max         41.00 (  0.00%)       34.00 ( 17.07%)       25.00 ( 39.02%)
> Success 2 Min         25.00 (  0.00%)       15.00 ( 40.00%)       10.00 ( 60.00%)
> Success 2 Mean        37.20 (  0.00%)       25.00 ( 32.80%)       17.20 ( 53.76%)
> Success 2 Max         44.00 (  0.00%)       36.00 ( 18.18%)       25.00 ( 43.18%)
> Success 3 Min         84.00 (  0.00%)       81.00 (  3.57%)       78.00 (  7.14%)
> Success 3 Mean        85.80 (  0.00%)       82.80 (  3.50%)       80.40 (  6.29%)
> Success 3 Max         87.00 (  0.00%)       84.00 (  3.45%)       82.00 (  5.75%)
> 
> Wouldn't it be much better, if it looked like this?
> 
>                            3.18                  3.18                  3.18
>                              3.19-rc4              3.19-rc4              3.19-rc4
>                             5-nothp-1             5-nothp-2             5-nothp-3
> Success 1 Min         49.00 (  0.00%)       42.00 ( 14.29%)       41.00 ( 16.33%)
> Success 1 Mean        51.00 (  0.00%)       45.00 ( 11.76%)       42.60 ( 16.47%)
> Success 1 Max         55.00 (  0.00%)       51.00 (  7.27%)       46.00 ( 16.36%)
> Success 2 Min         53.00 (  0.00%)       47.00 ( 11.32%)       44.00 ( 16.98%)
> Success 2 Mean        59.60 (  0.00%)       50.80 ( 14.77%)       48.20 ( 19.13%)
> Success 2 Max         64.00 (  0.00%)       56.00 ( 12.50%)       52.00 ( 18.75%)
> Success 3 Min         84.00 (  0.00%)       82.00 (  2.38%)       78.00 (  7.14%)
> Success 3 Mean        85.60 (  0.00%)       82.80 (  3.27%)       79.40 (  7.24%)
> Success 3 Max         86.00 (  0.00%)       83.00 (  3.49%)       80.00 (  6.98%)
> 
> In my humble opinion, it would :) Much lower degradation, and a nice
> improvement in the first iteration as a bonus.
> 
> So what sorcery is this? Nothing much, just a fundamental change of the
> compaction scanners operation...
> 
> As everyone knows [1] the migration scanner starts at the first pageblock
> of a zone, and goes towards the end, and the free scanner starts at the
> last pageblock and goes towards the beginning. Somewhere in the middle of the
> zone, the scanners meet:
> 
>    zone_start                                                   zone_end
>        |                                                           |
>        -------------------------------------------------------------
>        MMMMMMMMMMMMM| =>                            <= |FFFFFFFFFFFF
>                migrate_pfn                         free_pfn
> 
> In my tests, the scanners meet around the middle of the pageblock on the first
> iteration, and around the 1/3 on subsequent iterations. Which means the
> migration scanner doesn't see the larger part of the zone at all. For more
> details why it's bad, see Patch 4 description.
> 
> To make sure we eventually scan the whole zone with the migration scanner, we
> could e.g. reverse the directions after each run. But that would still be
> biased, and with 1/3 of zone reachable from each side, we would still omit the
> middle 1/3 of a zone.
> 
> Or we could stop terminating compaction when the scanners meet, and let them
> continue to scan the whole zone. Mel told me it used to be the case long ago,
> but that approach would result in migrating pages back and forth during single
> compaction run, which wouldn't be cool.
> 
> So the approach taken by this patchset is to let scanners start at any
> so-called pivot pfn within the zone, and keep their direction:
> 
>    zone_start                     pivot                         zone_end
>        |                            |                              |
>        -------------------------------------------------------------
>                          <= |FFFFFFFMMMMMM| =>
>                         free_pfn     migrate_pfn
> 
> Eventually, one of the scanners will reach the zone boundary and wrap around,
> e.g. the in the case of the free scanner:
> 
>    zone_start                     pivot                         zone_end
>        |                            |                              |
>        -------------------------------------------------------------
>        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFMMMMMMMMMMMM| =>           <= |F
>                                            migrate_pfn        free_pfn
> 
> Compaction will again terminate when the scanners meet.
> 
> 
> As you can imagine, the required code changes made the termination detection
> and the scanners themselves quite hairy. There are lots of corner cases and
> the code is often hard to wrap one's head around [puns intended]. The scanner
> functions isolate_migratepages() and isolate_freepages() were recently cleaned
> up a lot, and this makes them messy again, as they can no longer rely on the
> fact that they will meet the other scanner and not the zone boundary.
> 
> But the improvements seem to make these complications worth, and I hope
> somebody can suggest more elegant solutions to the various parts of the code.
> So here it is as a RFC. Patches 1-3 are cleanups that could be applied in any
> case. Patch 4 implements the main changes, but leaves the pivot to be the
> first zone's pfn, so that free scanner wraps immediately and there's no
> actual change. Patch 5 updates the pivot in a conservative way, as explained
> in the changelog.

Hello,

I don't have any elegant idea, but, have some humble opinion.

The point is that migrate scanner should scan whole zone.
Although your pivot approach makes some sense and it can scan whole zone,
it could cause back and forth migration in a very short term whenever
both scanners get toward and passed each other. I think that if we permit
overlap of scanner, we don't need to adhere to reverse linear scanning
in freepage scanner since reverse liner scan doesn't prevent back and
forth migration from now on.

There are two solutions on this problem.
One is that free scanner scans pfn in same direction where migrate scanner
goes with having proper interval.

|=========================|
MMM==>  <Interval>  FFF==>

Enough interval guarantees to prevent back and forth migration,
at least, in a very short period.

Or, we could make free scanner totally different with linear scan.
Linear scanning to get freepage wastes much time if system memory
is really big and most of it is used. If we takes freepage from the
buddy, we can eliminate this scanning overhead. With additional
logic, that is, comparing position of freepage with migrate scanner
and selectively taking it, we can avoid back and forth migration
in a very short period.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
