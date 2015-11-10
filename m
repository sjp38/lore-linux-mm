Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6409D6B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:13:40 -0500 (EST)
Received: by lbces9 with SMTP id es9so6699428lbc.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 14:13:39 -0800 (PST)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id l187si3808303lfg.12.2015.11.10.14.13.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 14:13:38 -0800 (PST)
Received: by lfdo63 with SMTP id o63so6528700lfd.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 14:13:38 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: memory reclaim problems on fs usage
Date: Tue, 10 Nov 2015 23:13:36 +0100
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511102313.36685.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, xfs@oss.sgi.com


Hi.

I have a x86_64 system running 4.1.12 kernel on top of software raid array =
(raid 1 and 6)
on top of adaptec HBA card (ASR71605E) that provides connectivity to 16 sata
rotational disks. fs is XFS.

System has 8GB of ram and 111GB of swap on ssd disk (swap is barely used:
~7,4MB in use).

Usage scenario on this machine is 5-10 (sometimes more) rsnapshot/rsync pro=
cesses
doing hardlinks and copying tons of files.


The usual (repeatable) problem is like this:

full dmesg: http://sprunge.us/VEiE (more in it then in partial log below)

partial log:

122365.832373] swapper/3: page allocation failure: order:0, mode:0x20
[122365.832382] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.1.12-3 #1
[122365.832384] Hardware name: Supermicro X8SIL/X8SIL, BIOS 1.2a       06/2=
7/2012
[122365.832386]  0000000000000000 ab5d50b5f2ae9872 ffff88023fcc3b18 fffffff=
f8164b37a
[122365.832390]  0000000000000000 0000000000000020 ffff88023fcc3ba8 fffffff=
f8118f02e
[122365.832392]  0000000000000000 0000000000000001 ffff880200000030 ffff880=
0ba984400
[122365.832395] Call Trace:
[122365.832398]  <IRQ>  [<ffffffff8164b37a>] dump_stack+0x45/0x57
[122365.832409]  [<ffffffff8118f02e>] warn_alloc_failed+0xfe/0x150
[122365.832415]  [<ffffffffc0247658>] ? raid5_align_endio+0x148/0x160 [raid=
456]
[122365.832418]  [<ffffffff81192c02>] __alloc_pages_nodemask+0x322/0xa90
[122365.832423]  [<ffffffff815281bc>] __alloc_page_frag+0x12c/0x150
[122365.832426]  [<ffffffff8152afd6>] __alloc_rx_skb+0x66/0x100
[122365.832430]  [<ffffffff8131101c>] ? __blk_mq_complete_request+0x7c/0x110
[122365.832433]  [<ffffffff8152b0d2>] __napi_alloc_skb+0x22/0x50
[122365.832440]  [<ffffffffc0336f1e>] e1000_clean_rx_irq+0x33e/0x3f0 [e1000=
e]
[122365.832444]  [<ffffffff810eaa10>] ? timer_cpu_notify+0x160/0x160
[122365.832449]  [<ffffffffc033debc>] e1000e_poll+0xbc/0x2f0 [e1000e]
[122365.832457]  [<ffffffffc00e244f>] ? aac_src_intr_message+0xaf/0x3e0 [aa=
craid]
[122365.832461]  [<ffffffff8153a7c2>] net_rx_action+0x212/0x340
[122365.832465]  [<ffffffff8107b2f3>] __do_softirq+0x103/0x280
[122365.832467]  [<ffffffff8107b5ed>] irq_exit+0xad/0xb0
[122365.832471]  [<ffffffff81653a58>] do_IRQ+0x58/0xf0
[122365.832474]  [<ffffffff816518ae>] common_interrupt+0x6e/0x6e
[122365.832476]  <EOI>  [<ffffffff8101f34c>] ? mwait_idle+0x8c/0x150
[122365.832482]  [<ffffffff8101fd4f>] arch_cpu_idle+0xf/0x20
[122365.832485]  [<ffffffff810b92e0>] cpu_startup_entry+0x380/0x400
[122365.832488]  [<ffffffff8104bf7d>] start_secondary+0x17d/0x1a0
[122365.832491] Mem-Info:
[122365.832496] active_anon:28246 inactive_anon:31593 isolated_anon:0
                 active_file:6641 inactive_file:1616279 isolated_file:0
                 unevictable:0 dirty:136960 writeback:0 unstable:0
                 slab_reclaimable:191482 slab_unreclaimable:34061
                 mapped:3744 shmem:0 pagetables:1015 bounce:0
                 free:5700 free_pcp:551 free_cma:0
