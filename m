Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 040016B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 07:58:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 201so21642834itu.13
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 04:58:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z129si2934639ioz.190.2017.06.10.04.58.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 10 Jun 2017 04:58:04 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the#PF
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170519112604.29090-3-mhocko@kernel.org>
	<20170608143606.GK19866@dhcp22.suse.cz>
	<20170609140853.GA14760@cmpxchg.org>
	<20170609144642.GH21764@dhcp22.suse.cz>
	<20170610084901.GB12347@dhcp22.suse.cz>
In-Reply-To: <20170610084901.GB12347@dhcp22.suse.cz>
Message-Id: <201706102057.GGG13003.OtFMJSQOVLFOHF@I-love.SAKURA.ne.jp>
Date: Sat, 10 Jun 2017 20:57:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, guro@fb.com, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> And just to clarify a bit. The OOM killer should be invoked whenever
> appropriate from the allocation context. If we decide to fail the
> allocation in the PF path then we can safely roll back and retry the
> whole PF. This has an advantage that any locks held while doing the
> allocation will be released and that alone can help to make a further
> progress. Moreover we can relax retry-for-ever _inside_ the allocator
> semantic for the PF path and fail allocations when we cannot make
> further progress even after we hit the OOM condition or we do stall for
> too long.

What!? Are you saying that leave the allocator loop rather than invoke
the OOM killer if it is from page fault event without __GFP_FS set?
With below patch applied (i.e. ignore __GFP_FS for emulation purpose),
I can trivially observe systemwide lockup where the OOM killer is
never called.

