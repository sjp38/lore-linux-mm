Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 371F06B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 21:51:41 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id a41so2608893yho.12
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 18:51:40 -0700 (PDT)
Message-ID: <51DCBE24.3030406@gmail.com>
Date: Tue, 09 Jul 2013 21:51:32 -0400
From: "Michael L. Semon" <mlsemon35@gmail.com>
MIME-Version: 1.0
Subject: [REGRESSION] x86 vmalloc issue from recent 3.10.0+ commit
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: d.hatayama@jp.fujitsu.com, akpm@linux-foundation.org

Hi!  I'm doing volunteer testing of xfstests and was sent here to 
ask about this issue.  I apologize in advance if the problem has 
already been solved...

I've been testing XFS from various git kernels on 32-bit Pentium 4 
and Pentium III PCs.  There was an issue with xfstests test xfs/167, 
which is one of many tests that run a lot of instances of the 
program "fsstress" to try to break something.  Usually, the test 
passes, but this time, the Pentium 4 got stuck in a loop, and the 
Pentium III had processes killed but didn't seem to have resources 
released back to the system.

The solution was to bisect the kernel to find the problem commit, 
get a patch out of it, then use the patch to reverse the commit.

The kernel git used was pulled on July 7.  SGI's xfs-oss/master was 
updated as well, and these additional XFS patches were applied:

    xfs: clean up unused codes at xfs_bulkstat()
    xfs: dquot log reservations are too small
    xfs: remove local fork format handling from xfs_bmapi_write()
    xfs: update mount options documentation

Hopefully, such merging and patching won't be needed to reproduce the 
problem on your end.  The problem is 100% reproducible here.

The rest of this letter is supplementary data from the Pentium 4 PC.

Thanks!

Michael

The partition used in the test was this (from `gdisk /dev/sdb`):

   5        70189056        90046463   9.5 GiB     8300  gScratchDev

The original/fixed test behaviors look like this to xfstests:

root@plbearer:/var/lib/xfstests# ./check xfs/167
FSTYP         -- xfs (debug)
PLATFORM      -- Linux/i686 plbearer 3.10.0+
MKFS_OPTIONS  -- -f -bsize=4096 /dev/sdb5
MOUNT_OPTIONS -- /dev/sdb5 /mnt/xfstests-scratch

xfs/167 922s ... 891s
Ran: xfs/167
Passed all 1 tests

On a failing test, the hard drive light dies after a while, and it's 
impossible to switch framebuffer consoles (i915).  This is the 
beginning of the infinite loop started by hitting Alt-Shift-SysRq-e-
i-e-i-s-u-s, captured over netconsole (the first SysRq-s seems to be 
the trigger):

