Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id C26136B0038
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 02:20:38 -0500 (EST)
Received: by igcto18 with SMTP id to18so64014911igc.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 23:20:38 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id d16si15351738igo.8.2015.12.12.23.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 12 Dec 2015 23:20:37 -0800 (PST)
From: Joshua Kinard <kumba@gentoo.org>
Subject: [BUG]: MIPS: VM_BUG_ON_PAGE in move_freepages() on an SGI_IP27
 (Onyx2/Origin)
Message-ID: <566D1C43.7040102@gentoo.org>
Date: Sun, 13 Dec 2015 02:20:35 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux/MIPS <linux-mips@linux-mips.org>

Hi -mm,

I've been trying to chase down a difficult-to-diagnose BUG() getting triggered
in move_freepages() on an SGI IP27 MIPS platform (a deskside Onyx2).  The key
trigger seems to be disk I/O of any kind will have a random chance of locking
the machine up, but I can reproduce the lockup pretty reliably by running
bonnie++.  Getting an Oops/BUG/Panic out on the serial port is the hard part.

I think it is specifically this VM_BUG_ON_PAGE() on line 1490 in
mm/page_alloc.c:

	for (page = start_page; page <= end_page;) {
		/* Make sure we are not inadvertently changing nodes */
-->		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);

		if (!pfn_valid_within(page_to_pfn(page))) {
			page++;
			continue;
		}

		if (!PageBuddy(page)) {
			page++;
			continue;
		}

		order = page_order(page);
		list_move(&page->lru,
			  &zone->free_area[order].free_list[migratetype]);
		page += 1 << order;
		pages_moved += 1 << order;
	}


Here's an Oops report from my last run with a 4.4-rc4 kernel (I reproduced
this Oops three times, twice in 4.3.2 and this one in 4.4-rc4, just to be
certain):

