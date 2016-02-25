Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 398E06B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:47:30 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so26956773pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 22:47:30 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id q28si10400037pfi.178.2016.02.24.22.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 22:47:28 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id c10so28504133pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 22:47:28 -0800 (PST)
Date: Thu, 25 Feb 2016 15:48:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160225064845.GA505@swordfish>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On (02/24/16 19:47), Hugh Dickins wrote:
> On Wed, 3 Feb 2016, Michal Hocko wrote:
> > Hi,
> > this thread went mostly quite. Are all the main concerns clarified?
> > Are there any new concerns? Are there any objections to targeting
> > this for the next merge window?
> 
> Sorry to say at this late date, but I do have one concern: hopefully
> you can tweak something somewhere, or point me to some tunable that
> I can adjust (I've not studied the patches, sorry).
> 
> This rework makes it impossible to run my tmpfs swapping loads:
> they're soon OOM-killed when they ran forever before, so swapping
> does not get the exercise on mmotm that it used to.  (But I'm not
> so arrogant as to expect you to optimize for my load!)
> 
> Maybe it's just that I'm using tmpfs, and there's code that's conscious
> of file and anon, but doesn't cope properly with the awkward shmem case.
> 
> (Of course, tmpfs is and always has been a problem for OOM-killing,
> given that it takes up memory, but none is freed by killing processes:
> but although that is a tiresome problem, it's not what either of us is
> attacking here.)
> 
> Taking many of the irrelevancies out of my load, here's something you
> could try, first on v4.5-rc5 and then on mmotm.
> 

FWIW,

I have recently noticed the same change while testing zram-zsmalloc. next/mmots
are much more likely to OOM-kill apps now. and, unlike before, I don't see a lot
of shrinker->zsmalloc->zs_shrinker_scan() calls or swapouts, the kernel just
oom-kills Xorg, etc.

the test script just creates a zram device (ext4 fs, lzo compression) and fills
it with some data, nothing special.


OOM example:

[ 2392.663170] zram-test.sh invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[ 2392.663175] CPU: 1 PID: 9517 Comm: zram-test.sh Not tainted 4.5.0-rc5-next-20160225-dbg-00009-g334f687-dirty #190
[ 2392.663178]  0000000000000000 ffff88000b4efb88 ffffffff81237bac 0000000000000000
[ 2392.663181]  ffff88000b4efd28 ffff88000b4efbf8 ffffffff8113a077 ffff88000b4efba8
[ 2392.663184]  ffffffff81080e24 ffff88000b4efbc8 ffffffff8151584e ffffffff81a48460
[ 2392.663187] Call Trace:
[ 2392.663191]  [<ffffffff81237bac>] dump_stack+0x67/0x90
[ 2392.663195]  [<ffffffff8113a077>] dump_header.isra.5+0x54/0x351
[ 2392.663197]  [<ffffffff81080e24>] ? trace_hardirqs_on+0xd/0xf
[ 2392.663201]  [<ffffffff8151584e>] ? _raw_spin_unlock_irqrestore+0x4b/0x60
[ 2392.663204]  [<ffffffff810f7ae7>] oom_kill_process+0x89/0x4ff
[ 2392.663206]  [<ffffffff810f8319>] out_of_memory+0x36c/0x387
[ 2392.663208]  [<ffffffff810fc9c2>] __alloc_pages_nodemask+0x9ba/0xaa8
[ 2392.663211]  [<ffffffff810fcca8>] alloc_kmem_pages_node+0x1b/0x1d
[ 2392.663213]  [<ffffffff81040216>] copy_process.part.9+0xfe/0x183f
[ 2392.663216]  [<ffffffff81041aea>] _do_fork+0xbd/0x5f1
[ 2392.663218]  [<ffffffff81117402>] ? __might_fault+0x40/0x8d
[ 2392.663220]  [<ffffffff81515f52>] ? entry_SYSCALL_64_fastpath+0x5/0xa8
[ 2392.663223]  [<ffffffff81001844>] ? do_syscall_64+0x18/0xe6
[ 2392.663224]  [<ffffffff810420a4>] SyS_clone+0x19/0x1b
[ 2392.663226]  [<ffffffff81001886>] do_syscall_64+0x5a/0xe6
[ 2392.663228]  [<ffffffff8151601a>] entry_SYSCALL64_slow_path+0x25/0x25
[ 2392.663230] Mem-Info:
[ 2392.663233] active_anon:87788 inactive_anon:69289 isolated_anon:0
                active_file:161111 inactive_file:320022 isolated_file:0
                unevictable:0 dirty:51 writeback:0 unstable:0
                slab_reclaimable:80335 slab_unreclaimable:5920
                mapped:30115 shmem:29235 pagetables:2589 bounce:0
                free:10949 free_pcp:189 free_cma:0
[ 2392.663239] DMA free:15096kB min:28kB low:40kB high:52kB active_anon:0kB inactive_anon:0kB active_file:32kB inactive_file:120kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:136kB shmem:0kB slab_reclaimable:48kB slab_unreclaimable:92kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 2392.663240] lowmem_reserve[]: 0 3031 3855 3855
[ 2392.663247] DMA32 free:22876kB min:6232kB low:9332kB high:12432kB active_anon:316384kB inactive_anon:172076kB active_file:512592kB inactive_file:1011992kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3194880kB managed:3107516kB mlocked:0kB dirty:148kB writeback:0kB mapped:93284kB shmem:90904kB slab_reclaimable:248836kB slab_unreclaimable:14620kB kernel_stack:2208kB pagetables:7796kB unstable:0kB bounce:0kB free_pcp:628kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:256 all_unreclaimable? no
[ 2392.663249] lowmem_reserve[]: 0 0 824 824
[ 2392.663256] Normal free:5824kB min:1696kB low:2540kB high:3384kB active_anon:34768kB inactive_anon:105080kB active_file:131820kB inactive_file:267720kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:917504kB managed:844512kB mlocked:0kB dirty:56kB writeback:0kB mapped:27040kB shmem:26036kB slab_reclaimable:72456kB slab_unreclaimable:8968kB kernel_stack:1296kB pagetables:2560kB unstable:0kB bounce:0kB free_pcp:128kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
[ 2392.663257] lowmem_reserve[]: 0 0 0 0
[ 2392.663260] DMA: 4*4kB (M) 1*8kB (M) 4*16kB (ME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 3*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (E) 2*4096kB (M) = 15096kB
[ 2392.663284] DMA32: 5809*4kB (UME) 3*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23260kB
[ 2392.663293] Normal: 1515*4kB (UME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6060kB
[ 2392.663302] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 2392.663303] 510384 total pagecache pages
[ 2392.663305] 31 pages in swap cache
[ 2392.663306] Swap cache stats: add 113, delete 82, find 47/62
[ 2392.663307] Free swap  = 8388268kB
[ 2392.663308] Total swap = 8388604kB
[ 2392.663308] 1032092 pages RAM
[ 2392.663309] 0 pages HighMem/MovableOnly
[ 2392.663310] 40110 pages reserved
[ 2392.663311] 0 pages hwpoisoned
[ 2392.663312] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 2392.663316] [  149]     0   149     9683     1612      20       3        4             0 systemd-journal
[ 2392.663319] [  183]     0   183     8598     1103      19       3       18         -1000 systemd-udevd
[ 2392.663321] [  285]    81   285     8183      911      20       3        0          -900 dbus-daemon
[ 2392.663323] [  288]     0   288     3569      653      13       3        0             0 crond
[ 2392.663326] [  289]     0   289     3855      649      12       3        0             0 systemd-logind
[ 2392.663328] [  291]     0   291    22469      967      48       3        0             0 login
[ 2392.663330] [  299]  1000   299     8493     1140      21       3        0             0 systemd
[ 2392.663332] [  301]  1000   301    24226      416      47       3       20             0 (sd-pam)
[ 2392.663334] [  306]  1000   306     4471     1126      14       3        0             0 bash
[ 2392.663336] [  313]  1000   313     3717      739      13       3        0             0 startx
[ 2392.663339] [  335]  1000   335     3981      236      14       3        0             0 xinit
[ 2392.663341] [  336]  1000   336    47841    19104      94       3        0             0 Xorg
[ 2392.663343] [  338]  1000   338    39714     4302      80       3        0             0 openbox
[ 2392.663345] [  349]  1000   349    43472     3280      88       3        0             0 tint2
[ 2392.663347] [  355]  1000   355    34168     5710      57       3        0             0 urxvt
[ 2392.663349] [  356]  1000   356     4533     1248      15       3        0             0 bash
[ 2392.663351] [  435]     0   435     3691     2168      10       3        0             0 dhclient
[ 2392.663353] [  451]  1000   451     4445     1111      14       4        0             0 bash
[ 2392.663355] [  459]  1000   459    45577     6121      59       3        0             0 urxvt
[ 2392.663357] [  460]  1000   460     4445     1070      15       3        0             0 bash
[ 2392.663359] [  463]  1000   463     5207      728      16       3        0             0 tmux
[ 2392.663362] [  465]  1000   465     6276     1299      18       3        0             0 tmux
[ 2392.663364] [  466]  1000   466     4445     1113      14       3        0             0 bash
[ 2392.663366] [  473]  1000   473     4445     1087      15       3        0             0 bash
[ 2392.663368] [  476]  1000   476     5207      760      15       3        0             0 tmux
[ 2392.663370] [  477]  1000   477     4445     1080      14       3        0             0 bash
[ 2392.663372] [  484]  1000   484     4445     1076      14       3        0             0 bash
[ 2392.663374] [  487]  1000   487     4445     1129      14       3        0             0 bash
[ 2392.663376] [  490]  1000   490     4445     1115      14       3        0             0 bash
[ 2392.663378] [  493]  1000   493    10206     1135      24       3        0             0 top
[ 2392.663380] [  495]  1000   495     4445     1146      15       3        0             0 bash
[ 2392.663382] [  502]  1000   502     3745      814      13       3        0             0 coretemp-sensor
[ 2392.663385] [  536]  1000   536    27937     4429      53       3        0             0 urxvt
[ 2392.663387] [  537]  1000   537     4445     1092      14       3        0             0 bash
[ 2392.663389] [  543]  1000   543    29981     4138      53       3        0             0 urxvt
[ 2392.663391] [  544]  1000   544     4445     1095      14       3        0             0 bash
[ 2392.663393] [  549]  1000   549    29981     4132      53       3        0             0 urxvt
[ 2392.663395] [  550]  1000   550     4445     1121      13       3        0             0 bash
[ 2392.663397] [  555]  1000   555    45194     5728      62       3        0             0 urxvt
[ 2392.663399] [  556]  1000   556     4445     1116      14       3        0             0 bash
[ 2392.663401] [  561]  1000   561    30173     4317      51       3        0             0 urxvt
[ 2392.663403] [  562]  1000   562     4445     1075      14       3        0             0 bash
[ 2392.663405] [  586]  1000   586    57178     7499      65       4        0             0 urxvt
[ 2392.663408] [  587]  1000   587     4478     1156      14       3        0             0 bash
[ 2392.663410] [  593]     0   593    17836     1213      39       3        0             0 sudo
[ 2392.663412] [  594]     0   594   136671     1794     188       4        0             0 journalctl
[ 2392.663414] [  616]  1000   616    29981     4140      54       3        0             0 urxvt
[ 2392.663416] [  617]  1000   617     4445     1122      14       3        0             0 bash
[ 2392.663418] [  622]  1000   622    34169     8473      60       3        0             0 urxvt
[ 2392.663420] [  623]  1000   623     4445     1116      14       3        0             0 bash
[ 2392.663422] [  646]  1000   646     4445     1124      15       3        0             0 bash
[ 2392.663424] [  668]  1000   668     4445     1090      15       3        0             0 bash
[ 2392.663426] [  671]  1000   671     4445     1090      13       3        0             0 bash
[ 2392.663429] [  674]  1000   674     4445     1083      13       3        0             0 bash
[ 2392.663431] [  677]  1000   677     4445     1124      15       3        0             0 bash
[ 2392.663433] [  720]  1000   720     3717      707      12       3        0             0 build99
[ 2392.663435] [  721]  1000   721     9107     1244      21       3        0             0 ssh
[ 2392.663437] [  768]     0   768    17827     1292      40       3        0             0 sudo
[ 2392.663439] [  771]     0   771     4640      622      14       3        0             0 screen
[ 2392.663441] [  772]     0   772     4673      505      11       3        0             0 screen
[ 2392.663443] [  775]  1000   775     4445     1120      14       3        0             0 bash
[ 2392.663445] [  778]  1000   778     4445     1097      14       3        0             0 bash
[ 2392.663447] [  781]  1000   781     4445     1088      13       3        0             0 bash
[ 2392.663449] [  784]  1000   784     4445     1109      13       3        0             0 bash
[ 2392.663451] [  808]  1000   808   341606    79367     532       5        0             0 firefox
[ 2392.663454] [  845]  1000   845     8144      799      20       3        0             0 dbus-daemon
[ 2392.663456] [  852]  1000   852    83828     1216      31       4        0             0 at-spi-bus-laun
[ 2392.663458] [ 9064]  1000  9064     4478     1154      13       3        0             0 bash
[ 2392.663460] [ 9068]  1000  9068     4478     1135      15       3        0             0 bash
[ 2392.663462] [ 9460]  1000  9460    11128      767      26       3        0             0 su
[ 2392.663464] [ 9463]     0  9463     4474     1188      14       4        0             0 bash
[ 2392.663482] [ 9517]     0  9517     3750      830      13       3        0             0 zram-test.sh
[ 2392.663485] [ 9917]  1000  9917     4444     1124      14       3        0             0 bash
[ 2392.663487] [13623]  1000 13623     1764      186       9       3        0             0 sleep
[ 2392.663489] Out of memory: Kill process 808 (firefox) score 25 or sacrifice child
[ 2392.663769] Killed process 808 (firefox) total-vm:1366424kB, anon-rss:235572kB, file-rss:82320kB, shmem-rss:8kB


