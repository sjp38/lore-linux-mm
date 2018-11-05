Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40C086B0269
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:26:27 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so19964411qkm.11
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:26:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si700293qtd.231.2018.11.05.01.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:26:23 -0800 (PST)
Date: Mon, 5 Nov 2018 17:26:18 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105092618.GI27491@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105091407.GB4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 11/05/18 at 10:14am, Michal Hocko wrote:
> On Mon 05-11-18 08:20:09, Baoquan He wrote:
> > Hi Michal,
> > 
> > On 11/02/18 at 04:55pm, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Baoquan He has noticed that 15c30bc09085  ("mm, memory_hotplug: make
> > > has_unmovable_pages more robust") is causing memory offlining failures
> > > on a movable node. After a further debugging it turned out that
> > > has_unmovable_pages fails prematurely because it stumbles over off-LRU
> > > pages. Nevertheless those pages are not on LRU because they are waiting
> > > on the pcp LRU caches (an example of __dump_page added by a debugging
> > > patch)
> > > [  560.923297] page:ffffea043f39fa80 count:1 mapcount:0 mapping:ffff880e5dce1b59 index:0x7f6eec459
> > > [  560.931967] flags: 0x5fffffc0080024(uptodate|active|swapbacked)
> > > [  560.937867] raw: 005fffffc0080024 dead000000000100 dead000000000200 ffff880e5dce1b59
> > > [  560.945606] raw: 00000007f6eec459 0000000000000000 00000001ffffffff ffff880e43ae8000
> > > [  560.953323] page dumped because: hotplug
> > > [  560.957238] page->mem_cgroup:ffff880e43ae8000
> > > [  560.961620] has_unmovable_pages: pfn:0x10fd030d, found:0x1, count:0x0
> > > [  560.968127] page:ffffea043f40c340 count:2 mapcount:0 mapping:ffff880e2f2d8628 index:0x0
> > > [  560.976104] flags: 0x5fffffc0000006(referenced|uptodate)
> > > [  560.981401] raw: 005fffffc0000006 dead000000000100 dead000000000200 ffff880e2f2d8628
> > > [  560.989119] raw: 0000000000000000 0000000000000000 00000002ffffffff ffff88010a8f5000
> > > [  560.996833] page dumped because: hotplug
> > 
> > Sorry, last week I didn't test this patch with memory pressure adding.
> > Today use "stress -m 200 -t 2h" to add pressure, hot removing failed.
> > Will send you output log. W/o memory pressure, it sometimes succeed. I
> > saw one failure last night, it still show un-removable as 0 in
> > hotpluggable node one time, I worried it might be caused by my compiling
> > mistake, so compile and try again this morning.
> 
> In a private email you have sent this (let's assume this is correctly
> testing the patch I have posted):

Yeah, I recompiled and copy bzImage to /boot to ensure the patch is
compiled in.

> 
> : [43283.914082] has_unmovable_pages: pfn:0x10e62600, found:0x1, count:0x0 
> : [43283.920669] page:ffffea0439898000 count:1 mapcount:1 mapping:ffff880e5639d3c9 index:0x7f2430400 compound_mapcount: 1
> : [43283.931219] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
> : [43283.937954] raw: 005fffffc0090034 ffffea043ffcb888 ffffea043f728008 ffff880e5639d3c9
> : [43283.945722] raw: 00000007f2430400 0000000000000000 00000001ffffffff ffff880e2baad000
> : [43283.955381] page dumped because: hotplug
> 
> The page is both LRU and SwapBacked which should hit the some of the
> checks in has_unmovable_pages. The fact it hasn't means we have clearly
> raced with the page being allocated and marked SwapBacked/LRU. This is
> surely possible and there is no universal way to prevent from that for
> all types of potentially migratedable pages. The race window should be
> relatively small. Maybe we can add a retry for movable zone pages.
> 
> How reproducible this is?

On the bare metal with 8 nodes and each node has 64 GB memory, node1~7
are hotpluggable and movable_node is added. After reboot, execute
"stress -m 200 -t 2h", by default the 200 processes will malloc/free
256MB continuously. Then hot remove one memory board on node1~7, it
always happened.

The progress is that all memory blocks on node1~7 are removable now,
accessing and reading them won't trigger the old trace now.

> 
> But, as I've said memory isolation resp. has_unmovable_pages begs for a
> complete redesign.

So how about using the patch I pasted before? It has an explanation and
test result is good. 

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5..021e39d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7824,7 +7824,8 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
                if (__PageMovable(page))
                        continue;

-               if (!PageLRU(page))
+               if (!PageLRU(page) &&
+                       (get_pageblock_migratetype(page) != MIGRATE_MOVABLE))
                        found++;
                /*
                 * If there are RECLAIMABLE pages, we need to check

Thanks
Baoquan