[  643.838908] page:a800000101014000 count:1 mapcount:0 mapping:  (null) index:0xa8000000fe1a3b80
[  643.951091] flags: 0x400000000000000()
[  643.996460] Kernel bug detected[#1]:
[  644.039500] CPU: 0 PID: 1371 Comm: bonnie++ Not tainted 4.4.0-rc4 #3
[  644.116049] task: a8000000ff6bd200 ti: a8000000ff8f0000 task.ti: a8000000ff8f0000
[  644.206216] $ 0   : 0000000000000000 ffffffffb4001ce0 0000000000580000 a8000000005c7a80
[  644.303199] $ 4   : 00000000005c7a80 0000000000000000 0000000000000000 00000000000000ea
[  644.400184] $ 8   : 0000000000000029 0000000000000000 00000000005c0000 00000000000000ea
[  644.497168] $12   : 0000000000000006 0000000005f5e100 0000000000000000 a8000000006556ed
[  644.594151] $16   : a800000100028000 0000000000000003 a800000101024020 a800000100028510
[  644.691136] $20   : 000000000000000a a8000001000285b8 000000000000000a 0000000000000007
[  644.788117] $24   : 0000000000000002 0000000000000000
[  644.885101] $28   : a8000000ff8f0000 a8000000ff8f3880 a800000100028100 a8000000001054fc
[  644.982086] Hi    : 0000000000000000
[  645.025131] Lo    : 00000063a147afa3
[  645.068219] epc   : a8000000001054fc move_freepages+0xe4/0x188
[  645.138569] ra    : a8000000001054fc move_freepages+0xe4/0x188
[  645.208836] Status: b4001ce2 KX SX UX KERNEL EXL
[  645.266128] Cause : 0000d024 (ExcCode 09)
[  645.314408] PrId  : 00000f14 (R14000)
[  645.358509] Process bonnie++ (pid: 1371, threadinfo=a8000000ff8f0000, task=a8000000ff6bd200, tls=0000000077195dd0)
[  645.483235] Stack : a8000000ff8f3ac0 a80000000010924c 01000002852c7fff a8000000002068b4
          a8000000006a0000 a800000101024000 0000000000000000 0000000000000010
          0000000000000001 a800000100028100 0000000000000000 0000000000000004
          0000000000000001 0000000000000003 0000000000000000 a800000100028000
          a800000100073fe0 a800000002015208 a8000000ff8f3a20 0000000000000007
          0000000000000001 a8000000001097e4 0000000000000000 0000000000000000
          a8000000005c0000 ffffffffffffffff 000000000342004a 0000000000000000
          0000000000000001 0000000000000001 a8000000006b9100 0000000000000100
          00000000000000c1 a800000100028100 0000000000000000 a8000000006b9110
          a8000000020151f8 ffffffffb4001ce1 a8000000020151e8 a8000000005bd328
          ...
[  646.272200] Call Trace:
[  646.301641] [<a8000000001054fc>] move_freepages+0xe4/0x188
[  646.367738] [<a80000000010924c>] __rmqueue.isra.10+0x74c/0xa28
[  646.438009] [<a8000000001097e4>] get_page_from_freelist+0x2bc/0xfd0
[  646.513520] [<a80000000010a9ac>] __alloc_pages_nodemask+0x25c/0xcf0
[  646.589034] [<a8000000000ff078>] pagecache_get_page+0x330/0x440
[  646.660360] [<a800000000101214>] grab_cache_page_write_begin+0x34/0x58
[  646.739017] [<a800000000238a40>] xfs_vm_write_begin+0x40/0x120
[  646.809290] [<a80000000010142c>] generic_perform_write+0x1f4/0x238
[  646.883764] [<a800000000246fec>] xfs_file_buffered_aio_write+0x114/0x218
[  646.964503] [<a8000000002471e8>] xfs_file_write_iter+0xf8/0x1f0
[  647.035831] [<a800000000173004>] __vfs_write+0xf4/0x120
[  647.098772] [<a800000000173208>] vfs_write+0xc8/0x1d0
[  647.159621] [<a80000000017343c>] SyS_write+0x5c/0xd0
[  647.219435] [<a8000000000342f4>] syscall_common+0x8/0x34
[  647.283404]
[  647.301312]
Code: 0005283c  0c04cbd4  00a2282d <000c000d> bfb40000  8c650018  10aa0003  646c0020  1000001b
[  647.422995] ---[ end trace 1d7505fcf6dc34b2 ]---

--------

The only real bit of info I can find on Google specific to this
VM_BUG_ON_PAGE() is here:
http://lists.infradead.org/pipermail/linux-arm-kernel/2010-February/010016.html

So, from that here's the memory layout at boot, via mminit_loglevel=4:
[    0.000000] ARCH: SGI-IP27
[    0.000000] PROMLIB: ARC firmware Version 64 Revision 0
[    0.000000] Discovered 4 cpus on 2 nodes
[    0.000000] node_distance: router_a NULL
[    0.000000] node_distance: router_a NULL
[    0.000000] node_distance: router_a NULL
[    0.000000] node_distance: router_a NULL
[    0.000000] ************** Topology ********************
[    0.000000]     00 01
[    0.000000] 00  255 255
[    0.000000] 01  255 255
[    0.000000] CPU0 revision is: 00000f14 (R14000)
[    0.000000] FPU revision is: 00000900
[    0.000000] Checking for the multiply/shift bug... no.
[    0.000000] Checking for the daddiu bug... no.
[    0.000000] IP27: Running on node 0.
[    0.000000] Node 0 has a primary CPU, CPU is running.
[    0.000000] Node 0 has a secondary CPU, CPU is running.
[    0.000000] Machine is in M mode.
[    0.000000] Cpu 0, Nasid 0x0, wid_part 0x0 (part 0x0) is is xbow
[    0.000000] Cpu 0, Nasid 0x0, widget 0x8 (part 0xc102) is
[    0.000000] xtalk:8 kona widget (rev unknown) registered as platform device.
[    0.000000] Cpu 0, Nasid 0x0, widget 0xb (part 0xc002) is a bridge
[    0.000000] Cpu 0, Nasid 0x0, widget 0xd (part 0xc003) is
[    0.000000] xtalk:13 impact widget (rev B) registered as platform device.
[    0.000000] Cpu 0, Nasid 0x0, widget 0xf (part 0xc002) is a bridge
[    0.000000] CPU 0 clock is 500MHz.
[    0.000000] Determined physical RAM map:
[    0.000000]  memory: 00000000005dc000 @ 000000000001c000 (usable)
[    0.000000]  memory: 0000000000048000 @ 00000000005f8000 (usable after init)
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x00000001ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000]   node   1: [mem 0x0000000100000000-0x00000001ffffffff]
[    0.000000] mminit::pageflags_layout_widths Section 0 Node 6 Zone 1 Lastcpupid 0 Flags 23
[    0.000000] mminit::pageflags_layout_shifts Section 0 Node 6 Zone 1 Lastcpupid 0
[    0.000000] mminit::pageflags_layout_pgshifts Section 0 Node 58 Zone 57 Lastcpupid 0
[    0.000000] mminit::pageflags_layout_nodezoneid Node/Zone ID: 64 -> 57
[    0.000000] mminit::pageflags_layout_usage location: 64 -> 57 layout 57 -> 23 unused 23 -> 0 page-flags
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000] On node 0 totalpages: 262144
[    0.000000] free_area_init_node: node 0, pgdat a8000000006b8000, node_mem_map a800000001000000
[    0.000000]   Normal zone: 1024 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 262144 pages, LIFO batch:7
[    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns 0 -> 262144
[    0.000000] Initmem setup node 1 [mem 0x0000000100000000-0x00000001ffffffff]
[    0.000000] On node 1 totalpages: 262144
[    0.000000] free_area_init_node: node 1, pgdat a800000100028000, node_mem_map a800000100034000
[    0.000000]   Normal zone: 1024 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 262144 pages, LIFO batch:7
[    0.000000] mminit::memmap_init Initialising map node 1 zone 0 pfns 262144 -> 524288
[    0.000000] REPLICATION: ON nasid 0, ktext from nasid 0, kdata from nasid 0
[    0.000000] REPLICATION: ON nasid 1, ktext from nasid 0, kdata from nasid 0
[    0.000000] Primary instruction cache 32kB, VIPT, 2-way, linesize 64 bytes.
[    0.000000] Primary data cache 32kB, 2-way, VIPT, no aliases, linesize 32 bytes
[    0.000000] Unified secondary cache 8192kB 2-way, linesize 128 bytes.
[    0.000000] PERCPU: Embedded 4 pages/cpu @a800000002010000 s20864 r0 d44672 u65536
[    0.000000] pcpu-alloc: s20864 r0 d44672 u65536 alloc=4*16384
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
[    0.000000] mminit::zonelist general 0:Normal = 0:Normal 0:Normal
[    0.000000] mminit::zonelist general 1:Normal = 0:Normal 0:Normal
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 522240
[    0.000000] Kernel command line: root=dksc(0,1,0) console=ttyS0,9600 root=/dev/sda1 mminit_loglevel=4
[    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 1048576 (order: 9, 8388608 bytes)
[    0.000000] Inode-cache hash table entries: 524288 (order: 8, 4194304 bytes)
[    0.000000] Memory: 8336064K/8388608K available (4675K kernel code, 320K rwdata, 980K rodata, 288K init, 467K bss, 52544K reserved, 0K cma-reserved)


IP27 appears to have been the first NUMA-class machine added to Linux back in
the day (circa ~2000?), so it's old code.  It also appears to be one of the
last platforms using DISCONTIG memory -- no one's attempted to port it to
SPARSEMEM (and I don't know if that's even possible with this platform).

My machine's local setup is 2x node boards w/ 4GB memory per board for a total
of 8GB.  I've tried both with and without CONFIG_NUMA, but the bug can be
triggered regardless.  I also have PAGE_SIZE set to 16K right now.  64K
triggers an entirely different BUG in __mm_populate() during boot, so I'll
worry about chasing that one down later.  Haven't tried 4K PAGE_SIZE in a
while, but I remember that the machine can be locked up there, too (I just
don't have an Oops detailing where/why).

I've poked around the kernel a bit and looked at IP27's code some.  But I'll
admit that this particular SGI platform is a doozy to understand.  My guess is
the bits of code that move memory around are accidentally grabbing a chunk of
a page being used by one of the CPUs and effectively yanks the tablecloth out
from underneath it.  Not really sure how to further debug this, so some
guidance would be really helpful to pin down the problem on this system.

Thanks!

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
6144R/F5C6C943 2015-04-27
177C 1972 1FB8 F254 BAD0 3E72 5C63 F4E3 F5C6 C943

"The past tempts us, the present confuses us, the future frightens us.  And our
lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
