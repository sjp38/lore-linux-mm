Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D10276B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 08:50:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so9385034wme.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:50:53 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id ud19si629990wjb.199.2016.07.26.05.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 05:50:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 05C3F1C13B7
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:50:52 +0100 (IST)
Date: Tue, 26 Jul 2016 13:50:50 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v2
Message-ID: <20160726125050.GP10438@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <20160726081129.GB15721@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160726081129.GB15721@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 26, 2016 at 05:11:30PM +0900, Joonsoo Kim wrote:
> > These patches did not OOM for me on a 2G 32-bit KVM instance while running
> > a stress test for an hour. Preliminary tests on a 64-bit system using a
> > parallel dd workload did not show anything alarming.
> > 
> > If an OOM is detected then please post the full OOM message.
> 
> Before attaching OOM message, I should note that my test case also triggers
> OOM in old kernel if there are four parallel file-readers. With node-lru and
> patch 1~5, OOM is triggered even if there are one or more parallel file-readers.
> With node-lru and patch 1~4, OOM is triggered if there are two or more
> parallel file-readers.
> 

The key there is that patch 5 allows OOM to be detected quicker. The fork
workload exits after some time so it's inherently a race to see if the
forked process exits before OOM is triggered or not.

> <SNIP>
> Mem-Info:
> active_anon:26762 inactive_anon:95 isolated_anon:0
>  active_file:42543 inactive_file:347438 isolated_file:0
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  slab_reclaimable:5476 slab_unreclaimable:23140
>  mapped:389534 shmem:95 pagetables:20927 bounce:0
>  free:6948 free_pcp:222 free_cma:0
> Node 0 active_anon:107048kB inactive_anon:380kB active_file:170008kB inactive_file:1389752kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1558136kB dirty:0kB writeback:0kB shmem:0kB shmem_$
> hp: 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB pages_scanned:4697206 all_unreclaimable? yes
> Node 0 DMA free:2168kB min:204kB low:252kB high:300kB active_anon:3544kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB sl$
> b_reclaimable:0kB slab_unreclaimable:2684kB kernel_stack:1760kB pagetables:3092kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 493 493 1955

Zone DMA is unusable

> Node 0 DMA32 free:6508kB min:6492kB low:8112kB high:9732kB active_anon:81264kB inactive_anon:0kB active_file:101204kB inactive_file:228kB unevictable:0kB writepending:0kB present:2080632kB managed:508584k$
>  mlocked:0kB slab_reclaimable:21904kB slab_unreclaimable:89876kB kernel_stack:46400kB pagetables:80616kB bounce:0kB free_pcp:544kB local_pcp:120kB free_cma:0kB
> lowmem_reserve[]: 0 0 0 1462

Zone DMA32 has reclaimable pages but not very many and they are active. It's
at the min watemark. The pgdat is unreclaimable indicating that scans
are high which implies that the active file pages are due to genuine
activations.

> Node 0 Movable free:19116kB min:19256kB low:24068kB high:28880kB active_anon:22240kB inactive_anon:380kB active_file:68812kB inactive_file:1389688kB unevictable:0kB writepending:0kB present:1535864kB mana$
> ed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:368kB local_pcp:0kB free_cma:0kB

Zone Movable has reclaimable pages but it's at the min watermark and
scanning aggressively.

As the failing allocation can use all allocations, this appears to be close
to a genuine OOM case. Whether it survives is down to timing of when OOM
is triggered and whether the forked process exits in time or not.

To some extent, it could be "addressed" by immediately reclaiming active
pages moving to the inactive list at the cost of distorting page age for a
workload that is genuinely close to OOM. That is similar to what zone-lru
ended up doing -- fast reclaiming young pages from a zone.

> > Optionally please test without patch 5 if an OOM occurs.
> 
> Here goes without patch 5.
> 

Causing OOM detection to be delayed. Observations on the OOM message
without patch 5 are similar.

Do you mind trying the following? In the patch there is a line

scan += list_empty(src) ? total_skipped : total_skipped >> 2;

Try 

scan += list_empty(src) ? total_skipped : total_skipped >> 3;
scan += list_empty(src) ? total_skipped : total_skipped >> 4;
scan += total_skipped >> 4;

Each line slows the rate that OOM is detected but it'll be somewhat
specific to your test case as it's relying to fork to exit before OOM is
fired.

A hackier option that is also related to the fact fork is a major source
of the OOM triggering is to increase the zone reserve. That would give
more space for the fork bomb while giving the file reader slightly less
memory to work with. Again, what this is doing is simply altering OOM
timing because indications are the stress workload is genuinely close to
OOM.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 08ae8b0ef5c5..cedc8113c7a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -201,9 +201,9 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
 	 256,
 #endif
 #ifdef CONFIG_HIGHMEM
-	 32,
+	 8,
 #endif
-	 32,
+	 8,
 };
 
 EXPORT_SYMBOL(totalram_pages);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
