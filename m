Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 701616B00AC
	for <linux-mm@kvack.org>; Sun, 15 Feb 2015 09:21:04 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so21256212wiw.1
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 06:21:03 -0800 (PST)
Received: from mail-we0-x241.google.com (mail-we0-x241.google.com. [2a00:1450:400c:c03::241])
        by mx.google.com with ESMTPS id q1si4214455wif.39.2015.02.15.06.21.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Feb 2015 06:21:02 -0800 (PST)
Received: by mail-we0-f193.google.com with SMTP id q59so9178716wes.0
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 06:21:02 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 15 Feb 2015 15:21:01 +0100
Message-ID: <CALszF6DP-RSX2-fp=a=gdcHMF3O0TE_JKom3AWcLFm5q80RrYw@mail.gmail.com>
Subject: [Regression]: mm: nommu: Memory leak introduced with commit
 "mm/nommu: use alloc_pages_exact() rather than its own implementation"
From: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Joonsoon,

I am currently working on STM32 microcontroller family upstream.
The STM32 family is ARM Cortex-M based, so no MMU.
As user-space, I use a ramdisk with a statically-linked busybox installed.

On v3.19, I am facing a memory leak.
Each time I run a command one page is lost. Here an example with
busybox's free command:

/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1972       5956          0          0        492
-/+ buffers/cache:       1480       6448
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1976       5952          0          0        492
-/+ buffers/cache:       1484       6444
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1980       5948          0          0        492
-/+ buffers/cache:       1488       6440
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1984       5944          0          0        492
-/+ buffers/cache:       1492       6436
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1988       5940          0          0        492
-/+ buffers/cache:       1496       6432

At some point, the system fails to sastisfy 256KB allocations:

[   38.720000] free: page allocation failure: order:6, mode:0xd0
[   38.730000] CPU: 0 PID: 67 Comm: free Not tainted
3.19.0-05389-gacf2cf1-dirty #64
[   38.740000] Hardware name: STM32 (Device Tree Support)
[   38.740000] [<08022e25>] (unwind_backtrace) from [<080221e7>]
(show_stack+0xb/0xc)
[   38.750000] [<080221e7>] (show_stack) from [<0804fd3b>]
(warn_alloc_failed+0x97/0xbc)
[   38.760000] [<0804fd3b>] (warn_alloc_failed) from [<08051171>]
(__alloc_pages_nodemask+0x295/0x35c)
[   38.770000] [<08051171>] (__alloc_pages_nodemask) from [<08051243>]
(__get_free_pages+0xb/0x24)
[   38.780000] [<08051243>] (__get_free_pages) from [<0805127f>]
(alloc_pages_exact+0x19/0x24)
[   38.790000] [<0805127f>] (alloc_pages_exact) from [<0805bdbf>]
(do_mmap_pgoff+0x423/0x658)
[   38.800000] [<0805bdbf>] (do_mmap_pgoff) from [<08056e73>]
(vm_mmap_pgoff+0x3f/0x4e)
[   38.810000] [<08056e73>] (vm_mmap_pgoff) from [<08080949>]
(load_flat_file+0x20d/0x4f8)
[   38.820000] [<08080949>] (load_flat_file) from [<08080dfb>]
(load_flat_binary+0x3f/0x26c)
[   38.830000] [<08080dfb>] (load_flat_binary) from [<08063741>]
(search_binary_handler+0x51/0xe4)
[   38.840000] [<08063741>] (search_binary_handler) from [<08063a45>]
(do_execveat_common+0x271/0x35c)
[   38.850000] [<08063a45>] (do_execveat_common) from [<08063b49>]
(do_execve+0x19/0x1c)
[   38.860000] [<08063b49>] (do_execve) from [<08020a01>]
(ret_fast_syscall+0x1/0x4a)
[   38.870000] Mem-info:
[   38.870000] Normal per-cpu:
[   38.870000] CPU    0: hi:    0, btch:   1 usd:   0
[   38.880000] active_anon:0 inactive_anon:0 isolated_anon:0
[   38.880000]  active_file:0 inactive_file:0 isolated_file:0
[   38.880000]  unevictable:123 dirty:0 writeback:0 unstable:0
[   38.880000]  free:1515 slab_reclaimable:17 slab_unreclaimable:139
[   38.880000]  mapped:0 shmem:0 pagetables:0 bounce:0
[   38.880000]  free_cma:0
[   38.910000] Normal free:6060kB min:352kB low:440kB high:528kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:492kB isolated(anon):0ks
[   38.950000] lowmem_reserve[]: 0 0
[   38.950000] Normal: 23*4kB (U) 22*8kB (U) 24*16kB (U) 23*32kB (U)
23*64kB (U) 23*128kB (U) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB
0*4096kB = 6060kB
[   38.970000] 123 total pagecache pages
[   38.970000] 2048 pages of RAM
[   38.980000] 1538 free pages
[   38.980000] 66 reserved pages
[   38.990000] 109 slab pages
[   38.990000] -46 pages shared
[   38.990000] 0 pages swap cached
[   38.990000] nommu: Allocation of length 221184 from process 67 (free) failed
[   39.000000] Normal per-cpu:
[   39.010000] CPU    0: hi:    0, btch:   1 usd:   0
[   39.010000] active_anon:0 inactive_anon:0 isolated_anon:0
[   39.010000]  active_file:0 inactive_file:0 isolated_file:0
[   39.010000]  unevictable:123 dirty:0 writeback:0 unstable:0
[   39.010000]  free:1515 slab_reclaimable:17 slab_unreclaimable:139
[   39.010000]  mapped:0 shmem:0 pagetables:0 bounce:0
[   39.010000]  free_cma:0
[   39.050000] Normal free:6060kB min:352kB low:440kB high:528kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:492kB isolated(anon):0ks
[   39.090000] lowmem_reserve[]: 0 0
[   39.090000] Normal: 23*4kB (U) 22*8kB (U) 24*16kB (U) 23*32kB (U)
23*64kB (U) 23*128kB (U) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB
0*4096kB = 6060kB
[   39.100000] 123 total pagecache pages
[   39.110000] Unable to allocate RAM for process text/data, errno 12
SEGV

