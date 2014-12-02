Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 618716B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 23:33:26 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so12524077pab.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 20:33:26 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qu3si31857620pbc.58.2014.12.01.20.33.23
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 20:33:25 -0800 (PST)
Date: Tue, 2 Dec 2014 13:36:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mm] BUG: unable to handle kernel paging request at c2446ffc
Message-ID: <20141202043638.GB6268@js1304-P5Q-DELUXE>
References: <20141128101000.GB8289@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141128101000.GB8289@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 28, 2014 at 02:10:00AM -0800, Fengguang Wu wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> 
> commit 1e491e9be4c97229a3a88763aada9582e37c7eaf
> Author:     Joonsoo Kim <iamjoonsoo.kim@lge.com>
> AuthorDate: Thu Nov 27 11:09:34 2014 +1100
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Thu Nov 27 11:09:34 2014 +1100
> 
>     mm/debug-pagealloc: prepare boottime configurable on/off
>     
>     Until now, debug-pagealloc needs extra flags in struct page, so we need to
>     recompile whole source code when we decide to use it.  This is really
>     painful, because it takes some time to recompile and sometimes rebuild is
>     not possible due to third party module depending on struct page.  So, we
>     can't use this good feature in many cases.
>     
>     Now, we have the page extension feature that allows us to insert extra
>     flags to outside of struct page.  This gets rid of third party module
>     issue mentioned above.  And, this allows us to determine if we need extra
>     memory for this page extension in boottime.  With these property, we can
>     avoid using debug-pagealloc in boottime with low computational overhead in
>     the kernel built with CONFIG_DEBUG_PAGEALLOC.  This will help our
>     development process greatly.
>     
>     This patch is the preparation step to achive above goal.  debug-pagealloc
>     originally uses extra field of struct page, but, after this patch, it will
>     use field of struct page_ext.  Because memory for page_ext is allocated
>     later than initialization of page allocator in CONFIG_SPARSEMEM, we should
>     disable debug-pagealloc feature temporarily until initialization of
>     page_ext.  This patch implements this.
>     
>     Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Cc: Mel Gorman <mgorman@suse.de>
>     Cc: Johannes Weiner <hannes@cmpxchg.org>
>     Cc: Minchan Kim <minchan@kernel.org>
>     Cc: Dave Hansen <dave@sr71.net>
>     Cc: Michal Nazarewicz <mina86@mina86.com>
>     Cc: Jungsoo Son <jungsoo.son@lge.com>
>     Cc: Ingo Molnar <mingo@redhat.com>
>     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Attached dmesg for the parent commit, too, to help confirm whether it is a noise error.
> 
> +-------------------------------------------------+------------+------------+---------------+
> |                                                 | 34bf7903e1 | 1e491e9be4 | next-20141127 |
> +-------------------------------------------------+------------+------------+---------------+
> | boot_successes                                  | 95         | 26         | 11            |
> | boot_failures                                   | 10         | 9          | 3             |
> | BUG:kernel_early_hang_without_any_printk_output | 10         | 8          |               |
> | BUG:unable_to_handle_kernel                     | 0          | 1          | 3             |
> | Oops                                            | 0          | 1          | 3             |
> | EIP_is_at__free_pages_ok                        | 0          | 1          | 3             |
> | Kernel_panic-not_syncing:Fatal_exception        | 0          | 1          | 3             |
> | backtrace:put_tty_driver                        | 0          | 1          | 3             |
> | backtrace:rp_init                               | 0          | 1          | 3             |
> | backtrace:kernel_init_freeable                  | 0          | 1          | 3             |
> +-------------------------------------------------+------------+------------+---------------+
> 
> [   13.206984] RocketPort device driver module, version 2.09, 12-June-2003
> [   13.208641] No rocketport ports found; unloading driver
> [   13.208641] No rocketport ports found; unloading driver
> [   13.213422] BUG: unable to handle kernel 
> [   13.213422] BUG: unable to handle kernel paging requestpaging request at c2446ffc
>  at c2446ffc
> [   13.214380] IP:
> [   13.214380] IP: [<b11ab6fe>] __free_pages_ok+0x376/0x62c
>  [<b11ab6fe>] __free_pages_ok+0x376/0x62c
> [   13.214380] *pde = 123ca067 
> [   13.214380] *pde = 123ca067 *pte = 12446060 *pte = 12446060 
> 
> [   13.214380] Oops: 0000 [#1] 
> [   13.214380] Oops: 0000 [#1] SMP SMP DEBUG_PAGEALLOCDEBUG_PAGEALLOC
> 
> [   13.214380] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.18.0-rc6-00201-g1e491e9 #14
> [   13.214380] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.18.0-rc6-00201-g1e491e9 #14
> [   13.214380] task: c1c40000 ti: c1c48000 task.ti: c1c48000
> [   13.214380] task: c1c40000 ti: c1c48000 task.ti: c1c48000
> [   13.214380] EIP: 0060:[<b11ab6fe>] EFLAGS: 00010097 CPU: 0
> [   13.214380] EIP: 0060:[<b11ab6fe>] EFLAGS: 00010097 CPU: 0
> [   13.214380] EIP is at __free_pages_ok+0x376/0x62c
> [   13.214380] EIP is at __free_pages_ok+0x376/0x62c
> [   13.214380] EAX: c2446ffc EBX: c2513200 ECX: 00000004 EDX: c2447000
> [   13.214380] EAX: c2446ffc EBX: c2513200 ECX: 00000004 EDX: c2447000
> [   13.214380] ESI: c2513300 EDI: 00000004 EBP: c1c49e94 ESP: c1c49e64
> [   13.214380] ESI: c2513300 EDI: 00000004 EBP: c1c49e94 ESP: c1c49e64
> [   13.214380]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   13.214380]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   13.214380] CR0: 8005003b CR2: c2446ffc CR3: 02729000 CR4: 00000690
> [   13.214380] CR0: 8005003b CR2: c2446ffc CR3: 02729000 CR4: 00000690
> [   13.214380] Stack:
> [   13.214380] Stack:
> [   13.214380]  00000008
> [   13.214380]  00000008 b26054ec b26054ec b2605440 b2605440 00000246 00000246 00000010 00000010 00000000 00000000 c2513000 c2513000 00000000 00000000
> 
> [   13.214380]  00000003
> [   13.214380]  00000003 00000000 00000000 c2513300 c2513300 00000000 00000000 c1c49e9c c1c49e9c b11aba32 b11aba32 c1c49ea4 c1c49ea4 b11abc52 b11abc52
> 
> [   13.214380]  c1c49ec4
> [   13.214380]  c1c49ec4 b1204fb5 b1204fb5 c1c49ebc c1c49ebc b10deca7 b10deca7 b0018000 b0018000 bbf20984 bbf20984 00000100 00000100 bbf20980 bbf20980
> 
> [   13.214380] Call Trace:
> [   13.214380] Call Trace:
> [   13.214380]  [<b11aba32>] __free_pages+0x7e/0x8e
> [   13.214380]  [<b11aba32>] __free_pages+0x7e/0x8e
> [   13.214380]  [<b11abc52>] __free_kmem_pages+0x16/0x26
> [   13.214380]  [<b11abc52>] __free_kmem_pages+0x16/0x26
> [   13.214380]  [<b1204fb5>] kfree+0x292/0x4e1
> [   13.214380]  [<b1204fb5>] kfree+0x292/0x4e1
> [   13.214380]  [<b10deca7>] ? debug_mutex_unlock+0x2f3/0x398
> [   13.214380]  [<b10deca7>] ? debug_mutex_unlock+0x2f3/0x398
> [   13.214380]  [<b14f5c36>] destruct_tty_driver+0xee/0x158
> [   13.214380]  [<b14f5c36>] destruct_tty_driver+0xee/0x158
> [   13.214380]  [<b14f5fe5>] tty_driver_kref_put+0xb4/0xc6
> [   13.214380]  [<b14f5fe5>] tty_driver_kref_put+0xb4/0xc6
> [   13.214380]  [<b14f6121>] put_tty_driver+0x16/0x26
> [   13.214380]  [<b14f6121>] put_tty_driver+0x16/0x26
> [   13.214380]  [<b26aa177>] rp_init+0xc04/0xc23
> [   13.214380]  [<b26aa177>] rp_init+0xc04/0xc23
> [   13.214380]  [<b12050e9>] ? kfree+0x3c6/0x4e1
> [   13.214380]  [<b12050e9>] ? kfree+0x3c6/0x4e1
> [   13.214380]  [<b26a9573>] ? register_PCI+0x1091/0x1091
> [   13.214380]  [<b26a9573>] ? register_PCI+0x1091/0x1091
> [   13.214380]  [<b26469d2>] do_one_initcall+0x1ed/0x356
> [   13.214380]  [<b26469d2>] do_one_initcall+0x1ed/0x356
> [   13.214380]  [<b2646d8b>] kernel_init_freeable+0x250/0x3ab
> [   13.214380]  [<b2646d8b>] kernel_init_freeable+0x250/0x3ab
> [   13.214380]  [<b1d95dd0>] kernel_init+0x16/0x1e7
> [   13.214380]  [<b1d95dd0>] kernel_init+0x16/0x1e7
> [   13.214380]  [<b1dcdd01>] ret_from_kernel_thread+0x21/0x30
> [   13.214380]  [<b1dcdd01>] ret_from_kernel_thread+0x21/0x30
> [   13.214380]  [<b1d95dba>] ? rest_init+0x15b/0x15b
> [   13.214380]  [<b1d95dba>] ? rest_init+0x15b/0x15b
> [   13.214380] Code:
> [   13.214380] Code: 31 31 d0 d0 29 29 d0 d0 c1 c1 e0 e0 05 05 80 80 3d 3d 00 00 30 30 64 64 b2 b2 00 00 8d 8d 14 14 03 03 74 74 71 71 83 83 05 05 28 28 90 90 da da b2 b2 01 01 89 89 d0 d0 89 89 55 55 e8 e8 83 83 15 15 2c 2c 90 90 da da b2 b2 00 00 e8 e8 67 67 d9 d9 05 05 00 00 <8b> <8b> 00 00 83 83 05 05 30 30 90 90 da da b2 b2 01 01 83 83 15 15 34 34 90 90 da da b2 b2 00 00 a8 a8 02 02 8b 8b 55 55 e8 e8
> 
> [   13.214380] EIP: [<b11ab6fe>] 
> [   13.214380] EIP: [<b11ab6fe>] __free_pages_ok+0x376/0x62c__free_pages_ok+0x376/0x62c SS:ESP 0068:c1c49e64
>  SS:ESP 0068:c1c49e64
> [   13.214380] CR2: 00000000c2446ffc
> [   13.214380] CR2: 00000000c2446ffc
> [   13.214380] ---[ end trace fe261d43ae421f43 ]---
> [   13.214380] ---[ end trace fe261d43ae421f43 ]---
> 
> git bisect start 3bcf494d225fd193d02e8cb2e2c3fe3cc476ff3f 5d01410fe4d92081f349b013a2e7a95429e4f2c9 --
> git bisect good 14692f2c9f01c7f21f83d41a8cb99fea1e4f803f  # 10:20     35+      0  Merge remote-tracking branch 'dlm/next'
> git bisect good 17623427488fe306376e18e0ee63c2c1bcbf5612  # 10:42     35+      0  Merge remote-tracking branch 'edac-amd/for-next'
> git bisect good 6acfd0c5752274ad5099152d9a00c99f81c273b5  # 10:54     35+      0  Merge remote-tracking branch 'char-misc/char-misc-next'
> git bisect good 574733068e280900745b7241a51f26815f25ca64  # 11:24     35+      5  Merge remote-tracking branch 'userns/for-next'
> git bisect good d3d6c2b2574a1700a33c3f40a8adcd11db728926  # 11:36     35+     11  Merge remote-tracking branch 'llvmlinux/for-next'
> git bisect good 749230afd0fa54770f95063071b1bdfb6dee9bc2  # 11:45     35+     13  Merge remote-tracking branch 'y2038/y2038'
> git bisect  bad 35cc8c3f978f75a04ac96b3cb72b8f7630ea04f4  # 11:50      0-      1  Merge branch 'akpm-current/current'
> git bisect  bad 6aab9099af555bf5a464f318d312ba5baa5cf516  # 11:59      0-      1  stacktrace: introduce snprint_stack_trace for buffer output
> git bisect good 15c2416b0e6f21f17152e0ba32202bb1354394e3  # 12:10     35+     18  mm-compaction-more-focused-lru-and-pcplists-draining-fix
> git bisect good c5c825302103a196aa94efa121c011121ffff14b  # 12:17     35+      2  uprobes: share the i_mmap_rwsem
> git bisect good b225ec73923a04a6d00dd28c6372c167780921b8  # 12:24     35+      0  hugetlb: hugetlb_register_all_nodes(): add __init marker
> git bisect good 4fb10ba778d4c4ccefee3ce833e487a6695068b1  # 12:32     35+      1  mm: support madvise(MADV_FREE)
> git bisect good 0aba43a2670028ec26cfeb59d3c2610ab0ee140b  # 12:42     35+      4  arm64: add pmd_[dirty|mkclean] for THP
> git bisect  bad 1e491e9be4c97229a3a88763aada9582e37c7eaf  # 12:51      0-      1  mm/debug-pagealloc: prepare boottime configurable on/off
> git bisect good 34bf7903e195347898a225220357f3a49dd65e7e  # 12:57     35+      0  mm/page_ext: resurrect struct page extending code for debugging
> # first bad commit: [1e491e9be4c97229a3a88763aada9582e37c7eaf] mm/debug-pagealloc: prepare boottime configurable on/off
> git bisect good 34bf7903e195347898a225220357f3a49dd65e7e  # 13:01    105+     10  mm/page_ext: resurrect struct page extending code for debugging
> # extra tests on HEAD of next/master
> git bisect  bad 3bcf494d225fd193d02e8cb2e2c3fe3cc476ff3f  # 13:01      0-      3  Add linux-next specific files for 20141127
> # extra tests on tree/branch next/master
> git bisect  bad 3bcf494d225fd193d02e8cb2e2c3fe3cc476ff3f  # 13:01      0-      3  Add linux-next specific files for 20141127
> # extra tests on tree/branch linus/master
> git bisect good 98e8d2e094de67315f786cd81b1dccb4ac040cc2  # 13:11    105+     21  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/ralf/upstream-linus
> # extra tests on tree/branch next/master
> git bisect  bad 3bcf494d225fd193d02e8cb2e2c3fe3cc476ff3f  # 13:11      0-      3  Add linux-next specific files for 20141127

Hello, Fengguang.

First of all, thanks for reporting!
It always helps me a lot.

But, in this time, I can't reproduce this failure with your attached
configuration. Instead of this failure, sometimes, OOM happens in my
testing with your configuration. I don't know why it happens. :)

Could you have another configuration to trigger this bug?

Anyway, this calltrace is really suspicious, because it looks like
failure of tty driver initialization. Why it is failed in this early
phase? Maybe, it is also related to OOM mentioned above.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