----------
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 8ad91a0..d01b671 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1495,6 +1495,7 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
 {
 	unsigned long address = read_cr2(); /* Get the faulting address */
 	enum ctx_state prev_state;
+	current->in_pagefault = 1;
 
 	/*
 	 * We must have this function tagged with __kprobes, notrace and call
@@ -1507,6 +1508,7 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
 	prev_state = exception_enter();
 	__do_page_fault(regs, error_code, address);
 	exception_exit(prev_state);
+	current->in_pagefault = 0;
 }
 NOKPROBE_SYMBOL(do_page_fault);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7704110..5a40e3d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -627,6 +627,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			in_pagefault:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e2c925..d786a84 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1056,25 +1056,22 @@ bool out_of_memory(struct oom_control *oc)
 }
 
 /*
- * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
- * killing is already in progress so do nothing.
+ * The pagefault handler calls here because some allocation has failed. We have
+ * to take care of the memcg OOM here because this is the only safe context without
+ * any locks held but let the oom killer triggered from the allocation context care
+ * about the global OOM.
  */
 void pagefault_out_of_memory(void)
 {
-	struct oom_control oc = {
-		.zonelist = NULL,
-		.nodemask = NULL,
-		.memcg = NULL,
-		.gfp_mask = 0,
-		.order = 0,
-	};
+	static DEFINE_RATELIMIT_STATE(pfoom_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
 
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
+	if (fatal_signal_pending(current))
 		return;
-	out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
+
+	if (__ratelimit(&pfoom_rs))
+		pr_warn("Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF\n");
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b896897..c79dfd5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3255,6 +3255,9 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
+	if (current->in_pagefault)
+		return NULL;
+
 	/*
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.
----------

(From http://I-love.SAKURA.ne.jp/tmp/serial-20170610.txt :)
----------
[   72.043747] tuned: page allocation failure: order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[   72.046391] tuned cpuset=/ mems_allowed=0
[   72.047685] CPU: 2 PID: 2236 Comm: tuned Not tainted 4.12.0-rc4-next-20170609+ #614
[   72.049568] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   72.052408] Call Trace:
[   72.053394]  dump_stack+0x67/0x9e
[   72.054522]  warn_alloc+0x10f/0x1b0
[   72.055957]  ? find_next_bit+0xb/0x10
[   72.057233]  __alloc_pages_nodemask+0xc7c/0xeb0
[   72.058527]  alloc_pages_current+0x65/0xb0
[   72.059649]  __page_cache_alloc+0x10b/0x140
[   72.060775]  filemap_fault+0x3d6/0x690
[   72.061834]  ? filemap_fault+0x2a6/0x690
[   72.062978]  xfs_filemap_fault+0x34/0x50
[   72.064065]  __do_fault+0x1b/0x120
[   72.065108]  __handle_mm_fault+0xa86/0x1260
[   72.066309]  ? native_sched_clock+0x5e/0xa0
[   72.067478]  handle_mm_fault+0x182/0x360
[   72.068784]  ? handle_mm_fault+0x44/0x360
[   72.070345]  __do_page_fault+0x1a2/0x580
[   72.071573]  do_page_fault+0x34/0x90
[   72.072726]  page_fault+0x22/0x30
[   72.073797] RIP: 0033:0x7f9fadbfcbd3
[   72.074931] RSP: 002b:00007f9f9e7cfda0 EFLAGS: 00010293
[   72.076467] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007f9fadbfcbd3
[   72.078318] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[   72.080156] RBP: 00000000009429a0 R08: 00007f9f9e7cfdd0 R09: 00007f9f9e7cfb80
[   72.082017] R10: 0000000000000000 R11: 0000000000000293 R12: 00007f9fa6356750
[   72.083898] R13: 0000000000000001 R14: 00007f9f9400d640 R15: 00007f9faec5add0
[   72.087057] Mem-Info:
[   72.088256] active_anon:356433 inactive_anon:2094 isolated_anon:0
[   72.088256]  active_file:92 inactive_file:82 isolated_file:15
[   72.088256]  unevictable:0 dirty:50 writeback:38 unstable:0
[   72.088256]  slab_reclaimable:0 slab_unreclaimable:88
[   72.088256]  mapped:423 shmem:2160 pagetables:8398 bounce:0
[   72.088256]  free:12922 free_pcp:175 free_cma:0
[   72.097601] Node 0 active_anon:1425732kB inactive_anon:8376kB active_file:368kB inactive_file:204kB unevictable:0kB isolated(anon):0kB isolated(file):60kB mapped:1692kB dirty:200kB writeback:152kB shmem:8640kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1163264kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   72.105838] Node 0 DMA free:7120kB min:412kB low:512kB high:612kB active_anon:8712kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:32kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   72.112517] lowmem_reserve[]: 0 1677 1677 1677
[   72.114210] Node 0 DMA32 free:44568kB min:44640kB low:55800kB high:66960kB active_anon:1416780kB inactive_anon:8376kB active_file:448kB inactive_file:696kB unevictable:0kB writepending:352kB present:2080640kB managed:1717500kB mlocked:0kB kernel_stack:20048kB pagetables:33560kB bounce:0kB free_pcp:700kB local_pcp:0kB free_cma:0kB
[   72.125094] lowmem_reserve[]: 0 0 0 0
[   72.126920] Node 0 DMA: 0*4kB 2*8kB (UM) 2*16kB (UM) 1*32kB (M) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 0*512kB 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 7120kB
[   72.130681] Node 0 DMA32: 571*4kB (UM) 293*8kB (UMH) 161*16kB (UMEH) 164*32kB (UMEH) 52*64kB (UME) 22*128kB (MEH) 11*256kB (MEH) 7*512kB (EH) 4*1024kB (EH) 2*2048kB (E) 3*4096kB (M) = 45476kB
[   72.136101] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   72.138790] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   72.141271] 2346 total pagecache pages
[   72.142820] 0 pages in swap cache
[   72.144280] Swap cache stats: add 0, delete 0, find 0/0
[   72.146419] Free swap  = 0kB
[   72.148095] Total swap = 0kB
[   72.149577] 524157 pages RAM
[   72.150991] 0 pages HighMem/MovableOnly
[   72.152681] 90806 pages reserved
[   72.154258] 0 pages hwpoisoned
[   72.156018] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[   72.213133] a.out: page allocation failure: order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[   72.216147] a.out cpuset=/ mems_allowed=0
[   72.217833] CPU: 0 PID: 2690 Comm: a.out Not tainted 4.12.0-rc4-next-20170609+ #614
[   72.220325] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   72.223090] Call Trace:
[   72.224552]  dump_stack+0x67/0x9e
[   72.226267]  warn_alloc+0x10f/0x1b0
[   72.227741]  ? find_next_bit+0xb/0x10
[   72.229278]  __alloc_pages_nodemask+0xc7c/0xeb0
[   72.231055]  alloc_pages_vma+0x76/0x1a0
[   72.232602]  __handle_mm_fault+0xe61/0x1260
[   72.236363]  ? native_sched_clock+0x5e/0xa0
[   72.238953]  handle_mm_fault+0x182/0x360
[   72.240626]  ? handle_mm_fault+0x44/0x360
[   72.242680]  __do_page_fault+0x1a2/0x580
[   72.244480]  do_page_fault+0x34/0x90
[   72.246333]  page_fault+0x22/0x30
[   72.247924] RIP: 0033:0x40084f
[   72.250262] RSP: 002b:00007ffc26c2d110 EFLAGS: 00010246
[   72.252464] RAX: 00000000521b2000 RBX: 0000000080000000 RCX: 00007f7412938650
[   72.255103] RDX: 0000000000000000 RSI: 00007ffc26c2cf30 RDI: 00007ffc26c2cf30
[   72.257500] RBP: 00007f7312a6f010 R08: 00007ffc26c2d040 R09: 00007ffc26c2ce80
[   72.259824] R10: 0000000000000008 R11: 0000000000000246 R12: 00000000521b2000
[   72.262136] R13: 00007f7312a6f010 R14: 0000000000000000 R15: 0000000000000000
[   72.279511] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[   72.406573] a.out: page allocation failure: order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[   72.408233] a.out: page allocation failure: order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[   72.408240] a.out cpuset=/ mems_allowed=0
[   72.408247] CPU: 3 PID: 2782 Comm: a.out Not tainted 4.12.0-rc4-next-20170609+ #614
[   72.408248] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   72.408249] Call Trace:
[   72.408254]  dump_stack+0x67/0x9e
[   72.408259]  warn_alloc+0x10f/0x1b0
[   72.408266]  ? find_next_bit+0xb/0x10
[   72.408270]  __alloc_pages_nodemask+0xc7c/0xeb0
[   72.408284]  alloc_pages_current+0x65/0xb0
[   72.408287]  __page_cache_alloc+0x10b/0x140
[   72.408291]  filemap_fault+0x3d6/0x690
[   72.408293]  ? filemap_fault+0x2a6/0x690
[   72.408300]  xfs_filemap_fault+0x34/0x50
[   72.408302]  __do_fault+0x1b/0x120
[   72.408305]  __handle_mm_fault+0xa86/0x1260
[   72.408308]  ? native_sched_clock+0x5e/0xa0
[   72.408317]  handle_mm_fault+0x182/0x360
[   72.408318]  ? handle_mm_fault+0x44/0x360
[   72.408322]  __do_page_fault+0x1a2/0x580
[   72.408328]  do_page_fault+0x34/0x90
[   72.408332]  page_fault+0x22/0x30
[   72.408334] RIP: 0033:0x7f7412968d60
[   72.408336] RSP: 002b:00007ffc26c2d108 EFLAGS: 00010246
[   72.408337] RAX: 0000000000000000 RBX: 0000000000000003 RCX: 00007f7412968d60
[   72.408338] RDX: 000000000000000a RSI: 0000000000000000 RDI: 0000000000000003
[   72.408339] RBP: 0000000000000003 R08: 00007f74128c2938 R09: 000000000000000e
[   72.408340] R10: 00007ffc26c2ce90 R11: 0000000000000246 R12: 0000000000400935
[   72.408341] R13: 00007ffc26c2d210 R14: 0000000000000000 R15: 0000000000000000
[   72.408353] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
(...snipped...)
[  118.340309] a.out cpuset=/ mems_allowed=0
[  118.341908] CPU: 2 PID: 2794 Comm: a.out Not tainted 4.12.0-rc4-next-20170609+ #614
[  118.344090] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  118.347215] Call Trace:
[  118.348535]  dump_stack+0x67/0x9e
[  118.354648]  warn_alloc+0x10f/0x1b0
[  118.356160]  ? wake_all_kswapds+0x56/0x8e
[  118.357515]  __alloc_pages_nodemask+0xacf/0xeb0
[  118.358960]  alloc_pages_current+0x65/0xb0
[  118.360310]  xfs_buf_allocate_memory+0x15b/0x292
[  118.361745]  xfs_buf_get_map+0xf4/0x150
[  118.363038]  xfs_buf_read_map+0x29/0xd0
[  118.364342]  xfs_trans_read_buf_map+0x9a/0x1a0
[  118.366352]  xfs_imap_to_bp+0x69/0xe0
[  118.367754]  xfs_iread+0x79/0x400
[  118.368983]  xfs_iget+0x42f/0x8a0
[  118.370606]  ? xfs_iget+0x15b/0x8a0
[  118.372530]  ? kfree+0x12a/0x180
[  118.374061]  xfs_lookup+0x8f/0xb0
[  118.375377]  xfs_vn_lookup+0x6b/0xb0
[  118.376609]  lookup_open+0x5a8/0x800
[  118.377795]  ? _raw_spin_unlock_irq+0x32/0x50
[  118.379173]  path_openat+0x437/0xa70
[  118.380367]  do_filp_open+0x8c/0x100
[  118.381608]  ? _raw_spin_unlock+0x2c/0x50
[  118.383121]  ? __alloc_fd+0xf2/0x210
[  118.384603]  do_sys_open+0x13a/0x200
[  118.386121]  SyS_open+0x19/0x20
[  118.387356]  do_syscall_64+0x61/0x1a0
[  118.388578]  entry_SYSCALL64_slow_path+0x25/0x25
[  118.389987] RIP: 0033:0x7f7412962a40
[  118.391148] RSP: 002b:00007ffc26c2d108 EFLAGS: 00000246 ORIG_RAX: 0000000000000002
[  118.393118] RAX: ffffffffffffffda RBX: 0000000000000067 RCX: 00007f7412962a40
[  118.395035] RDX: 0000000000000180 RSI: 0000000000000441 RDI: 00000000006010c0
[  118.396978] RBP: 0000000000000003 R08: 00007f74128c2938 R09: 000000000000000e
[  118.398952] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000400935
[  118.401126] R13: 00007ffc26c2d210 R14: 0000000000000000 R15: 0000000000000000
[  118.425345] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.425371] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.425441] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.428177] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.429258] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.430359] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
[  118.431457] Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
