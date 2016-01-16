Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAE3828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 20:07:29 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id py5so156378009obc.2
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 17:07:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n83si16154451oih.71.2016.01.15.17.07.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 17:07:28 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<1450203586-10959-2-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com>
Message-Id: <201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp>
Date: Sat, 16 Jan 2016 10:07:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

David Rientjes wrote:
> Tetsuo's log of an early oom in this thread shows that this check is 
> wrong.  The allocation in question is an order-2 GFP_KERNEL on a system 
> with only ZONE_DMA and ZONE_DMA32:
> 
> 	zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
> 	zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
> 
> and the watermarks:
> 
> 	Node 0 DMA free:6908kB min:44kB low:52kB high:64kB ...
> 	lowmem_reserve[]: 0 1714 1714 1714
> 	Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB  ...
> 	lowmem_reserve[]: 0 0 0 0
> 
> and the scary thing is that this triggers when no_progress_loops == 0, so 
> this is the first time trying the allocation after progress has been made.
> 
> Watermarks clearly indicate that memory is available, the problem is 
> fragmentation for the order-2 allocation.  This is not a situation where 
> we want to immediately call the oom killer to solve since we have no 
> guarantee it is going to free contiguous memory (in fact it wouldn't be 
> used at all for PAGE_ALLOC_COSTLY_ORDER).
> 
> There is order-2 memory available however:
> 
> 	Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB
> 
> The failure for ZONE_DMA makes sense for the lowmem_reserve ratio, it's 
> oom for this allocation.  ZONE_DMA32 is not, however.
> 
> I'm wondering if this has to do with the z->nr_reserved_highatomic 
> estimate.  ZONE_DMA32 present pages is 2080640kB, so this would be limited 
> to 1%, or 20806kB.  That failure would make sense if free is 17996kB.
> 
> Tetsuo, would it be possible to try your workload with just this match and 
> also show z->nr_reserved_highatomic?

I don't know what "try your workload with just this match" expects, but
zone->nr_reserved_highatomic is always 0.

