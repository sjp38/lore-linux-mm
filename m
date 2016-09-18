Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A67796B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 16:26:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so52714412wmz.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 13:26:19 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id oy1si14613072wjb.199.2016.09.18.13.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 13:26:17 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id 1so125856528wmz.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 13:26:17 -0700 (PDT)
Date: Sun, 18 Sep 2016 21:26:14 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: More OOM problems
Message-ID: <20160918202614.GB31286@lucifer>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

Hi all,

In case it's helpful - I have experienced these OOM issues invoked in my case via the nvidia driver and similarly to Linus an order 3 allocation resulted in killed chromium tabs. I encountered this even after applying the patch discussed in the original thread at https://lkml.org/lkml/2016/8/22/184. It's not easily reproducible but it is happening enough that I could probably check some specific state when it next occurs or test out a patch to see if it stops it if that'd be useful.

I saved a couple OOM's from the last time it occurred, this is on a 8GiB system with plenty of reclaimable memory:

[350085.038693] Xorg invoked oom-killer: gfp_mask=0x24040c0(GFP_KERNEL|__GFP_COMP), order=3, oom_score_adj=0
[350085.038696] Xorg cpuset=/ mems_allowed=0
[350085.038699] CPU: 0 PID: 2119 Comm: Xorg Tainted: P           O    4.7.2-1-custom #1
[350085.038701] Hardware name: MSI MS-7850/Z97 PC Mate(MS-7850), BIOS V4.10 08/11/2015
[350085.038702]  0000000000000286 000000009fd6569c ffff88020c60f940 ffffffff812eb122
[350085.038704]  ffff88020c60fb18 ffff8800b4cfaac0 ffff88020c60f9b0 ffffffff811f6e4c
[350085.038706]  0000000000000246 ffff880200000000 ffff88020c60f970 ffffffff00000001
[350085.038708] Call Trace:
[350085.038712]  [<ffffffff812eb122>] dump_stack+0x63/0x81
[350085.038715]  [<ffffffff811f6e4c>] dump_header+0x60/0x1e8
[350085.038718]  [<ffffffff811762fa>] oom_kill_process+0x22a/0x440
[350085.038720]  [<ffffffff8117696a>] out_of_memory+0x40a/0x4b0
[350085.038723]  [<ffffffff812ffdf8>] ? find_next_bit+0x18/0x20
[350085.038725]  [<ffffffff8117c034>] __alloc_pages_nodemask+0xee4/0xf20
[350085.038727]  [<ffffffff811cb835>] alloc_pages_current+0x95/0x140
[350085.038729]  [<ffffffff8117c2f9>] alloc_kmem_pages+0x19/0x90
[350085.038731]  [<ffffffff8119a79e>] kmalloc_order_trace+0x2e/0x100
[350085.038733]  [<ffffffff811d6bd3>] __kmalloc+0x213/0x230
[350085.038745]  [<ffffffffa147d2c7>] nvkms_alloc+0x27/0x60 [nvidia_modeset]
[350085.038752]  [<ffffffffa147e540>] ? _nv000318kms+0x40/0x40 [nvidia_modeset]
[350085.038760]  [<ffffffffa14b7eea>] _nv001929kms+0x1a/0x30 [nvidia_modeset]
[350085.038767]  [<ffffffffa14a4242>] ? _nv001878kms+0x32/0xcf0 [nvidia_modeset]
[350085.038768]  [<ffffffff8117c2f9>] ? alloc_kmem_pages+0x19/0x90
[350085.038770]  [<ffffffff811d6bd3>] ? __kmalloc+0x213/0x230
[350085.038776]  [<ffffffffa147d2c7>] ? nvkms_alloc+0x27/0x60 [nvidia_modeset]
[350085.038782]  [<ffffffffa147e540>] ? _nv000318kms+0x40/0x40 [nvidia_modeset]
[350085.038788]  [<ffffffffa147e56e>] ? _nv000169kms+0x2e/0x40 [nvidia_modeset]
[350085.038794]  [<ffffffffa147f0c1>] ? nvKmsIoctl+0x161/0x1e0 [nvidia_modeset]
[350085.038800]  [<ffffffffa147dd65>] ? nvkms_ioctl_common+0x45/0x80 [nvidia_modeset]
[350085.038806]  [<ffffffffa147de11>] ? nvkms_ioctl+0x71/0xa0 [nvidia_modeset]
[350085.038962]  [<ffffffffa0831080>] ? nvidia_frontend_compat_ioctl+0x40/0x50 [nvidia]
[350085.039032]  [<ffffffffa083109e>] ? nvidia_frontend_unlocked_ioctl+0xe/0x10 [nvidia]
[350085.039035]  [<ffffffff8120cd62>] ? do_vfs_ioctl+0xa2/0x5d0
[350085.039037]  [<ffffffff8120d309>] ? SyS_ioctl+0x79/0x90
[350085.039039]  [<ffffffff815de7b2>] ? entry_SYSCALL_64_fastpath+0x1a/0xa4
[350085.039048] Mem-Info:
[350085.039051] active_anon:861397 inactive_anon:23397 isolated_anon:0
                 active_file:146274 inactive_file:144248 isolated_file:0
                 unevictable:8 dirty:14587 writeback:0 unstable:0
                 slab_reclaimable:697630 slab_unreclaimable:24397
                 mapped:79655 shmem:26548 pagetables:7211 bounce:0
                 free:25159 free_pcp:235 free_cma:0
