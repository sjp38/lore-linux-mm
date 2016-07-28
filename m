Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBC26B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 02:39:52 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d65so51165098ith.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:39:52 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u17si26829060itc.119.2016.07.27.23.39.50
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 23:39:51 -0700 (PDT)
Date: Thu, 28 Jul 2016 15:44:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v2
Message-ID: <20160728064432.GA28136@js1304-P5Q-DELUXE>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <20160726081129.GB15721@js1304-P5Q-DELUXE>
 <20160726125050.GP10438@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160726125050.GP10438@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 26, 2016 at 01:50:50PM +0100, Mel Gorman wrote:
> On Tue, Jul 26, 2016 at 05:11:30PM +0900, Joonsoo Kim wrote:
> > > These patches did not OOM for me on a 2G 32-bit KVM instance while running
> > > a stress test for an hour. Preliminary tests on a 64-bit system using a
> > > parallel dd workload did not show anything alarming.
> > > 
> > > If an OOM is detected then please post the full OOM message.
> > 
> > Before attaching OOM message, I should note that my test case also triggers
> > OOM in old kernel if there are four parallel file-readers. With node-lru and
> > patch 1~5, OOM is triggered even if there are one or more parallel file-readers.
> > With node-lru and patch 1~4, OOM is triggered if there are two or more
> > parallel file-readers.
> > 
> 
> The key there is that patch 5 allows OOM to be detected quicker. The fork
> workload exits after some time so it's inherently a race to see if the
> forked process exits before OOM is triggered or not.
> 
> > <SNIP>
> > Mem-Info:
> > active_anon:26762 inactive_anon:95 isolated_anon:0
> >  active_file:42543 inactive_file:347438 isolated_file:0
> >  unevictable:0 dirty:0 writeback:0 unstable:0
> >  slab_reclaimable:5476 slab_unreclaimable:23140
> >  mapped:389534 shmem:95 pagetables:20927 bounce:0
> >  free:6948 free_pcp:222 free_cma:0
> > Node 0 active_anon:107048kB inactive_anon:380kB active_file:170008kB inactive_file:1389752kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1558136kB dirty:0kB writeback:0kB shmem:0kB shmem_$
> > hp: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB pages_scanned:4697206 all_unreclaimable? yes
> > Node 0 DMA free:2168kB min:204kB low:252kB high:300kB active_anon:3544kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB sl$
> > b_reclaimable:0kB slab_unreclaimable:2684kB kernel_stack:1760kB pagetables:3092kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > lowmem_reserve[]: 0 493 493 1955
> 
> Zone DMA is unusable
> 
> > Node 0 DMA32 free:6508kB min:6492kB low:8112kB high:9732kB active_anon:81264kB inactive_anon:0kB active_file:101204kB inactive_file:228kB unevictable:0kB writepending:0kB present:2080632kB managed:508584k$
> >  mlocked:0kB slab_reclaimable:21904kB slab_unreclaimable:89876kB kernel_stack:46400kB pagetables:80616kB bounce:0kB free_pcp:544kB local_pcp:120kB free_cma:0kB
> > lowmem_reserve[]: 0 0 0 1462
> 
> Zone DMA32 has reclaimable pages but not very many and they are active. It's
> at the min watemark. The pgdat is unreclaimable indicating that scans
> are high which implies that the active file pages are due to genuine
> activations.
> 
> > Node 0 Movable free:19116kB min:19256kB low:24068kB high:28880kB active_anon:22240kB inactive_anon:380kB active_file:68812kB inactive_file:1389688kB unevictable:0kB writepending:0kB present:1535864kB mana$
> > ed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:368kB local_pcp:0kB free_cma:0kB
> 
> Zone Movable has reclaimable pages but it's at the min watermark and
> scanning aggressively.
> 
> As the failing allocation can use all allocations, this appears to be close
> to a genuine OOM case. Whether it survives is down to timing of when OOM
> is triggered and whether the forked process exits in time or not.
>
> To some extent, it could be "addressed" by immediately reclaiming active
> pages moving to the inactive list at the cost of distorting page age for a
> workload that is genuinely close to OOM. That is similar to what zone-lru
> ended up doing -- fast reclaiming young pages from a zone.

My expectation on my test case is that reclaimers should kick out
actively used page and make a room for 'fork' because parallel readers
would work even if reading pages are not cached.

It is sensitive on reclaimers efficiency because parallel readers
read pages repeatedly and disturb reclaim. I thought that it is a
good test for node-lru which changes reclaimers efficiency for lower
zone. However, as you said, this efficiency comes from the cost
distorting page aging so now I'm not sure if it is a problem that we
need to consider. Let's skip it?

Anyway, thanks for tracking down the problem.


> 
> > > Optionally please test without patch 5 if an OOM occurs.
> > 
> > Here goes without patch 5.
> > 
> 
> Causing OOM detection to be delayed. Observations on the OOM message
> without patch 5 are similar.
> 
> Do you mind trying the following? In the patch there is a line
> 
> scan += list_empty(src) ? total_skipped : total_skipped >> 2;
> 
> Try 
> 
> scan += list_empty(src) ? total_skipped : total_skipped >> 3;
> scan += list_empty(src) ? total_skipped : total_skipped >> 4;
> scan += total_skipped >> 4;

Tested but all result looks like there isn't much difference.

> 
> Each line slows the rate that OOM is detected but it'll be somewhat
> specific to your test case as it's relying to fork to exit before OOM is
> fired.

Okay. I don't think optimizing general code to my specific test case
is a good idea.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
