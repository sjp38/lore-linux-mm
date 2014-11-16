Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE686B0089
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 09:15:07 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id 10so14807020lbg.14
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 06:15:06 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id bd12si42812523lab.83.2014.11.16.06.15.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 06:15:05 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Xq0bZ-0008HZ-03
	for linux-mm@kvack.org; Sun, 16 Nov 2014 15:15:05 +0100
Received: from ip-87-240-192-101.dyn.luxdsl.pt.lu ([ip-87-240-192-101.dyn.luxdsl.pt.lu])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 15:15:04 +0100
Received: from mro2 by ip-87-240-192-101.dyn.luxdsl.pt.lu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 15:15:04 +0100
From: Marki <mro2@gmx.net>
Subject: How to interpret this OOM situation?
Date: Sun, 16 Nov 2014 14:11:29 +0000 (UTC)
Message-ID: <loom.20141116T150953-370@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Hey there,

I wouldn't know where to turn anymore, maybe you guys can help me debug this
OOM.

Questions aside from "why in the end is this happening":
- GFP mask lower byte 0xa indicates a request for a free page in highmem.
This is a 64-bit system and therefore has no highmem zone. So what's going on?
- Swap is almost not used: why not use it before OOMing?
- Pagecache is high: why not empty it before OOMing? (almost no dirty pages)

Oh and it's a machine with 4G of RAM on kernel 3.0.101 (SLES11 SP3).


<4>[598175.284914] cifsd invoked oom-killer: gfp_mask=0x200da, order=0,
oom_adj=0, oom_score_adj=0
<6>[598175.284919] cifsd cpuset=/ mems_allowed=0
<4>[598175.284921] Pid: 5529, comm: cifsd Tainted: G           E X
3.0.101-0.35-default #1
<4>[598175.284923] Call Trace:
<4>[598175.284934]  [<ffffffff81004935>] dump_trace+0x75/0x310
<4>[598175.284941]  [<ffffffff8145f2f3>] dump_stack+0x69/0x6f
<4>[598175.284947]  [<ffffffff810fc53e>] dump_header+0x8e/0x110
<4>[598175.284950]  [<ffffffff810fc8e6>] oom_kill_process+0xa6/0x350
<4>[598175.284954]  [<ffffffff810fce25>] out_of_memory+0x295/0x2f0
<4>[598175.284957]  [<ffffffff8110287e>] __alloc_pages_slowpath+0x78e/0x7d0
<4>[598175.284960]  [<ffffffff81102aa9>] __alloc_pages_nodemask+0x1e9/0x200
<4>[598175.284965]  [<ffffffff8113de60>] alloc_pages_vma+0xd0/0x1c0
<4>[598175.284969]  [<ffffffff81130bcd>] read_swap_cache_async+0x10d/0x160
<4>[598175.284972]  [<ffffffff81130c94>] swapin_readahead+0x74/0xd0
<4>[598175.284975]  [<ffffffff81120bfa>] do_swap_page+0xea/0x5f0
<4>[598175.284978]  [<ffffffff81121c21>] handle_pte_fault+0x1e1/0x230
<4>[598175.284982]  [<ffffffff81465bcd>] do_page_fault+0x1fd/0x4c0
<4>[598175.284985]  [<ffffffff814627e5>] page_fault+0x25/0x30
<4>[598175.285002]  [<00007f65a0891078>] 0x7f65a0891077

Ok, it wants to swap in sth but fails because apparently there is no more
physical memory.

<4>[598175.285003] Mem-Info:
<4>[598175.285004] Node 0 DMA per-cpu:
<4>[598175.285006] CPU    0: hi:    0, btch:   1 usd:   0
<4>[598175.285007] CPU    1: hi:    0, btch:   1 usd:   0
<4>[598175.285008] Node 0 DMA32 per-cpu:
<4>[598175.285010] CPU    0: hi:  186, btch:  31 usd:   9
<4>[598175.285011] CPU    1: hi:  186, btch:  31 usd:   7
<4>[598175.285012] Node 0 Normal per-cpu:
<4>[598175.285013] CPU    0: hi:  186, btch:  31 usd:  35
<4>[598175.285014] CPU    1: hi:  186, btch:  31 usd:  31
<4>[598175.285017] active_anon:218 inactive_anon:91 isolated_anon:0
<4>[598175.285018]  active_file:187788 inactive_file:451982 isolated_file:896
<4>[598175.285018]  unevictable:0 dirty:0 writeback:69 unstable:0
<4>[598175.285019]  free:21841 slab_reclaimable:8417 slab_unreclaimable:132175
<4>[598175.285020]  mapped:8168 shmem:4 pagetables:2639 bounce:0

Here we see a little over 3G used although I wouldn't be able to say what
the different entries are exactly.

<4>[598175.285021] Node 0 DMA free:15880kB min:256kB low:320kB high:384kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB isolat
ed(anon):0kB isolated(file):0kB present:15688kB mlocked:0kB dirty:0kB
writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:0kB kernel_stack:0k
B pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? yes
<4>[598175.285027] lowmem_reserve[]: 0 3000 4010 4010
<4>[598175.285029] Node 0 DMA32 free:54600kB min:50368kB low:62960kB
high:75552kB active_anon:860kB inactive_anon:308kB active_file:600716kB
inactive_file:1576184kB
 unevictable:0kB isolated(anon):0kB isolated(file):3328kB present:3072160kB