[122365.832500] Node 0 DMA free:15884kB min:20kB low:24kB high:28kB active_=
anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0k=
B isolated(anon):0kB isolated(file):0kB present:15968kB managed:15884kB=20
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0=
kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB=20
pages_scanned:0 all_unreclaimable? yes
[122365.832505] lowmem_reserve[]: 0 2968 7958 7958
[122365.832508] Node 0 DMA32 free:6916kB min:4224kB low:5280kB high:6336kB =
active_anon:34904kB inactive_anon:44024kB active_file:9076kB inactive_file:=
2313600kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:3120704kB managed:3043796kB mlocked:0kB dirty:199004kB writeback:0k=
B mapped:5488kB shmem:0kB slab_reclaimable:441924kB slab_unreclaimable:3844=
0kB kernel_stack:960kB pagetables:1084kB unstable:0kB=20
bounce:0kB free_pcp:1132kB local_pcp:184kB free_cma:0kB writeback_tmp:0kB p=
ages_scanned:0 all_unreclaimable? no
[122365.832514] lowmem_reserve[]: 0 0 4990 4990
[122365.832517] Node 0 Normal free:0kB min:7104kB low:8880kB high:10656kB a=
ctive_anon:78080kB inactive_anon:82348kB active_file:17488kB inactive_file:=
4151516kB unevictable:0kB isolated(anon):0kB isolated(file):0kB=20
present:5242880kB managed:5109980kB mlocked:0kB dirty:348836kB writeback:0k=
B mapped:9488kB shmem:0kB slab_reclaimable:324004kB slab_unreclaimable:9780=
4kB kernel_stack:1760kB pagetables:2976kB unstable:0kB=20
bounce:0kB free_pcp:1072kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB p=
ages_scanned:0 all_unreclaimable? no
[122365.832522] lowmem_reserve[]: 0 0 0 0
[122365.832525] Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*=
128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) =3D 15=
884kB
[122365.832536] Node 0 DMA32: 1487*4kB (UE) 0*8kB 7*16kB (R) 9*32kB (R) 5*6=
4kB (R) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 6668kB
[122365.832544] Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*2=
56kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 0kB
[122365.832552] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_sur=
p=3D0 hugepages_size=3D2048kB
[122365.832554] 1623035 total pagecache pages
[122365.832556] 96 pages in swap cache
[122365.832558] Swap cache stats: add 1941, delete 1845, find 1489/1529
[122365.832559] Free swap  =3D 117213444kB
[122365.832561] Total swap =3D 117220820kB
[122365.832562] 2094888 pages RAM
[122365.832564] 0 pages HighMem/MovableOnly
[122365.832565] 48377 pages reserved
[122365.832567] 4096 pages cma reserved
[122365.832568] 0 pages hwpoisoned
[122377.888271] XFS: possible memory allocation deadlock in xfs_buf_allocat=
e_memory (mode:0x250)
[122379.889804] XFS: possible memory allocation deadlock in xfs_buf_allocat=
e_memory (mode:0x250)
[122381.891337] XFS: possible memory allocation deadlock in xfs_buf_allocat=
e_memory (mode:0x250)
[122383.892871] XFS: possible memory allocation deadlock in xfs_buf_allocat=
e_memory (mode:0x250)


Tried to ask on #xfs@freenode and #mm@oftc and did a bit of irc relay betwe=
en channels and people.

Essential parts of discussion:

#xfs
22:00 < dchinner__> arekm: so teh machine has 8GB ram, and it has almost 6G=
B of inactive file pages?
22:01 < dchinner__> it seems like there is a lot of reclaimable memory in t=
hat machine when it starts having problems...
22:04 < dchinner__> indeed, the ethernet driver is having problems with an =
order 0 allocation, when there appears to be lots of reclaimable memory....
22:04 < arekm> dchinner__: 8GB of ram, 111GB of swap (ssd; looks unused - o=
nly ~7.4MB in use), 5x rsync, 1xmysqldump, raid1 and raid6 on sata disks
22:04 < dchinner__> ah:
22:05 < dchinner__> Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB=
 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 0kB