[350085.039054] Node 0 DMA free:15516kB min:136kB low:168kB high:200kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[350085.039058] lowmem_reserve[]: 0 3196 7658 7658
[350085.039060] Node 0 DMA32 free:45980kB min:28148kB low:35184kB high:42220kB active_anon:1466208kB inactive_anon:43120kB active_file:239740kB inactive_file:234920kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3617864kB managed:3280092kB mlocked:0kB dirty:21692kB writeback:0kB mapped:131184kB shmem:47588kB slab_reclaimable:1147984kB slab_unreclaimable:37484kB kernel_stack:2976kB pagetables:11512kB unstable:0kB bounce:0kB free_pcp:188kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[350085.039064] lowmem_reserve[]: 0 0 4462 4462
[350085.039065] Node 0 Normal free:39140kB min:39296kB low:49120kB high:58944kB active_anon:1979380kB inactive_anon:50468kB active_file:345356kB inactive_file:342072kB unevictable:32kB isolated(anon):0kB isolated(file):0kB present:4702208kB managed:4569312kB mlocked:32kB dirty:36656kB writeback:0kB mapped:187436kB shmem:58604kB slab_reclaimable:1642536kB slab_unreclaimable:60104kB kernel_stack:5040kB pagetables:17332kB unstable:0kB bounce:0kB free_pcp:752kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:136 all_unreclaimable? no
[350085.039069] lowmem_reserve[]: 0 0 0 0
[350085.039071] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 0*128kB 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15516kB
[350085.039077] Node 0 DMA32: 11569*4kB (UME) 50*8kB (M) 2*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 46708kB
[350085.039083] Node 0 Normal: 9282*4kB (UE) 0*8kB 4*16kB (H) 2*32kB (H) 3*64kB (H) 1*128kB (H) 2*256kB (H) 2*512kB (H) 0*1024kB 0*2048kB 0*4096kB = 39112kB
[350085.039090] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[350085.039092] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[350085.039092] 316873 total pagecache pages
[350085.039093] 0 pages in swap cache
[350085.039094] Swap cache stats: add 0, delete 0, find 0/0
[350085.039095] Free swap  = 0kB
[350085.039096] Total swap = 0kB
[350085.039097] 2084014 pages RAM
[350085.039097] 0 pages HighMem/MovableOnly
[350085.039098] 117688 pages reserved
[350085.039099] 0 pages hwpoisoned
[350085.039099] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[350085.039107] [  208]     0   208    19325     3639      35       3        0             0 systemd-journal
[350085.039109] [  265]     0   265     9102      818      18       3        0         -1000 systemd-udevd
[350085.039113] [ 1809]   192  1809    28539      542      25       3        0             0 systemd-timesyn
[350085.039115] [ 1822]    81  1822     8296      653      21       4        0          -900 dbus-daemon
[350085.039117] [ 1832]     0  1832     9629      511      22       3        0             0 systemd-logind
[350085.039119] [ 1862]     0  1862     3260      611      10       3        0             0 crond
[350085.039121] [ 1910]  1000  1910     3505      776      11       3        0             0 devmon
[350085.039122] [ 2041]  1000  2041     6453      707      18       3        0             0 udevil
[350085.039124] [ 2050]     0  2050     1685       77       9       3        0             0 dhcpcd
[350085.039126] [ 2051]     0  2051   132774     4634      65       6        0          -500 dockerd
[350085.039128] [ 2057]     0  2057    10099      746      25       3        0         -1000 sshd
[350085.039130] [ 2085]     0  2085   108773     1180      30       5        0          -500 docker-containe
[350085.039132] [ 2100]     0  2100    66532      937      32       3        0             0 lightdm
[350085.039134] [ 2119]     0  2119    50761    17423      97       3        0             0 Xorg
[350085.039136] [ 2123]     0  2123    68666     1431      36       3        0             0 accounts-daemon
[350085.039138] [ 2135]   102  2135   129825     2707      50       4        0             0 polkitd
[350085.039142] [ 2562]     0  2562    65038     1104      59       3        0             0 lightdm
[350085.039144] [ 2572]  1000  2572    13695     1020      29       3        0             0 systemd
[350085.039146] [ 2577]  1000  2577    24641      397      48       3        0             0 (sd-pam)
[350085.039147] [ 2584]  1000  2584    32170     1929      66       3        0             0 i3
[350085.039149] [ 2596]  1000  2596     2788      184      10       3        0             0 ssh-agent
[350085.039151] [ 2603]  1000  2603     8212      576      20       3        0             0 dbus-daemon
[350085.039153] [ 2605]  1000  2605    27268     1497      56       3        0             0 i3bar
[350085.039155] [ 2606]  1000  2606     3406      459      10       3        0             0 measure-net-spe
[350085.039157] [ 2607]  1000  2607    17782      505      40       3        0             0 i3status
[350085.039159] [ 2608]  1000  2608     3406      585      10       3        0             0 measure-net-spe
[350085.039161] [ 2658]  1000  2658    67811      849      34       3        0             0 gvfsd
[350085.039163] [ 2663]  1000  2663    84725     1246      31       3        0             0 gvfsd-fuse
[350085.039164] [ 2671]  1000  2671    84401      651      33       3        0             0 at-spi-bus-laun
[350085.039166] [ 2676]  1000  2676     8186      714      20       3        0             0 dbus-daemon
[350085.039168] [ 2678]  1000  2678    53563      667      40       3        0             0 at-spi2-registr
[350085.039169] [ 2682]  1000  2682    14718      829      32       3        0             0 gconfd-2
[350085.039171] [ 2690]  1000  2690   222566     5206     122       4        0             0 pulseaudio
[350085.039173] [ 2691]   133  2691    44462      530      22       3        0             0 rtkit-daemon
[350085.039174] [ 2743]  1000  2743     4649      755      13       3        0             0 zsh
[350085.039176] [ 2748]  1000  2748   437286    84044     478       6        0             0 chromium
[350085.039178] [ 2752]  1000  2752     1585      191       9       3        0             0 chrome-sandbox
[350085.039179] [ 2753]  1000  2753   113527     5589     166       4        0             0 chromium
[350085.039181] [ 2756]  1000  2756     1585      177       8       3        0             0 chrome-sandbox
[350085.039182] [ 2757]  1000  2757     7909      840      22       4        0             0 nacl_helper
[350085.039184] [ 2759]  1000  2759   113527     2847     127       4        0             0 chromium
[350085.039186] [ 2866]  1000  2866   340267   219730     629       7        0           200 chromium
[350085.039187] [ 2881]  1000  2881   114831     4858     144       5        0           200 chromium
[350085.039189] [ 2891]  1000  2891   258525    43032     338      68        0           300 chromium
[350085.039191] [ 2908]  1000  2908   216776    17487     220      31        0           300 chromium
[350085.039193] [ 3096]     0  3096    73383     1417      42       3        0             0 upowerd
[350085.039194] [ 4273]  1000  4273     4649      761      13       3        0             0 zsh
[350085.039196] [ 4276]  1000  4276   206798     6849     144       4        0             0 pavucontrol
[350085.039198] [ 6647]  1000  6647   250470    37756     295      54        0           300 chromium
[350085.039200] [ 6658]  1000  6658   214211    17257     215      29        0           300 chromium
[350085.039201] [ 7390]  1000  7390   216243    17154     217      29        0           300 chromium
[350085.039204] [23007]  1000 23007   113232     2020      54       4        0             0 gvfs-udisks2-vo
[350085.039205] [23010]     0 23010    91532     2142      44       3        0             0 udisksd
[350085.039207] [ 6558]  1000  6558    20485     2858      42       3        0             0 urxvt
[350085.039209] [ 6559]  1000  6559     9121     1722      22       3        0             0 zsh
[350085.039210] [ 6581]  1000  6581    39165    25124      80       4        0             0 mutt
[350085.039213] [18246]  1000 18246     4649      848      12       3        0             0 zsh
[350085.039215] [18251]  1000 18251   191866    14934     175       4        0             0 emacs
[350085.039216] [18256]  1000 18256     4004      813      12       3        0             0 bash
[350085.039218] [18261]  1000 18261    20305     2924      43       3        0             0 urxvt
[350085.039220] [18262]  1000 18262     9121     1714      23       3        0             0 zsh
[350085.039223] [ 7362]  1000  7362   319274   102294     527     164        0           300 chromium
[350085.039225] [ 9185]  1000  9185   400186   164602     672     161        0           300 chromium
[350085.039227] [10839]  1000 10839   253464    41492     303      50        0           300 chromium
[350085.039228] [10957]     0 10957    17509     1231      37       3        0             0 sudo
[350085.039230] [10960]     0 10960    55798    21075      81       4        0             0 pacman
[350085.039232] [15262]     0 15262     3438      787      11       3        0             0 alpm-hook
[350085.039234] [15263]     0 15263     3868     1244      11       3        0             0 dkms
[350085.039236] [15278]     0 15278     3869     1168      11       3        0             0 dkms
[350085.039237] [15611]     0 15611     3869      916      11       3        0             0 dkms
[350085.039239] [15612]     0 15612     3869      947      11       3        0             0 dkms
[350085.039241] [15613]     0 15613     8562      865      20       3        0             0 make
[350085.039242] [15619]     0 15619     8793     1078      20       3        0             0 make
[350085.039244] [15889]     0 15889     9148     1498      22       3        0             0 make
[350085.039246] [18079]     0 18079     3442      779      11       3        0             0 sh
[350085.039248] [18080]     0 18080     2490      227       9       3        0             0 cc
[350085.039249] [18081]     0 18081    68687    38388      97       3        0             0 cc1
[350085.039251] [18082]     0 18082     4786     1977      14       3        0             0 as
[350085.039253] [18091]     0 18091     3442      808      11       3        0             0 sh
[350085.039255] [18093]     0 18093     1454      165       8       3        0             0 sleep
[350085.039257] [18094]     0 18094     2490      253       9       3        0             0 cc
[350085.039259] [18095]     0 18095    68650    38238      96       3        0             0 cc1
[350085.039261] [18101]     0 18101     4786     1964      14       3        0             0 as
[350085.039263] [18104]     0 18104     3442      814      11       3        0             0 sh
[350085.039264] [18106]     0 18106     2490      248       9       3        0             0 cc
[350085.039266] [18107]     0 18107    67906    36050      93       3        0             0 cc1
[350085.039268] [18108]     0 18108     4786     2030      14       3        0             0 as
[350085.039270] [18130]     0 18130     3442      790      12       3        0             0 sh
[350085.039271] [18133]     0 18133     2490      235       8       3        0             0 cc
[350085.039273] [18134]     0 18134     3442      781      12       3        0             0 sh
[350085.039275] [18135]     0 18135    67911    36623      95       3        0             0 cc1
[350085.039277] [18136]     0 18136     4786     1935      15       3        0             0 as
[350085.039278] [18137]     0 18137     3442      786      10       3        0             0 sh
[350085.039280] [18138]     0 18138     2490      229       9       3        0             0 cc
[350085.039282] [18139]     0 18139     2490      242       9       3        0             0 cc
[350085.039284] [18140]     0 18140    67922    20214      63       3        0             0 cc1
[350085.039286] [18141]     0 18141    66967    36993      94       3        0             0 cc1
[350085.039288] [18142]     0 18142     4786     1952      14       4        0             0 as
[350085.039289] [18143]     0 18143     4786     2012      13       3        0             0 as
[350085.039291] [18152]     0 18152     3442      778      10       3        0             0 sh
[350085.039293] [18153]     0 18153     2490      226       9       3        0             0 cc
[350085.039295] [18154]     0 18154    22881    13677      47       3        0             0 cc1
[350085.039296] [18155]     0 18155     4786     2012      15       3        0             0 as
[350085.039298] [18166]     0 18166     3442      809      10       3        0             0 sh
[350085.039300] [18167]     0 18167     3442      137       8       3        0             0 sh
[350085.039301] Out of memory: Kill process 9185 (chromium) score 384 or sacrifice child
[350085.039346] Killed process 9185 (chromium) total-vm:1600744kB, anon-rss:548240kB, file-rss:71988kB, shmem-rss:38180kB
[350085.075980] oom_reaper: reaped process 9185 (chromium), now anon-rss:0kB, file-rss:0kB, shmem-rss:38480kB
[350086.337625] Xorg invoked oom-killer: gfp_mask=0x24040c0(GFP_KERNEL|__GFP_COMP), order=3, oom_score_adj=0
[350086.337628] Xorg cpuset=/ mems_allowed=0
[350086.337633] CPU: 0 PID: 2119 Comm: Xorg Tainted: P           O    4.7.2-1-custom #1
[350086.337634] Hardware name: MSI MS-7850/Z97 PC Mate(MS-7850), BIOS V4.10 08/11/2015
[350086.337635]  0000000000000286 000000009fd6569c ffff88020c60f940 ffffffff812eb122
[350086.337637]  ffff88020c60fb18 ffff8800cb5ae3c0 ffff88020c60f9b0 ffffffff811f6e4c
[350086.337639]  0000000000000246 ffff880200000000 ffff88020c60f970 ffffffff00000002
[350086.337640] Call Trace:
[350086.337646]  [<ffffffff812eb122>] dump_stack+0x63/0x81
[350086.337649]  [<ffffffff811f6e4c>] dump_header+0x60/0x1e8
[350086.337653]  [<ffffffff811762fa>] oom_kill_process+0x22a/0x440
[350086.337655]  [<ffffffff8117696a>] out_of_memory+0x40a/0x4b0
[350086.337657]  [<ffffffff812ffdf8>] ? find_next_bit+0x18/0x20
[350086.337659]  [<ffffffff8117c034>] __alloc_pages_nodemask+0xee4/0xf20
[350086.337662]  [<ffffffff811cb835>] alloc_pages_current+0x95/0x140
[350086.337663]  [<ffffffff8117c2f9>] alloc_kmem_pages+0x19/0x90
[350086.337666]  [<ffffffff8119a79e>] kmalloc_order_trace+0x2e/0x100
[350086.337668]  [<ffffffff811d6bd3>] __kmalloc+0x213/0x230
[350086.337681]  [<ffffffffa147d2c7>] nvkms_alloc+0x27/0x60 [nvidia_modeset]
[350086.337687]  [<ffffffffa147e540>] ? _nv000318kms+0x40/0x40 [nvidia_modeset]
[350086.337695]  [<ffffffffa14b7eea>] _nv001929kms+0x1a/0x30 [nvidia_modeset]
[350086.337702]  [<ffffffffa14a4242>] ? _nv001878kms+0x32/0xcf0 [nvidia_modeset]
[350086.337703]  [<ffffffff8117c2f9>] ? alloc_kmem_pages+0x19/0x90
[350086.337705]  [<ffffffff811d6bd3>] ? __kmalloc+0x213/0x230
[350086.337711]  [<ffffffffa147d2c7>] ? nvkms_alloc+0x27/0x60 [nvidia_modeset]
[350086.337716]  [<ffffffffa147e540>] ? _nv000318kms+0x40/0x40 [nvidia_modeset]
[350086.337722]  [<ffffffffa147e56e>] ? _nv000169kms+0x2e/0x40 [nvidia_modeset]
[350086.337728]  [<ffffffffa147f0c1>] ? nvKmsIoctl+0x161/0x1e0 [nvidia_modeset]
[350086.337734]  [<ffffffffa147dd65>] ? nvkms_ioctl_common+0x45/0x80 [nvidia_modeset]
[350086.337740]  [<ffffffffa147de11>] ? nvkms_ioctl+0x71/0xa0 [nvidia_modeset]
[350086.337838]  [<ffffffffa0831080>] ? nvidia_frontend_compat_ioctl+0x40/0x50 [nvidia]
[350086.337911]  [<ffffffffa083109e>] ? nvidia_frontend_unlocked_ioctl+0xe/0x10 [nvidia]
[350086.337915]  [<ffffffff8120cd62>] ? do_vfs_ioctl+0xa2/0x5d0
[350086.337917]  [<ffffffff8120d309>] ? SyS_ioctl+0x79/0x90
[350086.337920]  [<ffffffff815de7b2>] ? entry_SYSCALL_64_fastpath+0x1a/0xa4
[350086.337933] Mem-Info:
[350086.337936] active_anon:926090 inactive_anon:14054 isolated_anon:0
                 active_file:127217 inactive_file:124640 isolated_file:0
                 unevictable:8 dirty:14757 writeback:0 unstable:0
                 slab_reclaimable:685505 slab_unreclaimable:20594
                 mapped:69794 shmem:17206 pagetables:7032 bounce:0
                 free:25275 free_pcp:114 free_cma:0
