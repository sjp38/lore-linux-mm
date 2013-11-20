Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 692616B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 03:44:48 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so7097516pde.7
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 00:44:48 -0800 (PST)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id yj7si7471534pab.315.2013.11.20.00.44.45
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 00:44:46 -0800 (PST)
Received: by mail-vc0-f173.google.com with SMTP id ia6so782676vcb.18
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 00:44:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 20 Nov 2013 12:44:44 +0400
Message-ID: <CANaxB-x3k8DPEaDCtCzhkuyPcwR1YcRJZwXW777+q+y2KBvzHg@mail.gmail.com>
Subject: Re: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot be
 embedded to struct page
From: Andrey Wagin <avagin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org

Hi Kirill,

Looks like this patch adds memory leaks.
[  116.188310] kmemleak: 15672 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
unreferenced object 0xffff8800da45a350 (size 96):
  comm "dracut-initqueu", pid 93, jiffies 4294671391 (age 362.277s)
  hex dump (first 32 bytes):
    07 00 07 00 ad 4e ad de ff ff ff ff 6b 6b 6b 6b  .....N......kkkk
    ff ff ff ff ff ff ff ff 80 24 b4 82 ff ff ff ff  .........$......
  backtrace:
    [<ffffffff817152fe>] kmemleak_alloc+0x5e/0xc0
    [<ffffffff811c34f3>] kmem_cache_alloc_trace+0x113/0x290
    [<ffffffff811920f7>] __ptlock_alloc+0x27/0x50
    [<ffffffff81192849>] __pmd_alloc+0x59/0x170
    [<ffffffff81195ffa>] copy_page_range+0x38a/0x3e0
    [<ffffffff8105a013>] dup_mm+0x313/0x540
    [<ffffffff8105b9da>] copy_process+0x161a/0x1880
    [<ffffffff8105c01b>] do_fork+0x8b/0x360
    [<ffffffff8105c306>] SyS_clone+0x16/0x20
    [<ffffffff81727b79>] stub_clone+0x69/0x90
    [<ffffffffffffffff>] 0xffffffffffffffff

It's quite serious, because my test host went to panic in a few hours.

