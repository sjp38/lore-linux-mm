Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 45C7282F64
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 12:19:26 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so25477450pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:19:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ae3si6090961pad.156.2015.10.13.09.19.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Oct 2015 09:19:25 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<20151013133225.GA31034@dhcp22.suse.cz>
In-Reply-To: <20151013133225.GA31034@dhcp22.suse.cz>
Message-Id: <201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
Date: Wed, 14 Oct 2015 01:19:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> I can see two options here. Either we teach zone_reclaimable to be less
> fragile or remove zone_reclaimable from shrink_zones altogether. Both of
> them are risky because we have a long history of changes in this areas
> which made other subtle behavior changes but I guess that the first
> option should be less fragile. What about the following patch? I am not
> happy about it because the condition is rather rough and a deeper
> inspection is really needed to check all the call sites but it should be
> good for testing.

While zone_reclaimable() for Node 0 DMA32 became false by your patch,
zone_reclaimable() for Node 0 DMA kept returning true, and as a result
overall result (i.e. zones_reclaimable) remained true.

  $ ./a.out

---------- When there is no data to write ----------
[  162.942371] MIN=11163 FREE=11155 (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=16
[  162.944541] MIN=100 FREE=1824 (ACTIVE_FILE=3+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  162.946560] zone_reclaimable returned 1 at line 2665
[  162.948722] shrink_zones returned 1 at line 2716
(...snipped...)
[  164.897587] zones_reclaimable=1 at line 2775
[  164.899172] do_try_to_free_pages returned 1 at line 2948
[  167.087119] __perform_reclaim returned 1 at line 2854
[  167.088868] did_some_progress=1 at line 3301
(...snipped...)
[  261.577944] MIN=11163 FREE=11155 (ACTIVE_FILE=0+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=0
[  261.580093] MIN=100 FREE=1824 (ACTIVE_FILE=3+INACTIVE_FILE=0) * 6 > PAGES_SCANNED=5
[  261.582333] zone_reclaimable returned 1 at line 2665
[  261.583841] shrink_zones returned 1 at line 2716
(...snipped...)
[  264.728434] zones_reclaimable=1 at line 2775
[  264.730002] do_try_to_free_pages returned 1 at line 2948
[  268.191368] __perform_reclaim returned 1 at line 2854
[  268.193113] did_some_progress=1 at line 3301
---------- When there is no data to write ----------

Complete log (with your patch inside) is at
http://I-love.SAKURA.ne.jp/tmp/serial-20151014.txt.xz .

By the way, the OOM killer seems to be invoked prematurely for different load
if your patch is applied.

  $ cat < /dev/zero > /tmp/log & sleep 10; ./a.out

---------- When there is a lot of data to write ----------
[   69.019271] Mem-Info:
[   69.019755] active_anon:335006 inactive_anon:2084 isolated_anon:23
[   69.019755]  active_file:12197 inactive_file:65310 isolated_file:31
[   69.019755]  unevictable:0 dirty:533 writeback:51020 unstable:0
[   69.019755]  slab_reclaimable:4753 slab_unreclaimable:4134
[   69.019755]  mapped:9639 shmem:2144 pagetables:2030 bounce:0
[   69.019755]  free:12972 free_pcp:45 free_cma:0
[   69.026260] Node 0 DMA free:7300kB min:400kB low:500kB high:600kB active_anon:5232kB inactive_anon:96kB active_file:424kB inactive_file:1068kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:164kB writeback:972kB mapped:416kB shmem:104kB slab_reclaimable:304kB slab_unreclaimable:244kB kernel_stack:96kB pagetables:256kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
[   69.037189] lowmem_reserve[]: 0 1729 1729 1729
[   69.039152] Node 0 DMA32 free:74224kB min:44652kB low:55812kB high:66976kB active_anon:1334792kB inactive_anon:8240kB active_file:48364kB inactive_file:230752kB unevictable:0kB isolated(anon):92kB isolated(file):0kB present:2080640kB managed:1774264kB mlocked:0kB dirty:9328kB writeback:199060kB mapped:38140kB shmem:8472kB slab_reclaimable:17840kB slab_unreclaimable:16292kB kernel_stack:3840kB pagetables:7864kB unstable:0kB bounce:0kB free_pcp:784kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   69.052017] lowmem_reserve[]: 0 0 0 0
[   69.053818] Node 0 DMA: 17*4kB (UME) 8*8kB (UME) 6*16kB (UME) 2*32kB (UM) 2*64kB (UE) 4*128kB (UME) 1*256kB (U) 2*512kB (UE) 3*1024kB (UME) 1*2048kB (U) 0*4096kB = 7332kB
[   69.059597] Node 0 DMA32: 632*4kB (UME) 454*8kB (UME) 507*16kB (UME) 310*32kB (UME) 177*64kB (UE) 61*128kB (UME) 15*256kB (ME) 19*512kB (M) 10*1024kB (M) 0*2048kB 0*4096kB = 67136kB
[   69.065810] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   69.068305] 72477 total pagecache pages
[   69.069932] 0 pages in swap cache
[   69.071435] Swap cache stats: add 0, delete 0, find 0/0
[   69.073354] Free swap  = 0kB
[   69.074822] Total swap = 0kB
[   69.076660] 524157 pages RAM
[   69.078113] 0 pages HighMem/MovableOnly
[   69.079930] 76615 pages reserved
[   69.081406] 0 pages hwpoisoned
---------- When there is a lot of data to write ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