logger: run xfstest xfs/167
kernel: [ 2497.774818] XFS (sdb5): Version 5 superblock detected. This kernel has EXPERIMENTAL support enabled!
kernel: [ 2497.774818] Use of these features in this kernel is at your own risk!
kernel: [ 2497.862312] XFS (sdb5): Mounting Filesystem
kernel: [ 2580.395592] vmap allocation for size 20480 failed: use vmalloc=<size> to increase size.
kernel: [ 2580.395761] vmalloc: allocation failure: 16384 bytes
kernel: [ 2580.395769] fsstress: page allocation failure: order:0, mode:0x80d2
kernel: [ 2580.395776] CPU: 0 PID: 6262 Comm: fsstress Not tainted 3.10.0+ #1
kernel: [ 2580.395781] Hardware name: Dell Computer Corporation Dimension 2350/07W080, BIOS A01 12/17/2002
kernel: [ 2580.395785]  00000001 00000001 c50b3bfc c14825b2 c50b3c24 c10a1c6c c15c1f70 ee319bb4
kernel: [ 2580.395802]  00000000 000080d2 c50b3c38 c15c34a4 c50b3c14 fffa0000 c50b3c54 c10c3243
kernel: [ 2580.395817]  000080d2 00000000 c15c34a4 00004000 c6bffb50 00004000 c6bffb80 f06f0000
kernel: [ 2580.395832] Call Trace:
kernel: [ 2580.395847]  [<c14825b2>] dump_stack+0x16/0x18
kernel: [ 2580.395859]  [<c10a1c6c>] warn_alloc_failed+0xb4/0xe7
kernel: [ 2580.395868]  [<c10c3243>] __vmalloc_node_range+0x16d/0x1cf
kernel: [ 2580.395875]  [<c10c32ed>] __vmalloc_node+0x48/0x4f
kernel: [ 2580.395884]  [<c118c061>] ? kmem_zalloc_greedy+0x21/0x2c
kernel: [ 2580.395890]  [<c10c3386>] vzalloc+0x30/0x32
kernel: [ 2580.395897]  [<c118c061>] ? kmem_zalloc_greedy+0x21/0x2c
kernel: [ 2580.395904]  [<c118c061>] kmem_zalloc_greedy+0x21/0x2c
kernel: [ 2580.395913]  [<c11846d4>] xfs_bulkstat+0x12a/0x94b
kernel: [ 2580.395921]  [<c1063d14>] ? lock_release_non_nested+0xa0/0x2b7
kernel: [ 2580.395931]  [<c10bae81>] ? might_fault+0x7c/0x9b
kernel: [ 2580.395938]  [<c10bae4e>] ? might_fault+0x49/0x9b
kernel: [ 2580.395945]  [<c10bae98>] ? might_fault+0x93/0x9b
kernel: [ 2580.395954]  [<c1232930>] ? _copy_from_user+0x3f/0x57
kernel: [ 2580.395961]  [<c117f6a8>] xfs_ioc_bulkstat+0xba/0x15a
kernel: [ 2580.395968]  [<c1184570>] ? xfs_bulkstat_one_int+0x2ff/0x2ff
kernel: [ 2580.395975]  [<c11809dc>] xfs_file_ioctl+0x6b9/0xa0d
kernel: [ 2580.395984]  [<c10e123a>] ? dput+0x2d/0x263
kernel: [ 2580.395990]  [<c10e1426>] ? dput+0x219/0x263
kernel: [ 2580.395999]  [<c1488c3e>] ? _raw_spin_unlock+0x22/0x30
kernel: [ 2580.396006]  [<c10e1426>] ? dput+0x219/0x263
kernel: [ 2580.396013]  [<c10e85fc>] ? mntput+0x1d/0x28
kernel: [ 2580.396022]  [<c10d7745>] ? terminate_walk+0x63/0x66
kernel: [ 2580.396030]  [<c10d9f7c>] ? do_last+0x1a9/0xbfa
kernel: [ 2580.396036]  [<c10d8a2e>] ? link_path_walk+0x54/0x6c2
kernel: [ 2580.396044]  [<c10daa7c>] ? path_openat+0xaf/0x515
kernel: [ 2580.396053]  [<c10e690f>] ? __fd_install+0x1f/0x4a
kernel: [ 2580.396060]  [<c1180323>] ? xfs_ioc_getbmapx+0x9b/0x9b
kernel: [ 2580.396068]  [<c10de220>] do_vfs_ioctl+0x2f6/0x4cc
kernel: [ 2580.396076]  [<c10e6930>] ? __fd_install+0x40/0x4a
kernel: [ 2580.396083]  [<c1488c3e>] ? _raw_spin_unlock+0x22/0x30
kernel: [ 2580.396090]  [<c10d7cd9>] ? final_putname+0x1d/0x36
kernel: [ 2580.396097]  [<c10d7cd9>] ? final_putname+0x1d/0x36
kernel: [ 2580.396104]  [<c10d7e4c>] ? putname+0x23/0x2f
kernel: [ 2580.396112]  [<c10cecdb>] ? do_sys_open+0x17d/0x1d8
kernel: [ 2580.396120]  [<c14895ab>] ? restore_all+0xf/0xf
kernel: [ 2580.396127]  [<c10de435>] SyS_ioctl+0x3f/0x6a
kernel: [ 2580.396135]  [<c1489578>] syscall_call+0x7/0xb
kernel: [ 2580.396138] Mem-Info:
kernel: [ 2580.396143] DMA per-cpu:
kernel: [ 2580.396148] CPU    0: hi:    0, btch:   1 usd:   0
kernel: [ 2580.396151] Normal per-cpu:
kernel: [ 2580.396155] CPU    0: hi:  186, btch:  31 usd:  45
kernel: [ 2580.396164] active_anon:5918 inactive_anon:1747 isolated_anon:0
kernel: [ 2580.396164]  active_file:11120 inactive_file:62706 isolated_file:0
kernel: [ 2580.396164]  unevictable:0 dirty:3201 writeback:1689 unstable:0
kernel: [ 2580.396164]  free:38741 slab_reclaimable:11386 slab_unreclaimable:3333
kernel: [ 2580.396164]  mapped:982 shmem:295 pagetables:580 bounce:0
kernel: [ 2580.396164]  free_cma:0
kernel: [ 2580.396182] DMA free:15848kB min:72kB low:88kB high:108kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15852kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:4kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
kernel: [ 2580.396186] lowmem_reserve[]: 0 730 730
kernel: [ 2580.396203] Normal free:139116kB min:3420kB low:4272kB high:5128kB active_anon:23672kB inactive_anon:6988kB active_file:44480kB inactive_file:250824kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:768960kB managed:748696kB mlocked:0kB dirty:12804kB writeback:6756kB mapped:3928kB shmem:1180kB slab_reclaimable:45544kB slab_unreclaimable:13328kB kernel_stack:2056kB pagetables:2320kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
kernel: [ 2580.396207] lowmem_reserve[]: 0 0 0
kernel: [ 2580.396216] DMA: 0*4kB 1*8kB (M) 0*16kB 1*32kB (M) 1*64kB (M) 1*128kB (M) 1*256kB (M) 0*512kB 1*1024kB (M) 1*2048kB (M) 3*4096kB (MR) = 15848kB
kernel: [ 2580.396252] Normal: 1*4kB (E) 1*8kB (U) 2*16kB (EM) 0*32kB 3*64kB (UEM) 1*128kB (M) 2*256kB (UE) 0*512kB 1*1024kB (U) 1*2048kB (E) 33*4096kB (MR) = 139116kB
kernel: [ 2580.396288] 75189 total pagecache pages
kernel: [ 2580.396294] 1068 pages in swap cache
kernel: [ 2580.396298] Swap cache stats: add 155872, delete 154804, find 15597/15818
kernel: [ 2580.396302] Free swap  = 604708kB
kernel: [ 2580.396306] Total swap = 616444kB
kernel: [ 2580.400379] 196335 pages RAM
kernel: [ 2580.400391] 5200 pages reserved
kernel: [ 2580.400395] 337314 pages shared