----------
[  178.058803] zone=DMA32 reclaimable=367474 available=369923 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0
[  178.061350] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0
[  178.132174] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:3256kB inactive_anon:172kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:56kB shmem:180kB slab_reclaimable:2056kB slab_unreclaimable:1096kB kernel_stack:192kB pagetables:180kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  178.145589] Node 0 DMA32 free:11532kB min:5564kB low:6952kB high:8344kB active_anon:133896kB inactive_anon:8204kB active_file:1001828kB inactive_file:462944kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021064kB mlocked:0kB dirty:8kB writeback:0kB mapped:8572kB shmem:8468kB slab_reclaimable:57136kB slab_unreclaimable:86380kB kernel_stack:50080kB pagetables:83600kB unstable:0kB bounce:0kB free_pcp:1268kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:356 all_unreclaimable? no
[  198.457718] zone=DMA32 reclaimable=381991 available=386237 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0
[  198.460111] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0
[  198.507204] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:3088kB inactive_anon:172kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:92kB shmem:180kB slab_reclaimable:976kB slab_unreclaimable:1468kB kernel_stack:672kB pagetables:336kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  198.507209] Node 0 DMA32 free:19992kB min:5564kB low:6952kB high:8344kB active_anon:104176kB inactive_anon:8204kB active_file:905320kB inactive_file:617264kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021064kB mlocked:0kB dirty:176kB writeback:0kB mapped:12772kB shmem:8468kB slab_reclaimable:60372kB slab_unreclaimable:77856kB kernel_stack:44144kB pagetables:69180kB unstable:0kB bounce:0kB free_pcp:1104kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  198.647075] zone=DMA32 reclaimable=374429 available=378945 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0
[  198.647076] zone=DMA reclaimable=1 available=1983 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0
[  198.652177] Node 0 DMA free:7928kB min:40kB low:48kB high:60kB active_anon:588kB inactive_anon:172kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:88kB shmem:180kB slab_reclaimable:1008kB slab_unreclaimable:2576kB kernel_stack:1840kB pagetables:408kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  198.652182] Node 0 DMA32 free:17608kB min:5564kB low:6952kB high:8344kB active_anon:89528kB inactive_anon:8204kB active_file:1025084kB inactive_file:472512kB unevictable:0kB isolated(anon):0kB isolated(file):120kB present:2080640kB managed:2021064kB mlocked:0kB dirty:176kB writeback:0kB mapped:12848kB shmem:8468kB slab_reclaimable:60372kB slab_unreclaimable:86628kB kernel_stack:50880kB pagetables:82336kB unstable:0kB bounce:0kB free_pcp:236kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  207.045450] zone=DMA32 reclaimable=386923 available=392299 no_progress_loops=0 did_some_progress=38 nr_reserved_highatomic=0
[  207.045451] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=38 nr_reserved_highatomic=0
[  207.050241] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:732kB inactive_anon:336kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:140kB shmem:436kB slab_reclaimable:456kB slab_unreclaimable:3536kB kernel_stack:1584kB pagetables:188kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  207.050246] Node 0 DMA32 free:20092kB min:5564kB low:6952kB high:8344kB active_anon:91600kB inactive_anon:18620kB active_file:921896kB inactive_file:626544kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021064kB mlocked:0kB dirty:964kB writeback:0kB mapped:17016kB shmem:24584kB slab_reclaimable:51908kB slab_unreclaimable:72792kB kernel_stack:40832kB pagetables:67396kB unstable:0kB bounce:0kB free_pcp:472kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  221.034713] zone=DMA32 reclaimable=389283 available=393245 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0
[  221.037103] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0
[  221.105952] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:416kB inactive_anon:304kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:132kB shmem:436kB slab_reclaimable:424kB slab_unreclaimable:3156kB kernel_stack:2352kB pagetables:212kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  221.119016] Node 0 DMA32 free:7220kB min:5564kB low:6952kB high:8344kB active_anon:74480kB inactive_anon:23544kB active_file:946560kB inactive_file:618900kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021064kB mlocked:0kB dirty:1056kB writeback:0kB mapped:14760kB shmem:32768kB slab_reclaimable:51328kB slab_unreclaimable:75692kB kernel_stack:42960kB pagetables:66732kB unstable:0kB bounce:0kB free_pcp:196kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:248 all_unreclaimable? no
[  224.072875] zone=DMA32 reclaimable=397667 available=401058 no_progress_loops=0 did_some_progress=56 nr_reserved_highatomic=0
[  224.075212] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=56 nr_reserved_highatomic=0
[  224.133813] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:664kB inactive_anon:296kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:436kB slab_reclaimable:424kB slab_unreclaimable:3760kB kernel_stack:1136kB pagetables:376kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  224.145691] Node 0 DMA32 free:12160kB min:5564kB low:6952kB high:8344kB active_anon:69352kB inactive_anon:23140kB active_file:1191992kB inactive_file:399408kB unevictable:0kB isolated(anon):0kB isolated(file):104kB present:2080640kB managed:2021064kB mlocked:0kB dirty:844kB writeback:0kB mapped:4916kB shmem:32768kB slab_reclaimable:51288kB slab_unreclaimable:68392kB kernel_stack:38560kB pagetables:61820kB unstable:0kB bounce:0kB free_pcp:184kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  234.291285] zone=DMA32 reclaimable=403563 available=407626 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0
[  234.293557] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0
[  234.357091] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB active_anon:312kB inactive_anon:296kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:144kB shmem:436kB slab_reclaimable:424kB slab_unreclaimable:2596kB kernel_stack:2992kB pagetables:204kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[  234.370106] Node 0 DMA32 free:6804kB min:5564kB low:6952kB high:8344kB active_anon:77364kB inactive_anon:23140kB active_file:1168356kB inactive_file:454384kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:2080640kB managed:2021064kB mlocked:0kB dirty:0kB writeback:0kB mapped:11884kB shmem:32768kB slab_reclaimable:51292kB slab_unreclaimable:61492kB kernel_stack:32016kB pagetables:49248kB unstable:0kB bounce:0kB free_pcp:760kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:696 all_unreclaimable? no
[  246.183836] zone=DMA32 reclaimable=405496 available=410200 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0
[  246.186069] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0
[  246.246157] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB active_anon:1144kB inactive_anon:284kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:124kB shmem:436kB slab_reclaimable:424kB slab_unreclaimable:2404kB kernel_stack:1392kB pagetables:660kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  246.260159] Node 0 DMA32 free:11564kB min:5564kB low:6952kB high:8344kB active_anon:74360kB inactive_anon:23036kB active_file:1173248kB inactive_file:456000kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021064kB mlocked:0kB dirty:732kB writeback:0kB mapped:14812kB shmem:32768kB slab_reclaimable:51292kB slab_unreclaimable:59884kB kernel_stack:31824kB pagetables:47960kB unstable:0kB bounce:0kB free_pcp:136kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  258.994846] zone=DMA32 reclaimable=403441 available=407544 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0
[  258.997488] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0
[  259.055818] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:848kB inactive_anon:284kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:136kB shmem:436kB slab_reclaimable:428kB slab_unreclaimable:2692kB kernel_stack:1872kB pagetables:476kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  259.067950] Node 0 DMA32 free:29136kB min:5564kB low:6952kB high:8344kB active_anon:71476kB inactive_anon:23032kB active_file:1129276kB inactive_file:485324kB unevictable:0kB isolated(anon):0kB isolated(file):112kB present:2080640kB managed:2021064kB mlocked:0kB dirty:0kB writeback:0kB mapped:14340kB shmem:32768kB slab_reclaimable:51312kB slab_unreclaimable:61680kB kernel_stack:34704kB pagetables:44856kB unstable:0kB bounce:0kB free_pcp:1996kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  271.392099] zone=DMA32 reclaimable=399774 available=406049 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0
[  271.394646] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0
[  271.459049] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:832kB inactive_anon:284kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:124kB shmem:436kB slab_reclaimable:428kB slab_unreclaimable:2824kB kernel_stack:2320kB pagetables:180kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  271.472413] Node 0 DMA32 free:21848kB min:5564kB low:6952kB high:8344kB active_anon:77144kB inactive_anon:23032kB active_file:1148420kB inactive_file:462308kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021064kB mlocked:0kB dirty:664kB writeback:0kB mapped:14700kB shmem:32768kB slab_reclaimable:51312kB slab_unreclaimable:61672kB kernel_stack:32064kB pagetables:50888kB unstable:0kB bounce:0kB free_pcp:848kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  274.428858] zone=DMA32 reclaimable=404186 available=408756 no_progress_loops=0 did_some_progress=52 nr_reserved_highatomic=0
[  274.431146] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=52 nr_reserved_highatomic=0
[  274.487864] Node 0 DMA free:7924kB min:40kB low:48kB high:60kB active_anon:600kB inactive_anon:284kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:436kB slab_reclaimable:428kB slab_unreclaimable:3504kB kernel_stack:1120kB pagetables:532kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  274.499779] Node 0 DMA32 free:17040kB min:5564kB low:6952kB high:8344kB active_anon:60480kB inactive_anon:23032kB active_file:1277956kB inactive_file:339528kB unevictable:0kB isolated(anon):0kB isolated(file):68kB present:2080640kB managed:2021064kB mlocked:0kB dirty:664kB writeback:0kB mapped:5912kB shmem:32768kB slab_reclaimable:51312kB slab_unreclaimable:64216kB kernel_stack:37520kB pagetables:52096kB unstable:0kB bounce:0kB free_pcp:308kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160116.txt.xz .

> 
> This patch would need to at least have knowledge of the heuristics used by 
> __zone_watermark_ok() since it's making an inference on reclaimability 
> based on numbers that include pageblocks that are reserved from usage.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
