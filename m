Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0136B0008
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 07:09:24 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id o62so167874260oif.3
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 04:09:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id za9si21483850obb.72.2015.12.28.04.09.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Dec 2015 04:09:22 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
In-Reply-To: <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
Message-Id: <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
Date: Mon, 28 Dec 2015 21:08:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> I got OOM killers while running heavy disk I/O (extracting kernel source,
> running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> Do you think these OOM killers reasonable? Too weak against fragmentation?

Well, current patch invokes OOM killers when more than 75% of memory is used
for file cache (active_file: + inactive_file:). I think this is a surprising
thing for administrators and we want to retry more harder (but not forever,
please).

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151228.txt.xz .
----------
[  277.863985] Node 0 DMA32 free:20128kB min:5564kB low:6952kB high:8344kB active_anon:108332kB inactive_anon:8252kB active_file:985160kB inactive_file:615436kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:5904kB shmem:8524kB slab_reclaimable:52088kB slab_unreclaimable:59748kB kernel_stack:31280kB pagetables:55708kB unstable:0kB bounce:0kB free_pcp:1056kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  277.884512] Node 0 DMA32: 3438*4kB (UME) 791*8kB (UME) 3*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20128kB
[  291.331040] Node 0 DMA32 free:29500kB min:5564kB low:6952kB high:8344kB active_anon:126756kB inactive_anon:8252kB active_file:821500kB inactive_file:604016kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:0kB writeback:0kB mapped:12684kB shmem:8524kB slab_reclaimable:56808kB slab_unreclaimable:99804kB kernel_stack:58448kB pagetables:92552kB unstable:0kB bounce:0kB free_pcp:2004kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  291.349097] Node 0 DMA32: 4221*4kB (UME) 1971*8kB (UME) 436*16kB (UME) 141*32kB (UME) 8*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44652kB
[  302.897985] Node 0 DMA32 free:28240kB min:5564kB low:6952kB high:8344kB active_anon:79344kB inactive_anon:8248kB active_file:1016568kB inactive_file:604696kB unevictable:0kB isolated(anon):0kB isolated(file):120kB present:2080640kB managed:2021100kB mlocked:0kB dirty:80kB writeback:0kB mapped:13004kB shmem:8520kB slab_reclaimable:52076kB slab_unreclaimable:64064kB kernel_stack:35168kB pagetables:48552kB unstable:0kB bounce:0kB free_pcp:1384kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  302.916334] Node 0 DMA32: 4304*4kB (UM) 1181*8kB (UME) 59*16kB (UME) 7*32kB (ME) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 27832kB
[  311.014501] Node 0 DMA32 free:22820kB min:5564kB low:6952kB high:8344kB active_anon:56852kB inactive_anon:11976kB active_file:1142936kB inactive_file:582040kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:160kB writeback:0kB mapped:10796kB shmem:16640kB slab_reclaimable:48608kB slab_unreclaimable:41912kB kernel_stack:16560kB pagetables:30876kB unstable:0kB bounce:0kB free_pcp:948kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
[  311.034251] Node 0 DMA32: 6*4kB (U) 2401*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 19232kB
[  314.293371] Node 0 DMA32 free:15244kB min:5564kB low:6952kB high:8344kB active_anon:82496kB inactive_anon:11976kB active_file:1110984kB inactive_file:467400kB unevictable:0kB isolated(anon):0kB isolated(file):88kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:9440kB shmem:16640kB slab_reclaimable:53684kB slab_unreclaimable:72536kB kernel_stack:40048kB pagetables:67672kB unstable:0kB bounce:0kB free_pcp:1076kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:12 all_unreclaimable? no
[  314.314336] Node 0 DMA32: 1180*4kB (UM) 1449*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16312kB
[  322.774181] Node 0 DMA32 free:19780kB min:5564kB low:6952kB high:8344kB active_anon:68264kB inactive_anon:17816kB active_file:1155724kB inactive_file:470216kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:8kB writeback:0kB mapped:9744kB shmem:24708kB slab_reclaimable:52540kB slab_unreclaimable:63216kB kernel_stack:32464kB pagetables:51856kB unstable:0kB bounce:0kB free_pcp:1076kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  322.796256] Node 0 DMA32: 86*4kB (UME) 2474*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20136kB
[  330.804341] Node 0 DMA32 free:22076kB min:5564kB low:6952kB high:8344kB active_anon:47616kB inactive_anon:17816kB active_file:1063272kB inactive_file:685848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:216kB writeback:0kB mapped:9708kB shmem:24708kB slab_reclaimable:48536kB slab_unreclaimable:36844kB kernel_stack:12048kB pagetables:25992kB unstable:0kB bounce:0kB free_pcp:776kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  330.826190] Node 0 DMA32: 1637*4kB (UM) 1354*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17380kB
[  332.828224] Node 0 DMA32 free:15544kB min:5564kB low:6952kB high:8344kB active_anon:63184kB inactive_anon:17784kB active_file:1215752kB inactive_file:468872kB unevictable:0kB isolated(anon):0kB isolated(file):68kB present:2080640kB managed:2021100kB mlocked:0kB dirty:312kB writeback:0kB mapped:9116kB shmem:24708kB slab_reclaimable:49912kB slab_unreclaimable:50068kB kernel_stack:21600kB pagetables:42384kB unstable:0kB bounce:0kB free_pcp:1364kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  332.846805] Node 0 DMA32: 4108*4kB (UME) 897*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23608kB
[  341.054731] Node 0 DMA32 free:20512kB min:5564kB low:6952kB high:8344kB active_anon:76796kB inactive_anon:23792kB active_file:1053836kB inactive_file:618588kB unevictable:0kB isolated(anon):0kB isolated(file):96kB present:2080640kB managed:2021100kB mlocked:0kB dirty:1656kB writeback:0kB mapped:19768kB shmem:32784kB slab_reclaimable:49000kB slab_unreclaimable:47636kB kernel_stack:21664kB pagetables:37188kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  341.073722] Node 0 DMA32: 3309*4kB (UM) 1124*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22228kB
[  360.075472] Node 0 DMA32 free:17856kB min:5564kB low:6952kB high:8344kB active_anon:117872kB inactive_anon:25588kB active_file:1022532kB inactive_file:466856kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:420kB writeback:0kB mapped:25300kB shmem:40976kB slab_reclaimable:57804kB slab_unreclaimable:79416kB kernel_stack:46784kB pagetables:78044kB unstable:0kB bounce:0kB free_pcp:1100kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  360.093794] Node 0 DMA32: 2719*4kB (UM) 97*8kB (UM) 14*16kB (UM) 37*32kB (UME) 27*64kB (UME) 3*128kB (UM) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15172kB
[  368.853099] Node 0 DMA32 free:22524kB min:5564kB low:6952kB high:8344kB active_anon:79156kB inactive_anon:24876kB active_file:872972kB inactive_file:738900kB unevictable:0kB isolated(anon):0kB isolated(file):96kB present:2080640kB managed:2021100kB mlocked:0kB dirty:0kB writeback:0kB mapped:25708kB shmem:40976kB slab_reclaimable:50820kB slab_unreclaimable:62880kB kernel_stack:32048kB pagetables:49656kB unstable:0kB bounce:0kB free_pcp:524kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  368.871173] Node 0 DMA32: 5042*4kB (UM) 248*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22152kB
[  379.261759] Node 0 DMA32 free:15888kB min:5564kB low:6952kB high:8344kB active_anon:89928kB inactive_anon:23780kB active_file:1295512kB inactive_file:358284kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:1608kB writeback:0kB mapped:25376kB shmem:40976kB slab_reclaimable:47972kB slab_unreclaimable:50848kB kernel_stack:22320kB pagetables:42360kB unstable:0kB bounce:0kB free_pcp:248kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  379.279344] Node 0 DMA32: 2994*4kB (ME) 503*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16000kB
[  387.367409] Node 0 DMA32 free:15320kB min:5564kB low:6952kB high:8344kB active_anon:76364kB inactive_anon:28712kB active_file:1061180kB inactive_file:596956kB unevictable:0kB isolated(anon):0kB isolated(file):120kB present:2080640kB managed:2021100kB mlocked:0kB dirty:20kB writeback:0kB mapped:27700kB shmem:49168kB slab_reclaimable:51236kB slab_unreclaimable:51096kB kernel_stack:22912kB pagetables:40920kB unstable:0kB bounce:0kB free_pcp:700kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  387.385740] Node 0 DMA32: 3638*4kB (UM) 115*8kB (UM) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15488kB
[  391.207543] Node 0 DMA32 free:15224kB min:5564kB low:6952kB high:8344kB active_anon:115956kB inactive_anon:28392kB active_file:1117532kB inactive_file:359656kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:0kB writeback:0kB mapped:29348kB shmem:49168kB slab_reclaimable:56028kB slab_unreclaimable:85168kB kernel_stack:48592kB pagetables:81620kB unstable:0kB bounce:0kB free_pcp:1124kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:356 all_unreclaimable? no
[  391.228084] Node 0 DMA32: 3374*4kB (UME) 221*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15264kB
[  395.663881] Node 0 DMA32 free:12820kB min:5564kB low:6952kB high:8344kB active_anon:98924kB inactive_anon:27520kB active_file:1105780kB inactive_file:494760kB unevictable:0kB isolated(anon):4kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:1412kB writeback:12kB mapped:29588kB shmem:49168kB slab_reclaimable:49836kB slab_unreclaimable:60524kB kernel_stack:32176kB pagetables:50356kB unstable:0kB bounce:0kB free_pcp:1500kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:388 all_unreclaimable? no
[  395.683137] Node 0 DMA32: 3794*4kB (ME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15176kB
[  399.871655] Node 0 DMA32 free:18432kB min:5564kB low:6952kB high:8344kB active_anon:99156kB inactive_anon:26780kB active_file:1150532kB inactive_file:408872kB unevictable:0kB isolated(anon):68kB isolated(file):80kB present:2080640kB managed:2021100kB mlocked:0kB dirty:3492kB writeback:0kB mapped:30924kB shmem:49168kB slab_reclaimable:54236kB slab_unreclaimable:68184kB kernel_stack:37392kB pagetables:63708kB unstable:0kB bounce:0kB free_pcp:784kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  399.890082] Node 0 DMA32: 4155*4kB (UME) 200*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18220kB
[  408.447006] Node 0 DMA32 free:12684kB min:5564kB low:6952kB high:8344kB active_anon:74296kB inactive_anon:25960kB active_file:1086404kB inactive_file:605660kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:264kB writeback:0kB mapped:30604kB shmem:49168kB slab_reclaimable:50200kB slab_unreclaimable:45212kB kernel_stack:19184kB pagetables:34500kB unstable:0kB bounce:0kB free_pcp:740kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  408.465169] Node 0 DMA32: 2804*4kB (ME) 203*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 12840kB
[  416.426931] Node 0 DMA32 free:15396kB min:5564kB low:6952kB high:8344kB active_anon:98836kB inactive_anon:32120kB active_file:964808kB inactive_file:666224kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:33628kB shmem:57332kB slab_reclaimable:51048kB slab_unreclaimable:51824kB kernel_stack:23328kB pagetables:41896kB unstable:0kB bounce:0kB free_pcp:988kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  416.447247] Node 0 DMA32: 5158*4kB (UME) 68*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 21176kB
[  418.780159] Node 0 DMA32 free:8876kB min:5564kB low:6952kB high:8344kB active_anon:86544kB inactive_anon:31516kB active_file:965016kB inactive_file:654444kB unevictable:0kB isolated(anon):0kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:8408kB shmem:57332kB slab_reclaimable:48856kB slab_unreclaimable:61116kB kernel_stack:30224kB pagetables:48636kB unstable:0kB bounce:0kB free_pcp:980kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:260 all_unreclaimable? no
[  418.799643] Node 0 DMA32: 3093*4kB (UME) 1043*8kB (UME) 2*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20748kB
[  428.087913] Node 0 DMA32 free:22760kB min:5564kB low:6952kB high:8344kB active_anon:94544kB inactive_anon:38936kB active_file:1013576kB inactive_file:564976kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:2021100kB mlocked:0kB dirty:0kB writeback:0kB mapped:36096kB shmem:65376kB slab_reclaimable:52196kB slab_unreclaimable:60576kB kernel_stack:29888kB pagetables:56364kB unstable:0kB bounce:0kB free_pcp:852kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  428.109005] Node 0 DMA32: 2943*4kB (UME) 458*8kB (UME) 20*16kB (UME) 11*32kB (UME) 11*64kB (ME) 4*128kB (UME) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17324kB
[  439.014180] Node 0 DMA32 free:11232kB min:5564kB low:6952kB high:8344kB active_anon:82868kB inactive_anon:38872kB active_file:1189912kB inactive_file:439592kB unevictable:0kB isolated(anon):12kB isolated(file):40kB present:2080640kB managed:2021100kB mlocked:0kB dirty:0kB writeback:1152kB mapped:35948kB shmem:65376kB slab_reclaimable:51224kB slab_unreclaimable:56664kB kernel_stack:27696kB pagetables:43180kB unstable:0kB bounce:0kB free_pcp:380kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  439.032446] Node 0 DMA32: 2761*4kB (UM) 28*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 11268kB
[  441.731001] Node 0 DMA32 free:15056kB min:5564kB low:6952kB high:8344kB active_anon:90532kB inactive_anon:42716kB active_file:1204248kB inactive_file:377196kB unevictable:0kB isolated(anon):12kB isolated(file):116kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:5552kB shmem:73568kB slab_reclaimable:52956kB slab_unreclaimable:68304kB kernel_stack:39936kB pagetables:47472kB unstable:0kB bounce:0kB free_pcp:624kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  441.731018] Node 0 DMA32: 3130*4kB (UM) 338*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15224kB
[  442.070851] Node 0 DMA32 free:8852kB min:5564kB low:6952kB high:8344kB active_anon:90412kB inactive_anon:42664kB active_file:1179304kB inactive_file:371316kB unevictable:0kB isolated(anon):108kB isolated(file):268kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:5544kB shmem:73568kB slab_reclaimable:55136kB slab_unreclaimable:80080kB kernel_stack:55456kB pagetables:52692kB unstable:0kB bounce:0kB free_pcp:312kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:348 all_unreclaimable? no
[  442.070867] Node 0 DMA32: 590*4kB (ME) 827*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8976kB
[  442.245192] Node 0 DMA32 free:10832kB min:5564kB low:6952kB high:8344kB active_anon:97756kB inactive_anon:42664kB active_file:1082048kB inactive_file:417012kB unevictable:0kB isolated(anon):108kB isolated(file):268kB present:2080640kB managed:2021100kB mlocked:0kB dirty:4kB writeback:0kB mapped:5248kB shmem:73568kB slab_reclaimable:62816kB slab_unreclaimable:88964kB kernel_stack:61408kB pagetables:62908kB unstable:0kB bounce:0kB free_pcp:696kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  442.245208] Node 0 DMA32: 1902*4kB (UME) 410*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10888kB
----------