[ 2400.152464] zram-test.sh invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[ 2400.152470] CPU: 1 PID: 9517 Comm: zram-test.sh Not tainted 4.5.0-rc5-next-20160225-dbg-00009-g334f687-dirty #190
[ 2400.152473]  0000000000000000 ffff88000b4efb88 ffffffff81237bac 0000000000000000
[ 2400.152476]  ffff88000b4efd28 ffff88000b4efbf8 ffffffff8113a077 ffff88000b4efba8
[ 2400.152479]  ffffffff81080e24 ffff88000b4efbc8 ffffffff8151584e ffffffff81a48460
[ 2400.152481] Call Trace:
[ 2400.152487]  [<ffffffff81237bac>] dump_stack+0x67/0x90
[ 2400.152490]  [<ffffffff8113a077>] dump_header.isra.5+0x54/0x351
[ 2400.152493]  [<ffffffff81080e24>] ? trace_hardirqs_on+0xd/0xf
[ 2400.152496]  [<ffffffff8151584e>] ? _raw_spin_unlock_irqrestore+0x4b/0x60
[ 2400.152500]  [<ffffffff810f7ae7>] oom_kill_process+0x89/0x4ff
[ 2400.152502]  [<ffffffff810f8319>] out_of_memory+0x36c/0x387
[ 2400.152504]  [<ffffffff810fc9c2>] __alloc_pages_nodemask+0x9ba/0xaa8
[ 2400.152506]  [<ffffffff810fcca8>] alloc_kmem_pages_node+0x1b/0x1d
[ 2400.152509]  [<ffffffff81040216>] copy_process.part.9+0xfe/0x183f
[ 2400.152511]  [<ffffffff81083178>] ? lock_acquire+0x11f/0x1c7
[ 2400.152513]  [<ffffffff81041aea>] _do_fork+0xbd/0x5f1
[ 2400.152515]  [<ffffffff81117402>] ? __might_fault+0x40/0x8d
[ 2400.152517]  [<ffffffff81515f52>] ? entry_SYSCALL_64_fastpath+0x5/0xa8
[ 2400.152520]  [<ffffffff81001844>] ? do_syscall_64+0x18/0xe6
[ 2400.152522]  [<ffffffff810420a4>] SyS_clone+0x19/0x1b
[ 2400.152524]  [<ffffffff81001886>] do_syscall_64+0x5a/0xe6
[ 2400.152526]  [<ffffffff8151601a>] entry_SYSCALL64_slow_path+0x25/0x25
[ 2400.152527] Mem-Info:
[ 2400.152531] active_anon:37648 inactive_anon:59709 isolated_anon:0
                active_file:160072 inactive_file:275086 isolated_file:0
                unevictable:0 dirty:49 writeback:0 unstable:0
                slab_reclaimable:54096 slab_unreclaimable:5978
                mapped:13650 shmem:29234 pagetables:2058 bounce:0
                free:13017 free_pcp:134 free_cma:0
