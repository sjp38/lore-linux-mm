Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 755636B0006
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:54:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b88-v6so15152943pfj.4
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 21:54:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v4-v6si25868612plz.250.2018.11.14.21.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 21:54:33 -0800 (PST)
Date: Thu, 15 Nov 2018 13:54:43 +0800
From: kernel test robot <rong.a.chen@intel.com>
Subject: [LKP] dd2283f260 [ 97.263072]
 WARNING:at_kernel/locking/lockdep.c:#lock_downgrade
Message-ID: <20181115055443.GF18977@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="dgjlcl3Tl+kb3YDk"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>


--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit dd2283f2605e3b3e9c61bcae844b34f2afa4813f
Author:     Yang Shi <yang.shi@linux.alibaba.com>
AuthorDate: Fri Oct 26 15:07:11 2018 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Fri Oct 26 16:26:33 2018 -0700

    mm: mmap: zap pages with read mmap_sem in munmap
    
    Patch series "mm: zap pages with read mmap_sem in munmap for large
    mapping", v11.
    
    Background:
    Recently, when we ran some vm scalability tests on machines with large memory,
    we ran into a couple of mmap_sem scalability issues when unmapping large memory
    space, please refer to https://lkml.org/lkml/2017/12/14/733 and
    https://lkml.org/lkml/2018/2/20/576.
    
    History:
    Then akpm suggested to unmap large mapping section by section and drop mmap_sem
    at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).
    
    V1 patch series was submitted to the mailing list per Andrew's suggestion
    (see https://lkml.org/lkml/2018/3/20/786).  Then I received a lot great
    feedback and suggestions.
    
    Then this topic was discussed on LSFMM summit 2018.  In the summit, Michal
    Hocko suggested (also in the v1 patches review) to try "two phases"
    approach.  Zapping pages with read mmap_sem, then doing via cleanup with
    write mmap_sem (for discussion detail, see
    https://lwn.net/Articles/753269/)
    
    Approach:
    Zapping pages is the most time consuming part, according to the suggestion from
    Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
    what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.
    
    But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
      * The unexpected state from PF if it wins the race in the middle of munmap.
        It may return zero page, instead of the content or SIGSEGV.
      * Can't handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
        is a showstopper from akpm
    
    But, some part may need write mmap_sem, for example, vma splitting. So,
    the design is as follows:
            acquire write mmap_sem
            lookup vmas (find and split vmas)
            deal with special mappings
            detach vmas
            downgrade_write
    
            zap pages
            free page tables
            release mmap_sem
    
    The vm events with read mmap_sem may come in during page zapping, but
    since vmas have been detached before, they, i.e.  page fault, gup, etc,
    will not be able to find valid vma, then just return SIGSEGV or -EFAULT as
    expected.
    
    If the vma has VM_HUGETLB | VM_PFNMAP, they are considered as special
    mappings.  They will be handled by falling back to regular do_munmap()
    with exclusive mmap_sem held in this patch since they may update vm flags.
    
    But, with the "detach vmas first" approach, the vmas have been detached
    when vm flags are updated, so it sounds safe to update vm flags with read
    mmap_sem for this specific case.  So, VM_HUGETLB and VM_PFNMAP will be
    handled by using the optimized path in the following separate patches for
    bisectable sake.
    
    Unmapping uprobe areas may need update mm flags (MMF_RECALC_UPROBES).
    However it is fine to have false-positive MMF_RECALC_UPROBES according to
    uprobes developer.  So, uprobe unmap will not be handled by the regular
    path.
    
    With the "detach vmas first" approach we don't have to re-acquire mmap_sem
    again to clean up vmas to avoid race window which might get the address
    space changed since downgrade_write() doesn't release the lock to lead
    regression, which simply downgrades to read lock.
    
    And, since the lock acquire/release cost is managed to the minimum and
    almost as same as before, the optimization could be extended to any size
    of mapping without incurring significant penalty to small mappings.
    
    For the time being, just do this in munmap syscall path.  Other
    vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
    intact due to some implementation difficulties since they acquire write
    mmap_sem from very beginning and hold it until the end, do_munmap() might
    be called in the middle.  But, the optimized do_munmap would like to be
    called without mmap_sem held so that we can do the optimization.  So, if
    we want to do the similar optimization for mmap/mremap path, I'm afraid we
    would have to redesign them.  mremap might be called on very large area
    depending on the usecases, the optimization to it will be considered in
    the future.
    
    This patch (of 3):
    
    When running some mmap/munmap scalability tests with large memory (i.e.
    > 300GB), the below hung task issue may happen occasionally.
    
    INFO: task ps:14018 blocked for more than 120 seconds.
           Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
     "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
    message.
     ps              D    0 14018      1 0x00000004
      ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
      ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
      00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
     Call Trace:
      [<ffffffff817154d0>] ? __schedule+0x250/0x730
      [<ffffffff817159e6>] schedule+0x36/0x80
      [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
      [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
      [<ffffffff81717db0>] down_read+0x20/0x40
      [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
      [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
      [<ffffffff81241d87>] __vfs_read+0x37/0x150
      [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
      [<ffffffff81242266>] vfs_read+0x96/0x130
      [<ffffffff812437b5>] SyS_read+0x55/0xc0
      [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
    
    It is because munmap holds mmap_sem exclusively from very beginning to all
    the way down to the end, and doesn't release it in the middle.  When
    unmapping large mapping, it may take long time (take ~18 seconds to unmap
    320GB mapping with every single page mapped on an idle machine).
    
    Zapping pages is the most time consuming part, according to the suggestion
    from Michal Hocko [1], zapping pages can be done with holding read
    mmap_sem, like what MADV_DONTNEED does.  Then re-acquire write mmap_sem to
    cleanup vmas.
    
    But, some part may need write mmap_sem, for example, vma splitting. So,
    the design is as follows:
            acquire write mmap_sem
            lookup vmas (find and split vmas)
            deal with special mappings
            detach vmas
            downgrade_write
    
            zap pages
            free page tables
            release mmap_sem
    
    The vm events with read mmap_sem may come in during page zapping, but
    since vmas have been detached before, they, i.e.  page fault, gup, etc,
    will not be able to find valid vma, then just return SIGSEGV or -EFAULT as
    expected.
    
    If the vma has VM_HUGETLB | VM_PFNMAP, they are considered as special
    mappings.  They will be handled by without downgrading mmap_sem in this
    patch since they may update vm flags.
    
    But, with the "detach vmas first" approach, the vmas have been detached
    when vm flags are updated, so it sounds safe to update vm flags with read
    mmap_sem for this specific case.  So, VM_HUGETLB and VM_PFNMAP will be
    handled by using the optimized path in the following separate patches for
    bisectable sake.
    
    Unmapping uprobe areas may need update mm flags (MMF_RECALC_UPROBES).
    However it is fine to have false-positive MMF_RECALC_UPROBES according to
    uprobes developer.
    
    With the "detach vmas first" approach we don't have to re-acquire mmap_sem
    again to clean up vmas to avoid race window which might get the address
    space changed since downgrade_write() doesn't release the lock to lead
    regression, which simply downgrades to read lock.
    
    And, since the lock acquire/release cost is managed to the minimum and
    almost as same as before, the optimization could be extended to any size
    of mapping without incurring significant penalty to small mappings.
    
    For the time being, just do this in munmap syscall path.  Other
    vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
    intact due to some implementation difficulties since they acquire write
    mmap_sem from very beginning and hold it until the end, do_munmap() might
    be called in the middle.  But, the optimized do_munmap would like to be
    called without mmap_sem held so that we can do the optimization.  So, if
    we want to do the similar optimization for mmap/mremap path, I'm afraid we
    would have to redesign them.  mremap might be called on very large area
    depending on the usecases, the optimization to it will be considered in
    the future.
    
    With the patches, exclusive mmap_sem hold time when munmap a 80GB address
    space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us level
    from second.
    
    munmap_test-15002 [008]   594.380138: funcgraph_entry: |
    __vm_munmap() {
    munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us
    |    unmap_region();
    munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us
    |  }
    
    Here the execution time of unmap_region() is used to evaluate the time of
    holding read mmap_sem, then the remaining time is used with holding
    exclusive lock.
    
    [1] https://lwn.net/Articles/753269/
    
    Link: http://lkml.kernel.org/r/1537376621-51150-2-git-send-email-yang.shi@linux.alibaba.com
    Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>Suggested-by: Michal Hocko <mhocko@kernel.org>
    Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
    Suggested-by: Matthew Wilcox <willy@infradead.org>
    Reviewed-by: Matthew Wilcox <willy@infradead.org>
    Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
    Acked-by: Vlastimil Babka <vbabka@suse.cz>
    Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
    Cc: Vlastimil Babka <vbabka@suse.cz>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

a8dda165ec  vfree: add debug might_sleep()
dd2283f260  mm: mmap: zap pages with read mmap_sem in munmap
5929a1f0ff  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
0bc80e3cb0  Add linux-next specific files for 20181114
+-----------------------------------------------------+------------+------------+------------+---------------+
|                                                     | a8dda165ec | dd2283f260 | 5929a1f0ff | next-20181114 |
+-----------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                      | 314        | 178        | 190        | 168           |
| boot_failures                                       | 393        | 27         | 21         | 40            |
| WARNING:held_lock_freed                             | 383        | 23         | 17         | 39            |
| is_freeing_memory#-#,with_a_lock_still_held_there   | 383        | 23         | 17         | 39            |
| BUG:unable_to_handle_kernel                         | 5          | 2          | 4          | 1             |
| Oops:#[##]                                          | 9          | 3          | 4          | 1             |
| EIP:debug_check_no_locks_freed                      | 9          | 3          | 4          | 1             |
| Kernel_panic-not_syncing:Fatal_exception            | 9          | 3          | 4          | 1             |
| Mem-Info                                            | 4          | 1          |            |               |
| invoked_oom-killer:gfp_mask=0x                      | 1          | 1          |            |               |
| WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 6          | 4          | 7             |
| EIP:lock_downgrade                                  | 0          | 6          | 4          | 7             |
+-----------------------------------------------------+------------+------------+------------+---------------+

[   96.288009] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
[   96.359626] input_id (331) used greatest stack depth: 6360 bytes left
[   96.749228] grep (358) used greatest stack depth: 6336 bytes left
[   96.921470] network.sh (341) used greatest stack depth: 6212 bytes left
[   97.262340] 
[   97.262587] =========================
[   97.263072] WARNING: held lock freed!
[   97.263536] 4.19.0-06969-gdd2283f #1 Not tainted
[   97.264110] -------------------------
[   97.264575] udevd/198 is freeing memory 9c16c930-9c16c99b, with a lock still held there!
[   97.265542] (ptrval) (&anon_vma->rwsem){....}, at: unlink_anon_vmas+0x14e/0x420
[   97.266450] 1 lock held by udevd/198:
[   97.266924]  #0: (ptrval) (&mm->mmap_sem){....}, at: __do_munmap+0x531/0x730
[   97.267773] 
[   97.267773] stack backtrace:
[   97.268140] _warn_unseeded_randomness: 113 callbacks suppressed
[   97.268148] random: get_random_u32 called from copy_process+0x673/0x2d80 with crng_init=0
[   97.268310] CPU: 1 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
[   97.270901] Call Trace:
[   97.271232]  dump_stack+0xd6/0x11a
[   97.271674]  debug_check_no_locks_freed+0x249/0x2c0
[   97.272311]  kmem_cache_free+0x193/0x6e0
[   97.272805]  __put_anon_vma+0xd6/0x240
[   97.273280]  unlink_anon_vmas+0x362/0x420
[   97.273793]  free_pgtables+0x46/0x190
[   97.274253]  unmap_region+0x168/0x1b0
[   97.274711]  __do_munmap+0x558/0x730
[   97.275164]  __vm_munmap+0x92/0x120
[   97.275604]  sys_munmap+0x26/0x40
[   97.276026]  do_int80_syscall_32+0xfe/0x360
[   97.276545]  entry_INT80_32+0xda/0xda
[   97.277036] EIP: 0x47f42d61
[   97.277391] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 <89> d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
[   97.279628] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
[   97.280412] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
[   97.281182] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
[   97.376958] ------------[ cut here ]------------
[   97.377600] downgrading a read lock
[   97.377622] WARNING: CPU: 0 PID: 198 at kernel/locking/lockdep.c:3556 lock_downgrade+0x20c/0x3a0
[   97.379416] CPU: 0 PID: 198 Comm: udevd Not tainted 4.19.0-06969-gdd2283f #1
[   97.380330] EIP: lock_downgrade+0x20c/0x3a0
[   97.380896] Code: 05 78 7a 95 84 01 c7 04 24 4f 5e b9 83 89 45 e0 83 15 7c 7a 95 84 00 e8 e2 5c f5 ff 83 05 80 7a 95 84 01 83 15 84 7a 95 84 00 <0f> 0b 8b 45 ec 83 05 88 7a 95 84 01 89 45 e8 8b 45 e0 83 15 8c 7a
[   97.383256] EAX: 00000017 EBX: 9d6adc80 ECX: 00000000 EDX: 000002dc
[   97.384100] ESI: 00000001 EDI: 8141bb11 EBP: 9c1b5ee8 ESP: 9c1b5ec0
[   97.384938] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010046
[   97.385831] CR0: 80050033 CR2: 77f68000 CR3: 1c11d000 CR4: 00140690
[   97.386641] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   97.387443] DR6: fffe0ff0 DR7: 00000400
[   97.387980] Call Trace:
[   97.388333]  downgrade_write+0x3d/0x1b0
[   97.388865]  __do_munmap+0x531/0x730
[   97.389406]  __vm_munmap+0x92/0x120
[   97.389891]  sys_munmap+0x26/0x40
[   97.390351]  do_int80_syscall_32+0xfe/0x360
[   97.390923]  entry_INT80_32+0xda/0xda
[   97.391437] EIP: 0x47f42d61
[   97.391813] Code: c1 be a2 09 00 8b 89 08 ff ff ff 31 d2 29 c2 65 89 11 83 c8 ff eb d7 90 90 89 da 8b 4c 24 08 8b 5c 24 04 b8 5b 00 00 00 cd 80 <89> d3 3d 01 f0 ff ff 73 01 c3 e8 76 c3 03 00 81 c1 84 a2 09 00 8b
[   97.394148] EAX: ffffffda EBX: 77f68000 ECX: 00001000 EDX: 47fdcff4
[   97.394945] ESI: 08080da0 EDI: 00000000 EBP: 00000000 ESP: 7fbf1d08
[   97.395759] DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b EFLAGS: 00000206
[   97.396628] ---[ end trace 2d49d562090f3ba6 ]---
[   97.502082] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start ccda4af0f4b92f7b4c308d3acc262f4a7e3affad v4.19 --
git bisect  bad ac435075892e3e651c667b4a9f2267cf3ef1d5a2  # 01:46  B      4     1    3   3  Merge tag 'csky-for-linus-4.20' of https://github.com/c-sky/csky-linux
git bisect good 01aa9d518eae8a4d75cd3049defc6ed0b6d0a658  # 03:05  G     42     0    6   6  Merge tag 'docs-4.20' of git://git.lwn.net/linux
git bisect good 26873acacbdbb4e4b444f5dd28dcc4853f0e8ba2  # 03:30  G     44     0    4   4  Merge tag 'driver-core-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect good a45dcff7489f7cb21a3a8e967a90ea41b31c1559  # 03:49  G     44     0    8   8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
git bisect  bad 5ecf3e110c32c5756351eed067cdf6a91c308e62  # 04:07  B     17     1    1   1  Merge tag 'linux-watchdog-4.20-rc1' of git://www.linux-watchdog.org/linux-watchdog
git bisect  bad b59dfdaef173677b0b7e10f375226c0a1114fd20  # 04:35  B     20     1    5   5  i2c-hid: properly terminate i2c_hid_dmi_desc_override_table[] array
git bisect good 4904008165c8a1c48602b8316139691b8c735e6e  # 05:48  G    200     0   24  24  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect  bad 345671ea0f9258f410eb057b9ced9cefbbe5dc78  # 06:13  B     31     1    5   5  Merge branch 'akpm' (patches from Andrew)
git bisect good 4b85afbdacd290c7a22c96df40a6433fdcacb509  # 06:53  G    205     0  101 101  mm: zero-seek shrinkers
git bisect  bad 85a06835f6f1ba79f0f00838ccd5ad840dd1eafb  # 07:24  B     61     3   34  34  mm: mremap: downgrade mmap_sem to read when shrinking
git bisect  bad 85cfb245060e45640fa3447f8b0bad5e8bd3bdaf  # 07:43  B     20     1    2   2  memcg: remove memcg_kmem_skip_account
git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 08:02  B     15     1    0   0  mm: mmap: zap pages with read mmap_sem in munmap
git bisect good dedf2c73b80b4566dfcae8ebe9ed46a38b63a1f9  # 08:36  G    196     0   33  33  mm/mempolicy.c: use match_string() helper to simplify the code
git bisect good 3ca4ea3a7a78a243ee9edf71a2736bc8fb26d70f  # 10:40  G    197     0   31  31  mm/vmalloc.c: improve vfree() kerneldoc
git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 11:28  G    202     0  114 115  vfree: add debug might_sleep()
# first bad commit: [dd2283f2605e3b3e9c61bcae844b34f2afa4813f] mm: mmap: zap pages with read mmap_sem in munmap
git bisect good a8dda165ec34fac2b4119654330150e2c896e531  # 12:17  G    585     0  283 399  vfree: add debug might_sleep()
# extra tests with debug options
git bisect  bad dd2283f2605e3b3e9c61bcae844b34f2afa4813f  # 12:38  B     14     1    4   4  mm: mmap: zap pages with read mmap_sem in munmap
# extra tests on HEAD of linux-devel/devel-hourly-2018111421
git bisect  bad ead84f4ee6640e1bda88302f402bf5f2e0cf78ec  # 12:38  B      5     3    0   5  0day head guard for 'devel-hourly-2018111421'
# extra tests on tree/branch linus/master
git bisect  bad 5929a1f0ff30d04ccf4b0f9c648e7aa8bc816bbd  # 12:59  B     36     1    8   8  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
# extra tests on tree/branch linux-next/master
git bisect  bad 0bc80e3cb0c14878ae0a7779d46f1192221f080e  # 13:19  B     57     3   14  14  Add linux-next specific files for 20181114

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--dgjlcl3Tl+kb3YDk
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-lkp-kboot01-3:20181115080451:i386-randconfig-c0-11142356:4.19.0-06969-gdd2283f:1.gz"
Content-Transfer-Encoding: base64

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
aDbITOj+DYjZH1W3mPM+5gAA

--dgjlcl3Tl+kb3YDk
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-vm-lkp-hsw-4ep1-quantal-i386-24:20181115110127:i386-randconfig-c0-11142356:4.19.0-06968-ga8dda16:1.gz"
Content-Transfer-Encoding: base64

H4sICAEC7VsAA2RtZXNnLXZtLWxrcC1oc3ctNGVwMS1xdWFudGFsLWkzODYtMjQ6MjAxODEx
MTUxMTAxMjc6aTM4Ni1yYW5kY29uZmlnLWMwLTExMTQyMzU2OjQuMTkuMC0wNjk2OC1nYThk
ZGExNjoxAKxbbXPiOrL+vPdX6NZ+mGQ3gOV3U8XW5oWZUAlJNmTmnN2pKcrYMvGJsTm2yYT5
9fdp2QYBIWRmL1MTsOh+1GpJraclIfw8WbIgS4ssESxOWSHKxRwFofifrwwvra3J1zd2HaeL
F/Ys8iLOUma2udfWWprt2W5r6rth6HObHT1NFnES/jN+npjGMTuaBsFKw2kbbY0dXYhJ7NdP
LX58zP7K2Wh4xx4eF+wme2bcYlzrmlbXMNn56IHpGne3Tbnq39/0r1mxmM+zvBQhC+aLorst
xdi5SEt/kTfvl/4iKbalzu8+d2FjGmb5OA7Zh08iXcSpGKSlSD6wRfqUZt/TE7Yo4nTKpiIV
eRzAUXHZfhXp3xnqK5ZFKWZs5i/ZRACjKP1JInYUXly7E80XXTaqGkI1/D46/dJnkfDLRS6Y
9qJpvMs+vLgOi5LMlyLzLE5LlotpjFry4sOvweqAHY36/zWOCZzTL7+/B+cFfijFOIsijLKv
+rcuY5ZjnzTlRfxDFFWxbtl7UfopOTOstRpbChjjnNBILsVLyQiLxQVzDZ1NlqUomh78AK00
9PPwA4uyfObvduPZ4HbUmufZcxyilvnjsogDP2H3p0N06HxnlElx4epal32dodPJJ5uv1kaR
F02i6BusoVb8FJgXBbtgEYGh+SJ/FuFPwUW7tkW/Dse3m8qjKKzgfrap0BS7YL9sWyQicpwK
R0W/DFehbcAdtG6eY8o+dVkoJotpl8XTNMtpNCbZNBHPIqGwS/NrZzDeZGUciC67+Z0d9V9E
sMCIv4ilQ4+BmpUiKCm4Bn6aZiVFG1FNjy5Ls7R1d9pnTyJPRfK/28iXyzlMjYssh1UEQzpX
X4bbck/Ps1aQZAGs/yxn0KzIC2ZOLNsMNc4wmZoHbUNV31BFgGbaCeky0zEN9OgJOWXm50v5
nRTb0Dc29KvJWwSPmJJV/MAbFgpXMyz883QWLINEbER33fpW4RaIyeREBW/mF/irvURbL3zx
Mq6g6GsehKYuTAzkyYn8Kg4TMU7xnetyy9Msj5uuwdKNem00vSyCLruo/cq453ltz7PY8PIH
9VogCvh9rWOjAd9YNdwW85DC2taoa0abMqFYr/ePVwacbfIVVi5m2bOK5a+xotcnp20acFvi
F+V4HqWsR06g+Shb7+fB47pYGqRqWnYVpu9OH7rsPEujeLrIfTk+v2otB4H9tzPGfntg7PN5
C//ZzrOK5pjf2AjjmuK0ZAhgJ3u8YqAliqplOW+pKnG0ip+Kqm24b6lG2/5bqXLXNTFbomyB
CUF6w7uWXPWZX6oAtu82APiIDsCaMscQIamjeZk/+8nxBio5lbHZHOMJGp7WiuyJY64lPDT3
myQkMVYpVJRhSlWgO7GLKraibcvB4Cji+YVo1Mvcn82zBDRo0y7mTYBSLa4crlqbAZamw+ln
91foalQygTc0TPj6sxxqd58eTs+u+4qOQVECC+vFYHS1MpYLk0eVsas1RNUxEBlOz+8GYAKS
vFZeRmTARF/MiG7GEVZsOezCKlSGir7lWI3+/ejibnNN/Gi7jsbkimOyo2e09ez2/HLEjlUA
z1EAHtSF6+PHPrd1VwIYGgHwGoCd/X53XonXsrJk9aRWYOteU8FHvG1XYDqVmmPuVFCJH66A
IlRVwcVuC0DpyAXcNM53Krh4ZwtcS2nBaKcCrfKxqSk6jmY3Oqd3g/PtVlt1v7i7bq3EDxrl
6G5TweVdf6ffrI9VBYa7U0ElfrgCW2squM6IMkrD/DBEkCZ6GglJazYa7RqrCCCly4w1Lxr4
crodrUpqALVS10GrLM6HZ+z69rdhf8j8Zz9ONvMNiHkyIaqrSrLvDFMcKxxrsYZuKdKexkn6
oJgO0P9kiBK5n06FkoHhO0MniBvi2Ak+vMKNaQF5jTCqKCYGxTB7llP8B9UE+p6XMjgLP3gE
yVESVchT5K/CQh3KSKA2T5WzPbJOfomiV6n7lnl4eWLbPFc/ALOfFqswHqbLABGctKsEXEJq
v+Y1SGBM3KYNSJmVfjL3qYMYN+BTfS1req6j9BO5GEIoZ1IB9ADDhbwNQzB4VEXP21HUaq0d
VqJbGtd365HGVDon7Hrw8ZZN/DJ47Bp8pWkg3kKzop5yioR5jBgP0hohnS/XgghYqwl+N2w9
xDNIDW7ZHVJX4nK25qrClvlzkxUq7lqFpMc3wwE78oN5DFr4lbjkNxZGifyPtbNEEf92rAAg
hqGfb0n3qwY25M/jgPYcsE42myQcOaxqhEw18P2n0YBpLd1Q0dzVOjS4eRiP7s/Ht1/u2dFk
AVWGv+M4/xOfpkk28RP5oDf2qVbZmhx98FGJlICMwdJPb2UeT+ldAuJ9cP8v+S49Nbhgq483
iI66iqgb77DMUi2z2GM8fWQyGdowzrBfMY7Xxhlbxll7jLNURNN9h3Geapy3zzib/4Rx3h7j
PBXRMd9hHN/oVDztMY8GyLvN8/eY56uInvce8/iGeXyPeQ5FhHebN9lj3kRF1Fe0AzpaFbwm
S4YcKM/jUFkQIUvB4t2jnu+pnauI1mujYR+isQdRneGObf4EorkH0VQRHdVD1tsecn/GQ/ae
2m0F0dV+xkPOHkRHReQ/4yF3D6K6LrgbY8h700Ou4Siy/O0B5ypxB8L8beFXI8u+dgV72hWo
iM7PeCrcgxiqiK+Gl32IYg+iUBA92m96N2K0BzFSEbm94g5wPTsanl48HK9y+2BjjyJOqx1h
fFYhDH0jbYhDIhOu5to+kl4QlkLIjSQRbvMFz0blxWw+yTI06TQBnSZDdDooAN9B2M7KebKY
ymdVj1hlzdQrtkBpAZE8X6YDDStQgilR9m8NW9RratgiqyLabgYxWWUFsvF35wMQqOc4UFix
AeKIis9grTxl8HP/Oc7LhZ8g3Q/rbUQGP6mbhFCivH9jmy0XUZyKsPVHHEUxkc7tzbatTbam
eGuHDdHPsuBEDYyWW7ar7rIZuu5hOoHXhxnyk6kox9XnsdzsZyB0dEQQ5dmsyhjGlfl/ByUz
tY72IhyffY/LRxbk6XRMuyc9pet0w4QnJBMfz0Ue0LHDzf0Y/TTqGjpL8zGKqFXjSVwW6yIY
X3TlA1Fv+aSsEK5DWUeD159NREgnDIbJKwrcoY3QfzabLazghmO5ls1yjYXI4JD5Lrjh2Y5h
q5i0JM+h2UKTs6D7lhqTIj1U+DcTKZCC4tJarKKAn1L6gb+cqXLExdH/dZbiF8s0YHcf5ZiS
W7yKrMd5tYVblMJPStDxjW1gHoaOGwQbGhRPzxZxUqJWShGSuCgxU2bZJE7icsmmebaY0+DM
0jZjD5TXsCax0T1POSgEmA0SelUN2iBD8pKGxMphRDzvdfGCZcnTvPVYfG+ZYs5bfy78FICt
2HDtlm52u+FjMGc5pkOvg7nSQSYsI3zegxr7I5v0OvjQwYeiIzemFxhynQOoHYQyDLZly9C0
YvVlkOWiltC42+K8pXntYPqjVZ+rWiIwzMgP9InJacPPNAyNW5rQAzRTWAaXehzTpIUV0fVa
08dJsOQt3l76M6Q29+eXPYJnT1XEkw8tmjHVcyvQUCk3dQPjZoLy4LGX0HFvKyTW1pF/W4+Y
38myqcrUufQrZs57rWRnt7cP48Hw9FO/15k/TTuyjs4bxnSmQdByOu+tAN4nyB+t10+nKbws
5jQSe1DT2H1/9Pn6YXwPq3odpFxIJ5v+6VD/vNmZnUOd9//ZLs6ur+7Go/79l/59L07T6iBJ
JpC96mOxLPI/x37y3V8W4/oMiOVBdZrQxgcZnxALk2RMHsgWZY/DB6ko23GU+jNR9LT6nKqN
/n6aFdMegv3cT1FHi7Mii0qK8hQSZRln6Swef6eEPcymPVnIsmxe1B+TzA8RlWdhXDz1dDr2
mM3LVQGCUz4J27M4zRA6s0Va9tz63DxsJ9l0LPOFHqhRdVomxquzsvq2Qm812U3NptRcuqBb
vbHKE81p2JpbmbrlITBciLSkoycfE5c9+sVjvY1MxXLNsi0LAfMoy0OR4+mE6bbOTbM6TD5W
4GxdpjGI9639aIbuYAFr0JCmcoNrjv4KGuW7yi66pa130a1Xd9GhQ5FuUB0AxD8oPGKh+qum
SDgWFgkZ2X06jrJ0sNy6cjpGoxA6Fi/rvRQLwROhfyi30LrM5HQQcdWxdAPNuFK4xJFhOSZK
npo4G4LnWYalX7H8O0YekkqOJcjEY1Y9Gh7J0xyDS7lma1dsUiDGc25YLh6arSM0+ooFM7/V
FByr1lnweU1Omrrr/b7EX2Jod7eF6RXFL2BVjFWcIzTIt6zVEBB6YOxIp6Xz6WynNkZr17ga
NRWAKUlWDWD6vAZgNkbJqwCMPc9kJ0gAX3PEGkBUu6sEwC2us+HrAKCQxPFYRUG1tQVevTsr
LbCQXewBYKxNvq8ATD1a+cA17bABoD7a1wQAUEdWAIYuPB4ENYAOAL1qgq27xhsI8oqGROBK
G1ZwrB5X2wgOEM7pnIfGeByx8jEu1sepoNMpVqgCxYL9dsdAzRjiRSpvNS1Wh90zjNF2u337
1FagHRrur7DJBaidyiWf4P2xnObjbC5S0EndBZu0TW0/mwSBJdY0uv58hhTiN8zRadqzka3f
UjToaS3jhA3j9HbyhwhKBOETmQ/09BN2A1OLHleQuIE4F5W5Tzy7ntDkDNvBV024oQYjvlTM
qFHGBLY5NTIA97yMRU5nudXFlvPPLJ7NEzGjW1KU/bQVJZfOiqTSX0iQHFrS+WAg+2A3wJIK
nf6sVTCBYVZQ1oGpqDxZ0+keHIzkZk2fe/oGlGT5KyjqiokfPLEwW6DWVgd0rOVHpchbUS5E
vSq+YpJHrZAQqJTJVZB99/MUNmG8VMshcVqyhVbFo1cXzOMNSAdR9y8PSAIK6cLXavV4bX1t
fLBIZAAGv18IirwNb8xbIiWyS12AViCIkW91i9U5lILqaZTTStTT8I9FUVb30rKZoNBERJxs
j3zMhRKLqB/1OFYv1cErLM8wyb/oCiTUoy7TDdpEgmic/4lFy7LpjoZYrxtVMbfXAKZFRxfk
U01+W6JzEMwf/TzsrRMZMIfVU6NrYAny7PXNmOYK4teyXI4wTmt3rsUNk6b/dUa9LzD3QpEG
S/JkjHiU5XThYL7M4+ljyY6CY4Yk2Gb3MPrSx0ozSIM2/Z1mbJglqZ+vcS2N9loQEdjw9Pfx
9e351UUfVOvz2fn16WjUh1uYq0h7lrspPYb4w2WXrV6mIm67dCC1DX7V//dopeByj68VHJcW
c1KQ1V+eji7Ho8F/+iq+kroZNNteMb9/83A/6NeVSPKx1vC81xp8fnk6uGmskuRnpeFxnYac
NIqkXjNqsw5PN+UFzHpNbna6kq3Oow0XsAtbcxDp18qGQ1sKlCiDRhVPyB/zRVA2YBESMjlo
MF45r1nMWtlx1vcDzkEbEX4Q92l7R+Yt2nqD1fDgie29i8e5KH91wwIdyXVbM03bUfYqTE33
aGeYkKu6qhja3Jdcj3FTs3SSpB2fLhthQQkeKSAVyxlNblDqQedWrl9V+r3Wsy3aB5UXI1fH
ZCSHDvqIiINcudoD4xKBvlbMc+VdrSZl6L+UtIsGf22QSFBAh7az+jcgn4ObT2xw26q23O7/
tcbiXPJGyTAGt+NXBHSDUGTiQqeFWKmQgmQlTf9U3pVaixoW3zwuG8GBOaIataQiYkfIqFjr
H+gSEdE77QuC+lDLNXaKJeeZPlxgAequT+pNDjfrh5H1CtnQGmTtMLLtyQ3pA8jGts3GYWRE
Hn4Y2dxGNg8i65pJ2y6HkK1tZKtC5m8g69x9Rw/a28j2YZuxerzDG842snMY2bIc7zCyu43s
HkZ2dOJFh5C9bWTvsJ/BCd5hM9d2pop2ENvQLOsdVvPdacgPY+s6peIHsfUdbP2gtw3jXTOR
70xFfnguGpZtviN+8J3JyA/PRsORd+IOYu9MR24dxnY97mwGX27vib5YSHVzS9bZI0vr1ras
u0+WG3RpaEPW2ydLN2M2ZfV9qwVdKd7C1fleWZeugm3I6vtksZhvLVi6sU/WcujmXrv9MBj2
7+lHJQGIaU8uIaTPexKA93T5qNOuGp7pfY3hyEMYeX146Ocy030Yna9+Q8JCJA7gBCgrqHCZ
Bo95ltIJzRrDNQ1Ex3NQ40le5YdVSpFk2ZwdFU8xHS3R9XFBKY9MRsDtjOqSMjvLptlwcDdi
R8n8j56DUs9dnzWZlqZR5jOPwzHYT7e5h9OVvJTNsPbPFkiijfXZuGnpjiPvcS3S8o1NMnnt
qNkjQxosATd3yEwLq7dXQ8nfwfy3eI5NrZkR95OpYfVTl0LGxvM+m/jp05q+WK5FG41Suv5l
kNSSx5UtOSxEQ8JIu0Zb63uOiWh67RdldR+CxQ/XZ2uLzaszMlQfyjeT3la6tiYviSu64SHd
E8Y/bUBUN1ZGcwxMMOMvOsMgi8t4KrP+Lvu4QFrc/MQpF2V1BXitrruauaXePDzrrNM83I/O
MA4U2DiRHqFy+qlC8xMdSXDX6KZsH2FQlowQxkYlEfiz5dwv0MAviwSWqbfVTdsyLPplGn/4
2G3Oeqq5OZvHSX1z7e6032Y3mWKSLCalNRBSYQB9zIUgS+ls2E9AzlNpSFHnHnCyebXScTRn
zxnk9q5RgMx0XO9T/V17sW2ro73oobd/08h0DJd+AUFTPxR+KK9il/JG21ZibDrwnKmcM2M8
al2m/oqNVX9lNnS32i07uvSL7yJBfn4U+bM4Wco7cicyb0josxGcMCQoczpwo2dzPWsc26Dr
BHcilyfmaSBYn5Kagn51wu6Gn+tLeicy9//uo2KZ9BTo/2TZVnAcmn3/R9u1NreNY9m/gpn5
0PaMJRMg+NKut9axk7SrY0cVJd29lUqpKImyOdYrouQkXfPj954LkoBEWnamJ9NTiSLhHoJ4
XNw3mjapwQGjlI7iSBMPQPRd5X3ocV92voL+SF0j8tm3Rhy4jr0Eobc0aj3xAqk4mPbtihQr
Wp4TZKWwqYp0Xkvi+1AbsN/ldxo7iCPrMoetVzvYGwEIPds88KWxG3TL4NK/lWbBUuX+W81c
YZI3oUx79n/bQktusZeNI51sHEX/sG/eyMepEKAWN1TE+jkBiQGcnPm4e7jRtsU9LCv3cDae
OO7hgGQBaWdsuYWhh54heYBOyqiKujVp4onv7Irr9CuSrXhxrWjejNNY2fZKITSqs/c/53fO
bvkXLzE6QTbFNt9kPfu778E8tU+/i+FHCIwUnJazycQVbBRieS/Ev2wbzckYAqZ+9LW1TaAR
9H34WaFEf14vl5MTGIrpW8X9HqcF8TNw1GzyFxc09JHX0Ab6yBMiHzpYPcLGG7+cCmVN8oVI
IYyy8fAoYvkiruWLencEyg+h3E6yh818NaV5yavFbHdsoEKJIIXb8fKhV4fLzlOaUmZONLi+
r+pgxUDrJNF7xp3/QECKp2UUB8Zr4Rh5aEY8PG66paOtXRixzsSOOjGyya4sEug4wdwTv6VT
FM60dbYzFPUvxXZkPKU1KUlYMAPevHzfE+9qwxInCC7Hy5kwHN4x3QZBnCAa+eXV4JzDqprm
qICkFeiVX5br+8/bbIvIHmQ3ddbLUW7kniKblfmHtMPHcNplXyEDgPfWJwOxcVoFNWqoAqwb
2uoY2Cqz7xZRcAtiE7N0QoNkWxN7qvNC0E8WtRC+1NLhMPYRc4KI7NUdsQkO+fqZ5IE+oqxA
dEGyx3pJJ/NaXJow8nIl9UBvgRISLT6BosdkyAZ1DIldEg6NKpZusFwmAQJEkTOHLtpTPIi8
uMYxFrjdiDN+GcnsEXFk1HPsm4o8UorN6+P1t9Vm0jOLdLUdfp5lC8dZ4dn2mo/l21W+7Ewj
Gccknt/Q66ckgpEIcF+GfJleG8ebyhzqAEfi91Brh5r+q9Nfzjmwafh2cHVESumW9sEl0x7b
5rG0scROcyufNCm0zSpyKFBUYDi46ONYyhaYoMIhgofi4GPOb29pJcGD0Hii7wVx2ELMhRA6
lyQ7dX7NJ9nSoZDsUHmE4k22WD4sOze/dn6+vL7qnG8nuUNLIp9fv580a/f8+o3hIwXteV4b
UxLRadmNP29zbHAOalqmE7sJoiBRNmIRkt+a9LxNU3CMQqR4VQ2PasVn4ImBLwbBsdNQezWi
WcZlWCIWLtbGer1d1VYKSycDnJnO6r9bYous88ltRqIvycpfSm8gsP8LLl1SqektSQpBvn4m
/roa52eL5Xhd/JXfdZ2hk7QkR1vnOUZaKnMCSzu2Eq/7L9kVOmK3g4c8GOHVIn8sTVREmS9C
m/wdHWOQBdG5j/QFreYjkuZT2KjB7T+a6NPOdGqTOmJJSqVvWI7o3/S9c8/veSR/07Rf9ARx
jXpcPw6yWwizxSdLHCjE0DaIp2k+Q2+JFYrr64u3N6+uXrvRqSdI9/5pU7IL4rkbeFQm/Ba7
DKYg1osCFBP4UuAtN4NfC7WxkgFWXc0yBzMahI+QyRvsNSZ25CeNtrq9rc8uib22QXtb2BQa
bcP2tnTSNvsQtbeN5M5xYNrG7W1pMuJG2+SRtkHYHDN2rrc0TgL4nvcby9bGxHF08+0g9rQ1
pqnzm43b586nuWvpRvvkQdFp6Ub77Pk6iZozLdunzw9Y6thv3D5/fhhU28Nt3D6BfhTAxrTf
uH0G/dYZVO0z6CdB0BwN1T6D2tjL9xu3z6AmSb45Kap9BjUt/eYKVe0zqP22haTaZ1Br2lTN
xu0zqIM2JqDaZ5CkKNWcbtU+gzoKvOYMqvYZJI26Zbr99hnUSRvT8NtnkEV8PrV2jitix4b/
E4O2IhepAgp8g46pofNzj8OGS7naaB/iY74UpeCE9M3xNCqPQHseBEp73wc2MVH+UGEaYH6M
lfQcsLbyEKN2UGI50feA7uQijKbtoKH2kueB2iPYUpOcYbpUU3peF7m4yNHoSYUOm3wSj9TB
lBMrEZTlzGJIylu8hyEtRsS+hRYM6WIY4XsPQ1oM2YaByEqLQTI4tkATg9YpD2avmvkxyWQd
/ssZiiiS4K5N8hlJuONv4urypYDgeF8BSgvoySnPvJxGDmAc+vtjexhQW0B/GjpIJtbiO5Bi
p2uR6VrkdC2mAfg+wLHTtcjpGp2NOAz2kPx64iSO1Obkx+4Cot3WMnGEUXahenBotlfoT2Ga
SPO5CYzpX139rlkUtYhhHCfPQIwMYuS1IQ6u67CaOPGU3F+fitc4bRHdkywrNV7T39knpE01
1jhjOMvJ7PvpxO77SWlkIT3ELtaEtEe5P2QuVmyxiHE4PMRzs90T6SfqAIzvuTCZhclauiRp
zPdfz3dYiedlLUOk3CFKEHe2P29++xBlo7Htz24Sf6KUanAkF0Y7nMAznMB3yH3tNybbf2xU
YtuLUcuo+JHC0tjB0nZUVJCOWkYldvdHQjKUvz8q+rFRmUo72fTR6YqmVSNbTgrSdG4+XJ+X
BQ/q5kGgfe2qeFe1rkoa+b34+Obml3PS8hCiJALxd+kJaf3lSRAp33uC/MUB8kSq8AnyC0tO
1H93yUPpxf4T5JcHyFXwJPmgIv97YgkjP9H7jJU31MNtmq5HvapUmUhJm8QJ/evr89I0ZDFC
meyz1B0MSwMlF5WKJtmYo53z5T9oIZwsvyzqz2zCPVssrSsyIe6v99fTzgNKqW1s7H1itSyK
3PEcJqTMQv6rmu/aUBI4mJAQtyqGxgrLBpx+f4DYOZgMu0K2yI5JDCndpRtU7i+mCbp+NxQd
J1KVuEXQoT8i8W45Wc6mS/E6RyTvJhf/fVt++l/Okurmm/+pn0NcD97B/vu+MXBXVoa2PhF7
RKmLl5fnF+L6goYeJmjiBV27T2jCYejiJpcvX3x43RPZJB0P5+Nh8a2YFuyc7FUTNh+L8TpL
68gHEpRopeJceNWnaZ2ni/Q2W4vpOp1nsB07rSLsXscexEYuGJEQwbJjPqLmtPV1ZTzFjjdh
9/CEcqXIygIaajcEFHTKQ9WYqgIaZ49w9cbRdjqljj1ZCIwxuJjIUxhOpcK6QqHFiDhU4cVs
m21on9yV8agwOquuUrYdqRzR07b7qiYKKBIOPneQf67zedlMVsamGA+JmY6GS0WiiIuOmzgF
QlQ3SKR5jCz0IMs5ZG/UxXn/GYRR7D/DSxFbAqibTxMor6agfYGiCZPxZET8yfyFQnyzmRiw
y6QQ1zwiHGnPNc9KR8BR5VMKumHX6/hddWxRQy4YtONMMvG51Btag84P1s1aUatQhljIv5l8
A4S6b2cTjlOotqvg6o3sJjPZlzD40r8Li6G5uMWrQecC2wBFayzHwu9BDFvHakHqbX/RNzsL
c2BbkHqtuYUoT032imC59BEcxBRmDZ2Q9FywRXKEXAj24WXHFinhIgkVknwWEk1MEylC9KlF
Us9Cmso2pMiIyyUSpPfJPBXqk22RcCa/0+IZz4ra3h9GyNAi6Wch6VYkkk+ckQyehRR4sgUp
VPAJV0jhv49EIhbMijsrqVfWNYx2iwZw6wStqSF8ZL2qNmm9MH1fa1jsdrYOl0xazff9sK1e
2D0frPJI4ffYe7oo7EMiqYM2C0JlONBPml+AEmvdajGpUIIn7S5ASdiZ/ThK+GyDC6FpKdVB
tOjZlhag+QEE4if5qSUI2bi7Ga+GSE/KFkOIGShQNWQnd5unWwXW1S1PhFQqjndc3cCFpPRJ
vL/oi4wDG/MCrLQNjqP2Kjx4zlF3ch8v8HwcFMAb0Ts/DYQU3NhTqomkpG96RqdhjVLUfhVE
MrhdNkGFeCY+OTh+iFyOD5f9JweJXkohELHRFZ0gJoUgOm/yTXuM47NwQpbonwwOsARJgEP0
Xf9ihwBJ4hPx4ebq9+qo39BhVbDgOWc3b7eGCD1OHNyH2E5Wh4hk3PZcWn2HiFQMC2wb0c2r
wYPuokbL+H58R2dsNjsEpMMWOxDOyaur3/2eTa/pk4qL8MR32SwjAcIChFy1uGmJfJMj9hBh
uPka0REk0p5CJeO+kDhpGVkIL3xbH85NHA37Xgfn4pKUXXqhWw7OSDkswwGJIz7pGsoRe6sr
OZFDD4u7lBgEDde7t9e7hWqdGteTHbnWj5CmVMrlF28GKPxlCqyXkcAkkdu2KuHqfQvEXHHG
KIkkpBhMizqyLuwi5h1u8yr6kttM6phLOiWV90vdONYRzBG0GYbFw7zHclQ6nwgkAH+7rUr3
oGEQQP++N404TI9VsZ2gXLSjaaenX5NchShLLiRLffgnR2835VhQJBHK7aQ4wjg0pK7e11VI
uLo1pjNxtBtjQj/LMB0f1ziJlDCvMk4VoUjq4Xn/GtmfeDHECBbpNLNjlcBH+EkMkb063C6K
LCMxsAw8XWSIk0VdjjJPtuCXRTFBp/eEEP+YuFWAk9ITliEry/nteoiYM3GkvWOTBXjLmiN9
xdGTSAaE/hCBjZlyBLNsWk+N9hRHsTXQ4sNosir6v4emPa7ItMoXQ4gjHZpfXB3Q63Q6YsB1
RZdTDpIj4RGZxJ9o4XxZ57jUYFhsMIxnJHbQMyfONx5L6kMOg3hIZ2ehh/keLYvsTNL+In2R
RJf6V59abzf0j7MAP25o9y2GRTYGznKxnE5t0+qLu+VsQn/bQdZexGGzzRcRFxgQ7KHym2HZ
AU6ktPSJL1sHooXe9LZBj7TWFvq2x5oCTHYBIpUQbopDj8fXwwrMTMFuF6SM4Rk81AWn580u
+Bxy8Oe6oEMwohaMx0ib3QgS/cREPt2NyA//bDfiMGqH+I5uJJzj8We6oaRG5bNnd4M15N1e
KBOm+6d6ob24fXE/8vB9hEQlIXSiZzBY5yeW4YjJjvxTLq3/KIslLZYz1v/z/FuyjS6BHnng
eDlwujBA4j2zlobhn8PlguaDpBjU0kjw7uGB7qGm6Q8aWsBrzSbHHzC0PqxtLDVUCwi/Dkck
sC4gt05NGOx6vBXG2FqvP7HeLhb11SAMlCjskzagt0gTMd+bgyxFsByC6/9SkyOlM/xP9MNH
/Yd/sx9R14sCBavzgaXmH1hqDMDhvj9gtgg8DrkGJ1YmioSgKgC6T3t9vuKqf2cqYdMEr64z
GYnRFjpR+e8aSErN9pQ/RtvJjp/B/MY5DT+g8AzQFSx1P2h84IBA10nFsmoXCw53mchpGrNi
OYPse599Y+egJTQVmH8pv99pvOe+4OYqhqziNi89/C2NSTJBNKa1kt5km2khfhrn0+Inh8Ak
pLDAf2uJkwCca4q4U65gcFQ6e8rby1R0XLcNZICQlWSFEFuuEYN3f0joYckKlhgxzUn8Ke8B
czUOpiYNpkVIDpPDYi3uPtgTawlNBRGbl5/0Hxizuoy7irQOUAw2PGNFNptyRouJMc7qBUot
lQyR1vD1j+EkG3M3e6XevLOU0VLFnOHktuRjO6ONX6qc7J7lFfXT/J7+4bYWY6F0LLyf2GbJ
B7Tofv2Dx7GAjb26cI0fFvJlDgdYR3SAdRgA+A9/xMYjdF9xxCAi6Yf5Jo5Y/3RcpNxGJ4gY
Ga8+c0jaxXK+Sj9/R7JC0rXz6YcB5jMfzQmLuMzVi+vvQAotTuwhnbK4W405TK68Ke07sHSN
FXhK2QC9IfWthw4O6y/4dGFL8Jd0dj/kCoQcrYzoZ2eqAlPk2WSLbrJxxUTtagj8EFGGi4d8
kqfT0dAknw3en797b9toHqJfr87F63W6usvHBXvEb8tA6Yu7fAWHInstSyef6mqr/tecAmCk
YcJ5PJ9NR71HmsQR103oX1+JOSLab2G/W0xmMNRVPMVPuspSJLwk89U8r/YLq4LT1Fk1oal0
iEbDIu8ZfOPYMg5+tC6TLy2Rkjhoa6IPHCLPNYVht0wX3xoQR6X5kMl9Nosb8iKfVk8dXL06
8EzipmH5/r/VSZrl1Q37NhUmMGOaL1ZbWhf95Rdq94I0OBqmtBCnpd/h9M3N74P/G7y/7nke
Pvd/e/fiBp+Zzvxp92GYRMAsYyBcyI9E+OpT3TCSfONJ7aGz6SH9WbpB3L2x4ZXlz6r70lCQ
esN2GjO1zppEFAVy8JeLIkfwvclILnMzp+vsc+2yp0leim+4NdIUMnQwIr6o5wec33E3RDEk
XHVFp3Y664mYNuypDIPAq1N3teDEBVNtu7hL18aC6fh3gKMSVmFL9xUX74KwhzpD3ld/Gosj
XAJwJvQJpzgNR+l2Qv+UEgmgx7BzpYKfe15DhqbCQOnHAqS0kMpC+s+HpMUFk+gll417T/yG
WFmZsM+eLdsQRT6J2ywX31Y54jdoc9BqIDYxn/OuQS9aWCDcol2L4ifsZ1kuOg9LJLPP6qu1
JjWBb5vr2Aj0xV0+SkuTpnO76Xvzg5ilJC+sLFnI+3pVLdHVmJSj8OsQ5w7MvTfpZpARNym/
F6/7V2+rDl+1MK0wiiJ9CLA+xfYHLeE77xbFmJu2ckRqFCO4eZPNxsTubdYQrpKb8mWF8/Fq
NMMFN+Luix1LokKQws/p4pZNsz2jb3M6UfVdmRqPU1GKo00OA24BB0+Z1Ywa0umaNBN8Hdbf
HjtPCcLkeZI4hJXhZD0fzue8p2i/+RG220g/vtsQUIQMVybrifeZKdt3+e7a3E2EMA1EaRyV
tc5Mw+MTg1j2BGLOGZcuH42TLDCOURpGPsGKs1gmir/DvYrZmVSxfXwSIbm3enx+uxkWKcoc
m9HriOX9X+rGiRfh5EYjU0/xqRtNUfWTVkcgVU+gDKNFUh68fI8iqSZSCCS4d3ssClsoyEsH
oMImVGqhdnulWaN4FCptQmWP9SqUB18wa0AhtLF1qKIA54VF4kubjNPyxGgFNJgxE/Enpgwj
vj4KxrvfIDGjPMB7Q0h8jE4PTyDz/fQaOrl3itqsr0i6wkVNoKclgrIGHDmwT+8jeS+Wh+kT
kh5xQUILvU7imNjCE/Sqm7AS/CNEcYOuJeLuP9LS/wQ30e1qWxcMRrxhGcvoFu80dDF7mQzd
lZVXxMMtyUkS4XMoKEj/l4q1yaoacckgEXmF0tbCdoV0qbiGHFRpgQ+jWbq4t7aFSi0lVe5B
KHGkZFd6XXqOf2x7p3wPrkoDVXL0OtGQdJ1xTjpsA/nzNlt/c0BCFcatr3g/L+wrkk4g9cFX
lDWk78XMOkbztJgbPeR8cA0hgymc5N59x5jn6JMGChfQEMvazuffOjnqetPpA0nkligXXNEw
QxWOsxtLEkYQjvt0LJBaXd5XfllKM9WjFqw6nRgN/+0vNbFGWNsn8XoLXXRFjZeLlO8ccBPw
oZrmSCo1QTOWWHMN7l+vq6Shcogci8MRFJyzh/k4x1n0z+X6TOIiBAzgWWDCbw1UGEh/dz4Y
0elS3TbwOcp7vpmg7HoPH6onH9Fn+niGp54utvNRtj4W823BVwRjqcxyZ7ADEpZi9+C/+1bM
01VnOkuLu26ZkVqFuqX53IafOHfexfZsiJxYSPOAmO8+K2Z8naCpk4QSHnzLyBzpyYVdmHEU
gqNkhldy8Zqjd8ei/+7tKRfZvsk2MMtVi6izc8O8kp37uHNzblIpDB6ty6jG2y0Ti5t5O1wr
ti6SQ7vIFpwh7talGUl84/F+JIa7Kp4JKZVr3xlS3ZXKZBbxs3dC8UW2uaPeHMGN7vvXP//R
81VnlG+ORaB6gUYzOiR83TM3oRswFQSHwB4fqos6INSCaR/nBoNlzxpmGtxu2Lm3CAGbMCqE
emCrcSUS4h/BoyMLiEgFfKyPnB68zm9TFO9+ubkDp948PuFBV3c9t0cxibAlXKMccIT7GfSh
3vgkkuA4/3o7ckeEBNKqS1gCL7+yNelQr+ROr8qr+krY1vUnH19/AKBtHv0ARdCAk45MiyqP
SVbrISyQ/hicKlfJ+VgGcPZ+eXF5UoZg9q7ffvhkakGE3glOYcG3vZ1IVUNrWv5wpZGOueyZ
JwiCECaHv0Fq6ZRCcYgduvMPvz9GVz9QxX7IF2k/8C3rF1WFvpIp9ox1waNNt2NeoL1cWhJO
R/xVaUc4trhJDMWoMk5coEpZeo+4Xcc0UXHP09W4WN3/P3XXwts2kqT/Ss8OMLEBUyKbb+E8
e17byXgndry2M5nDIBAoibY5kURFlPy4w91vv/qqm+yWZEvKngLcCjOOKFYVu5v9qK6u+mpq
mySaqkmaihCyu76EHqYF84wZrTmklEbeSrmAWhY25Tq6ETfwKFIY48CNlDC/90rY8F4sKTdt
m9t5wYRiWpQ0XCgthewzewMxb8w9ikwhrE+K4inoViPbVVFFrV2f/41++wUrmdWx+F3GyHDR
gKs0HdN3kSNjU1ORhrS+2nXjuQvVNG3ou6kHWC+qoUOLEbqYM8Tw7IhsQPttHBPj3GE+riak
V902yyaxem6MZZMeoNj7mUPf2WWMPcOEYnlmo0FPu4opTuWKoqcOKFee81hMc3FCg5le1VjP
LbURv2U4wwTeO49e99Yd8FjeM3UJvRBKU0bLe16NkAyqsSEo24GxePxgmCRjjhsmy0pXL/x7
03x26HjpfsMWMOTVZ20jQJWPlZUBTzAGMn1YgB+LMb2BmWk+0pk47YIddlIgH4W2DZ8fdwwp
4N+XSYMXSWOkrl4ipefUpIbOY7yVRTpE7awQBgw8tUCY0EoT1kZsfGUPXUzMtYGE2s1IoO1d
tCKBtnxPWoK+Wi8k4T38ghDftBZ/XysgQdLeZQHSEiA3CVApLpcbIqol0Lf1/L5E3Eg1uO/D
tJb3cTp8UtwVAA5bnhpesiwrKQEbdbWUBaXjsiDdLBcfKlJex4YhjDDWHnvVoCM+FeNeSVr8
p8R/H3pPJ+L6pH1+fkyLKE0WxavPjF3szpWIbR6Z+OyghTI6k+Hsllbt6xME1zQqNrYSH97W
Y+0+H07M80JX5b2lkYfMhw7ni7P2EjgNGw+Q4z5XAGvYpyg4vsrI8N3wZaVhNUVe0ev2G2uW
F0RQGjL5qs5AQ5+3jnr6ekMbAJ2+4Y14zIBLWx8wNAEuLAoJYnkyfYNxhuDBN7Qd6Wc4ccW5
MZYN8KvZotkAtcxzQ46Pr5/7MBl87wfSXiTESU/eRea3Dm3xTrHznNLqjH5ypBB4Tha6C20X
4tC3uS5K7mDVgWDwXfaw4IJOM1snD6XH6CEcR3fy4dPF+w9HJ4Dk+9lQSA9ZM5iiGOFUiQ+a
sc3riKdhMX7q3k7usu5tMR3B27XVUyFAitmPoW2zHfjs4uxGvD06e//DD+Z+lGBLMKKh2DXo
c2Z9AY4vfBkUAQ3xVQLSkxYlWN12nD8yqB0fhpRA5hQQYphTxrjfmpkWyYaX1mIM8rspLfzz
aoVTDzP0AOrvhkt6sBhs4LrrOXVzGk6fU0Ru4GRFwgxJP/ABYbaJqbwzHKrDb+QoJzjqNmxq
Zd3A9sDw0KXpt37MGVg3Nsfk/tnwJCl0oLtel39/lWlSlIYnTaG2buKpJkXDEriMjZg9FRW9
jNvSVB1WIzXajS1BwEe3ztqDoyEXOiY7FSz9ah6g/EyyiqaMxxGtLEf0zY4VfPfx7GTxwEjx
UW1cm28LllhCmUFHzoZdpZgRX4ntrtJaVWxgv7xjYG+x9x/lXEcNAnQQM5fSq95UCnjRaapu
hmKQMnr6IB8OUbBuhr0UTUQKtfrT+Zkq3mLRAO7NiET5VLcCfRPvle6Ic1QHjKdPNHGZbh16
7DZgmOgppNGSxtxon+BqVtcDa77G+zOCSAvST78f3HYELa0k507baBsH/qU8vYo1YLzk2/mf
xayaN42qe4mLkM5FCD3b3Aj+SCKoYVQVqgo3AEsb6ZCAQZlXwFu7zx5oqs0LvChxfn3m3Jcz
2mlg/ZhykAmPd3o/DE+LShv5iQftjQqF06umfByWl3NzLvbohjFyGVkEjTfsltkXIoUBvTmX
3kVXiZEY/LM4O7mBgcM55YNL3lMRMcfJqmh6ve7Klhk2qXImHEzLSXdU0mKATEwLWMT1VgYk
QpNga197wygxvpRbRAbLyHDQbEUvjKTno45lSPYNReSBgk0kQKXA3m1q3U18XyWks2GsORMl
ZhCrb5HyjjNhfHjzWNtY1eGZTZgyQvT3OMoIWhGNTNTnadZVYMn6GAMXyJULw7TjWlNa5KZs
azi7/O36xVatxN7N8eUBAswOxPXxDf09vb5sukUESJio5jcWRDsOzY6KQ1D+oTqvUmfdh778
1YSiKZG+jzBdJfKU6m+HqitI1XGeD5D6rA7hyAB3n1UzIyNxYUtWMorJQ2U7BCmK1MVpv6L4
Yzr9bPKsWUuNoZcuJ6XQ9MP+RnqPMxVr+ttyIz2py76R39viCYBGX+DYXImQ83pplsH9RvqI
kzlr+mozfZyaV/fH+OtGeuVJruhvZ5Pab6txfEFyWfoXOaYPhWxMZBFtZIPAFKyYIGf2i4/w
YT+GZ1IBP8zLh4B3VeeX769FyU4O+Gk2R9wf+64saOkRaWOSC0hEmrzK+2vo04BTytiT2+9v
r84xBw1xGKCCIht6xBFwA0MqE+p5Y0kuoOGTLcIzzcCOJKMoakBRcaWzw/DMQdWJDGEo4dc0
KiYRFIwetgoLBEkUutvgRsc2B+xPXzCn59P2POhIpCyN1rquRqRXLrmuKmFxCuVp4+PDhiOV
fGqhFyRSy/NH7Xy76A6siMM42qJlU8OAQLTP4ncZasgXoKUos2SrsYnGriuxu1+OOJ0CcODF
8FLFJdn68SLXxgBVlgDXabm5OoFnOGIfB0bDvN8ZZuO8qyRqcw392uqvYK0rPlqPaakZytmk
BsCRwJrB/qt2D/vNUgNiZOpJNQMGI5OfXdKU3s8mFefzKMfNyN/D7Qd/37D7bvM8PZq0jHps
LbhCKp6A02/oR0abnskoM9T1X3h4xCDd1KxBR5ycHuPEiROEoAPQjr8lWyF1VVotj/m8hgF7
/Pp4WdFfTkvEi4qbPBsZwWmAcx9F0mmG6UrCmvIWDiE6fqA6EFIvm40g3/PRuhuHiemivoq7
3egTHhqOIIWykLjS+9rBPy3vH+K390cXtasCXNYSQ56y+//JMeLkjxqQ/+Nj2lJI1iucYfEl
N60cBD7G4qyY9G2GBnVFwt/AIg8ZIGBjBUwXDOIE9lz1gGsVksWpf6nNh9r3HC4fDUPIMICb
h5NvOKib+vD65/dpOf6nl+zzb/n5K/ogjLbxzI8NB/wyrWiHwbh6LTpC0VMnkxZ9P5/cv0iX
hjAGDoseKJqleI/08XZZ6SLRPNuWgXkHpCJgVPayGenG3Wzw0BF/ax21blrn9PeiJegX6MwD
9hJpBWKPd7SzgpYZGCQbnTzcX9rUkD6dAJAVqu+DcuzuiA90IR501kv1Iy/C2SwjofeGN04Q
kjCaDKvuXUV7Wl7v311/WGn+KGXjCbsLignwK9h5r7mfxj40lJx0hpfuJl6TGcp4TPOhCFI7
1X4WU+ptTtg0Gu1Cme3qiHXmKeL9mfcUe1nASAyHK4HlLcMdJKnO/6qSZ57ohC+1/5jYc61n
0Z4gtah/O726Pvtw0REuduSuFxjKmB3V3P/jx8hLOBvv/yd5tjUn8SQHVinHF0yw55fKjZm9
VhDFGJpGp9k1WCCuc5v+6DZjCXH1gcUSelBDZtqPE9vsM5VYtfXyx3BGbELV1PSI5fsxgzFz
6p/GmP0jHFdWGs1LGOJPPwG9pMOeO5zkhqUXA7AZhjT2kiWGE9J1aaQ+ixuaPzrm+DWRbqLz
BBvi9zfXovksEJPG4K2W2sPjPZzIeYZUpjonci1XcGoL4lPwGPVWUKVNiQ1jIEN/mfGSXmqT
Jwo4glaZwiCIlunrdm9iVuySKdV2uRLyhaaXcQRL6aLsbNortEV/odllovMCEiUD3VkV5cmh
Y0hpTkrq9I/CNTd8l+cqpICBKbN2wz8QOfTgA3Ff3N2TTrbnuvtw2L/aw7/X/LfuEgfiRN0+
t+cQUvSSWrB30HgyrQiWckVwnU+JBcsVwUGEswwWLNcI9ldLvCDYWxEcxfDUY8H+TpsiYTd8
FhzsUjAOkAMtONypYN9nIxYERzsVHJpeEe9UcBwHteBkl4LhOFB3t9Tubpwr0erH3jf24xAO
1lpwttMSBy6iBFlwb6eCVVwIC+6vG9IbmmJl5NFy49f9eLDLEkcuQwyz4HyngiWvpiz4dqeC
gyTUTeHtdD5GqJKehDxvp4JTv542PblLwbEXhXoS8nY6H9Mm063beKfzMW2HPD3yvJ3Ox3HM
4dIseKfzcZyGTVPsdD5O4KH8mdUS2t0gvfEoYweFqmPRqFjOq3+oDOIdaW7R+HL5lkoA3jHa
FKksOFunWyrHdse3bkXws6VbKkV2x2xUaK2EzYRuqQzXndC6lYTqlsoY34nMrdAH3jTdUinf
O7F1Kw1VMVTO9k5ibkWhpwSqpOud1NyKXbg6oV66zsb8Sjf5PAg361pb1U74IBE3pb5pNRd9
9E3dKJ7VKmldHJ05vGNt4FIAq6ibumGMUZRuxpY2uvYjBuXYmBSTVHLknk7qdXkmLkrn+p42
0f35bMFakrpeCHMb2/y7Oo1onaBap6beI8IoAlwb1eRAqMykEa0yzs+4BTx1SdtbGsoO8vrF
1Av2jfw0XMySw9g6CmWnsSQ01MB4RsBCdpd3y8cxvBWrhdhUReWnSFrUWEdm03kFq9CqgSRF
F7cNL/mY0RleJqaCB3ye8xB1xNHJyRVSdO1dnN6cnP7W/Xi539H++MpyWekz2mzwbCSk7D6i
rW3ZYIBmZGsbpyn75RPcerD9oFprSwNENvyBF0UmpAG3xAVtGN7rB36csHODOO9NKpXV+WRO
e6SnA/F2WD7WbnYdcfV7IzGMY3Va8VKdjn85unh3ulivXt4vR3m1VLEYtmMcTYy5Sie/HF8S
xdc540u0DpqIGyJNU8/lAyvnmE8RO+IdtRNzZOPqkSHEyxFVpOW2ZIuWrNEzWop97xHdqX6v
h0HYogqnPBkZgUBVGOazeoMFGlqsVH5VoRv2EHWiGfQRsg9Xgi8ORDHhO83zDhi29lCGYav+
n/jvHmsKaR7ms/2PPwjiOXwYOcMvE+e+enSCfOI5X+fZeJYNnYLGiSOxxnG+ucMDMS4qR1/s
Afl+3wgNGbmeP/BnYmzypnjUTNPXfoQZ7XBBTl04Bl9gFrfm8RtC2r/7iyjh13UALqBDaiOI
oU+8YBH3/G0xVmCpL9JHaYIlqEZ/nI/5IEmfbisftxoK0k+D5NeGMY1SzPocecgWTOypSUJ9
MI4k4yppYDZwkHiajYkdQZNU4n4xYkjFh8VuPhZtNu9llTLz6TiKmpDagdP11cf76hRlPrYD
xObqJj+S5sP6DBuX+0ZOwivjOuCj1+FLtAQv/B7IRxAu3cR/xXF0WTjSdXen4wFCoPttePK/
LtWjqW47XDDYirvUUbq9YpxNn0k4zUxA7op7yavy/RBYkZ95mKE3U+PH3vozyaiGJbbOJMNW
kMgAhy2jL4NiCikbTjajGkJ4QUrk+pw2qJ/NICNeLyOIVk9HSYYfeZwzafg8Kueze3So2F8v
yYtW6xS1vMRPYFZSPXbELi4DB71CcHpL3T/EHmkD+zRupiNq+VntVoc1eF7Viy+kxQHcXNZh
xPnpmg6sRMCNdZd9jKQizi/4Xn0M8kkD3Q4ejktNc8LduMsviB4QyvWl9xnD3Ujn10Qiv2mK
ef8rYKs/XN9cHJ2fio3LzfnR8Wq44UE9gQZU45br0AQdJc5dlgwGmRcJThUP0BChfb45MKjN
yB91XWLYx1nz0jMxrf4q8T0pAD/YVBhq6jpGr4iwcrSp0Px/Ne236QW1p/MxKmLT4dSruU4j
X27okGGypkMqEeF2XWfrDgmpMec//D4dkuUzpOD36JBxK6EZDHbrOb3ewR9IOGNBbzQqeRw2
9FhWqTRXp9cf3990rz58uDlsUzPPh7M2kMaK2XPbd92qva5btusL+BrojkoaheN5jpu2+nf/
2ebfUEvle+b0XbrpBaTMRO27ft+J27qnhnnfD26zvuwFHr3fMPB92sS4uewnaZSHvtf27KIj
cL2+Js1UIuHHn2XvkHsifanatb/TYG0NaGDV1XVQXWdTjZxty8t8VNfQIQ0rSZ27+17/2XO8
1nM2GtpFh1bUXNMejJdzGkNUC/GvVh0qPpQudQ2MMpoy1qNGemG4ZqwzPBvnr9nlWIfUUG65
pP0TYx3yY465+R5jPW3JwJXQKNeu6XJNs7II390OU+9bldK05cO74xtmum3eGUkNwwWNfrfv
LG0FgdqRtufVlBeyR3qCcL4KxxmWJN3Jx/0S++TDjzdvnYR+nuaz6bMDn9gpoFgBB+88ZsWM
f1d7esdREbh8cT+bTTpt2raMO4nb/h+M7f5d4eBZGNE0zhEe5GSTCW3InYds+lf6qYvf/lXm
tZ9QYKig+aEGoBXOB6VyjOfDod3UkdYlJLIu0NKIXR23+J4PH5Q1ejO8wZf0ZgihqVT5FGVT
iJkjQ11H2HdhUa+vpRe5abRwnWLLc/jaxxDGnLDh09HVxdnFuw6iAQeMNs1wPypUVxEmISyP
LytmP3righSsWQZfuYHhSUPo/s5rn4ZQ0jbfNZ6dXke2vSCGqeVWb801hBm9QxdoHw5/4Rw9
PAIyVWba3Q+Hqg4IlMhN8aXkONi9yQwA9/ti76e9n0hvdH5mkE9GGd53fp7yv/8Fa+V/H4hs
hvAgDqdmqGiiB5RzqJCijWjs2z4LyUWo1NN7z8uV6Rj6MIZnpPgRGBxNefYev3b7ymZEys3+
Xxjur/rLQmH0vGXjVgcDl4qTS6s4cYSdCL2TRfFEbz9AVx84ZvMJS9v/Uf4TT0uTILQ6nr5W
XRzz9Wya9XNTeZqncaR5fPkRcN6XcDLCmz4uAQ5mNZndn17tdEaqnyB87xOxf53ncxopqvmW
X59hiDhm75imWUTwL5QwdnHkAPifSbOIDRCX6nmZRcVxZIIRs7ocjtEdl9yPqi4PHQRWBEAV
l33TXD6SVhHbF5BwgwK/LZE2RQIdSvxVDEpaER67jII9H0MyImRvMfXL1DAEboLZh0cK6thV
OG5Y3BDXkViUXowtwQt92gv6S506kDF2hFSMrbpB4HMik5eI41QuEwcR9l5byw4jhAgJ1Tm6
s3vsN3kVBKh632pduH3APvmloaGf0Vy2NMBj8sNJh+jPFwTmIKa/hhjWCybudrVQrMKDLsyw
aDfP5X5hcaQh+1vQqtnF6t291fjyOREqHGSmCyMX7btG6YlehyCvJXwXwHgWnrjRlla+LXUe
JVVy+p7vofPQOo5MhJy5eF2CGvm6gq5F+N52cVRbVxxSE+l9JwWd5ceuG32DCWF7BR3SSS/i
2NxigvQ3662AQAhZ0Wa8VuS5UaLheLIhAF+RLKUUo3n/nsc1e70X069+zRGTvgbdYXuOxHMZ
tGV7jjQAOOb2HLLlxhHnX9yeA9kzceB/TX2R3TWVGsuQLAMcsa2xKRgZIaeMaa5pakb40N20
nOOAqKO+iTfjkr+8EdmQj8ZE/lRUKgi85oOlqblOXEZ+XLfz8l43XtUitoRQ/NZZiISnKYMC
7HIwypaPaJjvZBlj+V4qoSnXOxIvFK7shGEnjET/HodhpBADmwEIPWJc9srBc0e/OdFuOgi2
avTfUJS3t8KpBG0HPB+gVrRXe1KFLnvzasbJEfHTNB9lE95fdXE2XQnnQqT1xy5cGJku4Kch
J+i70U+lYSTECWKN/05rciX+bUDf//x37D5G5fhL/twqp3et+ZefbQGRNAIDpMbACLkfddBc
UdJzGZgv8XM/zr2A5hA+O1eRmTULvHiaa4SYkYg/cEDw2Zz0P1d4NytVpx2W3MfB2awEwGB9
Et+yxUmr1wdIbBnVJxJAiUGWs6XTiAAnOF8K7gqky9+cXp2LiibNbGjE0PBvDjZgqHRu9UBx
7mqY90WhIQq67oiD5YZ+CPv1K7Vfect7tJ1YW32ShxHaXMdhBA1cyz9GvDYCzPv3o5J2TaNJ
G5KQ5qtlscSe/Y6TkDOvahHKgwM9ml4sJgc9tATmE0aDjWnZoHmwZQsIUiMwdCWjU9SVRUV1
hStUzYZI1fSBaxUI8dg4FtIFUolgrVbDiyDdkZHImmR39FppOzTCKS0Se4tywljGtszYfgag
/hffC06VN76WQZ7VEUctW5YfW7KBO/6q7Fc7/IuiIxXG01zT9t7qTqfaIZM6b9M4rSZzrrB+
tAWkdjvAWShcevmTAirxE7DW3TSySWOr61E/jAPT9W7ns/wJeLzsRdNxbbLItdkiH94aG9ki
3wsNW+TS+r75aSBLrPpFNMcmcjObJz17TY5kymh1m9gk3H0sNt9Lwv9t79qb20iO+9/ip9hc
FIXnHBbzfrCKti/JOefyOXad5apUOS4GBEAKEUjwAFA6+ZHPnu6eBbEgufOAdst3Lp1pSQDR
v1nMo9/TbdJkkpOmsn8N/9MZZIZy5B5eG7ztmCaDj3HbJjNUTDFJZoRoyRZjGceHTpHBx3yb
zIVyKA3ZtyE7ZDZuByI5C3Dz/T5FMtmaWUCVrZmFff3uAoUSXkxhFRYMOKP+uVfYM/PMXrLq
brs+O71dLD9vQ7T3LyhynKvnIeGUGR9ghTNWNLj8eWAAkq09h230LN/JkqZqBXm9DuWHcGn5
AVikcDYP+eVsRrfkqFYT5doE1WbcVD/akYjWeltMnmtVpEcNMxYIDn2ID7NNBJOgHCLPjNtj
rNuz30AoNkT9UQTHIooir/J+tn6JqMJkmpBl+uUPIMAumKqxdTu6b7oD7M2nhHhQ6vC1p5sB
sQB78znB1J4Oc3fwzC1vDypBh+5Omw83l6vlYhqyAv9nvFxcGjVezkZLvCA9+h5mwqh6s6rF
P2MmGDavbhlEAXzPM6jYqnGJaL4xkQ1LEHTRrc89hUVOh0thCviciwK3R4kDQdWoQGDS6o8s
Or97dOP2OwSwHErUH1l0fvfohre+ijecnEY/vuj87vFdi8FYsBlRpn4KeA4a8NxN9d400rV3
hiTegcohJXz0idaB8rlNJh8UP1tjwZCWnh9gQJhi65FHMKB6tancAw93NZqS6ARmvKJK9fij
2P7fzLT+/TE/0+ffBy3wclrZScVmPQ30w/hpza/f24Pw2inJHs23bpOKnh7hsnO+ucc/exvo
h/HTnl/B9vMNp5eS52NKdXcK9w7BD5EtE8AFFSp5Lm8h/FaK9pfxst9kXELFRLQ8v/ER2hLi
a4a2fnvLm/bqqZ52gX7+ffgOk0k1FwcP8Hfw057fvcvSgRKGLT0P59u2Sfti6fOO+XaVBQN3
9vfKYnB+pdrPt+ac6cci1LVI7fN4qnsoUfJcV7rSqrp8drJbb7o2Cau4quyjB+s4h2pawelW
+rEMd7qazqpLXulZJVp7ytjKyurSH2664+cb59e15htztR6rLAf8ZNLTknfsbyEqPqvmfXGt
H8xPe36t3c83WOgMnUrtzdSeb+l6fpBHP3NfTWSlQaHJG0j6v/1clsw3zu/ereJr2O3U4+tg
vltfXV719AgdKiKcXG4rf5krL3mHav9D+2nP7z6u7/GOHgV1O/n3wPxkQhwUR//7Yint+TV2
P9/SKo8B7E6Ts6/zK59/3zq8tSlU54L8SH/286vZ3nPla4VNy+STmCZXY+wWSRUF32Hn603d
rnR3xlXdRrC+hYj5oPugCRXMoxKBIWVnMoW/L1a3WPQLwy8bun80g1/vrKoA4dwe0jQO8Kgv
OZbiFyBcrzcPAqpULC/qcYR1hPiW3Dr9m5ec1ViN1LuPSKdCDMX2IXJ4LbEnhCpMp2roJN/j
KCcpc/hR4o85Azb4t038aR7Otr40cDCDNbWPS/wJABRn3L3Glg8YRNwl/uhLvkv8menZ08Sf
hkSJFoTE0FI/iT8N3EOWBb52oe98L5k1Dd6D2YSvvdatoHwys6YhebAEOMc6EnQB/rjMmgbA
sRYgms65mTXN50WbXmkhTY+ZNQ2mtq0xtCeP1kdn1jRYWrewsXKP/PjMmgbKtqYGdFzG7bGZ
NQ2Aai0+l+GiWSqzpvmobj+LFtwksk+aj+2ZAL7WjCcyNJqPCd8iM57pRBpJ87GDCfMmmf7T
fMzINpmXJpEi03ysfZTgcAjrk2TwMUouengNf+gMMvjDmjYZrEh6SvBjvrUAsFc1T08JfkzZ
NhlsaplB5g7JUJKossyahkyLFgww1lYG4UEajNEarOd0dk2Asaq1q7AIgWXPw3qUXlnZNQ1Q
eydI4alBT0QT0901I3YImQ7lXEUMUSXsmTz1rlRRQnDvMsHLtTzEV5IrmZ9m1JA85Plygb2t
U+uiIssSAFReICN7WRBVWDvUZQ3C13RXaoBcC0D3yHX9LpVsu/2gHieRqVQSMqII7EzQjTK/
nWEFQFiOu8n726aiEhHCmVbt4fWT4WXG8NJReaUulO7htaIchwdC8WR4lTE8aFSol3ahdA/v
gFG6FqF8MnyiyE1ACbVkulA6hpc1Q9HFWoTmyfA2NTyiSFISulA6hre1BdXTu8dpAMCrfHca
QCDbZwkLNM/C9cAjA5wBwZacsAy+EFDJ3BuELxA+sIVBSvyAsoLt7jVnRckVDZXc6Svw2lps
7HXoyW17FmVHgMxfVXNZsStY8Gre+vyEd/hkOyJ6YBFf4oWkx+/PAOq5oJTscPheWYR6+nPZ
4fm9mjzvNG3jfLSnq5nfB5cCvPZc0j3MdiRYf8Q4nT8dj28m1dRWl3F/8aFXEh4PSOyjBfyB
Barb82t1a76dolKgs9XFbDq9u9jMt9hZCwzYs6r5x2koSHnxzfjbz6ny5xy4D7ZDBoP8avF9
9WF1v8aG5gFSYL4MR9fip/yYIZYwzO+uSg++5l6TVt3pjO8rJtFxKMS8molKX3UuyI/0pz2/
D9c1BF2nMzqWnNGRxFL808GiLGxujozq7zHYFObXPiTEC7x4ZJz3n5KPhppvg6Vz3H6+rXXO
uk/JR0PNN8yvZy3+7a334seVfKTpqX4MyUfN/D54YYQkVzI6cjodBpzxlNVIMJ5uJJZ5DJAQ
7MPH+tGn5KeP/2nP70N+PL522pl45ZmIMzQAeFlgp+ZY14hq6T5t/87QAC74QNV5EV84TQ/f
6fXiTLD0GUK/tZGlbi8k9FoZE3F7wfgptxvBWIrrlPm9gFBKr52I+L1g/AwegoUZrCl1fCGh
VYJFXFanGGrLGN9qr0yp5wsIlZfkdvyUUDgMD8P5bfMwbbluXbYvTQAKCIa1pKCB/WPd8QlA
DYR/gFRYIs5iODfmx4xx2oBg+y1GhaiKWTFUfIPwtcksCVTqx5S8Voa7RBHeSFJVAPA9lzYj
VEkB+f7FF4FjpGygFZPEdynpo1sFtMm4BcFIyYpVQCI0RrW+39Vksw1tMLBj0O5TSnEv43EB
ziNLjwiCyb4qrfM9qs4tzV+yOnt8zYvuSGWdpwd0kNvcuZjqYq1Or7120nFTqroAodFMHYju
J6qLdSnVhWAEFZEuU12A0ApPfSy7VRew/9PjW8mpYUaZ6kKEwI1kTHWxPhWwRRjFqR9zmeoi
NQXlbdwc4BEpFRBEbyUT+R7VSNW/lGrhW5XZsCObYTfgpvZKKZcqrBeZVEKgcsvPPF4otNJ+
wAt4uvC77eJmvsZqo9NQlvT5J1RUgcaXBBszFg1RBeN6qEUjfO4yU4tLWaECHsY4lzExKIxI
HUWCkVzwUjEIhEZprWKsWICUTI+PBSdtxBjtHN9SI7wIK8ZalunxrbekB5exYiD0GAFP9FeI
FF8JCJb1Ffjne1RLdQmG2dWSGgDKgqYQZbvaK0v9RToFHJa8Ta+q15jdUSrgkBDkp1ERAQfj
+4zx8QF4qYBTBo+DdserjQGBKov0uasMKj7W5u3VI3YV4gudma5Suqs0Vhw2DgPl1AAPprB6
vdpOlphIqQVYvVX168n3418vsBn9GF5Vv5gslpihGuiRSTEKvHfyWqlcitcSjKBSBmW8VpO+
pk1iV0TsyIBgSkomZewKQlXGD7UrCN/ozEJSxbsC0B1jPibBpPKp/DuCAZOk2JjQqmZwpLyK
SDAJXz41PsJ4YyMwneNz2LQxByaML1LGFMKgJqJLeS0QCsGNiTBJGD/pByUYKUQkj7BjfAu8
Xkoez+gF3tB9qgKC7VcvJVSlMlN6C5X9AG4zy6mUH1kja0cZFrGMXpvilISio2G+59fUKEwH
FSpREy9Sw7FByGx1lLumhKpkJv8tXFMEF9gwZqg1hRMu9aHX40madNLoJxTLD/hUFp9EQmO5
1hE+aXiKTREKNgYoZZNAKLmlC1+dbNIkuRShOH8QdMvikkgIquTBt3/MJY1MCSlCsYxFHDcd
w1OXV8njZo6IMMmAQO6FPg8UooJOlqd6lB4oBNd6MG3X+FprsN0T+lyMSxECFR7tc1IRVVJI
d4BJRXDHMuND5ZNqUQ8QjEfjAjJpOhKMtL44LgCEkmFg4GjTLSDYzKyC3EUlVG15z0WJ2+DU
IWuoRZXaMx0RGrCoNmNRpWHW21LZA4TKcK4iUgPHT7FfghFWFAsfINRKGxe7owPjp/wRBAMG
YPElHSDES7HRSzpcupSXjWDEofTLEj/W1F447eI6ekz8BART0os651ABKmgFmYfqiH2P+IJs
w/4PrWO1B13UxIsyxjhVg5Bp+OdOKqE62RFG+PhJRXwdSvwP4E5wqGIx6tTT7ZBnMhWXJhju
WbFDHgjhywmVUCoiR6VBcH3Vt+R7VKn6bnfbAldsgGbCe3zsvBi7IQpaWCrgSjBCxFxNnYtq
0BqN5coJpjM2leGh5lOZ/AFCB/LFxnLlBDMp249gQLMsDjgjIYZZIpFiGD/pTyAY6WNirGN8
h03IyLkWkz8Rz2tAoMozfR4qRNXGDKVME37ocjUAq/TUhssmLs3GWFVAcJlurNxZJVQjM1Nu
ymeV8K3OdNQUzyoeci21iwkgm3QVEAzu2FIBBIRWKWHieQSR3IwAQA7ZPhcVUa1hPbce3YNr
IQcoT/aA78SjZLcn8sfqlPcJYUCOqGL7x+uaKylNLEaBjCg1vsbK2cYV52oDIRgPMh4Ptkn5
AzBYosAXyx8kxALhMfsHGCXPGN9j9ZRS+eNNLSXodIkmsTFOSQjaPK8hfXxujve1xbsQ/frL
ERX1mqE8cIQvqE59/5wY2AHMSbgacZx/r0Hw/SZ/EqpgzA3ErQI+dvEYZlZ1zRysXEQwnUqV
ajkWYLTRETvt2bOIhAJLKB5tNgcElTv/2auqqT38IA6+BlxnhjiP2DIay1+RARcJwqsEgyUY
rG5XGoRHQmM1NbfrDsIrk3AwEoyTUpc6+JDQMWWjDj5MsUiP75hxB16DHAFHhJi6Egsvgd6Q
EPAEo60rvowksRCe4t4m7p1EDhUhoA3a66EKqLkGUOGhInDpB+iw3uBjvqwhn+fjfCfQArHk
ZDTfSXJQ10D26EQoIyK/GgTXq4MwoCrGBrJ6G3yfiV8qvwAdeL8QMftMpxJ2A4ov9w8ioXZg
A0Tua57qlHsyoAgqP1zGaIHQK25VzJLQKUU6oEg4QKV8lhvq3aNjNye0Tw5vsFcP1xFu3Tk8
qLM8XuzMp7g8oYQ8xkIui0aAsh/DZQnBZRq62QcaUa3L5LJHHGjAV6AyDuLGkiL0NWZxN1Z3
6bcdQG+X01uPZbUYInbUgA+WXg6WamhoHVPyuZQpfQxhFGcuwmufPylAaA0oE/GTEkm13SFk
JlFkLyqiciqiO8CiErjPbC181KI6qc1BFOFpFD8VRQkwVvtIMKZjUU3NlDMilkGGuWmp8Q11
CWYRmM7xFSiTKhJ+P8U7k+nxlQqt5cukDxBq4RyPZdpyxRKeYYIBG9+XerGksDXDbqdxL1Yk
03aHYHpNIguoUg+VkhTwtcjMjikVP1LhVUat4v72CKdqAEyvrruA6lTfDRv34HAEByh33OAD
iwHmHwt+nIJ0SiSbBhhgKMU+JiAEs8nqhOcwtqgBwfVrDhOqdXagfJeA76wZRGeRwLcFFtCI
BvGT2jfBWGlLC94goeD2cPwnQRSeymAOML781jgSaoct5WJBFJ4Uvwjj8cJKqfgBQrzSxqJB
fG4SQSyCMeyw0HWW+JEOfUxOxm+NR4IoOwTda7g5oCo7VLg54Bs1kDteoTZmxPH5rjuEnp1E
iKqY9UNctQjgodr5IEumgMd4Zw/cK0/kj7OpowownDFZHMMnQuf9wXXwJ6zS+ZT5pchPomNp
u53jS2t8zL9zKjxLsUqCcVr7UlapkMd4bWKaOrYTSY9vHTeiNN8WCZ0xjiVYVXebiR1CpqGY
fagQ1duhaiUQvpUys8xT6aE1tdewrW1M/niVsaheK+rQVSZ/FAabvVFx88dF1jQAZGq92WsK
qGCiqKFCe4QPp7Dv1iEBXYM25JngNsIpZbJSQIDhTkVgnl9UIJQGTYVjc9h2CJlFY3JXNaCa
YU4SgVud6U8t3zKArzCJOnbdA75dylGDMIpTX7ky8QOEGriviEaDTaq+FMFYxg82VZb40bZm
UnITu2soLUvFiAhGuViFy87x8a6fjqjYMH6qNGiAkbo8GgyEwDEMT6Tbxg5VQMi8Q5B9qADV
cW37r2nXwodpH6T8hdS+doJplvBpx2Y1IKjnWflHJ5FJw2sB58X1a18RqhRiKAFH+CrXaZH9
1MC8cC/EemKZVMZlQHGHt62z5BoQao3egKPNugbB9LyYiKq5HsryInzjM7Wh0iMI6MaDRRSz
q0zqGiOiWMaoJ2yZXANCB0sqY3ULjUv5/wkFbNMISsfwtubW+lg5plPLU/43QvFGFPufgFCB
WNOx8IdNZj4QivKy2P1kHFXkUvG8wcgdkh2C65nRACoc9AHqjLfwFS/Jsc14aitq4I1UXfmo
WwYNgO+37BqhYiLjUAYy4VtbYtYXsCeLxTFAYX4uYQyzP72OJ4xZYG9Gah3pwHjKVdJtQjDa
lIdNgJAKZCVScyMaToPQ793HgCpcpolXaIwRuCcn3zBbztR49TuWUwuLqlNSA2E44+W+QCTE
HsmRS4swfjI114IxxLgtD5sAIUZXY5fmYfxU3ZsAgwXgS8UWEGKJdhNLzeXJ+mABBgRXBOb5
8R3DPgmUnRSTW5Es0Aah51QYRFVCZ5ZsLzxUBA6sbKiUACcp0JmopxNLrW0QVL9iFVEV84Nd
DSF87ku2QoH8cshjhGTRq488GeElGKV4cdjEAY/hTvJ42bFIJmADoPrNb0FU1PAGKgwW8A01
XB1iUQHdGyZjCctCJM0GgrFOFBtNQChA69bRsD3YFenx4SG1Ks4aA0KsPcNiVpMQSflLMOKw
2H2W/AFCsDmEjNbCFUlnKMJ4kMCltXClx3anwtlELb+Iqh8QfL8XigOqzq3rXX6qCN/yzIIZ
2U+ta4XtrhNV3iOChxBgJfs1nBAVHixTnB0xm4ivfCZ+obbgybFxmBH5RO74VHmkAAM7tdhZ
B4RYu90mtImIs65B6LeST0C1PLNg/xGLivjAmQdRAREcCy5GrySyZLYswYjDJhdZcgcIFbdC
xeweyXjK7iEY50xxEAoIjQFOEav5IllS7iGMZcYX50B4BwabMyYSPYLxk+liCMOZcBHx9ez4
ikmsAmLZ0TXHdggldT7ShyqgusGCUAHfazuIiq6Yqp0FXTEehOoW5juAjryuj45BKWZq4Ciy
3xy/gOpYpopcxqkCuLdDBbgUAxaiveciIt6kTWWjEYzhRka8gx0nEVmIcSpWfUva1L2JAOOs
LbUAkNAqbXmUEzuW4EQBxgpXmo2GhDD5WidicbFDExD6dWsGVDD7BnKSBHwrSi4blnAiQHcg
l2JXQaVLydcAA9ZJqXxTzNXcgB4dS0dDhTg1PsBYpotv4yiONYuk00f3e9ohZNZHzt1VhAqK
x1C7ivCt5b36WEBTwwqp0sUydp1IKEsBRXBXzCKBEGaMp4qS6MhiEgKpm/1Oi/NWD9AFsoXv
iyqQFrAIjl0S+GEboseCx6USRgOKVMVVH0Ftx0o3h+V6H8sdkIqp4RFFMRlB6RxeMGZ8rCaJ
M8lvjyjwJUrD9UiIFUditepPXarkMaFoJmKVI58fXpiaK20SV7Bkt6OkQbAlZSQyThShZhfa
Kj9RAd/JXuMKSsAZ0GgHxiLDhqVUSIJ51Ksmiz8KOARGsEQprogG1QD0m3sRUFVuW/ojFhPx
w5Wz/s0OgQqMtDJWlJCbVOOgAKOVLS1KiIRYaknGLonAA6YUOIIBfaPUMY+EyhnOYlm63CTF
A8FY40uvcyOh8ZbFMpFOeTJLOsCAIlzaE0QJj7dbDY/XvYg5SBoE1TOHRFQtzVA6B+KDVlDC
IQt0Dqlr7Y12zzSpMxrlkYnm4Chpa40tBo5NjNoB9FtIK6B6X9IQOhNVcj5AW/gG32Hsj5xN
3Y59aROO/QDjBStNaEJCadVhv54nsU+Z6k0XYLR2pVeWkRAYnI/2phMqKbYJRtjiuuNIaCXe
2Y6bNd13pnYIvtfaOgE1tMIaat9ZadkgZV4IXGvhYnJLgOKcXlSwo0EZK5VbQOixCFbEYwHj
J+U2waByUyq3FK+FcGQQHRcC3SH07CMOqKqjRO9HLjqBez1UrUGlQIvBdhWx6wqYe51YVIQR
GK4p5ZRAqJlVx9fa3SH07CNFVC70UIWyAr7WapDaMoRunfSx+wrYTza9qljmv7g3KhKSqhXL
vZE81XE3wDxqX5Elf5SvGUaYY7mfkicjDwQDem6xig+EHFOfYvUCpWApJwjB4NWvYlbpUb9i
CSeIiGiTAYHrft0JhKpz6+2XskoE9zLzSJUfWS1qDOureLZG993+BkCV1JPKmFNCdbbjcl8/
X1syp4fhVBqtWHZ41/SJ/PFJpYZghIzBPH9SgNCBSpUwhmPRlAah36rgAdWbzCy1wpMSwHML
vR+xZQDfMKEjnvNTTE1PLypW84plkHYsKvBNzQ/7RTwRP16nzD+COaJaLRIKD/w3Kn68SW5q
hNEs1r2pc3yN5Y6i4se7VIgSYUCpi2XyPD++YbWRUoh46mfMw9Qg6H6DfYRqeOaN3/J9T/hW
Zd5eLzy02AMY85WPLm26Q+g5VEioOreL+hGTiviWZ2bJlMofAyoeGFnRioFepRw1gMJB2/PF
4gcIFags0UilT+XKBRRtY3U3OofXDq8ORhilT6rphPJITc7ik0BosONVLFLpU9c+AorWsUT7
zuExtcsm8nNibAoRFO85VBhQ5SDVFAO4yb3We8Rx9bV3XkdNH854xp7ynnNfLHusqAVXjCdM
n4hC1yD0HN0gVE3tA/pf1AAuMxOqyxfV6tpabxK1amNacoPQb1UJQnUitztw6aQG8KEu6CoL
W9zow5YKT2LrVqa0RIIB86/01ptyrGbSHlaVeBIHtirlJCEYr2SxkwgIOSjpPuH6i2wqQtCs
pO5OxqYiVOuHunYX8N0wV1oI3GK/3lhw3Sb9uQTDvS69fYCEwoCWySIiHcZPmX4I4/yh6ZEl
0+kCMLKqmPixJqXQIQwKyeLbB07WxnqrE/6ESOSrQei3mBKhOliWIa7cBHCj5FCeN7yDyUJs
/cggQUAwvN9wIqH63NtXR35vn5uFWWr6eDhjzDEbq9YndKpaXIDxrviiFBF6p6WOyD+heUr+
AIxkoFCWloBEQqVN6oJq963vHUDPuRGE6i0b6jAhvmGSDSJ+ANxgVlLM8yZ0UqdAGMtVTIp1
rqkV2ruY+IHxUyYlwVjtigM/QIiZvy6W/CrAWE2P74TyvDj7FRvuCkWN244UPwGhqChAzqYm
VJNZTLZ00yG49pktK444MViPE/bDc6ld1mGJrHhql3e1xqqkR9/d3iGUVLfLWRRElbn3dI6Y
N8LX/VbI1Qx4g1BWRG+VgWCJH7EAY1SsNfezR4wIHdcxX9+plKka5wEGM5wKxRYS4qKlKjx2
76YdQmY3kIJ1gcXWbCDnesC3LFMulrEQzXjNmZcxewcWVSbkBsEAjilNmENCwdhhwuCTiJFU
CbMpwGjqBFYkt5BQ8lB2vjtiJFON6gMMcMTSYlVgw9faKm4TOcmxTU0IlD/b56ZGVCuGykkO
+J5lHppCDR/RrXIeXTPj5ds7+v9mPR2DCNtuxts1fvTDWbVc3M4rZUGqAYmrfrWgEZ/8t1xd
X0xvZtX0zXq12laj0f1mvt7czafV7epyNftwdru6Xq/u76px9RI/J3766uAxsChXeC2xyLPC
2yDj+816DLM1fg9fuxp9B6jLFXzl0fx2uprB7jj//etfjBy8vZ5v1x9G09Xt7Xp+BSPP4L33
k8WW3q84nB14A77SfBNevNlu787G48Xt7Zlj4//Drz69XoxwLPj36H9Xl1eL5Xw0ubuDHTl6
N1n/DN66wPfOaZ7g1Wa8mb6Zz+5hNsbvbkZI9mbzfqTmd3z03f3kFjSA0UI6MxJqN5kj0Ks3
D7+crtbz5hOMuxHnI+br6fWfRhM3m0240fOpVFeTqbhU6OrWCptgazYXUzAq5lpyouOc6xHW
f/Wj6zeX0w98xOsPk5vlK3xgPH7z87vVBjbN/W01+k01ns3fjW/vl8v2XGMoPLw2tVFMJupv
iu4Lhw2CdcPwYQTnrt96JgFV66EaJMKhqYXG5vbxO2cmMqkBIbM4RPb3RlQp7RC93Brwwdof
IT61Cgb8t8CRKqNs9e4G93s1usWoXPtTKLh2r0GO0OVH5A7V1Wpd4YwjZ7qdVTcrGGC13uCl
DF6tVjcjxJ6vW7QW6zOH1752XFLpseOuEu4QMuMT2cvqqRx0ZpHD0mVFcM0zb8mULysHNQ4m
Ga+pZMok0FX7l0nhMRwGdx5eu5Bcf1x2RYMg+72fHlCdHOraaMD3uYUdC/cSgnusxfNorZeL
S5Sv9eZNs9DcOVxpPOKv9/rlwX+fvfz5Z21QTErevfaCUx/Ng0FQ0oNIRLHdjGIMDQKmUdcg
WzDbkbuALnFVvfxJ9dPqJWoE7XHwLD+8NtzGCuOeYsP4hMpMMIoXd8XVnNdMavHkIHV/b3nc
9w7juIeTAq+9UipWNE0xnzIVCCY04Cmzf4EQuJPX+eutjv3eOA5u3t1r0GQ1mmiftNaBtdZm
roXZz73RnsU68pxKlQhqEophjpVWVEBCi4WCovmcqQvDAcWbWHO6zuGdModO7SfGecqnTShG
R5sDdQ7vrbYinvcuuy8T7BB0r4mHAdX6TNFYKroQ3OW2oTxC7sqaKawHF79MEJtURFAs8+tn
TyqhimGsOwLXejhlBksEMYnRp08s+iNYNM785N31ORe1sP8kAFtq+EvV2sFfXI658PgPodQr
4DHrLdXoOwclTICA1Ea+gq9+8J7T5tU70MwXq9vzB6ldg9jePYgaYd8yLl89IwzCqrqdWSYY
CAPOZZwfRbLLGwTVb2HhBlUPlQUR8BXP9GKU+goFh0X2DNNOPp2dXtSbKxh88wbn5PGODnPN
xU6lhtdgzrNYa/JTOCIplZpgMCJZakoAobZgp8VUehg/EbUnGLDMTCSho3N8a0A9iN/sVt2p
GDuEzPZi2ScaUZ3LLJRYKAwJ3PPB4mVCYPtwJiP1cWBRfeISVICx5uBmd5bSDIRCWGNidYgx
wy49vlCe8dJLUEgowT4X0TI7giU3NcJIpUrL7CChBmUfH7zYE9nQyp39I2RtQQKyxNXTiNe+
Qej3QlVAtbmdjUsPCIBz7oa6qaCFwrCU8IkWwBEVPCDITImfPamo7wibeaG0dFIRXLOhKpdp
oUFlFBavHn7zq9+ewaG4XK22D2eCfkv7ePcaK3omVDnVnQK+Qyi5nZyzBIiq9CA3cAI4Xvoa
bgk8bMq/qRX0fntz97Pt5er7i9sJWAEJRe0VfTJoTQ8b5hm1KXyxB8+vMLVUoImBaNp82Ky/
O6t+92Hz7XfVWfXVzXx9Dd/xA7xzO91/2AtsC/Dow9/ON/MtbdGTr5aTO/zuaLqcVVqxk5N/
/AeawMvJ5g28qF6vYEvDWs/up/Mv4DX/vNpM3s0rUPtGm+l6cbetYB2r7ZsFbNXw+vRyBas0
Wc+ryRY0cdQIQXiw2eQDQq3W22oO4mT5OaCJzyv0h7WpaYk/rO7XsM1u7ha4L97O17fzJY2z
utuCSTVZggx6V7385X/+7vWX33xz8evf/PvFb798/fXJSfjo+Ut+coI7ZD3bnJ+evBivNoub
yfV83KzDOKUbA8nOaMN1xE80b++Q7t5ew2JdLia3o++duTAKEcyIuZHk+NEHXRxXeTENgzSf
NKB3X17NxAWQWByUM0L//OTk69evf3vx22+/+sUv/+sct9wG9txs9f4WT0XNeL1aX49xJkfT
BT3Zd/Ob+5Ow2Ue4iDAaTBpsps9e/rmZgD/8/I/jfxy/bCH/9bOTkz+fvJhOto8+Nv7Jf4/H
8NsXf/jD08mt/vjH6tWrCqbzxXQGhI9/D2QvwASYVcvFZfWXanq3WFUj+Pm6up2/n8LzfXe/
gOf8S3X9p8XdyYvPT17Mp29WVXsnJan+Wv20Cs9bL25g/759d4Pri7Mwgl2+nd/QRJ+8gAM/
uQTLCj4AL6Z399XXk837+XL5xb9sbuZ3+OcEHmLUbK2X4W94I6C3B3kxugGbXMDfm5u7Cv+G
Q7qYzqs5MoYvbudbeH0OfzH4VXhVYVTui8Vs9y6e8Gq1ns3X53A64VOrUTj28O/3k+30zWx1
XS0MmG3zzWXrvdFkitu9go12jw+y3k5BpdrMz4mp4XrjU83XCzgQm+1sscKHW2zulnDUble3
+NtG7aqIqcAGC6YmTtri7vwM/kuwqrOz2ZspzBSGG8+JPa0nN/Cd8BueA+HJC1i/8/F+EU9e
fPntv319HpbhLTDYq8U1vRohww+vR1M2Qh+IkBo+dAm/mL45Xy5u77/HuZ0vx/Tn6A1wgeWH
B4+J4LBnVzc3wPhzTdeTF//6m9+8vvjlr7/8j6/O6czSKOPI84yvp9ORHeeOADY5Qv5ppGru
azZixhs3um7IT17cTL6/uL9rXEMMJu7br373+29eX3wLz3U+BsF+v9zueMUY7faokZ9kXH1+
M5i98HwXsNa4489ByF1tTl4023Fyt5ieN/8mEXMxWb6ffNhchLM3A/Lp/d0MhFwN/7iAQ4gi
b7kkR9nqHsQ3zgcckXpxhVJzcw4v72Aqtm9r2ABvbzbX56tbeGtyCwON4HE2q6stbP2393cX
4U147/ZmcbE7L+f07smL1epus/s36ROwZ+FcvD0XOACIle3DOzDkbH05q8EgWq0vpmCqbM8d
fR9gJrMa4+1L3Izn8/Uazsw1fGp+Ae/Sm7gfbzerJczM9gMgzSewX8M3wHd+x74ATU3gt2x9
rvXuu+vJOQDeTABp/f75J8E5nK+v6s2b+y1KAnhiOMbAt4G1Ac/+62dV4z5CXh7+9YefwNsn
/w+/4oSG/+MBAA==

--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-lkp-kboot01-3:20181115080451:i386-randconfig-c0-11142356:4.19.0-06969-gdd2283f:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.19.0-06969-gdd2283f"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.19.0 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ARCH_CLOCKSOURCE_INIT=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_SCHED_AVG_IRQ=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_PSI is not set
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_MEMBARRIER is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_SLUB_DEBUG is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_X86_BIGSMP=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
CONFIG_X86_INTEL_MID=y
CONFIG_X86_INTEL_QUARK=y
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_NON_STANDARD=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_STA2X11 is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
CONFIG_MEFFICEON=y
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=6
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_CYRIX_32 is not set
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_HYGON is not set
CONFIG_CPU_SUP_CENTAUR=y
# CONFIG_CPU_SUP_TRANSMETA_32 is not set
# CONFIG_CPU_SUP_UMC_32 is not set
CONFIG_HPET_TIMER=y
CONFIG_APB_TIMER=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS_RANGE_BEGIN=2
CONFIG_NR_CPUS_RANGE_END=64
CONFIG_NR_CPUS_DEFAULT=32
CONFIG_NR_CPUS=32
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_ANCIENT_MCE is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_X86_LEGACY_VM86=y
CONFIG_VM86=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=y
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
CONFIG_VMSPLIT_2G=y
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x80000000
# CONFIG_X86_PAE is not set
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=y
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_TAD=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
CONFIG_ACPI_EXTLOG=y
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
# CONFIG_TPS68470_PMIC_OPREGION is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
CONFIG_APM_IGNORE_USER_SUSPEND=y
CONFIG_APM_DO_ENABLE=y
# CONFIG_APM_CPU_IDLE is not set
CONFIG_APM_DISPLAY_BLANK=y
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_CPU_IDLE_GOV_MENU is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
# CONFIG_PCI_PF_STUB is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_COMPAQ=y
# CONFIG_HOTPLUG_PCI_COMPAQ_NVRAM is not set
CONFIG_HOTPLUG_PCI_IBM=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#

#
# DesignWare PCI Core Support
#

#
# PCI Endpoint
#
CONFIG_PCI_ENDPOINT=y
# CONFIG_PCI_ENDPOINT_CONFIGFS is not set
# CONFIG_PCI_EPF_TEST is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
# CONFIG_EISA_PCI_EISA is not set
# CONFIG_EISA_VIRTUAL_ROOT is not set
# CONFIG_EISA_NAMES is not set
# CONFIG_SCx200 is not set
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
CONFIG_NET5501=y
# CONFIG_PCCARD is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_CHMAN=y
CONFIG_RAPIDIO_MPORT_CDEV=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=y
# CONFIG_RAPIDIO_CPS_GEN2 is not set
CONFIG_RAPIDIO_RXS_GEN3=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_COREBOOT_TABLE=y
CONFIG_GOOGLE_MEMCONSOLE=y
CONFIG_GOOGLE_MEMCONSOLE_COREBOOT=y
CONFIG_GOOGLE_VPD=y

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set
CONFIG_EFI_ESRT=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_CAPSULE_LOADER=y
CONFIG_EFI_CAPSULE_QUIRK_QUARK_CSH=y
CONFIG_EFI_TEST=y
CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_AMD=y
CONFIG_KVM_MMU_AUDIT=y
CONFIG_VHOST_NET=y
CONFIG_VHOST=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# General architecture-dependent options
#
CONFIG_HOTPLUG_SMT=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_HAVE_RCU_TABLE_INVALIDATE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
CONFIG_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_IDLE_PAGE_TRACKING=y
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_TLS=y
CONFIG_TLS_DEVICE=y
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_INTERFACE=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_SMC=y
CONFIG_SMC_DIAG=y
# CONFIG_XDP_SOCKETS is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE_COMMON=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=y
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
CONFIG_NET_FOU_IP_TUNNELS=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_ESP_OFFLOAD=y
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
CONFIG_INET_DIAG_DESTROY=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
# CONFIG_TCP_CONG_HTCP is not set
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_NV=y
CONFIG_TCP_CONG_SCALABLE=y
# CONFIG_TCP_CONG_LP is not set
CONFIG_TCP_CONG_VENO=y
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_TCP_CONG_DCTCP=y
CONFIG_TCP_CONG_CDG=y
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_DCTCP is not set
# CONFIG_DEFAULT_CDG is not set
# CONFIG_DEFAULT_BBR is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
# CONFIG_IPV6_ROUTE_INFO is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
CONFIG_INET6_ESP=y
CONFIG_INET6_ESP_OFFLOAD=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_IPV6_ILA=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_VTI=y
# CONFIG_IPV6_SIT is not set
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_FOU_TUNNEL=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
# CONFIG_IPV6_PIMSM_V2 is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
CONFIG_IPV6_SEG6_HMAC=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NETFILTER_NETLINK_OSF=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_LOG_COMMON=y
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
# CONFIG_NF_CT_PROTO_SCTP is not set
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
CONFIG_NF_CONNTRACK_SNMP=y
CONFIG_NF_CONNTRACK_PPTP=y
# CONFIG_NF_CONNTRACK_SANE is not set
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_CT_NETLINK_TIMEOUT=y
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_SIP=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NETFILTER_SYNPROXY=y
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_SET=y
CONFIG_NF_TABLES_INET=y
CONFIG_NF_TABLES_NETDEV=y
CONFIG_NFT_NUMGEN=y
CONFIG_NFT_CT=y
CONFIG_NFT_FLOW_OFFLOAD=y
CONFIG_NFT_COUNTER=y
CONFIG_NFT_CONNLIMIT=y
CONFIG_NFT_LOG=y
CONFIG_NFT_LIMIT=y
# CONFIG_NFT_MASQ is not set
CONFIG_NFT_REDIR=y
CONFIG_NFT_NAT=y
CONFIG_NFT_TUNNEL=y
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUEUE is not set
CONFIG_NFT_QUOTA=y
# CONFIG_NFT_REJECT is not set
# CONFIG_NFT_COMPAT is not set
CONFIG_NFT_HASH=y
CONFIG_NFT_XFRM=y
CONFIG_NFT_SOCKET=y
CONFIG_NFT_OSF=y
# CONFIG_NFT_TPROXY is not set
CONFIG_NF_DUP_NETDEV=y
CONFIG_NFT_DUP_NETDEV=y
# CONFIG_NFT_FWD_NETDEV is not set
CONFIG_NF_FLOW_TABLE_INET=y
CONFIG_NF_FLOW_TABLE=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
# CONFIG_NETFILTER_XT_MARK is not set
CONFIG_NETFILTER_XT_CONNMARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
# CONFIG_NETFILTER_XT_TARGET_CT is not set
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
# CONFIG_NETFILTER_XT_TARGET_LED is not set
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
# CONFIG_NETFILTER_XT_TARGET_MARK is not set
CONFIG_NETFILTER_XT_NAT=y
CONFIG_NETFILTER_XT_TARGET_NETMAP=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
# CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
# CONFIG_NETFILTER_XT_TARGET_REDIRECT is not set
# CONFIG_NETFILTER_XT_TARGET_TEE is not set
# CONFIG_NETFILTER_XT_TARGET_TPROXY is not set
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=y
# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set
# CONFIG_NETFILTER_XT_MATCH_CONNMARK is not set
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPCOMP=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
CONFIG_NETFILTER_XT_MATCH_L2TP=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
CONFIG_NETFILTER_XT_MATCH_RECENT=y
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
# CONFIG_NETFILTER_XT_MATCH_SOCKET is not set
CONFIG_NETFILTER_XT_MATCH_STATE=y
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
# CONFIG_IP_SET_HASH_IP is not set
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=y
# CONFIG_IP_SET_HASH_IPPORTIP is not set
# CONFIG_IP_SET_HASH_IPPORTNET is not set
CONFIG_IP_SET_HASH_IPMAC=y
CONFIG_IP_SET_HASH_MAC=y
CONFIG_IP_SET_HASH_NETPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETNET=y
# CONFIG_IP_SET_HASH_NETPORT is not set
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
# CONFIG_IP_VS_PROTO_AH is not set
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
# CONFIG_IP_VS_WRR is not set
CONFIG_IP_VS_LC=y
# CONFIG_IP_VS_WLC is not set
CONFIG_IP_VS_FO=y
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
# CONFIG_IP_VS_MH is not set
# CONFIG_IP_VS_SED is not set
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS MH scheduler
#
CONFIG_IP_VS_MH_TAB_INDEX=12

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=y
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_SOCKET_IPV4=y
CONFIG_NF_TPROXY_IPV4=y
CONFIG_NF_TABLES_IPV4=y
# CONFIG_NFT_CHAIN_ROUTE_IPV4 is not set
# CONFIG_NFT_DUP_IPV4 is not set
# CONFIG_NFT_FIB_IPV4 is not set
CONFIG_NF_TABLES_ARP=y
CONFIG_NF_FLOW_TABLE_IPV4=y
CONFIG_NF_DUP_IPV4=y
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=y
CONFIG_NF_REJECT_IPV4=y
# CONFIG_NF_NAT_IPV4 is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_RPFILTER=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_SYNPROXY=y
# CONFIG_IP_NF_NAT is not set
CONFIG_IP_NF_MANGLE=y
# CONFIG_IP_NF_TARGET_CLUSTERIP is not set
# CONFIG_IP_NF_TARGET_ECN is not set
# CONFIG_IP_NF_TARGET_TTL is not set
# CONFIG_IP_NF_RAW is not set
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_SOCKET_IPV6=y
# CONFIG_NF_TPROXY_IPV6 is not set
CONFIG_NF_TABLES_IPV6=y
# CONFIG_NFT_CHAIN_ROUTE_IPV6 is not set
CONFIG_NFT_CHAIN_NAT_IPV6=y
CONFIG_NFT_REDIR_IPV6=y
CONFIG_NFT_DUP_IPV6=y
# CONFIG_NFT_FIB_IPV6 is not set
# CONFIG_NF_FLOW_TABLE_IPV6 is not set
CONFIG_NF_DUP_IPV6=y
CONFIG_NF_REJECT_IPV6=y
# CONFIG_NF_LOG_IPV6 is not set
CONFIG_NF_NAT_IPV6=y
CONFIG_NF_NAT_MASQUERADE_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
# CONFIG_IP6_NF_MATCH_OPTS is not set
# CONFIG_IP6_NF_MATCH_HL is not set
# CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
# CONFIG_IP6_NF_MATCH_MH is not set
CONFIG_IP6_NF_MATCH_RPFILTER=y
CONFIG_IP6_NF_MATCH_RT=y
# CONFIG_IP6_NF_MATCH_SRH is not set
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
# CONFIG_IP6_NF_TARGET_SYNPROXY is not set
# CONFIG_IP6_NF_MANGLE is not set
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_NAT=y
CONFIG_IP6_NF_TARGET_MASQUERADE=y
# CONFIG_IP6_NF_TARGET_NPT is not set
CONFIG_NF_DEFRAG_IPV6=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_NF_TABLES_BRIDGE=y
CONFIG_NF_LOG_BRIDGE=y
CONFIG_BRIDGE_NF_EBTABLES=y
# CONFIG_BRIDGE_EBT_BROUTE is not set
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
# CONFIG_BRIDGE_EBT_802_3 is not set
CONFIG_BRIDGE_EBT_AMONG=y
# CONFIG_BRIDGE_EBT_ARP is not set
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
# CONFIG_BRIDGE_EBT_LIMIT is not set
CONFIG_BRIDGE_EBT_MARK=y
# CONFIG_BRIDGE_EBT_PKTTYPE is not set
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
# CONFIG_BRIDGE_EBT_ARPREPLY is not set
CONFIG_BRIDGE_EBT_DNAT=y
# CONFIG_BRIDGE_EBT_MARK_T is not set
# CONFIG_BRIDGE_EBT_REDIRECT is not set
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
CONFIG_BPFILTER=y
CONFIG_BPFILTER_UMH=y
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
CONFIG_TIPC=y
# CONFIG_TIPC_MEDIA_UDP is not set
# CONFIG_TIPC_DIAG is not set
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
CONFIG_ATM_CLIP_NO_ICMP=y
CONFIG_ATM_LANE=y
# CONFIG_ATM_MPOA is not set
# CONFIG_ATM_BR2684 is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
# CONFIG_L2TP_ETH is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_6LOWPAN=y
# CONFIG_6LOWPAN_DEBUGFS is not set
CONFIG_6LOWPAN_NHC=y
# CONFIG_6LOWPAN_NHC_DEST is not set
CONFIG_6LOWPAN_NHC_FRAGMENT=y
# CONFIG_6LOWPAN_NHC_HOP is not set
CONFIG_6LOWPAN_NHC_IPV6=y
CONFIG_6LOWPAN_NHC_MOBILITY=y
CONFIG_6LOWPAN_NHC_ROUTING=y
CONFIG_6LOWPAN_NHC_UDP=y
CONFIG_6LOWPAN_GHC_EXT_HDR_HOP=y
# CONFIG_6LOWPAN_GHC_UDP is not set
# CONFIG_6LOWPAN_GHC_ICMPV6 is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_DEST is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG is not set
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
# CONFIG_NET_SCH_RED is not set
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
# CONFIG_NET_SCH_ETF is not set
CONFIG_NET_SCH_TAPRIO=y
CONFIG_NET_SCH_GRED=y
# CONFIG_NET_SCH_DSMARK is not set
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_SKBPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_CAKE=y
CONFIG_NET_SCH_FQ=y
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
# CONFIG_NET_SCH_PLUG is not set
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
# CONFIG_NET_CLS_FW is not set
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
# CONFIG_NET_CLS_RSVP6 is not set
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
# CONFIG_NET_CLS_BPF is not set
# CONFIG_NET_CLS_FLOWER is not set
CONFIG_NET_CLS_MATCHALL=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_IPSET=y
# CONFIG_NET_EMATCH_IPT is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BATMAN_V=y
# CONFIG_BATMAN_ADV_BLA is not set
# CONFIG_BATMAN_ADV_DAT is not set
CONFIG_BATMAN_ADV_NC=y
CONFIG_BATMAN_ADV_MCAST=y
CONFIG_BATMAN_ADV_DEBUGFS=y
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_BATMAN_ADV_TRACING=y
CONFIG_OPENVSWITCH=y
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
CONFIG_MPLS_IPTUNNEL=y
CONFIG_NET_NSH=y
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
CONFIG_NET_NCSI=y
# CONFIG_NCSI_OEM_CMD_GET_MAC is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_BT=y
# CONFIG_BT_BREDR is not set
# CONFIG_BT_LE is not set
CONFIG_BT_LEDS=y
CONFIG_BT_SELFTEST=y
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTSDIO is not set
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIVHCI=y
# CONFIG_BT_MRVL is not set
# CONFIG_BT_MTKUART is not set
# CONFIG_AF_RXRPC is not set
CONFIG_AF_KCM=y
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
# CONFIG_NET_9P_RDMA is not set
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=y
# CONFIG_CAIF_USB is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
CONFIG_LWTUNNEL=y
# CONFIG_LWTUNNEL_BPF is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_SOCK_VALIDATE_XMIT=y
CONFIG_NET_SOCK_MSG=y
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_FAILOVER=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
# CONFIG_GNSS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
CONFIG_MTD_CK804XROM=y
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_M25P80 is not set
CONFIG_MTD_MCHP23K256=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_CORE=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y
# CONFIG_MTD_NAND is not set
CONFIG_MTD_SPI_NAND=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_MT81xx_NOR=y
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_SPI_INTEL_SPI=y
CONFIG_SPI_INTEL_SPI_PCI=y
CONFIG_SPI_INTEL_SPI_PLATFORM=y
# CONFIG_MTD_UBI is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
CONFIG_PNPBIOS=y
# CONFIG_PNPBIOS_PROC_FS is not set
CONFIG_PNPACPI=y

#
# NVME Support
#

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_CS5535_MFGPT is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=y
CONFIG_MISC_RTSX=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_EEPROM_EE1004=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_ECHO is not set
CONFIG_MISC_RTSX_PCI=y
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
# CONFIG_ATM_TCP is not set
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
# CONFIG_CAIF_SPI_SLAVE is not set
# CONFIG_CAIF_HSI is not set
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_EL3 is not set
# CONFIG_3C515 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_LANCE is not set
# CONFIG_PCNET32 is not set
# CONFIG_NI65 is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
# CONFIG_CS89x0 is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2000 is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_ULTRA is not set
# CONFIG_WD80x3 is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_SMC9194 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_DLINK_DIR685=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_SAMSUNG=y
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_MTK_PMIC=y
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
# CONFIG_JOYSTICK_A3D is not set
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
# CONFIG_JOYSTICK_GF2K is not set
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=y
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_JOYSTICK_PSXPAD_SPI is not set
# CONFIG_JOYSTICK_PXRC is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_AD714X=y
CONFIG_INPUT_AD714X_I2C=y
# CONFIG_INPUT_AD714X_SPI is not set
CONFIG_INPUT_BMA150=y
CONFIG_INPUT_E3X0_BUTTON=y
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MAX8925_ONKEY is not set
# CONFIG_INPUT_MC13783_PWRBUTTON is not set
CONFIG_INPUT_MMA8450=y
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_GP2A is not set
CONFIG_INPUT_GPIO_BEEPER=y
# CONFIG_INPUT_GPIO_DECODER is not set
# CONFIG_INPUT_WISTRON_BTNS is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
# CONFIG_INPUT_AXP20X_PEK is not set
CONFIG_INPUT_TWL6040_VIBRA=y
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9052_ONKEY=y
# CONFIG_INPUT_DA9063_ONKEY is not set
# CONFIG_INPUT_WM831X_ON is not set
# CONFIG_INPUT_PCAP is not set
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_ADXL34X_SPI=y
# CONFIG_INPUT_CMA3000 is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
CONFIG_INPUT_DRV2665_HAPTICS=y
CONFIG_INPUT_DRV2667_HAPTICS=y
CONFIG_INPUT_RAVE_SP_PWRBUTTON=y
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
# CONFIG_RMI4_F03 is not set
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
# CONFIG_RMI4_F34 is not set
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
# CONFIG_TTY_PRINTK is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_SSIF=y
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_SONYPI=y
# CONFIG_MWAVE is not set
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
CONFIG_XILLYBUS=y
# CONFIG_RANDOM_TRUST_CPU is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_REG is not set
CONFIG_I2C_MUX_MLXCPLD=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_CHT_WC=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=y
CONFIG_SCx200_ACB=y
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y
CONFIG_SPI_MEM=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=y
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPI_SLAVE is not set
CONFIG_SPMI=y
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
# CONFIG_PINCTRL_AMD is not set
CONFIG_PINCTRL_MCP23S08=y
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
CONFIG_PINCTRL_CHERRYVIEW=y
# CONFIG_PINCTRL_MERRIFIELD is not set
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
CONFIG_PINCTRL_CANNONLAKE=y
CONFIG_PINCTRL_CEDARFORK=y
CONFIG_PINCTRL_DENVERTON=y
CONFIG_PINCTRL_GEMINILAKE=y
CONFIG_PINCTRL_ICELAKE=y
CONFIG_PINCTRL_LEWISBURG=y
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_EXAR is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_ICH=y
CONFIG_GPIO_LYNXPOINT=y
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MENZ127=y
# CONFIG_GPIO_MOCKUP is not set
# CONFIG_GPIO_SIOX is not set
CONFIG_GPIO_VX855=y

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_104_DIO_48E is not set
# CONFIG_GPIO_104_IDIO_16 is not set
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_GPIO_MM=y
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_CRYSTAL_COVE=y
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_LP873X is not set
CONFIG_GPIO_MSIC=y
CONFIG_GPIO_TIMBERDALE=y
# CONFIG_GPIO_TPS65086 is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TPS68470=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WHISKEY_COVE=y
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_INTEL_MID=y
CONFIG_GPIO_MERRIFIELD=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_PCI_IDIO_16=y
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX3191X=y
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_PISOSR=y
# CONFIG_GPIO_XRA1403 is not set
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2805=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2438 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_DS28E17=y
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_CHARGER_ADP5061=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
CONFIG_MANAGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_DA9150=y
CONFIG_CHARGER_AXP20X=y
CONFIG_BATTERY_AXP20X=y
CONFIG_AXP20X_POWER=y
CONFIG_AXP288_FUEL_GAUGE=y
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_BATTERY_MAX1721X is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_LP8788=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_LTC3651 is not set
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8997=y
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ASPEED=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
# CONFIG_SENSORS_DELL_SMM is not set
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6621=y
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_MLXREG_FAN is not set
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_NPCM7XX=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_IBM_CFFPS=y
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_LTC2978_REGULATOR=y
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_TPS53679=y
CONFIG_SENSORS_UCD9000=y
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_STTS751=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP108=y
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83773G=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_CLOCK_THERMAL=y
# CONFIG_DEVFREQ_THERMAL is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_X86_PKG_TEMP_THERMAL=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set
CONFIG_INTEL_QUARK_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
CONFIG_INT3406_THERMAL=y
# CONFIG_INTEL_BXT_PMIC_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_GENERIC_ADC_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_SFLASH=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_AT91_USART=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_BD9571MWV is not set
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_MFD_MADERA is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_INTEL_SOC_PMIC_BXTWC=y
CONFIG_INTEL_SOC_PMIC_CHTWC=y
CONFIG_INTEL_SOC_PMIC_CHTDC_TI=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
CONFIG_MFD_INTEL_MSIC=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS68470=y
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PG86X=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BCM590XX=y
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LM363X=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX8998 is not set
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_MT6311=y
# CONFIG_REGULATOR_MT6323 is not set
CONFIG_REGULATOR_MT6397=y
# CONFIG_REGULATOR_PCAP is not set
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
# CONFIG_REGULATOR_QCOM_SPMI is not set
# CONFIG_REGULATOR_SKY81452 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8994=y
CONFIG_CEC_CORE=y
CONFIG_CEC_NOTIFIER=y
# CONFIG_RC_CORE is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_MM=y
CONFIG_DRM_DEBUG_SELFTEST=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y
CONFIG_DRM_SCHED=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_I2C_NXP_TDA9950=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_AMDGPU=y
# CONFIG_DRM_AMDGPU_SI is not set
CONFIG_DRM_AMDGPU_CIK=y
# CONFIG_DRM_AMDGPU_USERPTR is not set
# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_AMD_ACP is not set

#
# Display Engine Configuration
#
# CONFIG_DRM_AMD_DC is not set

#
# AMD Library routines
#
CONFIG_CHASH=y
CONFIG_CHASH_STATS=y
# CONFIG_CHASH_SELFTEST is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_NOUVEAU_DEBUG_MMU=y
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
CONFIG_DRM_I915=y
CONFIG_DRM_I915_ALPHA_SUPPORT=y
# CONFIG_DRM_I915_CAPTURE_ERROR is not set
CONFIG_DRM_I915_USERPTR=y

#
# drm/i915 Debugging
#
CONFIG_DRM_I915_WERROR=y
CONFIG_DRM_I915_DEBUG=y
CONFIG_DRM_I915_DEBUG_GEM=y
CONFIG_DRM_I915_ERRLOG_GEM=y
# CONFIG_DRM_I915_TRACE_GEM is not set
CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS=y
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
CONFIG_DRM_I915_DEBUG_GUC=y
CONFIG_DRM_I915_SELFTEST=y
CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS=y
CONFIG_DRM_I915_DEBUG_VBLANK_EVADE=y
CONFIG_DRM_VGEM=y
CONFIG_DRM_VKMS=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN=y
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_HISI_HIBMC is not set
CONFIG_DRM_TINYDRM=y
CONFIG_TINYDRM_MIPI_DBI=y
# CONFIG_TINYDRM_ILI9225 is not set
CONFIG_TINYDRM_ILI9341=y
CONFIG_TINYDRM_MI0283QT=y
CONFIG_TINYDRM_REPAPER=y
CONFIG_TINYDRM_ST7586=y
CONFIG_TINYDRM_ST7735R=y
CONFIG_DRM_LEGACY=y
CONFIG_DRM_TDFX=y
# CONFIG_DRM_R128 is not set
CONFIG_DRM_MGA=y
# CONFIG_DRM_VIA is not set
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
CONFIG_FB_SM501=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_BACKLIGHT_RAVE_SP=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
# CONFIG_HID is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_DEBUG=y
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
# CONFIG_MMC_SDHCI_F_SDH30 is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_CB710=y
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MMC_CQHCI=y
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MMC_MTK=y
CONFIG_MMC_SDHCI_XENON=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_AS3645A is not set
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_LM3601X=y
CONFIG_LEDS_MT6323=y
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=y
# CONFIG_LEDS_MAX8997 is not set
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_MLXREG is not set
CONFIG_LEDS_USER=y
CONFIG_LEDS_NIC78BX=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_ACTIVITY=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_LEDS_TRIGGER_NETDEV=y
# CONFIG_LEDS_TRIGGER_PATTERN is not set
CONFIG_ACCESSIBILITY=y
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_ADDR_TRANS_CONFIGFS=y
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
# CONFIG_MLX4_INFINIBAND is not set
CONFIG_INFINIBAND_NES=y
CONFIG_INFINIBAND_NES_DEBUG=y
# CONFIG_INFINIBAND_OCRDMA is not set
# CONFIG_INFINIBAND_IPOIB is not set
# CONFIG_RDMA_RXE is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_AMD76X is not set
CONFIG_EDAC_E7XXX=y
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82875P=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_IE31200=y
# CONFIG_EDAC_X38 is not set
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
CONFIG_EDAC_I82860=y
CONFIG_EDAC_R82600=y
CONFIG_EDAC_I5000=y
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_ALTERA_MSGDMA=y
CONFIG_INTEL_IDMA64=y
CONFIG_PCH_DMA=y
CONFIG_TIMB_DMA=y
# CONFIG_QCOM_HIDMA_MGMT is not set
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y
CONFIG_HSU_DMA_PCI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_PRUSS=y
CONFIG_UIO_MF624=y
CONFIG_IRQ_BYPASS_MANAGER=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VBOXGUEST=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_COMEDI is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
# CONFIG_ADIS16203 is not set
CONFIG_ADIS16240=y

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
CONFIG_AD7780=y
CONFIG_AD7816=y
CONFIG_AD7192=y
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
CONFIG_AD9834=y

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Active energy metering IC
#
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
# CONFIG_ADE7854_SPI is not set

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
CONFIG_AD2S1210=y
# CONFIG_FB_SM750 is not set
CONFIG_FB_XGI=y

#
# Speakup console speech
#
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ASHMEM is not set
CONFIG_ION=y
# CONFIG_ION_SYSTEM_HEAP is not set
CONFIG_ION_CARVEOUT_HEAP=y
# CONFIG_ION_CHUNK_HEAP is not set
# CONFIG_DGNC is not set
CONFIG_GS_FPGABOOT=y
# CONFIG_UNISYSSPAR is not set
CONFIG_FB_TFT=y
CONFIG_FB_TFT_AGM1264K_FL=y
CONFIG_FB_TFT_BD663474=y
# CONFIG_FB_TFT_HX8340BN is not set
# CONFIG_FB_TFT_HX8347D is not set
CONFIG_FB_TFT_HX8353D=y
# CONFIG_FB_TFT_HX8357D is not set
# CONFIG_FB_TFT_ILI9163 is not set
CONFIG_FB_TFT_ILI9320=y
CONFIG_FB_TFT_ILI9325=y
CONFIG_FB_TFT_ILI9340=y
CONFIG_FB_TFT_ILI9341=y
# CONFIG_FB_TFT_ILI9481 is not set
CONFIG_FB_TFT_ILI9486=y
# CONFIG_FB_TFT_PCD8544 is not set
CONFIG_FB_TFT_RA8875=y
CONFIG_FB_TFT_S6D02A1=y
CONFIG_FB_TFT_S6D1121=y
# CONFIG_FB_TFT_SH1106 is not set
CONFIG_FB_TFT_SSD1289=y
CONFIG_FB_TFT_SSD1305=y
# CONFIG_FB_TFT_SSD1306 is not set
CONFIG_FB_TFT_SSD1331=y
# CONFIG_FB_TFT_SSD1351 is not set
# CONFIG_FB_TFT_ST7735R is not set
CONFIG_FB_TFT_ST7789V=y
CONFIG_FB_TFT_TINYLCD=y
# CONFIG_FB_TFT_TLS8204 is not set
CONFIG_FB_TFT_UC1611=y
CONFIG_FB_TFT_UC1701=y
# CONFIG_FB_TFT_UPD161704 is not set
# CONFIG_FB_TFT_WATTEROTT is not set
# CONFIG_FB_FLEX is not set
# CONFIG_FB_TFT_FBTFT_DEVICE is not set
CONFIG_MOST=y
CONFIG_MOST_CDEV=y
CONFIG_MOST_NET=y
CONFIG_MOST_I2C=y
CONFIG_KS7010=y
CONFIG_GREYBUS=y
CONFIG_GREYBUS_BOOTROM=y
CONFIG_GREYBUS_FIRMWARE=y
CONFIG_GREYBUS_LIGHT=y
CONFIG_GREYBUS_LOG=y
CONFIG_GREYBUS_LOOPBACK=y
# CONFIG_GREYBUS_POWER is not set
# CONFIG_GREYBUS_RAW is not set
CONFIG_GREYBUS_VIBRATOR=y
CONFIG_GREYBUS_BRIDGED_PHY=y
CONFIG_GREYBUS_GPIO=y
# CONFIG_GREYBUS_I2C is not set
# CONFIG_GREYBUS_SDIO is not set
CONFIG_GREYBUS_SPI=y
# CONFIG_GREYBUS_UART is not set
CONFIG_DRM_VBOXVIDEO=y
# CONFIG_PI433 is not set
CONFIG_MTK_MMC=y
CONFIG_MTK_AEE_KDUMP=y
CONFIG_MTK_MMC_CD_POLL=y

#
# Gasket devices
#
CONFIG_XIL_AXIS_FIFO=y
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACER_WIRELESS=y
CONFIG_ACERHDF=y
# CONFIG_ALIENWARE_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_SMBIOS is not set
CONFIG_DELL_WMI_AIO=y
CONFIG_DELL_WMI_LED=y
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_TABLET=y
# CONFIG_AMILO_RFKILL is not set
CONFIG_GPD_POCKET_FAN=y
# CONFIG_TC1100_WMI is not set
CONFIG_HP_ACCEL=y
CONFIG_HP_WIRELESS=y
# CONFIG_HP_WMI is not set
# CONFIG_MSI_LAPTOP is not set
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
# CONFIG_SONY_LAPTOP is not set
CONFIG_IDEAPAD_LAPTOP=y
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
CONFIG_ASUS_WMI=y
# CONFIG_ASUS_NB_WMI is not set
CONFIG_EEEPC_WMI=y
CONFIG_ASUS_WIRELESS=y
CONFIG_ACPI_WMI=y
# CONFIG_WMI_BMOF is not set
CONFIG_INTEL_WMI_THUNDERBOLT=y
CONFIG_MSI_WMI=y
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
# CONFIG_TOSHIBA_BT_RFKILL is not set
CONFIG_TOSHIBA_HAPS=y
CONFIG_TOSHIBA_WMI=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_INT0002_VGPIO is not set
CONFIG_INTEL_HID_EVENT=y
# CONFIG_INTEL_VBTN is not set
CONFIG_INTEL_SCU_IPC=y
# CONFIG_INTEL_SCU_IPC_UTIL is not set
# CONFIG_INTEL_MID_POWER_BUTTON is not set
CONFIG_INTEL_MFLD_THERMAL=y
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_IMR=y
CONFIG_INTEL_PMC_CORE=y
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
# CONFIG_SAMSUNG_Q10 is not set
CONFIG_APPLE_GMUX=y
CONFIG_INTEL_RST=y
CONFIG_INTEL_SMARTCONNECT=y
CONFIG_PVPANIC=y
CONFIG_INTEL_PMC_IPC=y
CONFIG_INTEL_BXTWC_PMIC_TMU=y
CONFIG_SURFACE_PRO3_BUTTON=y
# CONFIG_SURFACE_3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_PLATFORM=y
CONFIG_INTEL_CHTDC_TI_PWRBTN=y
CONFIG_I2C_MULTI_INSTANTIATE=y
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
# CONFIG_CHROMEOS_TBMC is not set
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_MELLANOX_PLATFORM=y
CONFIG_MLXREG_HOTPLUG=y
CONFIG_MLXREG_IO=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
CONFIG_COMMON_CLK_MAX9485=y
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI544=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_CLK_TWL6040=y
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_DW_APB_TIMER=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_VIRTIO is not set
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# NXP/Freescale QorIQ SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
# CONFIG_XILINX_VCU is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_AXP288 is not set
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_INTEL_INT3496=y
CONFIG_EXTCON_INTEL_CHT_WC=y
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
# CONFIG_EXTCON_MAX77693 is not set
# CONFIG_EXTCON_MAX77843 is not set
CONFIG_EXTCON_MAX8997=y
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
# CONFIG_IIO_BUFFER_HW_CONSUMER is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16209=y
CONFIG_BMA180=y
# CONFIG_BMA220 is not set
# CONFIG_BMC150_ACCEL is not set
CONFIG_DA280=y
# CONFIG_DA311 is not set
CONFIG_DMARD09=y
CONFIG_DMARD10=y
CONFIG_IIO_CROS_EC_ACCEL_LEGACY=y
CONFIG_KXSD9=y
CONFIG_KXSD9_SPI=y
CONFIG_KXSD9_I2C=y
# CONFIG_KXCJK1013 is not set
CONFIG_MC3230=y
CONFIG_MMA7455=y
# CONFIG_MMA7455_I2C is not set
CONFIG_MMA7455_SPI=y
CONFIG_MMA7660=y
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
# CONFIG_MMA9553 is not set
# CONFIG_MXC4005 is not set
# CONFIG_MXC6255 is not set
CONFIG_SCA3000=y
CONFIG_STK8312=y
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
CONFIG_AD7298=y
# CONFIG_AD7476 is not set
CONFIG_AD7766=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
# CONFIG_AD799X is not set
CONFIG_AXP20X_ADC=y
# CONFIG_AXP288_ADC is not set
# CONFIG_CC10001_ADC is not set
# CONFIG_DA9150_GPADC is not set
# CONFIG_HI8435 is not set
# CONFIG_HX711 is not set
CONFIG_LP8788_ADC=y
# CONFIG_LTC2471 is not set
CONFIG_LTC2485=y
# CONFIG_LTC2497 is not set
CONFIG_MAX1027=y
# CONFIG_MAX11100 is not set
CONFIG_MAX1118=y
# CONFIG_MAX1363 is not set
CONFIG_MAX9611=y
# CONFIG_MCP320X is not set
CONFIG_MCP3422=y
# CONFIG_MEN_Z188_ADC is not set
# CONFIG_NAU7802 is not set
CONFIG_QCOM_VADC_COMMON=y
# CONFIG_QCOM_SPMI_IADC is not set
CONFIG_QCOM_SPMI_VADC=y
CONFIG_STX104=y
CONFIG_TI_ADC081C=y
CONFIG_TI_ADC0832=y
CONFIG_TI_ADC084S021=y
# CONFIG_TI_ADC12138 is not set
CONFIG_TI_ADC108S102=y
CONFIG_TI_ADC128S052=y
CONFIG_TI_ADC161S626=y
CONFIG_TI_ADS7950=y
CONFIG_TI_AM335X_ADC=y
# CONFIG_TI_TLC4541 is not set

#
# Analog Front Ends
#

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
# CONFIG_BME680 is not set
# CONFIG_CCS811 is not set
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=y
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#
CONFIG_104_QUAD_8=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
CONFIG_AD5421=y
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
CONFIG_AD5593R=y
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
# CONFIG_LTC2632 is not set
CONFIG_AD5686=y
CONFIG_AD5686_SPI=y
# CONFIG_AD5696_I2C is not set
# CONFIG_AD5755 is not set
# CONFIG_AD5758 is not set
CONFIG_AD5761=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
# CONFIG_CIO_DAC is not set
CONFIG_AD8801=y
CONFIG_DS4424=y
CONFIG_M62332=y
# CONFIG_MAX517 is not set
CONFIG_MCP4725=y
# CONFIG_MCP4922 is not set
# CONFIG_TI_DAC082S085 is not set
# CONFIG_TI_DAC5571 is not set

#
# IIO dummy driver
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
# CONFIG_ADIS16136 is not set
CONFIG_ADIS16260=y
CONFIG_ADXRS450=y
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_BMG160_SPI=y
CONFIG_MPU3050=y
CONFIG_MPU3050_I2C=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4403 is not set
CONFIG_AFE4404=y
CONFIG_MAX30100=y
CONFIG_MAX30102=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
CONFIG_HDC100X=y
CONFIG_HTS221=y
CONFIG_HTS221_I2C=y
CONFIG_HTS221_SPI=y
CONFIG_HTU21=y
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
CONFIG_ADIS16480=y
CONFIG_BMI160=y
# CONFIG_BMI160_I2C is not set
CONFIG_BMI160_SPI=y
# CONFIG_KMX61 is not set
# CONFIG_INV_MPU6050_I2C is not set
# CONFIG_INV_MPU6050_SPI is not set
# CONFIG_IIO_ST_LSM6DSX is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ACPI_ALS=y
# CONFIG_ADJD_S311 is not set
CONFIG_AL3320A=y
# CONFIG_APDS9300 is not set
CONFIG_APDS9960=y
CONFIG_BH1750=y
CONFIG_BH1780=y
CONFIG_CM32181=y
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
# CONFIG_CM36651 is not set
CONFIG_GP2AP020A00F=y
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_ISL29125=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
CONFIG_LV0104CS=y
CONFIG_MAX44000=y
CONFIG_OPT3001=y
CONFIG_PA12203001=y
# CONFIG_SI1133 is not set
# CONFIG_SI1145 is not set
# CONFIG_STK3310 is not set
CONFIG_ST_UVIS25=y
CONFIG_ST_UVIS25_I2C=y
CONFIG_ST_UVIS25_SPI=y
CONFIG_TCS3414=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL2583=y
CONFIG_TSL2772=y
CONFIG_TSL4531=y
CONFIG_US5182D=y
CONFIG_VCNL4000=y
CONFIG_VEML6070=y
CONFIG_VL6180=y
# CONFIG_ZOPT2201 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_BMC150_MAGN_SPI=y
CONFIG_MAG3110=y
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
CONFIG_SENSORS_HMC5843_SPI=y

#
# Multiplexers
#

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
# CONFIG_AD5272 is not set
CONFIG_DS1803=y
# CONFIG_MAX5481 is not set
CONFIG_MAX5487=y
CONFIG_MCP4018=y
CONFIG_MCP4131=y
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set

#
# Pressure sensors
#
CONFIG_ABP060MG=y
# CONFIG_BMP280 is not set
CONFIG_HP03=y
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
CONFIG_MPL115_SPI=y
CONFIG_MPL3115=y
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
CONFIG_MS5611_SPI=y
# CONFIG_MS5637 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
# CONFIG_T5403 is not set
# CONFIG_HP206C is not set
# CONFIG_ZPA2326 is not set

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_ISL29501=y
CONFIG_LIDAR_LITE_V2=y
# CONFIG_RFD77402 is not set
CONFIG_SRF04=y
CONFIG_SX9500=y
CONFIG_SRF08=y

#
# Resolver to digital converters
#
CONFIG_AD2S1200=y

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=y
CONFIG_MLX90614=y
CONFIG_MLX90632=y
# CONFIG_TMP006 is not set
CONFIG_TMP007=y
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
CONFIG_NTB=y
CONFIG_NTB_IDT=y
CONFIG_NTB_SWITCHTEC=y
CONFIG_NTB_PINGPONG=y
CONFIG_NTB_TOOL=y
CONFIG_NTB_PERF=y
# CONFIG_NTB_TRANSPORT is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
# CONFIG_VME_CA91CX42 is not set
# CONFIG_VME_TSI148 is not set
# CONFIG_VME_FAKE is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_VME_USER=y
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_TI_SYSCON=y
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_PHY_CPCAP_USB is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=y
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_RAS_CEC=y
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
# CONFIG_DAX is not set
CONFIG_NVMEM=y
CONFIG_RAVE_SP_EEPROM=y

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_PROTO_BASIC=y
CONFIG_STM_PROTO_SYS_T=y
CONFIG_STM_DUMMY=y
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
# CONFIG_STM_SOURCE_FTRACE is not set
# CONFIG_INTEL_TH is not set
CONFIG_FPGA=y
# CONFIG_ALTERA_PR_IP_CORE is not set
CONFIG_FPGA_MGR_ALTERA_PS_SPI=y
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_MGR_XILINX_SPI=y
# CONFIG_FPGA_MGR_MACHXO2_SPI is not set
CONFIG_FPGA_BRIDGE=y
# CONFIG_XILINX_PR_DECOUPLER is not set
CONFIG_FPGA_REGION=y
CONFIG_FPGA_DFL=y
CONFIG_FPGA_DFL_FME=y
CONFIG_FPGA_DFL_FME_MGR=y
# CONFIG_FPGA_DFL_FME_BRIDGE is not set
CONFIG_FPGA_DFL_FME_REGION=y
# CONFIG_FPGA_DFL_AFU is not set
CONFIG_FPGA_DFL_PCI=y
CONFIG_PM_OPP=y
CONFIG_SIOX=y
# CONFIG_SIOX_BUS_GPIO is not set
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
CONFIG_MEMFD_CREATE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_EFIVAR_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_SUNRPC_XPRT_RDMA=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS2 is not set
# CONFIG_CIFS_ALLOW_INSECURE_LEGACY is not set
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
# CONFIG_CIFS_POSIX is not set
# CONFIG_CIFS_ACL is not set
# CONFIG_CIFS_DEBUG is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB_DIRECT is not set
CONFIG_CIFS_FSCACHE=y
CONFIG_CODA_FS=y
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
# CONFIG_9P_FSCACHE is not set
# CONFIG_9P_FS_POSIX_ACL is not set
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
CONFIG_FORTIFY_SOURCE=y
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
# CONFIG_CRYPTO_AEGIS128 is not set
CONFIG_CRYPTO_AEGIS128L=y
# CONFIG_CRYPTO_AEGIS256 is not set
CONFIG_CRYPTO_MORUS640=y
# CONFIG_CRYPTO_MORUS1280 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_OFB=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_ZSTD=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_AEAD=y
# CONFIG_CRYPTO_STATS is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC64=y
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_SGL_ALLOC=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_STACKDEPOT=y
CONFIG_PRIME_NUMBERS=y
CONFIG_STRING_SELFTEST=y

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
CONFIG_PAGE_POISONING_ZERO=y
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_RWSEMS=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_FAIL_MMC_REQUEST=y
CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
CONFIG_HWLAT_TRACER=y
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
# CONFIG_STACK_TRACER is not set
# CONFIG_UPROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_EVAL_MAP_FILE=y
CONFIG_TRACING_EVENTS_GPIO=y
CONFIG_GCOV_PROFILE_FTRACE=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
CONFIG_MEMTEST=y
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
CONFIG_IO_STRICT_DEVMEM=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_DEBUG_IMR_SELFTEST is not set
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=y
CONFIG_UNWINDER_FRAME_POINTER=y

--dgjlcl3Tl+kb3YDk--