mlocked:0kB dirty:0kB writeback:248kB mapped:26800kB shmem:16kB
slab_reclaimable:23552kB
 slab_unreclaimable:412540kB kernel_stack:752kB pagetables:2412kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:4169324
all_unreclaimable? yes
<4>[598175.285036] lowmem_reserve[]: 0 0 1010 1010
<4>[598175.285038] Node 0 Normal free:16884kB min:16956kB low:21192kB
high:25432kB active_anon:12kB inactive_anon:56kB active_file:150436kB
inactive_file:231744kB u
nevictable:0kB isolated(anon):0kB isolated(file):384kB present:1034240kB
mlocked:0kB dirty:0kB writeback:28kB mapped:5872kB shmem:0kB
slab_reclaimable:10116kB slab_
unreclaimable:116160kB kernel_stack:2848kB pagetables:8144kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:688103 all_unreclaimable? yes
<4>[598175.285044] lowmem_reserve[]: 0 0 0 0
<4>[598175.285046] Node 0 DMA: 0*4kB 1*8kB 0*16kB 0*32kB 2*64kB 1*128kB
1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15880kB
<4>[598175.285051] Node 0 DMA32: 12620*4kB 3*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 54600kB
<4>[598175.285056] Node 0 Normal: 3195*4kB 1*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 16884kB

There seems to be a lot of fragmentation. But since an order 0 page (4k) was
requested (in highmem!?), and tons of those are available, that wouldn't
matter, would it?

<4>[598175.285061] 375504 total pagecache pages

That's more than 1G of pagecache. Shouldn't it first lower that cache before
throwing OOM?

<4>[598175.285062] 268 pages in swap cache
<4>[598175.285064] Swap cache stats: add 1266107, delete 1265839, find
3666696/3838636
<4>[598175.285065] Free swap  = 4641856kB
<4>[598175.285066] Total swap = 5244924kB

Almost no swap used. Shouldn't it swap before throwing OOM?

<4>[598175.285066] 1030522 pages RAM

Oh and FWIW here comes the process list

<6>[598175.285067] [ pid ]   uid  tgid total_vm      rss cpu oom_adj
oom_score_adj name
<6>[598175.285071] [  485]     0   485     4223       62   0     -17       
 -1000 udevd
<6>[598175.285073] [ 1434]     0  1434     1003       65   1       0       
     0 acpid
<6>[598175.285075] [ 1449]   100  1449     8585      112   0       0       
     0 dbus-daemon
<6>[598175.285077] [ 1475]     0  1475    36450      428   1       0       
     0 mono
<6>[598175.285079] [ 1772]     0  1772    21365      298   1       0       
     0 vmtoolsd
<6>[598175.285081] [ 1838]   101  1838    12322      180   0       0       
     0 hald
<6>[598175.285083] [ 1842]     0  1842    41067      187   1       0       
     0 console-kit-dae
<6>[598175.285085] [ 1843]     0  1843     4510       56   1       0       
     0 hald-runner
<6>[598175.285087] [ 1961]     0  1961     8691       17   0       0       
     0 hald-addon-inpu
<6>[598175.285107] [ 1984]     0  1984     8691       75   1       0       
     0 hald-addon-stor
<6>[598175.285109] [ 1992]   101  1992     9130        7   1       0       
     0 hald-addon-acpi
<6>[598175.285111] [ 1993]     0  1993     8691       77   0       0       
     0 hald-addon-stor
<6>[598175.285113] [ 2562]     0  2562    47184       78   1       0       
     0 httpstkd
<6>[598175.285115] [ 2581]     0  2581     5881      221   1       0       
     0 syslog-ng
<6>[598175.285117] [ 2584]     0  2584     1070       63   1       0       
     0 klogd
<6>[598175.285119] [ 2598]     0  2598    23796      104   1     -17       
 -1000 auditd
<6>[598175.285121] [ 2600]     0  2600    19995       87   1       0       
     0 audispd
<6>[598175.285123] [ 2621]     0  2621     2093       58   0       0       
     0 haveged
<6>[598175.285125] [ 2641]     0  2641     4728       81   1       0       
     0 rpcbind
<6>[598175.285127] [ 2680]     0  2680    77513      657   0       0       
     0 nsrexecd
<6>[598175.285129] [ 2753]     0  2753     4222       52   0     -17       
 -1000 udevd
<6>[598175.285131] [ 2832]     0  2832     2160       75   0       0       
     0 irqbalance
<6>[598175.285133] [ 2863]     0  2863     6778       53   1       0       
     0 mcelog
<6>[598175.285135] [ 3163]     0  3163    35027      170   1       0       
     0 gmond
<6>[598175.285137] [ 3177] 65534  3177    56670      185   0       0       
     0 gmetad
<6>[598175.285139] [ 3213]     0  3213    24991      107   1       0       
     0 sfcbd
