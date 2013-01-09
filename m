Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 58F5E6B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:00:21 -0500 (EST)
Date: Wed, 9 Jan 2013 03:00:20 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1130319870.1895368.1357718420464.JavaMail.root@redhat.com>
In-Reply-To: <239895331.1183913.1357638392087.JavaMail.root@redhat.com>
Subject: Re: mmap regression on power7?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>



----- Original Message -----
> From: "CAI Qian" <caiqian@redhat.com>
> To: "linux-mm" <linux-mm@kvack.org>
> Cc: "linux-kernel" <linux-kernel@vger.kernel.org>
> Sent: Tuesday, January 8, 2013 5:46:32 PM
> Subject: mmap regression on power7?
> 
> Noticed that this test is failing at the moment up to v3.8.0-rc1,
This turned out to be a possible gcc regression introduced in 4.7, so
will be tracked there.
> http://ltp.git.sourceforge.net/git/gitweb.cgi?p=ltp/ltp.git;a=blob;f=testcases/kernel/mem/mtest06/mmap1.c
> 
> mmap1       0  TINFO  :  created writing thread[70366791266816]
> mmap1       0  TINFO  :  [70366791266816] - map, change contents,
> unmap files 1000 times
> mmap1       0  TINFO  :  [70366799655424] - read contents of memory
> 0x3fff8b180000 1000 times
> mmap1       0  TINFO  :  created reading thread[70366799655424]
> mmap1       0  TINFO  :  [70366799655424] Unexpected page fault at
> 0x3fff8b1803a8
> 
> Bisecting going back to v2.6.38 has no such problem and keep running
> despite sometimes it triggered memory allocation failures.
> 
> swapper: page allocation failure. order:0, mode:0x0
> Call Trace:
> [c00000013feab370] [c0000000000143f4] .show_stack+0x74/0x1c0
> (unreliable)
> [c00000013feab420] [c0000000001474d0]
> .__alloc_pages_nodemask+0x4f0/0x8e0
> [c00000013feab5c0] [c000000000031870]
> .iommu_alloc_coherent+0x100/0x280
> [c00000013feab680] [c000000000031020]
> .dma_iommu_alloc_coherent+0x30/0x50
> [c00000013feab6f0] [d000000001712220]
> .ibmvscsi_queuecommand+0x5b0/0x600 [ibmvscsic]
> [c00000013feab7d0] [c0000000003aa0d0] .scsi_dispatch_cmd+0x120/0x380
> [c00000013feab870] [c0000000003b2a8c] .scsi_request_fn+0x4fc/0x620
> [c00000013feab950] [c0000000002a13ac] .__blk_run_queue+0x15c/0x1c0
> [c00000013feab9e0] [c0000000002a1514] .blk_run_queue+0x34/0x60
> [c00000013feaba70] [c0000000003b1894] .scsi_run_queue+0x114/0x450
> [c00000013feabb50] [c0000000003b2de8] .scsi_next_command+0x48/0x70
> [c00000013feabbe0] [c0000000003b3e60] .scsi_io_completion+0x3e0/0x580
> [c00000013feabcc0] [c0000000003a9d98]
> .scsi_finish_command+0x128/0x180
> [c00000013feabd60] [c0000000003b4118] .scsi_softirq_done+0x108/0x1d0
> [c00000013feabe00] [c0000000002a795c] .blk_done_softirq+0xbc/0xf0
> [c00000013feabea0] [c000000000092e90] .__do_softirq+0x110/0x290
> [c00000013feabf90] [c000000000020eb8] .call_do_softirq+0x14/0x24
> [c00000013e963960] [c00000000000f2b4] .do_softirq+0xf4/0x120
> [c00000013e963a00] [c000000000092ca4] .irq_exit+0xb4/0xc0
> [c00000013e963a80] [c00000000000f540] .do_IRQ+0x160/0x2c0
> [c00000013e963b40] [c000000000004898]
> hardware_interrupt_entry+0x18/0x80
> --- Exception: 501 at .arch_local_irq_restore+0x34/0x60
>     LR = .cpu_idle+0x170/0x210
> [c00000013e963e30] [c000000000016c14] .cpu_idle+0x164/0x210
> (unreliable)
> [c00000013e963ee0] [c00000000059e454] .start_secondary+0x324/0x35c
> [c00000013e963f90] [c000000000008268]
> .start_secondary_prolog+0x10/0x14
> Mem-Info:
> Node 0 DMA per-cpu:
> CPU    0: hi:    6, btch:   1 usd:   5
> CPU    1: hi:    6, btch:   1 usd:   1
> CPU    2: hi:    6, btch:   1 usd:   5
> CPU    3: hi:    6, btch:   1 usd:   5
> CPU    4: hi:    6, btch:   1 usd:   3
> CPU    5: hi:    6, btch:   1 usd:   1
> CPU    6: hi:    6, btch:   1 usd:   5
> CPU    7: hi:    6, btch:   1 usd:   4
> CPU    8: hi:    6, btch:   1 usd:   1
> CPU    9: hi:    6, btch:   1 usd:   5
> CPU   10: hi:    6, btch:   1 usd:   5
> CPU   11: hi:    6, btch:   1 usd:   5
> CPU   12: hi:    6, btch:   1 usd:   4
> CPU   13: hi:    6, btch:   1 usd:   1
> CPU   14: hi:    6, btch:   1 usd:   5
> CPU   15: hi:    6, btch:   1 usd:   3
> CPU   16: hi:    6, btch:   1 usd:   5
> CPU   17: hi:    6, btch:   1 usd:   1
> CPU   18: hi:    6, btch:   1 usd:   5
> CPU   19: hi:    6, btch:   1 usd:   2
> CPU   20: hi:    6, btch:   1 usd:   4
> CPU   21: hi:    6, btch:   1 usd:   1
> CPU   22: hi:    6, btch:   1 usd:   5
> CPU   23: hi:    6, btch:   1 usd:   1
> CPU   24: hi:    6, btch:   1 usd:   5
> CPU   25: hi:    6, btch:   1 usd:   1
> CPU   26: hi:    6, btch:   1 usd:   5
> CPU   27: hi:    6, btch:   1 usd:   5
> CPU   28: hi:    6, btch:   1 usd:   5
> CPU   29: hi:    6, btch:   1 usd:   1
> CPU   30: hi:    6, btch:   1 usd:   1
> CPU   31: hi:    6, btch:   1 usd:   1
> CPU   32: hi:    6, btch:   1 usd:   5
> CPU   33: hi:    6, btch:   1 usd:   5
> CPU   34: hi:    6, btch:   1 usd:   1
> CPU   35: hi:    6, btch:   1 usd:   1
> CPU   36: hi:    6, btch:   1 usd:   5
> CPU   37: hi:    6, btch:   1 usd:   5
> CPU   38: hi:    6, btch:   1 usd:   4
> CPU   39: hi:    6, btch:   1 usd:   2
> CPU   40: hi:    6, btch:   1 usd:   4
> CPU   41: hi:    6, btch:   1 usd:   5
> CPU   42: hi:    6, btch:   1 usd:   5
> CPU   43: hi:    6, btch:   1 usd:   2
> CPU   44: hi:    6, btch:   1 usd:   5
> CPU   45: hi:    6, btch:   1 usd:   5
> CPU   46: hi:    6, btch:   1 usd:   5
> CPU   47: hi:    6, btch:   1 usd:   5
> CPU   48: hi:    6, btch:   1 usd:   1
> CPU   49: hi:    6, btch:   1 usd:   1
> CPU   50: hi:    6, btch:   1 usd:   3
> CPU   51: hi:    6, btch:   1 usd:   5
> CPU   52: hi:    6, btch:   1 usd:   5
> CPU   53: hi:    6, btch:   1 usd:   2
> CPU   54: hi:    6, btch:   1 usd:   5
> CPU   55: hi:    6, btch:   1 usd:   5
> CPU   56: hi:    6, btch:   1 usd:   1
> CPU   57: hi:    6, btch:   1 usd:   1
> CPU   58: hi:    6, btch:   1 usd:   5
> CPU   59: hi:    6, btch:   1 usd:   4
> Node 1 DMA per-cpu:
> CPU    0: hi:    6, btch:   1 usd:   5
> CPU    1: hi:    6, btch:   1 usd:   5
> CPU    2: hi:    6, btch:   1 usd:   5
> CPU    3: hi:    6, btch:   1 usd:   4
> CPU    4: hi:    6, btch:   1 usd:   5
> CPU    5: hi:    6, btch:   1 usd:   3
> CPU    6: hi:    6, btch:   1 usd:   5
> CPU    7: hi:    6, btch:   1 usd:   5
> CPU    8: hi:    6, btch:   1 usd:   5
> CPU    9: hi:    6, btch:   1 usd:   2
> CPU   10: hi:    6, btch:   1 usd:   5
> CPU   11: hi:    6, btch:   1 usd:   3
> CPU   12: hi:    6, btch:   1 usd:   5
> CPU   13: hi:    6, btch:   1 usd:   2
> CPU   14: hi:    6, btch:   1 usd:   5
> CPU   15: hi:    6, btch:   1 usd:   4
> CPU   16: hi:    6, btch:   1 usd:   5
> CPU   17: hi:    6, btch:   1 usd:   5
> CPU   18: hi:    6, btch:   1 usd:   5
> CPU   19: hi:    6, btch:   1 usd:   5
> CPU   20: hi:    6, btch:   1 usd:   5
> CPU   21: hi:    6, btch:   1 usd:   5
> CPU   22: hi:    6, btch:   1 usd:   5
> CPU   23: hi:    6, btch:   1 usd:   4
> CPU   24: hi:    6, btch:   1 usd:   5
> CPU   25: hi:    6, btch:   1 usd:   4
> CPU   26: hi:    6, btch:   1 usd:   5
> CPU   27: hi:    6, btch:   1 usd:   5
> CPU   28: hi:    6, btch:   1 usd:   5
> CPU   29: hi:    6, btch:   1 usd:   1
> CPU   30: hi:    6, btch:   1 usd:   5
> CPU   31: hi:    6, btch:   1 usd:   5
> CPU   32: hi:    6, btch:   1 usd:   5
> CPU   33: hi:    6, btch:   1 usd:   5
> CPU   34: hi:    6, btch:   1 usd:   2
> CPU   35: hi:    6, btch:   1 usd:   5
> CPU   36: hi:    6, btch:   1 usd:   5
> CPU   37: hi:    6, btch:   1 usd:   5
> CPU   38: hi:    6, btch:   1 usd:   1
> CPU   39: hi:    6, btch:   1 usd:   4
> CPU   40: hi:    6, btch:   1 usd:   0
> CPU   41: hi:    6, btch:   1 usd:   4
> CPU   42: hi:    6, btch:   1 usd:   5
> CPU   43: hi:    6, btch:   1 usd:   5
> CPU   44: hi:    6, btch:   1 usd:   5
> CPU   45: hi:    6, btch:   1 usd:   5
> CPU   46: hi:    6, btch:   1 usd:   5
> CPU   47: hi:    6, btch:   1 usd:   4
> CPU   48: hi:    6, btch:   1 usd:   5
> CPU   49: hi:    6, btch:   1 usd:   3
> CPU   50: hi:    6, btch:   1 usd:   5
> CPU   51: hi:    6, btch:   1 usd:   5
> CPU   52: hi:    6, btch:   1 usd:   5
> CPU   53: hi:    6, btch:   1 usd:   2
> CPU   54: hi:    6, btch:   1 usd:   2
> CPU   55: hi:    6, btch:   1 usd:   2
> CPU   56: hi:    6, btch:   1 usd:   5
> CPU   57: hi:    6, btch:   1 usd:   1
> CPU   58: hi:    6, btch:   1 usd:   5
> CPU   59: hi:    6, btch:   1 usd:   5
> active_anon:2553 inactive_anon:3246 isolated_anon:0
>  active_file:34958 inactive_file:31322 isolated_file:0
>  unevictable:0 dirty:13086 writeback:1581 unstable:0
>  free:291 slab_reclaimable:2076 slab_unreclaimable:3873
>  mapped:186 shmem:3 pagetables:796 bounce:0
> Node 0 DMA free:10176kB min:7296kB low:9088kB high:10944kB
> active_anon:96128kB inactive_anon:138368kB active_file:1837440kB
> inactive_file:1605056kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:4190720kB mlocked:0kB dirty:459840kB
> writeback:62848kB mapped:11840kB shmem:192kB
> slab_reclaimable:127360kB slab_unreclaimable:226688kB
> kernel_stack:9088kB pagetables:35520kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:32 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Node 1 DMA free:8448kB min:1792kB low:2240kB high:2688kB
> active_anon:67264kB inactive_anon:69376kB active_file:399872kB
> inactive_file:399552kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:1047680kB mlocked:0kB dirty:377664kB
> writeback:38336kB mapped:64kB shmem:0kB slab_reclaimable:5504kB
> slab_unreclaimable:21184kB kernel_stack:480kB pagetables:15424kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Node 0 DMA: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
> 0*8192kB 0*16384kB = 0kB
> Node 1 DMA: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
> 0*8192kB 0*16384kB = 0kB
> 66497 total pagecache pages
> 56 pages in swap cache
> Swap cache stats: add 538, delete 482, find 127/141
> Free swap  = 5161024kB
> Total swap = 5177280kB
> 81920 pages RAM
> 900 pages reserved
> 47062 pages shared
> 39873 pages non-shared
> sd 0:0:1:0: Can't allocate memory for indirect table
> sd 0:0:1:0: couldn't convert cmd to srp_cmd
> 
> CAI Qian
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
