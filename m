Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6997B6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 22:49:45 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id x188so3174196pfb.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:49:45 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id 64si1542514pfi.163.2016.03.07.19.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 19:49:44 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id 1so357918pal.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:49:44 -0800 (PST)
Date: Tue, 8 Mar 2016 12:51:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160308035104.GA447@swordfish>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160307160838.GB5028@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

Hello Michal,

On (03/07/16 17:08), Michal Hocko wrote:
> On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> > Andrew,
> > could you queue this one as well, please? This is more a band aid than a
> > real solution which I will be working on as soon as I am able to
> > reproduce the issue but the patch should help to some degree at least.
> 
> Joonsoo wasn't very happy about this approach so let me try a different
> way. What do you think about the following? Hugh, Sergey does it help
> for your load? I have tested it with the Hugh's load and there was no
> major difference from the previous testing so at least nothing has blown
> up as I am not able to reproduce the issue here.

(next-20160307 + "[PATCH] mm, oom: protect !costly allocations some more")

seems it's significantly less likely to oom-kill now, but I still can see
something like this

[  501.942745] coretemp-sensor invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[  501.942796] CPU: 3 PID: 409 Comm: coretemp-sensor Not tainted 4.5.0-rc6-next-20160307-dbg-00015-g8a56edd-dirty #250
[  501.942801]  0000000000000000 ffff88013114fb88 ffffffff812364e9 0000000000000000
[  501.942804]  ffff88013114fd28 ffff88013114fbf8 ffffffff8113b11c ffff88013114fba8
[  501.942807]  ffffffff810835c1 ffff88013114fbc8 0000000000000206 ffffffff81a46de0
[  501.942808] Call Trace:
[  501.942813]  [<ffffffff812364e9>] dump_stack+0x67/0x90
[  501.942817]  [<ffffffff8113b11c>] dump_header.isra.5+0x54/0x359
[  501.942820]  [<ffffffff810835c1>] ? trace_hardirqs_on+0xd/0xf
[  501.942823]  [<ffffffff810f97c2>] oom_kill_process+0x89/0x503
[  501.942825]  [<ffffffff810f9ffe>] out_of_memory+0x372/0x38d
[  501.942827]  [<ffffffff810fe5ae>] __alloc_pages_nodemask+0x9b6/0xa92
[  501.942830]  [<ffffffff810fe882>] alloc_kmem_pages_node+0x1b/0x1d
[  501.942833]  [<ffffffff81041f86>] copy_process.part.9+0xfe/0x17f4
[  501.942835]  [<ffffffff810858f6>] ? lock_acquire+0x10f/0x1a3
[  501.942837]  [<ffffffff8104380f>] _do_fork+0xbd/0x5da
[  501.942838]  [<ffffffff81083598>] ? trace_hardirqs_on_caller+0x16c/0x188
[  501.942842]  [<ffffffff81001a79>] ? do_syscall_64+0x18/0xe6
[  501.942844]  [<ffffffff81043db2>] SyS_clone+0x19/0x1b
[  501.942845]  [<ffffffff81001abb>] do_syscall_64+0x5a/0xe6
[  501.942848]  [<ffffffff8151245a>] entry_SYSCALL64_slow_path+0x25/0x25
[  501.942850] Mem-Info:
[  501.942853] active_anon:151312 inactive_anon:54791 isolated_anon:0
                active_file:31213 inactive_file:302048 isolated_file:0
                unevictable:0 dirty:44 writeback:221 unstable:0
                slab_reclaimable:43570 slab_unreclaimable:5651
                mapped:16660 shmem:29495 pagetables:2542 bounce:0
                free:10884 free_pcp:214 free_cma:0