[12000.632734] kmemleak: 74155 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[12080.734075] zombie00[29282]: segfault at 0 ip 0000000000401862 sp
00007fffc509bc20 error 6 in zombie00[400000+5000]
[12619.799052] BUG: unable to handle kernel paging request at 000000007aa9e3a0
[12619.800044] IP: [<ffffffff810b2c07>] cpuacct_charge+0x97/0x1e0
[12619.800044] PGD 0
[12619.800044] Thread overran stack, or stack corrupted
[12619.800044] Oops: 0000 [#1] SMP
[12619.800044] Modules linked in: binfmt_misc ip6table_filter
ip6_tables tun netlink_diag af_packet_diag udp_diag tcp_diag inet_diag
unix_diag joydev microcode pcspkr i2c_piix4 virtio_balloon virtio_net
i2c_core virtio_blk floppy
[12619.800044] CPU: 1 PID: 1324 Comm: kworker/u4:2 Not tainted 3.12.0+ #142
[12619.800044] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
[12619.800044] Workqueue: writeback bdi_writeback_workfn (flush-252:0)
[12619.800044] task: ffff88001f1a8000 ti: ffff880096f26000 task.ti:
ffff880096f26000
[12619.800044] RIP: 0010:[<ffffffff810b2c07>]  [<ffffffff810b2c07>]
cpuacct_charge+0x97/0x1e0
[12619.800044] RSP: 0018:ffff88011b403ce8  EFLAGS: 00010002
[12619.800044] RAX: 000000000000d580 RBX: 00000000000f11b1 RCX: 0000000000000003
[12619.800044] RDX: ffffffff81c49e40 RSI: ffffffff81c4bb00 RDI: ffff88001f1a8c68
[12619.800044] RBP: ffff88011b403d18 R08: 0000000000000001 R09: 0000000000000001
[12619.800044] R10: 0000000000000001 R11: 0000000000000007 R12: ffff88001f1a8000
[12619.800044] R13: 000000001f1a8000 R14: ffffffff82a86320 R15: 000006b1bda1e433
[12619.800044] FS:  0000000000000000(0000) GS:ffff88011b400000(0000)
knlGS:0000000000000000
[12619.800044] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[12619.800044] CR2: 000000007aa9e3a0 CR3: 0000000001c0b000 CR4: 00000000000006e0
[12619.800044] Stack:
[12619.800044]  ffffffff810b2b70 0000000000000002 ffff88011b5d40c0
00000000000f11b1
[12619.800044]  ffff88001f1a8068 ffff88001f1a8000 ffff88011b403d58
ffffffff810a108f
[12619.800044]  ffff88011b403d88 ffff88001f1a8068 ffff88011b5d40c0
ffff88011b5d4000
[12619.800044] Call Trace:
[12619.800044]  <IRQ>
[12619.800044]  [<ffffffff810b2b70>] ? cpuacct_css_alloc+0xb0/0xb0
[12619.800044]  [<ffffffff810a108f>] update_curr+0x13f/0x230
[12619.800044]  [<ffffffff810a9e57>] task_tick_fair+0x2d7/0x650
[12619.800044]  [<ffffffff8109dcc8>] ? sched_clock_cpu+0xb8/0x120
[12619.800044]  [<ffffffff8109482d>] scheduler_tick+0x6d/0xf0
[12619.800044]  [<ffffffff8106afd1>] update_process_times+0x61/0x80
[12619.800044]  [<ffffffff810e38c7>] tick_sched_handle+0x37/0x80
[12619.800044]  [<ffffffff810e3e74>] tick_sched_timer+0x54/0x90
[12619.800044]  [<ffffffff8108bd21>] __run_hrtimer+0x71/0x2d0
[12619.800044]  [<ffffffff810e3e20>] ? tick_nohz_handler+0xc0/0xc0
[12619.800044]  [<ffffffff8108c246>] hrtimer_interrupt+0x116/0x2a0
[12619.800044]  [<ffffffff81062959>] ? __local_bh_enable+0x49/0x70
[12619.800044]  [<ffffffff81033dcb>] local_apic_timer_interrupt+0x3b/0x60
[12619.800044]  [<ffffffff81727c05>] smp_apic_timer_interrupt+0x45/0x60
[12619.800044]  [<ffffffff8172686f>] apic_timer_interrupt+0x6f/0x80
[12619.800044]  <EOI>
[12619.800044]  [<ffffffff810b8e10>] ? mark_held_locks+0x90/0x150
[12619.800044]  [<ffffffff8171c6f2>] ? _raw_spin_unlock_irqrestore+0x42/0x70
[12619.800044]  [<ffffffffa001b71b>] virtio_queue_rq+0xdb/0x1b0 [virtio_blk]
[12619.800044]  [<ffffffff8134647a>] __blk_mq_run_hw_queue+0x1ca/0x520
[12619.800044]  [<ffffffff81346b35>] blk_mq_run_hw_queue+0x35/0x40
[12619.800044]  [<ffffffff813470f2>] blk_mq_insert_requests+0xe2/0x190
[12619.800044]  [<ffffffff813472d4>] blk_mq_flush_plug_list+0x134/0x150
[12619.800044]  [<ffffffff8133d0cd>] blk_flush_plug_list+0xbd/0x220
[12619.800044]  [<ffffffff81346f1a>] blk_mq_make_request+0x3da/0x4d0
[12619.800044]  [<ffffffff813397aa>] generic_make_request+0xca/0x100
[12619.800044]  [<ffffffff81339856>] submit_bio+0x76/0x160
[12619.800044]  [<ffffffff81173c66>] ? test_set_page_writeback+0x36/0x2b0
[12619.800044]  [<ffffffff811a9ae0>] ? end_swap_bio_read+0xc0/0xc0
[12619.800044]  [<ffffffff811a96c8>] __swap_writepage+0x198/0x230
[12619.800044]  [<ffffffff8171c74b>] ? _raw_spin_unlock+0x2b/0x40
[12619.800044]  [<ffffffff811aaf93>] ? page_swapcount+0x53/0x70
[12619.800044]  [<ffffffff811a97a3>] swap_writepage+0x43/0x90
[12619.800044]  [<ffffffff8117c3df>] shrink_page_list+0x6cf/0xaa0
[12619.800044]  [<ffffffff8117d452>] shrink_inactive_list+0x1c2/0x5b0
[12619.800044]  [<ffffffff810b976f>] ? __lock_acquire+0x23f/0x1810
[12619.800044]  [<ffffffff8117dea5>] shrink_lruvec+0x335/0x600
[12619.800044]  [<ffffffff811d24f5>] ? mem_cgroup_iter+0x1f5/0x510
[12619.800044]  [<ffffffff8117e206>] shrink_zone+0x96/0x1d0
[12619.800044]  [<ffffffff8117ec83>] do_try_to_free_pages+0x103/0x600
[12619.800044]  [<ffffffff8109dba5>] ? sched_clock_local+0x25/0x90
[12619.800044]  [<ffffffff8117f692>] try_to_free_pages+0x222/0x440
[12619.800044]  [<ffffffff8117233f>] __alloc_pages_nodemask+0x8af/0xc70
[12619.800044]  [<ffffffff811b7fce>] alloc_pages_current+0x10e/0x1e0
[12619.800044]  [<ffffffff81167077>] ? __page_cache_alloc+0x127/0x160
[12619.800044]  [<ffffffff81167077>] __page_cache_alloc+0x127/0x160
[12619.800044]  [<ffffffff8116864f>] find_or_create_page+0x4f/0xb0
[12619.800044]  [<ffffffff8121c369>] __getblk+0x109/0x300
[12619.800044]  [<ffffffff8121c572>] __breadahead+0x12/0x40
[12619.800044]  [<ffffffff8127cf7d>] __ext4_get_inode_loc+0x30d/0x430
[12619.800044]  [<ffffffff8127d1ef>] ext4_get_inode_loc+0x1f/0x30
[12619.800044]  [<ffffffff8127d22d>] ext4_reserve_inode_write+0x2d/0xa0
[12619.800044]  [<ffffffff8127d305>] ext4_mark_inode_dirty+0x65/0x2b0
[12619.800044]  [<ffffffff812a3d7b>] __ext4_ext_dirty+0x7b/0x80
[12619.800044]  [<ffffffff812a4c97>] ext4_ext_insert_extent+0x417/0x12d0
[12619.800044]  [<ffffffff811c3eaf>] ? __kmalloc+0x1bf/0x2e0
[12619.800044]  [<ffffffff812a758b>] ext4_ext_map_blocks+0x57b/0xfb0
[12619.800044]  [<ffffffff8127a5e6>] ? ext4_map_blocks+0x126/0x470
[12619.800044]  [<ffffffff8127a624>] ext4_map_blocks+0x164/0x470
[12619.800044]  [<ffffffff8127fba5>] ext4_writepages+0x6a5/0xc80
[12619.800044]  [<ffffffff8109dba5>] ? sched_clock_local+0x25/0x90
[12619.800044]  [<ffffffff8109dd7f>] ? local_clock+0x4f/0x60
[12619.800044]  [<ffffffff81175313>] do_writepages+0x23/0x40
[12619.800044]  [<ffffffff81210995>] __writeback_single_inode+0x45/0x3c0
[12619.800044]  [<ffffffff81213c9f>] writeback_sb_inodes+0x28f/0x520
[12619.800044]  [<ffffffff8171c74b>] ? _raw_spin_unlock+0x2b/0x40
[12619.800044]  [<ffffffff81213fce>] __writeback_inodes_wb+0x9e/0xd0
[12619.800044]  [<ffffffff8121429b>] wb_writeback+0x29b/0x540
[12619.800044]  [<ffffffff810b918d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
[12619.800044]  [<ffffffff8121459d>] ? wb_do_writeback+0x5d/0x290
[12619.800044]  [<ffffffff812145b2>] wb_do_writeback+0x72/0x290
[12619.800044]  [<ffffffff8109dcc8>] ? sched_clock_cpu+0xb8/0x120
[12619.800044]  [<ffffffff81214840>] bdi_writeback_workfn+0x70/0x320
[12619.800044]  [<ffffffff8107eea6>] ? process_one_work+0x176/0x610
[12619.800044]  [<ffffffff8107ef0e>] process_one_work+0x1de/0x610
[12619.800044]  [<ffffffff8107eea6>] ? process_one_work+0x176/0x610
[12619.800044]  [<ffffffff81080e40>] worker_thread+0x120/0x3a0
[12619.800044]  [<ffffffff81080d20>] ? manage_workers+0x2c0/0x2c0
[12619.800044]  [<ffffffff81087f26>] kthread+0xf6/0x120
[12619.800044]  [<ffffffff8109dd7f>] ? local_clock+0x4f/0x60
[12619.800044]  [<ffffffff81087e30>] ? __init_kthread_worker+0x70/0x70
[12619.800044]  [<ffffffff81725b6c>] ret_from_fork+0x7c/0xb0
[12619.800044]  [<ffffffff81087e30>] ? __init_kthread_worker+0x70/0x70
[12619.800044] Code: 00 00 e8 fd 03 02 00 85 c0 74 0d 80 3d 51 e5 c8
00 00 0f 84 d4 00 00 00 49 8b 56 48 4d 63 ed 0f 1f 44 00 00 48 8b 82
b8 00 00 00 <4a> 03 04 ed a0 e3 d5 81 48 01 18 48 8b 52 40 48 85 d2 75
e5 e8
[12619.800044] RIP  [<ffffffff810b2c07>] cpuacct_charge+0x97/0x1e0
[12619.800044]  RSP <ffff88011b403ce8>
[12619.800044] CR2: 000000007aa9e3a0

2013/10/10 Kirill A. Shutemov <kirill.shutemov@linux.intel.com>:
> If split page table lock is in use, we embed the lock into struct page
> of table's page. We have to disable split lock, if spinlock_t is too big
> be to be embedded, like when DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC enabled.
>
> This patch add support for dynamic allocation of split page table lock
> if we can't embed it to struct page.
>
> page->ptl is unsigned long now and we use it as spinlock_t if
> sizeof(spinlock_t) <= sizeof(long), otherwise it's pointer to
> spinlock_t.
>
> The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
> pgtable_pmd_page_ctor() for PMD table. All other helpers converted to
> support dynamically allocated page->ptl.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/split_page_table_lock | 90 ++++++++++++++++++++++++++++++++++
>  arch/x86/xen/mmu.c                     |  2 +-
>  include/linux/mm.h                     | 72 +++++++++++++++++++--------
>  include/linux/mm_types.h               |  5 +-
>  mm/Kconfig                             |  2 -
>  mm/memory.c                            | 19 +++++++
>  6 files changed, 166 insertions(+), 24 deletions(-)
>  create mode 100644 Documentation/vm/split_page_table_lock
>
> diff --git a/Documentation/vm/split_page_table_lock b/Documentation/vm/split_page_table_lock
> new file mode 100644
> index 0000000000..e2f617b732
> --- /dev/null
> +++ b/Documentation/vm/split_page_table_lock
> @@ -0,0 +1,90 @@
> +Split page table lock
> +=====================
> +
> +Originally, mm->page_table_lock spinlock protected all page tables of the
> +mm_struct. But this approach leads to poor page fault scalability of
> +multi-threaded applications due high contention on the lock. To improve
> +scalability, split page table lock was introduced.
> +
> +With split page table lock we have separate per-table lock to serialize
> +access to the table. At the moment we use split lock for PTE and PMD
> +tables. Access to higher level tables protected by mm->page_table_lock.
> +
> +There are helpers to lock/unlock a table and other accessor functions:
> + - pte_offset_map_lock()
> +       maps pte and takes PTE table lock, returns pointer to the taken
> +       lock;
> + - pte_unmap_unlock()
> +       unlocks and unmaps PTE table;
> + - pte_alloc_map_lock()
> +       allocates PTE table if needed and take the lock, returns pointer
> +       to taken lock or NULL if allocation failed;
> + - pte_lockptr()
> +       returns pointer to PTE table lock;
> + - pmd_lock()
> +       takes PMD table lock, returns pointer to taken lock;
> + - pmd_lockptr()
> +       returns pointer to PMD table lock;
> +
> +Split page table lock for PTE tables is enabled compile-time if
> +CONFIG_SPLIT_PTLOCK_CPUS (usually 4) is less or equal to NR_CPUS.
> +If split lock is disabled, all tables guaded by mm->page_table_lock.
> +
> +Split page table lock for PMD tables is enabled, if it's enabled for PTE
> +tables and the architecture supports it (see below).
> +
> +Hugetlb and split page table lock
> +---------------------------------
> +
> +Hugetlb can support several page sizes. We use split lock only for PMD
> +level, but not for PUD.
> +
> +Hugetlb-specific helpers:
> + - huge_pte_lock()
> +       takes pmd split lock for PMD_SIZE page, mm->page_table_lock
> +       otherwise;
> + - huge_pte_lockptr()
> +       returns pointer to table lock;
> +
> +Support of split page table lock by an architecture
> +---------------------------------------------------
> +
> +There's no need in special enabling of PTE split page table lock:
> +everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
> +which must be called on PTE table allocation / freeing.
> +
> +PMD split lock only makes sense if you have more than two page table
> +levels.
> +
> +PMD split lock enabling requires pgtable_pmd_page_ctor() call on PMD table
> +allocation and pgtable_pmd_page_dtor() on freeing.
> +
> +Allocation usually happens in pmd_alloc_one(), freeing in pmd_free(), but
> +make sure you cover all PMD table allocation / freeing paths: i.e X86_PAE
> +preallocate few PMDs on pgd_alloc().
> +
> +With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
> +
> +NOTE: pgtable_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
> +be handled properly.
> +
> +page->ptl
> +---------
> +
> +page->ptl is used to access split page table lock, where 'page' is struct
> +page of page containing the table. It shares storage with page->private
> +(and few other fields in union).
> +
> +To avoid increasing size of struct page and have best performance, we use a
> +trick:
> + - if spinlock_t fits into long, we use page->ptr as spinlock, so we
> +   can avoid indirect access and save a cache line.
> + - if size of spinlock_t is bigger then size of long, we use page->ptl as
> +   pointer to spinlock_t and allocate it dynamically. This allows to use
> +   split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but costs
> +   one more cache line for indirect access;
> +
> +The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
> +pgtable_pmd_page_ctor() for PMD table.
> +
> +Please, never access page->ptl directly -- use appropriate helper.
> diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
> index 455c873ce0..49c962fe7e 100644
> --- a/arch/x86/xen/mmu.c
> +++ b/arch/x86/xen/mmu.c
> @@ -797,7 +797,7 @@ static spinlock_t *xen_pte_lock(struct page *page, struct mm_struct *mm)
>         spinlock_t *ptl = NULL;
>
>  #if USE_SPLIT_PTE_PTLOCKS
> -       ptl = __pte_lockptr(page);
> +       ptl = ptlock_ptr(page);
>         spin_lock_nest_lock(ptl, &mm->page_table_lock);
>  #endif
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f6467032a9..658e8b317f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1233,32 +1233,64 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
>  #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
>
>  #if USE_SPLIT_PTE_PTLOCKS
> -/*
> - * We tuck a spinlock to guard each pagetable page into its struct page,
> - * at page->private, with BUILD_BUG_ON to make sure that this will not
> - * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
> - * When freeing, reset page->mapping so free_pages_check won't complain.
> - */
> -#define __pte_lockptr(page)    &((page)->ptl)
> -#define pte_lock_init(_page)   do {                                    \
> -       spin_lock_init(__pte_lockptr(_page));                           \
> -} while (0)
> -#define pte_lock_deinit(page)  ((page)->mapping = NULL)
> -#define pte_lockptr(mm, pmd)   ({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
> +bool __ptlock_alloc(struct page *page);
> +void __ptlock_free(struct page *page);
> +static inline bool ptlock_alloc(struct page *page)
> +{
> +       if (sizeof(spinlock_t) > sizeof(page->ptl))
> +               return __ptlock_alloc(page);
> +       return true;
> +}
> +static inline void ptlock_free(struct page *page)
> +{
> +       if (sizeof(spinlock_t) > sizeof(page->ptl))
> +               __ptlock_free(page);
> +}
> +
> +static inline spinlock_t *ptlock_ptr(struct page *page)
> +{
> +       if (sizeof(spinlock_t) > sizeof(page->ptl))
> +               return (spinlock_t *) page->ptl;
> +       else
> +               return (spinlock_t *) &page->ptl;
> +}
> +
> +static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
> +{
> +       return ptlock_ptr(pmd_page(*pmd));
> +}
> +
> +static inline bool ptlock_init(struct page *page)
> +{
> +       if (!ptlock_alloc(page))
> +               return false;
> +       spin_lock_init(ptlock_ptr(page));
> +       return true;
> +}
> +
> +/* Reset page->mapping so free_pages_check won't complain. */
> +static inline void pte_lock_deinit(struct page *page)
> +{
> +       page->mapping = NULL;
> +       ptlock_free(page);
> +}
> +
>  #else  /* !USE_SPLIT_PTE_PTLOCKS */
>  /*
>   * We use mm->page_table_lock to guard all pagetable pages of the mm.
>   */
> -#define pte_lock_init(page)    do {} while (0)
> -#define pte_lock_deinit(page)  do {} while (0)
> -#define pte_lockptr(mm, pmd)   ({(void)(pmd); &(mm)->page_table_lock;})
> +static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
> +{
> +       return &mm->page_table_lock;
> +}
> +static inline bool ptlock_init(struct page *page) { return true; }
> +static inline void pte_lock_deinit(struct page *page) {}
>  #endif /* USE_SPLIT_PTE_PTLOCKS */
>
>  static inline bool pgtable_page_ctor(struct page *page)
>  {
> -       pte_lock_init(page);
>         inc_zone_page_state(page, NR_PAGETABLE);
> -       return true;
> +       return ptlock_init(page);
>  }
>
>  static inline void pgtable_page_dtor(struct page *page)
> @@ -1299,16 +1331,15 @@ static inline void pgtable_page_dtor(struct page *page)
>
>  static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
>  {
> -       return &virt_to_page(pmd)->ptl;
> +       return ptlock_ptr(virt_to_page(pmd));
>  }
>
>  static inline bool pgtable_pmd_page_ctor(struct page *page)
>  {
> -       spin_lock_init(&page->ptl);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>         page->pmd_huge_pte = NULL;
>  #endif
> -       return true;
> +       return ptlock_init(page);
>  }
>
>  static inline void pgtable_pmd_page_dtor(struct page *page)
> @@ -1316,6 +1347,7 @@ static inline void pgtable_pmd_page_dtor(struct page *page)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>         VM_BUG_ON(page->pmd_huge_pte);
>  #endif
> +       ptlock_free(page);
>  }
>
>  #define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd_huge_pte)
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index bacc15f078..257ac12fac 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -147,7 +147,10 @@ struct page {
>                                                  * system if PG_buddy is set.
>                                                  */
>  #if USE_SPLIT_PTE_PTLOCKS
> -               spinlock_t ptl;
> +               unsigned long ptl; /* It's spinlock_t if it fits to long,
> +                                   * otherwise it's pointer to dynamicaly
> +                                   * allocated spinlock_t.
> +                                   */
>  #endif
>                 struct kmem_cache *slab_cache;  /* SL[AU]B: Pointer to slab */
>                 struct page *first_page;        /* Compound tail pages */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d19f7d380b..9e8c8ae3b6 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -211,8 +211,6 @@ config SPLIT_PTLOCK_CPUS
>         int
>         default "999999" if ARM && !CPU_CACHE_VIPT
>         default "999999" if PARISC && !PA20
> -       default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
> -       default "999999" if !64BIT && GENERIC_LOCKBREAK
>         default "4"
>
>  config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> diff --git a/mm/memory.c b/mm/memory.c
> index 1200d6230c..7e11f745bc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4330,3 +4330,22 @@ void copy_user_huge_page(struct page *dst, struct page *src,
>         }
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
> +
> +#if USE_SPLIT_PTE_PTLOCKS
> +bool __ptlock_alloc(struct page *page)
> +{
> +       spinlock_t *ptl;
> +
> +       ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
> +       if (!ptl)
> +               return false;
> +       page->ptl = (unsigned long)ptl;
> +       return true;
> +}
> +
> +void __ptlock_free(struct page *page)
> +{
> +       if (sizeof(spinlock_t) > sizeof(page->ptl))
> +               kfree((spinlock_t *)page->ptl);
> +}
> +#endif
> --
> 1.8.4.rc3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