22:05 < dchinner__> looks like there's a problem with a zone imbalance
22:05 < dchinner__> Node 0 DMA32: 1487*4kB (UE) 0*8kB 7*16kB (R) 9*32kB (R)=
 5*64kB (R) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 6668kB
22:07 < dchinner__> given that the zones have heaps of clean, inactive file=
 pages, the DMA32 and NORMAL zones are not marked as "all unreclaimable", a=
nd there's the free
                    pages in ZONE_NORMAL have been completely drained
22:07 < dchinner__> I'd be asking the mm folks what is going on
22:08 < dchinner__> I'd say XFS is backed up on the same issue

so normal zone is drained to 0

#mm

22:15 < arekmx> hi. I'm running backup system on 4.1.12 kernel. Machine mos=
tly does rsnapshot/rsyncs (5-10 in parallel). Unfortunately it hits memory =
problems often ->
                http://sprunge.us/VEiE . I've asked XFS people and the conc=
lusion was that this is most likely mm problem -> http://sprunge.us/ggVG An=
y ideas what could be
                going on ? (like normal zone is completly drained for examp=
le)
22:29 < sasha_> Wild guess: your xfs is on a rather slow storage device (ne=
twork?)
22:33 < arekmx> sasha_: raid6 on local rotational sata disks... so could be=
 slow, especially when 10x rsyncs start and hdd heads need to jump like cra=
zy
22:33 < sasha_> Hm, shouldn't be *that* slow though
22:34 < sasha_> The scenario I see is that xfs can't run reclaim fast enoug=
h, so the system runs out of memory and it appears to have a lot of "unused=
 cache" it should
                have freed
22:34 < sasha_> Look at all those cpus stuck in xfs reclaim, while one of t=
hem is waiting for IO
22:38 < sasha_> I suppose the easiest one is just not caching on that files=
ystem

I don't think there is a way to do that.

22:41 < sasha_> Or maybe your RAID box/disks are dying?

Nope, good condition according to smart logs (but started long tests to ret=
est)

#xfs:

22:40 < dchinner__> arekm: XFs is waiting on slab cache reclaim
22:41 < dchinner__> because there are already as many slab reclaimers as th=
ere are AGs, and reclaim can't progress any faster than that
22:41 < dchinner__> but slab reclaim does not prevent clean pages from bein=
g reclaimed by direct reclaim during memory allocation
22:41 < dchinner__> it's a completely different part of memory reclaim
22:42 < dchinner__> the fact that XFs is repeatedly saying "memory allocati=
on failed" means it is not getting backed up on slab cache reclaim
22:42 < dchinner__> especially as it's a GFP_NOFS allocation which means th=
e slab shrinkers are being skipped.
22:43 < dchinner__> direct page cache reclaim should be occurring on GFP_NO=
=46S allocation because there are clean pages available to be reclaimed
22:44 < dchinner__> but that is not happening - the processes blocked in th=
e shrinkers are not relevant to the XFS allocations that=20


Overall I was asked to post this to both mailing list to get better coverag=
e and possibly solution to the problem.

kernel config:
http://sprunge.us/SRUi


# cat /proc/mdstat
Personalities : [raid1] [raid6] [raid5] [raid4]
md4 : active raid6 sdg[0] sdi[5] sdh[4] sdd[3] sdf[2] sde[1]
      11720540160 blocks super 1.2 level 6, 512k chunk, algorithm 2 [6/6] [=
UUUUUU]
      bitmap: 1/22 pages [4KB], 65536KB chunk

md3 : active raid6 sdj[9] sdq[7] sdp[6] sdo[10] sdn[4] sdm[8] sdl[2] sdk[1]
      5859781632 blocks super 1.2 level 6, 512k chunk, algorithm 2 [8/8] [U=
UUUUUUU]
      bitmap: 3/8 pages [12KB], 65536KB chunk

md1 : active raid1 sdb1[0] sdc1[1]
      524224 blocks [2/2] [UU]

md2 : active raid1 sdb2[0] sdc2[1]
      731918016 blocks super 1.2 [2/2] [UU]

rsync/rsnapshot processes operate on md3 and md4


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