[  501.942859] DMA free:14896kB min:28kB low:40kB high:52kB active_anon:0kB inactive_anon:0kB active_file:96kB inactive_file:104kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:124kB shmem:0kB slab_reclaimable:28kB slab_unreclaimable:108kB kernel_stack:16kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  501.942862] lowmem_reserve[]: 0 3031 3855 3855
[  501.942867] DMA32 free:23664kB min:6232kB low:9332kB high:12432kB active_anon:516228kB inactive_anon:129136kB active_file:96508kB inactive_file:954780kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3194880kB managed:3107512kB mlocked:0kB dirty:136kB writeback:440kB mapped:51816kB shmem:91488kB slab_reclaimable:129856kB slab_unreclaimable:13876kB kernel_stack:2160kB pagetables:7888kB unstable:0kB bounce:0kB free_pcp:724kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
[  501.942870] lowmem_reserve[]: 0 0 824 824
[  501.942876] Normal free:4784kB min:1696kB low:2540kB high:3384kB active_anon:89020kB inactive_anon:90028kB active_file:28248kB inactive_file:253308kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:917504kB managed:844512kB mlocked:0kB dirty:40kB writeback:444kB mapped:14700kB shmem:26492kB slab_reclaimable:44396kB slab_unreclaimable:8620kB kernel_stack:1328kB pagetables:2280kB unstable:0kB bounce:0kB free_pcp:244kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:60 all_unreclaimable? no
[  501.942879] lowmem_reserve[]: 0 0 0 0
[  501.942902] DMA: 6*4kB (UME) 3*8kB (M) 2*16kB (UM) 3*32kB (ME) 2*64kB (ME) 2*128kB (ME) 2*256kB (UE) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (E) 2*4096kB (M) = 14896kB
[  501.942912] DMA32: 564*4kB (UME) 2700*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23856kB
[  501.942921] Normal: 959*4kB (ME) 128*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4860kB
[  501.942922] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  501.942923] 362670 total pagecache pages
[  501.942924] 0 pages in swap cache
[  501.942926] Swap cache stats: add 150, delete 150, find 0/0
[  501.942926] Free swap  = 8388504kB
[  501.942927] Total swap = 8388604kB
[  501.942928] 1032092 pages RAM
[  501.942928] 0 pages HighMem/MovableOnly
[  501.942929] 40111 pages reserved
[  501.942930] 0 pages hwpoisoned
[  501.942930] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  501.942935] [  162]     0   162    15823     1065      35       3        0             0 systemd-journal
[  501.942991] [  186]     0   186     8586     1054      19       3        0         -1000 systemd-udevd
[  501.942993] [  287]     0   287     3557      651      12       3        0             0 crond
[  501.942995] [  288]    81   288     8159      775      20       3        0          -900 dbus-daemon
[  501.942997] [  289]     0   289     3843      518      13       3        0             0 systemd-logind
[  501.942999] [  294]     0   294    22455      856      47       3        0             0 login
[  501.943001] [  302]  1000   302     8481     1029      20       3        0             0 systemd
[  501.943003] [  304]  1000   304    24212      438      47       3        0             0 (sd-pam)
[  501.943005] [  309]  1000   309     4431     1123      14       3        0             0 bash
[  501.943007] [  316]  1000   316     3712      764      13       3        0             0 startx
[  501.943009] [  338]  1000   338     3976      255      14       3        0             0 xinit
[  501.943012] [  339]  1000   339    44397    11311      90       3        0             0 Xorg
[  501.943014] [  341]  1000   341    39703     4045      78       3        0             0 openbox
[  501.943016] [  352]  1000   352    43465     2997      86       4        0             0 tint2
[  501.943018] [  355]  1000   355    33962     4351      57       3        0             0 urxvt
[  501.943020] [  356]  1000   356     4466     1155      13       3        0             0 bash
[  501.943022] [  359]  1000   359     4433     1116      13       3        0             0 bash
[  501.943024] [  364]  1000   364    49365     6236      62       3        0             0 urxvt
[  501.943026] [  365]  1000   365     4433     1093      15       3        0             0 bash
[  501.943028] [  368]  1000   368     5203      745      15       3        0             0 tmux
[  501.943030] [  370]  1000   370     6336     1374      17       3        0             0 tmux
[  501.943046] [  371]  1000   371     4433     1100      14       3        0             0 bash
[  501.943049] [  378]  1000   378     4433     1115      13       3        0             0 bash
[  501.943051] [  381]  1000   381     5203      763      16       3        0             0 tmux
[  501.943053] [  382]  1000   382     4433     1089      15       3        0             0 bash
[  501.943055] [  389]  1000   389     4433     1078      15       3        0             0 bash
[  501.943057] [  392]  1000   392     4433     1078      15       3        0             0 bash
[  501.943058] [  395]  1000   395     4433     1090      14       3        0             0 bash
[  501.943060] [  398]  1000   398     4433     1111      14       3        0             0 bash
[  501.943062] [  401]  1000   401    10126     1010      25       3        0             0 top
[  501.943064] [  403]  1000   403     4433     1129      14       3        0             0 bash
[  501.943066] [  409]  1000   409     3740      786      13       3        0             0 coretemp-sensor
[  501.943069] [  443]  1000   443    25873     3141      51       3        0             0 urxvt
[  501.943071] [  444]  1000   444     4433     1110      13       3        0             0 bash
[  501.943073] [  447]  1000   447    68144    55547     138       3        0             0 mutt
[  501.943075] [  450]  1000   450    29966     3825      51       3        0             0 urxvt
[  501.943077] [  451]  1000   451     4433     1117      14       3        0             0 bash
[  501.943079] [  456]  1000   456    29967     3793      53       3        0             0 urxvt
[  501.943081] [  457]  1000   457     4433     1085      14       3        0             0 bash
[  501.943083] [  462]  1000   462    29967     3845      51       4        0             0 urxvt
[  501.943085] [  463]  1000   463     4433     1093      14       3        0             0 bash
[  501.943087] [  468]  1000   468    29967     3793      50       3        0             0 urxvt
[  501.943089] [  469]  1000   469     4433     1086      15       3        0             0 bash
[  501.943091] [  493]  1000   493    52976     6416      69       3        0             0 urxvt
[  501.943093] [  494]  1000   494     4433     1106      14       3        0             0 bash
[  501.943095] [  499]  1000   499    29966     3792      54       3        0             0 urxvt
[  501.943097] [  500]  1000   500     4433     1078      14       3        0             0 bash
[  501.943099] [  525]     0   525    17802     1108      38       3        0             0 sudo
[  501.943101] [  528]     0   528   186583      768     207       4        0             0 journalctl
[  501.943103] [  550]  1000   550    42144     9259      66       4        0             0 urxvt
[  501.943105] [  551]  1000   551     4433     1067      14       4        0             0 bash
[  501.943107] [  557]  1000   557    11115      768      27       3        0             0 su
[  501.943109] [  579]     0   579     4462     1148      13       3        0             0 bash
[  501.943111] [  963]  1000   963     4433     1075      14       3        0             0 bash
[  501.943113] [  981]  1000   981     4433     1114      13       3        0             0 bash
[  501.943115] [  993]  1000   993     4432     1118      14       3        0             0 bash
[  501.943117] [ 1062]  1000  1062     5203      734      15       3        0             0 tmux
[  501.943119] [ 1063]  1000  1063    13805    10479      32       3        0             0 bash
[  501.943121] [ 1145]  1000  1145     4466     1144      14       3        0             0 bash
[  501.943123] [ 4331]  1000  4331   287422    64040     429       4        0             0 firefox
[  501.943125] [ 4440]  1000  4440     8132      761      20       3        0             0 dbus-daemon
[  501.943127] [ 4470]  1000  4470    83823      934      31       4        0             0 at-spi-bus-laun
[  501.943129] [17875]  1000 17875     7549     1926      20       3        0             0 vim
[  501.943131] [27066]  1000 27066     4432     1120      15       3        0             0 bash
[  501.943133] [27073]  1000 27073     4432     1071      13       3        0             0 bash
[  501.943135] [27079]  1000 27079     4432     1077      15       3        0             0 bash
[  501.943137] [27085]  1000 27085     4432     1080      14       3        0             0 bash
[  501.943139] [27091]  1000 27091     4432     1091      14       3        0             0 bash
[  501.943141] [27097]  1000 27097     4432     1096      15       3        0             0 bash
[  501.943143] [ 1235]     0  1235     3745      809      11       3        0             0 zram-test.sh
[  501.943145] [ 2316]  1000  2316     1759      166       9       3        0             0 sleep
[  501.943147] [ 2323]     0  2323     3302     1946      12       3        0             0 dd
[  501.943148] Out of memory: Kill process 4331 (firefox) score 20 or sacrifice child
[  501.943352] Killed process 4331 (firefox) total-vm:1149688kB, anon-rss:207844kB, file-rss:48172kB, shmem-rss:516kB

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