Since I cannot establish workload that caused December 24's natural OOM
killers, I used the following stressor for generating similar situation.

The fileio.c fills up all memory with file cache and tries to keep them
on memory. The fork.c is flood of order-2 allocation generator because
December 24's OOM killers were triggered by copy_process() which involves
order-2 allocation request.

---------- fileio.c start ----------
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

int main(int argc, char *argv[])
{
	int i;
	static char buffer[4096];
	signal(SIGCHLD, SIG_IGN);
	for (i = 0; i < 2; i++) {
		int fd;
		int j;
		snprintf(buffer, sizeof(buffer), "/tmp/file.%u", i);
		fd = open(buffer, O_RDWR | O_CREAT, 0600);
		memset(buffer, 0, sizeof(buffer));
		for (j = 0; j < 1048576 * 1000 / 4096; j++) /* 1000 is MemTotal / 2 */
			write(fd, buffer, sizeof(buffer));
		close(fd);
	}
	for (i = 0; i < 2; i++) {
		if (fork() == 0) {
			int fd;
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", i);
			fd = open(buffer, O_RDWR);
			memset(buffer, 0, sizeof(buffer));
			while (fd != EOF) {
				lseek(fd, 0, SEEK_SET);
				while (read(fd, buffer, sizeof(buffer)) == sizeof(buffer));
			}
			_exit(0);
		}
	}
	if (fork() == 0) {
		execl("./fork", "./fork", NULL);
		_exit(1);
	}
	if (fork() == 0) {
		sleep(1);
		execl("./fork", "./fork", NULL);
		_exit(1);
	}
	while (1)
		system("pidof fork | wc");
	return 0;
}
---------- fileio.c end ----------

---------- fork.c start ----------
#include <unistd.h>
#include <signal.h>

int main(int argc, char *argv[])
{
	int i;
	signal(SIGCHLD, SIG_IGN);
	while (1) {
		sleep(5);
		for (i = 0; i < 2000; i++) {
			if (fork() == 0) {
				sleep(3);
				_exit(0);
			}
		}
	}
}
---------- fork.c end ----------

This reproducer also showed that once the OOM killer is invoked,
subsequent OOM killers tend to occur shortly because file cache
do not decrease.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
