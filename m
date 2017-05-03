Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 773876B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 02:00:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so4531666wme.16
        for <linux-mm@kvack.org>; Tue, 02 May 2017 23:00:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s127si2621754wmd.63.2017.05.02.23.00.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 23:00:48 -0700 (PDT)
Date: Wed, 3 May 2017 08:00:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: scan pages until it founds eligible pages
Message-ID: <20170503060044.GA1236@dhcp22.suse.cz>
References: <1493700038-27091-1-git-send-email-minchan@kernel.org>
 <20170502051452.GA27264@bbox>
 <20170502075432.GC14593@dhcp22.suse.cz>
 <20170502145150.GA19011@bgram>
 <20170502151436.GN14593@dhcp22.suse.cz>
 <20170503044809.GA21619@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170503044809.GA21619@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 03-05-17 13:48:09, Minchan Kim wrote:
> On Tue, May 02, 2017 at 05:14:36PM +0200, Michal Hocko wrote:
> > On Tue 02-05-17 23:51:50, Minchan Kim wrote:
> > > Hi Michal,
> > > 
> > > On Tue, May 02, 2017 at 09:54:32AM +0200, Michal Hocko wrote:
> > > > On Tue 02-05-17 14:14:52, Minchan Kim wrote:
> > > > > Oops, forgot to add lkml and linux-mm.
> > > > > Sorry for that.
> > > > > Send it again.
> > > > > 
> > > > > >From 8ddf1c8aa15baf085bc6e8c62ce705459d57ea4c Mon Sep 17 00:00:00 2001
> > > > > From: Minchan Kim <minchan@kernel.org>
> > > > > Date: Tue, 2 May 2017 12:34:05 +0900
> > > > > Subject: [PATCH] vmscan: scan pages until it founds eligible pages
> > > > > 
> > > > > On Tue, May 02, 2017 at 01:40:38PM +0900, Minchan Kim wrote:
> > > > > There are premature OOM happening. Although there are a ton of free
> > > > > swap and anonymous LRU list of elgible zones, OOM happened.
> > > > > 
> > > > > With investigation, skipping page of isolate_lru_pages makes reclaim
> > > > > void because it returns zero nr_taken easily so LRU shrinking is
> > > > > effectively nothing and just increases priority aggressively.
> > > > > Finally, OOM happens.
> > > > 
> > > > I am not really sure I understand the problem you are facing. Could you
> > > > be more specific please? What is your configuration etc...
> > > 
> > > Sure, KVM guest on x86_64, It has 2G memory and 1G swap and configured
> > > movablecore=1G to simulate highmem zone.
> > > Workload is a process consumes 2.2G memory and then random touch the
> > > address space so it makes lots of swap in/out.
> > > 
> > > > 
> > > > > balloon invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=0, oom_score_adj=0
> > > > [...]
> > > > > Node 0 active_anon:1698864kB inactive_anon:261256kB active_file:208kB inactive_file:184kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:532kB dirty:108kB writeback:0kB shmem:172kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> > > > > DMA free:7316kB min:32kB low:44kB high:56kB active_anon:8064kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:464kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > > > > lowmem_reserve[]: 0 992 992 1952
> > > > > DMA32 free:9088kB min:2048kB low:3064kB high:4080kB active_anon:952176kB inactive_anon:0kB active_file:36kB inactive_file:0kB unevictable:0kB writepending:88kB present:1032192kB managed:1019388kB mlocked:0kB slab_reclaimable:13532kB slab_unreclaimable:16460kB kernel_stack:3552kB pagetables:6672kB bounce:0kB free_pcp:56kB local_pcp:24kB free_cma:0kB
> > > > > lowmem_reserve[]: 0 0 0 959
> > > > 
> > > > Hmm DMA32 has sufficient free memory to allow this order-0 request.
> > > > Inactive anon lru is basically empty. Why do not we rotate a really
> > > > large active anon list? Isn't this the primary problem?
> > > 
> > > It's a side effect by skipping page logic in isolate_lru_pages
> > > I mentioned above in changelog.
> > > 
> > > The problem is a lot of anonymous memory in movable zone(ie, highmem)
> > > and non-small memory in DMA32 zone.
> > 
> > Such a configuration is questionable on its own. But let't keep this
> > part alone.
> 
> It seems you are misunderstood. It's really common on 32bit.

Yes, I am not arguing about 32b systems. It is quite common to see
issues which are inherent to the highmem zone.

> Think of 2G DRAM system on 32bit. Normally, it's 1G normal:1G highmem.
> It's almost same with one I configured.
> 
> > 
> > > In heavy memory pressure,
> > > requesting a page in GFP_KERNEL triggers reclaim. VM knows inactive list
> > > is low so it tries to deactivate pages. For it, first of all, it tries
> > > to isolate pages from active list but there are lots of anonymous pages
> > > from movable zone so skipping logic in isolate_lru_pages works. With
> > > the result, isolate_lru_pages cannot isolate any eligible pages so
> > > reclaim trial is effectively void. It continues to meet OOM.
> > 
> > But skipped pages should be rotated and we should eventually hit pages
> > from the right zone(s). Moreover we should scan the full LRU at priority
> > 0 so why exactly we hit the OOM killer?
> 
> Yes, full scan in priority 0 but keep it in mind that the number of full
> LRU pages to scan is one of eligible pages, not all pages of the node.

I have hard time understanding what you are trying to say here.

> And isolate_lru_pages have accounted skipped pages as scan count so that
> VM cannot isolate any pages of eligible pages in LRU if non-eligible pages
> are a lot in the LRU.
> 
> > 
> > Anyway [1] has changed this behavior. Are you seeing the issue with this
> > patch dropped?
> 
> Good point. Before the patch, it didn't increase scan count with skipped
> pages so with reverting [1], I guess it might work but worry about
> isolating lots of skipped pages into temporal pages_skipped list which
> might causes premate OOM. Anyway, I will test it when I returns at
> office after vacation.

I do not think we want to drop this patch. I think we might be good
enough to simply fold this into the patch
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 24efcc20af91..ac146f10f222 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1472,7 +1472,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+					!list_empty(src);) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1486,6 +1486,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
+		/*
+		 * Do not count skipped pages because we do want to isolate
+		 * some pages even when the LRU mostly contains ineligible
+		 * pages
+		 */
+		scan++;
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);

What do you think Johannes?

> > [1] http://www.ozlabs.org/~akpm/mmotm/broken-out/revert-mm-vmscan-account-for-skipped-pages-as-a-partial-scan.patch
> > -- 
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