<6>[598175.285141] [ 3214]     0  3214    16795        0   1       0       
     0 sfcbd
<6>[598175.285143] [ 3221]     0  3221    20445       78   1       0       
     0 sfcbd
<6>[598175.285145] [ 3222]     0  3222    41992      117   1       0       
     0 sfcbd
<6>[598175.285147] [ 3239]     0  3239    16092       58   1       0       
     0 pure-ftpd
<6>[598175.285149] [ 3240]     2  3240     6284       82   0       0       
     0 slpd
<6>[598175.285151] [ 3290]     0  3290    12855      120   0     -17       
 -1000 sshd
<6>[598175.285153] [ 3316]    74  3316     8070      152   0       0       
     0 ntpd
<6>[598175.285154] [ 3333]     0  3333    17945       90   1       0       
     0 cupsd
<6>[598175.285156] [ 3393]     0  3393    19365       31   1       0       
     0 sfcbd
<6>[598175.285158] [ 3395]     0  3395    21475      109   0       0       
     0 sfcbd
<6>[598175.285160] [ 3400]     0  3400    38331      129   1       0       
     0 sfcbd
<6>[598175.285162] [ 3479]     0  3479    38357      125   0       0       
     0 sfcbd
<6>[598175.285164] [ 3719]     0  3655   220311     2005   0       0       
     0 ndsd
<6>[598175.285166] [ 3893]    30  3893   177915      910   0       0       
     0 java
<6>[598175.285168] [ 3910]     0  3910    14968       97   1       0       
     0 nscd
<6>[598175.285170] [ 3961]     0  3961    47276      332   0       0       
     0 namcd
<6>[598175.285172] [ 4073]     0  4073    10998      104   0       0       
     0 master
<6>[598175.285174] [ 4099]    51  4099    14190      229   0       0       
     0 qmgr
<6>[598175.285176] [ 4135]     0  4135    33370       99   1       0       
     0 httpd2-prefork
<6>[598175.285178] [ 4136]    30  4136    35518       85   1       0       
     0 httpd2-prefork
<6>[598175.285180] [ 4137]    30  4137    35523      266   0       0       
     0 httpd2-prefork
<6>[598175.285182] [ 4138]    30  4138    35523      111   0       0       
     0 httpd2-prefork
<6>[598175.285184] [ 4139]    30  4139    35523      137   0       0       
     0 httpd2-prefork
<6>[598175.285186] [ 4140]    30  4140    35523      299   0       0       
     0 httpd2-prefork
<6>[598175.285188] [ 4168]     0  4168     5751       86   0       0       
     0 cron
<6>[598175.285190] [ 4349]     0  4349    43028      120   0       0       
     0 ndpapp
<6>[598175.285194] [ 4548]     0  4548    17722       33   0       0       
     0 adminusd
<6>[598175.285196] [ 4577]     0  4577    17136       26   1       0       
     0 jstcpd
<6>[598175.285198] [ 4580]     0  4580    12511        0   1       0       
     0 jstcpd
<6>[598175.285200] [ 4601]     0  4601    10976       42   1       0       
     0 vlrpc
<6>[598175.285202] [ 4621]     0  4621     4222       54   1     -17       
 -1000 udevd
<6>[598175.285204] [ 4672]     0  4672    21525       70   0       0       
     0 volmnd
<6>[598175.285206] [ 4693]     0  4693    48377      195   0       0       
     0 ncp2nss
<6>[598175.285208] [ 4942]    81  4942    40049       32   0       0       
     0 novell-xregd
<6>[598175.285210] [ 5195]     0  5195    90312      479   0       0       
     0 cifsd
<6>[598175.285212] [ 5240]     0  5240     9586        9   1       0       
     0 smdrd
<6>[598175.285214] [ 5279]     0  5279    55127      172   0       0       
     0 novfsd
<6>[598175.285216] [ 5327]   104  5327     9431       72   0       0       
     0 nrpe
<6>[598175.285218] [ 5337]     0  5337     3177       78   0       0       
     0 mingetty
<6>[598175.285219] [ 5338]     0  5338     3177       78   1       0       
     0 mingetty
<6>[598175.285221] [ 5339]     0  5339     3177       78   0       0       
     0 mingetty
<6>[598175.285223] [ 5340]     0  5340     3177       78   1       0       
     0 mingetty
<6>[598175.285225] [ 5341]     0  5341     3177       78   0       0       
     0 mingetty
<6>[598175.285227] [ 5342]     0  5342     3177       78   1       0       
     0 mingetty
<6>[598175.285229] [ 5520]     0  5520    67658       99   0       0       
     0 cifsd
<6>[598175.285231] [25139]     0 25139    17698      836   0       0       
     0 snmpd
<6>[598175.285233] [ 4842]    51  4842    14147      511   0       0       
     0 pickup
<6>[598175.285235] [ 7917]     0  7917    21027     2460   1       0       
     0 savepnpc
<3>[598175.285237] Out of memory: Kill process 3719 (ndsd) score 19 or
sacrifice child
<3>[598175.285239] Killed process 3719 (ndsd) total-vm:881244kB,
anon-rss:0kB, file-rss:8020kB



Thanks

Marki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