[350086.337939] Node 0 DMA free:15516kB min:136kB low:168kB high:200kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[350086.337944] lowmem_reserve[]: 0 3196 7658 7658
[350086.337946] Node 0 DMA32 free:46168kB min:28148kB low:35184kB high:42220kB active_anon:1571968kB inactive_anon:33316kB active_file:206232kB inactive_file:198884kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3617864kB managed:3280092kB mlocked:0kB dirty:21952kB writeback:0kB mapped:120868kB shmem:37784kB slab_reclaimable:1128300kB slab_unreclaimable:31216kB kernel_stack:2848kB pagetables:11300kB unstable:0kB bounce:0kB free_pcp:4kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:92 all_unreclaimable? no
[350086.337950] lowmem_reserve[]: 0 0 4462 4462
[350086.337952] Node 0 Normal free:39416kB min:39296kB low:49120kB high:58944kB active_anon:2132392kB inactive_anon:22900kB active_file:302636kB inactive_file:299676kB unevictable:32kB isolated(anon):0kB isolated(file):0kB present:4702208kB managed:4569312kB mlocked:32kB dirty:37076kB writeback:0kB mapped:158308kB shmem:31040kB slab_reclaimable:1613720kB slab_unreclaimable:51160kB kernel_stack:4752kB pagetables:16828kB unstable:0kB bounce:0kB free_pcp:440kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:400 all_unreclaimable? no
[350086.337956] lowmem_reserve[]: 0 0 0 0
[350086.337958] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 0*128kB 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15516kB
[350086.337984] Node 0 DMA32: 11350*4kB (UME) 172*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 46776kB
[350086.337989] Node 0 Normal: 9232*4kB (UME) 54*8kB (ME) 62*16kB (MEH) 2*32kB (H) 3*64kB (H) 1*128kB (H) 2*256kB (H) 2*512kB (H) 0*1024kB 0*2048kB 0*4096kB = 40272kB
[350086.337997] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[350086.337998] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[350086.337999] 269040 total pagecache pages
[350086.338011] 0 pages in swap cache
[350086.338012] Swap cache stats: add 0, delete 0, find 0/0
[350086.338013] Free swap  = 0kB
[350086.338013] Total swap = 0kB
[350086.338014] 2084014 pages RAM
[350086.338015] 0 pages HighMem/MovableOnly
[350086.338016] 117688 pages reserved
[350086.338016] 0 pages hwpoisoned
[350086.338017] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[350086.338027] [  208]     0   208    19325     3815      35       3        0             0 systemd-journal
[350086.338029] [  265]     0   265     9102      818      18       3        0         -1000 systemd-udevd
[350086.338033] [ 1809]   192  1809    28539      542      25       3        0             0 systemd-timesyn
[350086.338035] [ 1822]    81  1822     8296      653      21       4        0          -900 dbus-daemon
[350086.338037] [ 1832]     0  1832     9629      511      22       3        0             0 systemd-logind
[350086.338039] [ 1862]     0  1862     3260      611      10       3        0             0 crond
[350086.338041] [ 1910]  1000  1910     3505      776      11       3        0             0 devmon
[350086.338043] [ 2041]  1000  2041     6453      707      18       3        0             0 udevil
[350086.338045] [ 2050]     0  2050     1685       77       9       3        0             0 dhcpcd
[350086.338047] [ 2051]     0  2051   132774     4634      65       6        0          -500 dockerd
[350086.338049] [ 2057]     0  2057    10099      746      25       3        0         -1000 sshd
[350086.338051] [ 2085]     0  2085   108773     1180      30       5        0          -500 docker-containe
[350086.338053] [ 2100]     0  2100    66532      937      32       3        0             0 lightdm
[350086.338055] [ 2119]     0  2119    50761    17520      97       3        0             0 Xorg
[350086.338057] [ 2123]     0  2123    68666     1431      36       3        0             0 accounts-daemon
[350086.338058] [ 2135]   102  2135   129825     2705      50       4        0             0 polkitd
[350086.338062] [ 2562]     0  2562    65038     1104      59       3        0             0 lightdm
[350086.338064] [ 2572]  1000  2572    13695     1020      29       3        0             0 systemd
[350086.338066] [ 2577]  1000  2577    24641      397      48       3        0             0 (sd-pam)
[350086.338069] [ 2584]  1000  2584    32170     1929      66       3        0             0 i3
[350086.338070] [ 2596]  1000  2596     2788      184      10       3        0             0 ssh-agent
[350086.338073] [ 2603]  1000  2603     8212      576      20       3        0             0 dbus-daemon
[350086.338075] [ 2605]  1000  2605    27268     1497      56       3        0             0 i3bar
[350086.338077] [ 2606]  1000  2606     3406      459      10       3        0             0 measure-net-spe
[350086.338079] [ 2607]  1000  2607    17782      505      40       3        0             0 i3status
[350086.338081] [ 2608]  1000  2608     3406      585      10       3        0             0 measure-net-spe
[350086.338084] [ 2658]  1000  2658    67811      849      34       3        0             0 gvfsd
[350086.338086] [ 2663]  1000  2663    84725     1246      31       3        0             0 gvfsd-fuse
[350086.338088] [ 2671]  1000  2671    84401      651      33       3        0             0 at-spi-bus-laun
[350086.338091] [ 2676]  1000  2676     8186      714      20       3        0             0 dbus-daemon
[350086.338093] [ 2678]  1000  2678    53563      667      40       3        0             0 at-spi2-registr
[350086.338095] [ 2682]  1000  2682    14718      829      32       3        0             0 gconfd-2
[350086.338098] [ 2690]  1000  2690   222566     5206     122       4        0             0 pulseaudio
[350086.338100] [ 2691]   133  2691    44462      530      22       3        0             0 rtkit-daemon
[350086.338103] [ 2743]  1000  2743     4649      755      13       3        0             0 zsh
[350086.338106] [ 2748]  1000  2748   433311    84260     475       6        0             0 chromium
[350086.338108] [ 2752]  1000  2752     1585      191       9       3        0             0 chrome-sandbox
[350086.338110] [ 2753]  1000  2753   113527     5589     166       4        0             0 chromium
[350086.338112] [ 2756]  1000  2756     1585      177       8       3        0             0 chrome-sandbox
[350086.338114] [ 2757]  1000  2757     7909      840      22       4        0             0 nacl_helper
[350086.338117] [ 2759]  1000  2759   113527     2847     127       4        0             0 chromium
[350086.338120] [ 2866]  1000  2866   332680   213705     612       7        0           200 chromium
[350086.338122] [ 2881]  1000  2881   114831     4858     144       5        0           200 chromium
[350086.338124] [ 2891]  1000  2891   258525    43032     338      68        0           300 chromium
[350086.338126] [ 2908]  1000  2908   216776    17487     220      31        0           300 chromium
[350086.338129] [ 3096]     0  3096    73383     1417      42       3        0             0 upowerd
[350086.338131] [ 4273]  1000  4273     4649      761      13       3        0             0 zsh
[350086.338134] [ 4276]  1000  4276   206984     7921     144       4        0             0 pavucontrol
[350086.338136] [ 6647]  1000  6647   250470    37756     295      54        0           300 chromium
[350086.338138] [ 6658]  1000  6658   214211    17257     215      29        0           300 chromium
[350086.338140] [ 7390]  1000  7390   216243    17154     217      29        0           300 chromium
[350086.338143] [23007]  1000 23007   113232     2020      54       4        0             0 gvfs-udisks2-vo
[350086.338145] [23010]     0 23010    91532     2140      44       3        0             0 udisksd
[350086.338147] [ 6558]  1000  6558    20485     2858      42       3        0             0 urxvt
[350086.338150] [ 6559]  1000  6559     9121     1722      22       3        0             0 zsh
[350086.338152] [ 6581]  1000  6581    39165    25124      80       4        0             0 mutt
[350086.338155] [18246]  1000 18246     4649      848      12       3        0             0 zsh
[350086.338157] [18251]  1000 18251   191866    14934     175       4        0             0 emacs
[350086.338159] [18256]  1000 18256     4004      813      12       3        0             0 bash
[350086.338161] [18261]  1000 18261    20305     2924      43       3        0             0 urxvt
[350086.338163] [18262]  1000 18262     9121     1714      23       3        0             0 zsh
[350086.338168] [ 7362]  1000  7362   319274   102294     527     164        0           300 chromium
[350086.338171] [10839]  1000 10839   253464    41492     303      50        0           300 chromium
[350086.338173] [10957]     0 10957    17509     1231      37       3        0             0 sudo
[350086.338175] [10960]     0 10960    55798    21075      81       4        0             0 pacman
[350086.338178] [15262]     0 15262     3438      787      11       3        0             0 alpm-hook
[350086.338180] [15263]     0 15263     3868     1244      11       3        0             0 dkms
[350086.338182] [15278]     0 15278     3869     1168      11       3        0             0 dkms
[350086.338184] [15611]     0 15611     3869      916      11       3        0             0 dkms
[350086.338186] [15612]     0 15612     3869      947      11       3        0             0 dkms
[350086.338189] [15613]     0 15613     8562      865      20       3        0             0 make
[350086.338191] [15619]     0 15619     8793     1078      20       3        0             0 make
[350086.338193] [15889]     0 15889     9148     1498      22       3        0             0 make
[350086.338196] [18079]     0 18079     3442      779      11       3        0             0 sh
[350086.338198] [18080]     0 18080     2490      227       9       3        0             0 cc
[350086.338201] [18081]     0 18081    99723    59927     144       3        0             0 cc1
[350086.338203] [18082]     0 18082     4786     1977      14       3        0             0 as
[350086.338205] [18091]     0 18091     3442      808      11       3        0             0 sh
[350086.338208] [18093]     0 18093     1454      165       8       3        0             0 sleep
[350086.338210] [18094]     0 18094     2490      253       9       3        0             0 cc
[350086.338211] [18095]     0 18095   100238    60442     146       3        0             0 cc1
[350086.338213] [18101]     0 18101     4786     1964      14       3        0             0 as
[350086.338215] [18104]     0 18104     3442      814      11       3        0             0 sh
[350086.338217] [18106]     0 18106     2490      248       9       3        0             0 cc
[350086.338219] [18107]     0 18107    99725    57639     141       4        0             0 cc1
[350086.338221] [18108]     0 18108     4786     2030      14       3        0             0 as
[350086.338223] [18130]     0 18130     3442      790      12       3        0             0 sh
[350086.338226] [18133]     0 18133     2490      235       8       3        0             0 cc
[350086.338228] [18134]     0 18134     3442      781      12       3        0             0 sh
[350086.338230] [18135]     0 18135    81008    48498     121       3        0             0 cc1
[350086.338232] [18136]     0 18136     4786     1935      15       3        0             0 as
[350086.338234] [18137]     0 18137     3442      786      10       3        0             0 sh
[350086.338236] [18138]     0 18138     2490      229       9       3        0             0 cc
[350086.338238] [18139]     0 18139     2490      242       9       3        0             0 cc
[350086.338240] [18140]     0 18140    80993    48202     118       3        0             0 cc1
[350086.338242] [18141]     0 18141    99713    53841     132       3        0             0 cc1
[350086.338243] [18142]     0 18142     4786     1952      14       4        0             0 as
[350086.338245] [18143]     0 18143     4786     2012      13       3        0             0 as
[350086.338247] [18152]     0 18152     3442      778      10       3        0             0 sh
[350086.338249] [18153]     0 18153     2490      226       9       3        0             0 cc
[350086.338251] [18154]     0 18154    83047    50126     121       3        0             0 cc1
[350086.338253] [18155]     0 18155     4786     2012      15       3        0             0 as
[350086.338255] [18166]     0 18166     3442      809      10       3        0             0 sh
[350086.338257] [18167]     0 18167     2490      236       9       3        0             0 cc
[350086.338259] [18168]     0 18168    73800    42887     106       4        0             0 cc1
[350086.338260] [18169]     0 18169     4786     1952      14       3        0             0 as
[350086.338262] Out of memory: Kill process 7362 (chromium) score 352 or sacrifice child
[350086.338298] Killed process 7362 (chromium) total-vm:1277096kB, anon-rss:313392kB, file-rss:68416kB, shmem-rss:27368kB
[350086.360581] oom_reaper: reaped process 7362 (chromium), now anon-rss:0kB, file-rss:0kB, shmem-rss:27268kB
[~]$ free -h
              total        used        free      shared  buff/cache   available
Mem:           7.5G        3.3G        810M         39M        3.4G        3.9G
Swap:            0B          0B          0B

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