[ 2400.152536] DMA free:15096kB min:28kB low:40kB high:52kB active_anon:0kB inactive_anon:0kB active_file:32kB inactive_file:120kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:136kB shmem:0kB slab_reclaimable:48kB slab_unreclaimable:92kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 2400.152537] lowmem_reserve[]: 0 3031 3855 3855
[ 2400.152545] DMA32 free:31504kB min:6232kB low:9332kB high:12432kB active_anon:129548kB inactive_anon:172076kB active_file:508480kB inactive_file:872492kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3194880kB managed:3107516kB mlocked:0kB dirty:132kB writeback:0kB mapped:42296kB shmem:90900kB slab_reclaimable:165548kB slab_unreclaimable:14964kB kernel_stack:1712kB pagetables:6176kB unstable:0kB bounce:0kB free_pcp:428kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:424 all_unreclaimable? no
[ 2400.152546] lowmem_reserve[]: 0 0 824 824
[ 2400.152553] Normal free:5468kB min:1696kB low:2540kB high:3384kB active_anon:21044kB inactive_anon:66760kB active_file:131776kB inactive_file:227732kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:917504kB managed:844512kB mlocked:0kB dirty:64kB writeback:0kB mapped:12168kB shmem:26036kB slab_reclaimable:50788kB slab_unreclaimable:8856kB kernel_stack:912kB pagetables:2056kB unstable:0kB bounce:0kB free_pcp:108kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:160 all_unreclaimable? no
[ 2400.152555] lowmem_reserve[]: 0 0 0 0
[ 2400.152558] DMA: 4*4kB (M) 1*8kB (M) 4*16kB (ME) 1*32kB (M) 2*64kB (UE) 2*128kB (UE) 3*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 1*2048kB (E) 2*4096kB (M) = 15096kB
[ 2400.152573] DMA32: 7835*4kB (UME) 55*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 31780kB
[ 2400.152582] Normal: 1383*4kB (UM) 22*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5708kB
[ 2400.152592] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 2400.152593] 464295 total pagecache pages
[ 2400.152594] 31 pages in swap cache
[ 2400.152595] Swap cache stats: add 113, delete 82, find 47/62
[ 2400.152596] Free swap  = 8388268kB
[ 2400.152597] Total swap = 8388604kB
[ 2400.152598] 1032092 pages RAM
[ 2400.152599] 0 pages HighMem/MovableOnly
[ 2400.152600] 40110 pages reserved
[ 2400.152600] 0 pages hwpoisoned
[ 2400.152601] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 2400.152605] [  149]     0   149     9683     1990      20       3        4             0 systemd-journal
[ 2400.152608] [  183]     0   183     8598     1103      19       3       18         -1000 systemd-udevd
[ 2400.152610] [  285]    81   285     8183      911      20       3        0          -900 dbus-daemon
[ 2400.152613] [  288]     0   288     3569      653      13       3        0             0 crond
[ 2400.152615] [  289]     0   289     3855      649      12       3        0             0 systemd-logind
[ 2400.152617] [  291]     0   291    22469      967      48       3        0             0 login
[ 2400.152619] [  299]  1000   299     8493     1140      21       3        0             0 systemd
[ 2400.152621] [  301]  1000   301    24226      416      47       3       20             0 (sd-pam)
[ 2400.152623] [  306]  1000   306     4471     1126      14       3        0             0 bash
[ 2400.152626] [  313]  1000   313     3717      739      13       3        0             0 startx
[ 2400.152628] [  335]  1000   335     3981      236      14       3        0             0 xinit
[ 2400.152630] [  336]  1000   336    47713    19103      93       3        0             0 Xorg
[ 2400.152632] [  338]  1000   338    39714     4302      80       3        0             0 openbox
[ 2400.152634] [  349]  1000   349    43472     3280      88       3        0             0 tint2
[ 2400.152636] [  355]  1000   355    34168     5754      58       3        0             0 urxvt
[ 2400.152638] [  356]  1000   356     4533     1248      15       3        0             0 bash
[ 2400.152640] [  435]     0   435     3691     2168      10       3        0             0 dhclient
[ 2400.152642] [  451]  1000   451     4445     1111      14       4        0             0 bash
[ 2400.152644] [  459]  1000   459    45577     6121      59       3        0             0 urxvt
[ 2400.152646] [  460]  1000   460     4445     1070      15       3        0             0 bash
[ 2400.152648] [  463]  1000   463     5207      728      16       3        0             0 tmux
[ 2400.152650] [  465]  1000   465     6276     1299      18       3        0             0 tmux
[ 2400.152653] [  466]  1000   466     4445     1113      14       3        0             0 bash
[ 2400.152655] [  473]  1000   473     4445     1087      15       3        0             0 bash
[ 2400.152657] [  476]  1000   476     5207      760      15       3        0             0 tmux
[ 2400.152659] [  477]  1000   477     4445     1080      14       3        0             0 bash
[ 2400.152661] [  484]  1000   484     4445     1076      14       3        0             0 bash
[ 2400.152663] [  487]  1000   487     4445     1129      14       3        0             0 bash
[ 2400.152665] [  490]  1000   490     4445     1115      14       3        0             0 bash
[ 2400.152667] [  493]  1000   493    10206     1135      24       3        0             0 top
[ 2400.152669] [  495]  1000   495     4445     1146      15       3        0             0 bash
[ 2400.152671] [  502]  1000   502     3745      814      13       3        0             0 coretemp-sensor
[ 2400.152673] [  536]  1000   536    27937     4429      53       3        0             0 urxvt
[ 2400.152675] [  537]  1000   537     4445     1092      14       3        0             0 bash
[ 2400.152677] [  543]  1000   543    29981     4138      53       3        0             0 urxvt
[ 2400.152680] [  544]  1000   544     4445     1095      14       3        0             0 bash
[ 2400.152682] [  549]  1000   549    29981     4132      53       3        0             0 urxvt
[ 2400.152684] [  550]  1000   550     4445     1121      13       3        0             0 bash
[ 2400.152686] [  555]  1000   555    45194     5728      62       3        0             0 urxvt
[ 2400.152688] [  556]  1000   556     4445     1116      14       3        0             0 bash
[ 2400.152690] [  561]  1000   561    30173     4317      51       3        0             0 urxvt
[ 2400.152692] [  562]  1000   562     4445     1075      14       3        0             0 bash
[ 2400.152694] [  586]  1000   586    57178     7499      65       4        0             0 urxvt
[ 2400.152696] [  587]  1000   587     4478     1156      14       3        0             0 bash
[ 2400.152698] [  593]     0   593    17836     1213      39       3        0             0 sudo
[ 2400.152700] [  594]     0   594   136671     1794     188       4        0             0 journalctl
[ 2400.152702] [  616]  1000   616    29981     4140      54       3        0             0 urxvt
[ 2400.152705] [  617]  1000   617     4445     1122      14       3        0             0 bash
[ 2400.152707] [  622]  1000   622    34169     8473      60       3        0             0 urxvt
[ 2400.152709] [  623]  1000   623     4445     1116      14       3        0             0 bash
[ 2400.152711] [  646]  1000   646     4445     1124      15       3        0             0 bash
[ 2400.152713] [  668]  1000   668     4445     1090      15       3        0             0 bash
[ 2400.152715] [  671]  1000   671     4445     1090      13       3        0             0 bash
[ 2400.152717] [  674]  1000   674     4445     1083      13       3        0             0 bash
[ 2400.152719] [  677]  1000   677     4445     1124      15       3        0             0 bash
[ 2400.152721] [  720]  1000   720     3717      707      12       3        0             0 build99
[ 2400.152723] [  721]  1000   721     9107     1244      21       3        0             0 ssh
[ 2400.152725] [  768]     0   768    17827     1292      40       3        0             0 sudo
[ 2400.152727] [  771]     0   771     4640      622      14       3        0             0 screen
[ 2400.152729] [  772]     0   772     4673      505      11       3        0             0 screen
[ 2400.152731] [  775]  1000   775     4445     1120      14       3        0             0 bash
[ 2400.152733] [  778]  1000   778     4445     1097      14       3        0             0 bash
[ 2400.152735] [  781]  1000   781     4445     1088      13       3        0             0 bash
[ 2400.152737] [  784]  1000   784     4445     1109      13       3        0             0 bash
[ 2400.152740] [  845]  1000   845     8144      799      20       3        0             0 dbus-daemon
[ 2400.152742] [  852]  1000   852    83828     1216      31       4        0             0 at-spi-bus-laun
[ 2400.152744] [ 9064]  1000  9064     4478     1154      13       3        0             0 bash
[ 2400.152746] [ 9068]  1000  9068     4478     1135      15       3        0             0 bash
[ 2400.152748] [ 9460]  1000  9460    11128      767      26       3        0             0 su
[ 2400.152750] [ 9463]     0  9463     4474     1188      14       4        0             0 bash
[ 2400.152752] [ 9517]     0  9517     3783      832      13       3        0             0 zram-test.sh
[ 2400.152754] [ 9917]  1000  9917     4444     1124      14       3        0             0 bash
[ 2400.152757] [14052]  1000 14052     1764      162       9       3        0             0 sleep
[ 2400.152758] Out of memory: Kill process 336 (Xorg) score 6 or sacrifice child
[ 2400.152767] Killed process 336 (Xorg) total-vm:190852kB, anon-rss:58728kB, file-rss:17684kB, shmem-rss:0kB
[ 2400.161723] oom_reaper: reaped process 336 (Xorg), now anon-rss:0kB, file-rss:0kB, shmem-rss:0lB




$ free
              total        used        free      shared  buff/cache   available
Mem:        3967928     1563132      310548      116936     2094248     2207584
Swap:       8388604         332     8388272


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
