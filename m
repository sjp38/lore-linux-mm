Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3258E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 10:12:12 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id j13so1439739oii.8
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:12:12 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g36si7066355otb.82.2018.12.18.07.12.10
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 07:12:11 -0800 (PST)
Date: Tue, 18 Dec 2018 15:12:06 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181218151206.GC20197@arrakis.emea.arm.com>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: bigeasy@linutronix.de, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On Thu, Nov 22, 2018 at 05:04:19PM +0800, zhe.he@windriver.com wrote:
> From: He Zhe <zhe.he@windriver.com>
> 
> kmemleak_lock, as a rwlock on RT, can possibly be held in atomic context and
> causes the follow BUG.
> 
> BUG: scheduling while atomic: migration/15/132/0x00000002
> Modules linked in: iTCO_wdt iTCO_vendor_support intel_rapl pcc_cpufreq
> pnd2_edac intel_powerclamp coretemp crct10dif_pclmul crct10dif_common
> aesni_intel matroxfb_base aes_x86_64 matroxfb_g450 matroxfb_accel
> crypto_simd matroxfb_DAC1064 cryptd glue_helper g450_pll matroxfb_misc
> i2c_ismt i2c_i801 acpi_cpufreq
> Preemption disabled at:
> [<ffffffff8c927c11>] cpu_stopper_thread+0x71/0x100
> CPU: 15 PID: 132 Comm: migration/15 Not tainted 4.19.0-rt1-preempt-rt #1
> Hardware name: Intel Corp. Harcuvar/Server, BIOS HAVLCRB1.X64.0015.D62.1708310404 08/31/2017
> Call Trace:
>  dump_stack+0x4f/0x6a
>  ? cpu_stopper_thread+0x71/0x100
>  __schedule_bug.cold.16+0x38/0x55
>  __schedule+0x484/0x6c0
>  schedule+0x3d/0xe0
>  rt_spin_lock_slowlock_locked+0x118/0x2a0
>  rt_spin_lock_slowlock+0x57/0x90
>  __rt_spin_lock+0x26/0x30
>  __write_rt_lock+0x23/0x1a0
>  ? intel_pmu_cpu_dying+0x67/0x70
>  rt_write_lock+0x2a/0x30
>  find_and_remove_object+0x1e/0x80
>  delete_object_full+0x10/0x20
>  kmemleak_free+0x32/0x50
>  kfree+0x104/0x1f0
>  ? x86_pmu_starting_cpu+0x30/0x30
>  intel_pmu_cpu_dying+0x67/0x70
>  x86_pmu_dying_cpu+0x1a/0x30
>  cpuhp_invoke_callback+0x92/0x700
>  take_cpu_down+0x70/0xa0
>  multi_cpu_stop+0x62/0xc0
>  ? cpu_stop_queue_work+0x130/0x130
>  cpu_stopper_thread+0x79/0x100
>  smpboot_thread_fn+0x20f/0x2d0
>  kthread+0x121/0x140
>  ? sort_range+0x30/0x30
>  ? kthread_park+0x90/0x90
>  ret_from_fork+0x35/0x40
> 
> And on v4.18 stable tree the following call trace, caused by grabbing
> kmemleak_lock again, is also observed.
> 
> kernel BUG at kernel/locking/rtmutex.c:1048! 
> invalid opcode: 0000 [#1] PREEMPT SMP PTI 
> CPU: 5 PID: 689 Comm: mkfs.ext4 Not tainted 4.18.16-rt9-preempt-rt #1 
> Hardware name: Intel Corp. Harcuvar/Server, BIOS HAVLCRB1.X64.0015.D62.1708310404 08/31/2017 
> RIP: 0010:rt_spin_lock_slowlock_locked+0x277/0x2a0 
> Code: e8 5e 64 61 ff e9 bc fe ff ff e8 54 64 61 ff e9 b7 fe ff ff 0f 0b e8 98 57 53 ff e9 43 fe ff ff e8 8e 57 53 ff e9 74 ff ff ff <0f> 0b 0f 0b 0f 0b 48 8b 43 10 48 85 c0 74 06 48 3b 58 38 75 0b 49 
> RSP: 0018:ffff936846d4f3b0 EFLAGS: 00010046 
> RAX: ffff8e3680361e00 RBX: ffffffff83a8b240 RCX: 0000000000000001 
> RDX: 0000000000000000 RSI: ffff8e3680361e00 RDI: ffffffff83a8b258 
> RBP: ffff936846d4f3e8 R08: ffff8e3680361e01 R09: ffffffff82adfdf0 
> R10: ffffffff827ede18 R11: 0000000000000000 R12: ffff936846d4f3f8 
> R13: ffff8e3680361e00 R14: ffff936846d4f3f8 R15: 0000000000000246 
> FS: 00007fc8b6bfd780(0000) GS:ffff8e369f340000(0000) knlGS:0000000000000000 
> CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
> CR2: 000055fb5659e000 CR3: 00000007fdd14000 CR4: 00000000003406e0 
> Call Trace: 
>  ? preempt_count_add+0x74/0xc0 
>  rt_spin_lock_slowlock+0x57/0x90 
>  ? __kernel_text_address+0x12/0x40 
>  ? __save_stack_trace+0x75/0x100 
>  __rt_spin_lock+0x26/0x30 
>  __write_rt_lock+0x23/0x1a0 
>  rt_write_lock+0x2a/0x30 
>  create_object+0x17d/0x2b0 
>  kmemleak_alloc+0x34/0x50 
>  kmem_cache_alloc+0x146/0x220 
>  ? mempool_alloc_slab+0x15/0x20 
>  mempool_alloc_slab+0x15/0x20 
>  mempool_alloc+0x65/0x170 
>  sg_pool_alloc+0x21/0x60 
>  __sg_alloc_table+0x101/0x160 
>  ? sg_free_table_chained+0x30/0x30 
>  sg_alloc_table_chained+0x8b/0xb0 
>  scsi_init_sgtable+0x31/0x90 
>  scsi_init_io+0x44/0x130 
>  sd_setup_write_same16_cmnd+0xef/0x150 
>  sd_init_command+0x6bf/0xaa0 
>  ? cgroup_base_stat_cputime_account_end.isra.0+0x26/0x60 
>  ? elv_rb_del+0x2a/0x40 
>  scsi_setup_cmnd+0x8e/0x140 
>  scsi_prep_fn+0x5d/0x140 
>  blk_peek_request+0xda/0x2f0 
>  scsi_request_fn+0x33/0x550 
>  ? cfq_rb_erase+0x23/0x40 
>  __blk_run_queue+0x43/0x60 
>  cfq_insert_request+0x2f3/0x5d0 
>  __elv_add_request+0x160/0x290 
>  blk_flush_plug_list+0x204/0x230 
>  schedule+0x87/0xe0 
>  __write_rt_lock+0x18b/0x1a0 
>  rt_write_lock+0x2a/0x30 
>  create_object+0x17d/0x2b0 
>  kmemleak_alloc+0x34/0x50 
>  __kmalloc_node+0x1cd/0x340 
>  alloc_request_size+0x30/0x70 
>  mempool_alloc+0x65/0x170 
>  ? ioc_lookup_icq+0x54/0x70 
>  get_request+0x4e3/0x8d0 
>  ? wait_woken+0x80/0x80 
>  blk_queue_bio+0x153/0x470 
>  generic_make_request+0x1dc/0x3f0 
>  submit_bio+0x49/0x140 
>  ? next_bio+0x38/0x40 
>  submit_bio_wait+0x59/0x90 
>  blkdev_issue_discard+0x7a/0xd0 
>  ? _raw_spin_unlock_irqrestore+0x18/0x50 
>  blk_ioctl_discard+0xc7/0x110 
>  blkdev_ioctl+0x57e/0x960 
>  ? __wake_up+0x13/0x20 
>  block_ioctl+0x3d/0x50 
>  do_vfs_ioctl+0xa8/0x610 
>  ? vfs_write+0x166/0x1b0 
>  ksys_ioctl+0x67/0x90 
>  __x64_sys_ioctl+0x1a/0x20 
>  do_syscall_64+0x4d/0xf0 
>  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> 
> kmemleak is an error detecting feature. We would not expect as good performance
> as without it. As there is no raw rwlock defining helpers, we turn kmemleak_lock
> to a raw spinlock.
> 
> Signed-off-by: He Zhe <zhe.he@windriver.com>
> Cc: catalin.marinas@arm.com
> Cc: bigeasy@linutronix.de
> Cc: tglx@linutronix.de
> Cc: rostedt@goodmis.org

As I replied already, I don't think this patch would increase the
kmemleak latency (or performance), although I haven't actually tested
it. FWIW:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