# GIT BISECT LOG

# bad: [ebb823f3e2a3a45f212950a40dd04ba171b7583c] xfs: clean up unused codes at xfs_bulkstat()
# good: [8bb495e3f02401ee6f76d1b1d77f3ac9f079e376] Linux 3.10
git bisect start 'ebb823f3e2a3a45f212950a40dd04ba171b7583c' 'v3.10'
# good: [f0bb4c0ab064a8aeeffbda1cee380151a594eaab] Merge branch 'perf-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good f0bb4c0ab064a8aeeffbda1cee380151a594eaab
# good: [862f0012549110d6f2586bf54b52ed4540cbff3a] Merge tag 'pci-v3.11-changes' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
git bisect good 862f0012549110d6f2586bf54b52ed4540cbff3a
# bad: [1286da8bc009cb2aee7f285e94623fc974c0c983] Merge tag 'sound-3.11' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad 1286da8bc009cb2aee7f285e94623fc974c0c983
# bad: [dd04b452f532ca100f7c557295ffcbc049c77171] idr: print a stack dump after ida_remove warning
git bisect bad dd04b452f532ca100f7c557295ffcbc049c77171
# bad: [5cb0656b62ff1199763764e4f6b4c06d30d5d0f5] ipw2200: convert __list_for_each usage to list_for_each
git bisect bad 5cb0656b62ff1199763764e4f6b4c06d30d5d0f5
# bad: [abd1b6d65fc49b7b95724c94a4e5892a3b3fc618] mm/tile: use common help functions to free reserved pages
git bisect bad abd1b6d65fc49b7b95724c94a4e5892a3b3fc618
# good: [3664033c56f211a3dcf28d9d68c604ed447d8d79] mm/page_alloc: rename setup_pagelist_highmark() to match naming of pageset_set_batch()
git bisect good 3664033c56f211a3dcf28d9d68c604ed447d8d79
# good: [cef2ac3f6c8ab532e49cf69d05f540931ad8ee64] vmalloc: make find_vm_area check in range
git bisect good cef2ac3f6c8ab532e49cf69d05f540931ad8ee64
# bad: [9bde916bc73255dcee3d8aded990443675daa707] mm/nommu.c: add additional check for vread() just like vwrite() has done
git bisect bad 9bde916bc73255dcee3d8aded990443675daa707
# bad: [f968ef1c55199301e98c28fe7dfa8ace05ecdb96] memcg: update TODO list in Documentation
git bisect bad f968ef1c55199301e98c28fe7dfa8ace05ecdb96
# bad: [ef9e78fd2753213ea01d77f7a76a9cb6ad0f50a7] vmcore: allow user process to remap ELF note segment buffer
git bisect bad ef9e78fd2753213ea01d77f7a76a9cb6ad0f50a7
# bad: [087350c9dcf1b38c597b31d7761f7366e2866e6b] vmcore: allocate ELF note segment in the 2nd kernel vmalloc memory
git bisect bad 087350c9dcf1b38c597b31d7761f7366e2866e6b
# bad: [e69e9d4aee712a22665f008ae0550bb3d7c7f7c1] vmalloc: introduce remap_vmalloc_range_partial
git bisect bad e69e9d4aee712a22665f008ae0550bb3d7c7f7c1
# first bad commit: [e69e9d4aee712a22665f008ae0550bb3d7c7f7c1] vmalloc: introduce remap_vmalloc_range_partial

# PATCH INFO