I found that this is a regression, which has been introduced with this patch:

------------------------------------------------------------------------------
commit dbc8358c72373daa4f37b7e233fecbc47105fe54
Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date:   Fri Dec 12 16:55:55 2014 -0800

    mm/nommu: use alloc_pages_exact() rather than its own implementation

    do_mmap_private() in nommu.c try to allocate physically contiguous pages
    with arbitrary size in some cases and we now have good abstract function
    to do exactly same thing, alloc_pages_exact().  So, change to use it.

    There is no functional change.  This is the preparation step for support
    page owner feature accurately.

    Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
------------------------------------------------------------------------------

Indeed, when I revert it, the issue no more appear, I can run the free
command for hours without any issue.
The problem is that I fail to understand what in your patch could
cause the issue.

I enabled the traces in mm/nommu.c file, this is what I get with you patch:

[    5.970000] ==> do_mmap_pgoff(,0,36000,7,2,0)
[    5.970000] xxxalloc order 6 for 36000yyy
[    5.970000] xxxtry to alloc exact 54 pagesyyy
[    5.970000] ==> add_vma_to_mm(,d0781600)
[    5.970000] <== do_mmap_pgoff() = d0540000
[    5.990000] ==> do_mmap_pgoff(,0,2000,3,4000021,0)
[    5.990000] xxxalloc order 1 for 2000yyy
[    5.990000] ==> add_vma_to_mm(,d07818a0)
[    5.990000] <== do_mmap_pgoff() = d0576000
[    6.000000] ==> exit_mmap()
[    6.000000] ==> delete_vma_from_mm(d0781600)
[    6.000000] ==> delete_vma(d0781600)
[    6.000000] ==> __put_nommu_region(d078f120{1})
[    6.000000] xxxfree seriesyyy
[    6.000000] xxx- free d0540000yyy
[    6.000000] xxx- free d0541000yyy
[    6.010000] xxx- free d0542000yyy
</snip>
[    6.020000] xxx- free d0572000yyy
[    6.020000] xxx- free d0573000yyy
[    6.020000] xxx- free d0574000yyy
[    6.020000] xxx- free d0575000yyy
[    6.020000] ==> delete_vma_from_mm(d07818a0)
[    6.020000] ==> delete_vma(d07818a0)
[    6.020000] ==> __put_nommu_region(d078f0f0{1})
[    6.020000] xxxfree seriesyyy
[    6.020000] xxx- free d0576000yyy
[    6.020000] xxx- free d0577000yyy
[    6.020000] xxxfree page d07faee0: refcount not one: 0yyy
[    6.020000] <== exit_mmap()

As you can see, I have one warning that shows up "free page d07faee0:
refcount not one: 0".
When reverting your patch, I don't have this warning:

[    6.320000] ==> do_mmap_pgoff(,0,36000,7,2,0)
[    6.320000] xxxalloc order 6 for 36000yyy
[    6.320000] xxxshave 8/10 @64yyy
[    6.320000] xxxshave 2/2 @56yyy
[    6.320000] ==> add_vma_to_mm(,d0781600)
[    6.320000] <== do_mmap_pgoff() = d0540000
[    6.340000] ==> do_mmap_pgoff(,0,2000,3,4000021,0)
[    6.340000] xxxalloc order 1 for 2000yyy
[    6.340000] ==> add_vma_to_mm(,d0781720)
[    6.340000] <== do_mmap_pgoff() = d0536000
[    6.350000] ==> exit_mmap()
[    6.350000] ==> delete_vma_from_mm(d0781720)
[    6.350000] ==> delete_vma(d0781720)
[    6.350000] ==> __put_nommu_region(d078f0f0{1})
[    6.350000] xxxfree seriesyyy
[    6.350000] xxx- free d0536000yyy
[    6.350000] xxx- free d0537000yyy
[    6.350000] ==> delete_vma_from_mm(d0781600)
[    6.350000] ==> delete_vma(d0781600)
[    6.350000] ==> __put_nommu_region(d078f120{1})
[    6.350000] xxxfree seriesyyy
[    6.350000] xxx- free d0540000yyy
[    6.350000] xxx- free d0541000yyy
[    6.350000] xxx- free d0542000yyy
</snip>
[    6.370000] xxx- free d0572000yyy
[    6.370000] xxx- free d0573000yyy
[    6.370000] xxx- free d0574000yyy
[    6.370000] xxx- free d0575000yyy
[    6.370000] <== exit_mmap()

Do you have an idea on what could cause the issue?

I can do any tests you could find relevant to hunt down this bug.

Best regards,
Maxime

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
