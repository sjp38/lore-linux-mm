Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3146B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 05:33:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so188798617pge.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 02:33:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 72si6752613pgf.169.2017.02.08.02.33.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 02:33:01 -0800 (PST)
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v18AWx2j045464
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:59 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227147111.bbtec.net [126.227.147.111])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v18AWxhU045461
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:59 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: mm: kernel BUG at __free_one_page() or free_pcppages_bulk()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201702081932.IJD35962.LJFMFQFOtSOHVO@I-love.SAKURA.ne.jp>
Date: Wed, 8 Feb 2017 19:32:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I trivially get race conditions while testing below diff on linux-next-20170207.
Is this diff doing something wrong? I tried CONFIG_KASAN=y but it reported nothing.

----------------------------------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3358d4..48e3f76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -92,10 +92,6 @@
 int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
-/* work_structs for global per-cpu drains */
-DEFINE_MUTEX(pcpu_drain_mutex);
-DEFINE_PER_CPU(struct work_struct, pcpu_drain);
-
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile unsigned long latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
@@ -1114,7 +1110,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (++migratetype == MIGRATE_PCPTYPES)
 				migratetype = 0;
 			list = &pcp->lists[migratetype];
-		} while (list_empty(list));
+		} while (list_empty(list) && batch_free < MIGRATE_PCPTYPES);
 
 		/* This is the only non-empty list. Free them all. */
 		if (batch_free == MIGRATE_PCPTYPES)
@@ -2341,20 +2337,20 @@ void drain_local_pages(struct zone *zone)
 		drain_pages(cpu);
 }
 
-static void drain_local_pages_wq(struct work_struct *work)
-{
-	drain_local_pages(NULL);
-}
-
 /*
  * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
  *
  * When zone parameter is non-NULL, spill just the single zone's pages.
  *
- * Note that this can be extremely slow as the draining happens in a workqueue.
+ * Note that this code is protected against sending an IPI to an offline
+ * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
+ * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
+ * nothing keeps CPUs from showing up after we populated the cpumask and
+ * before the call to on_each_cpu_mask().
  */
 void drain_all_pages(struct zone *zone)
 {
+	static DEFINE_MUTEX(lock);
 	int cpu;
 
 	/*
@@ -2363,27 +2359,7 @@ void drain_all_pages(struct zone *zone)
 	 */
 	static cpumask_t cpus_with_pcps;
 
-	/* Workqueues cannot recurse */
-	if (current->flags & PF_WQ_WORKER)
-		return;
-
-	/*
-	 * Do not drain if one is already in progress unless it's specific to
-	 * a zone. Such callers are primarily CMA and memory hotplug and need
-	 * the drain to be complete when the call returns.
-	 */
-	if (unlikely(!mutex_trylock(&pcpu_drain_mutex))) {
-		if (!zone)
-			return;
-		mutex_lock(&pcpu_drain_mutex);
-	}
-
-	/*
-	 * As this can be called from reclaim context, do not reenter reclaim.
-	 * An allocation failure can be handled, it's simply slower
-	 */
-	get_online_cpus();
-
+	mutex_lock(&lock);
 	/*
 	 * We don't care about racing with CPU hotplug event
 	 * as offline notification will cause the notified
@@ -2414,17 +2390,9 @@ void drain_all_pages(struct zone *zone)
 		else
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
-
-	for_each_cpu(cpu, &cpus_with_pcps) {
-		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
-		INIT_WORK(work, drain_local_pages_wq);
-		schedule_work_on(cpu, work);
-	}
-	for_each_cpu(cpu, &cpus_with_pcps)
-		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
-
-	put_online_cpus();
-	mutex_unlock(&pcpu_drain_mutex);
+	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
+								zone, 1);
+	mutex_unlock(&lock);
 }
 
 #ifdef CONFIG_HIBERNATION
----------------------------------------

serial-20170208-1.txt in http://I-love.SAKURA.ne.jp/tmp/serial-20170208.tar.xz
----------------------------------------
[   94.163454] ------------[ cut here ]------------
[   94.165784] WARNING: CPU: 1 PID: 7957 at lib/list_debug.c:25 __list_add_valid+0x46/0xa0
[   94.169337] list_add corruption. next->prev should be prev (ffffea00019941e0), but was ffff8800755e1dd0. (next=ffff8800755e1dd0).
[   94.174024] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper vmw_balloon ppdev sg vmw_vmci pcspkr parport_pc i2c_piix4 parport shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt ahci fb_sys_fops
[   94.203979]  mptspi ttm scsi_transport_spi drm mptscsih ata_piix libahci e1000 mptbase i2c_core libata
[   94.208112] CPU: 1 PID: 7957 Comm: write Tainted: G        W       4.10.0-rc7-next-20170207+ #55
[   94.212369] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   94.216773] Call Trace:
[   94.218242]  dump_stack+0x85/0xc9
[   94.219978]  __warn+0xd1/0xf0
[   94.221888]  warn_slowpath_fmt+0x5f/0x80
[   94.223870]  __list_add_valid+0x46/0xa0
[   94.225822]  free_hot_cold_page+0x205/0x460
[   94.228085]  free_hot_cold_page_list+0x3c/0x1c0
[   94.230262]  shrink_page_list+0x4dd/0xd10
[   94.232390]  shrink_inactive_list+0x1c5/0x660
[   94.234690]  shrink_node_memcg+0x535/0x7f0
[   94.236717]  ? mem_cgroup_iter+0x1d0/0x720
[   94.238901]  shrink_node+0xe1/0x310
[   94.240789]  do_try_to_free_pages+0xe1/0x300
[   94.242954]  try_to_free_pages+0x131/0x3f0
[   94.245004]  __alloc_pages_slowpath+0x479/0xe32
[   94.247212]  __alloc_pages_nodemask+0x382/0x3d0
[   94.249665]  ? sched_clock_cpu+0x11/0xc0
[   94.251680]  alloc_pages_current+0x97/0x1b0
[   94.253887]  __page_cache_alloc+0x15d/0x1a0
[   94.256288]  pagecache_get_page+0x5a/0x2b0
[   94.258426]  ? xfs_file_iomap_begin+0x5fe/0x1140 [xfs]
[   94.260872]  grab_cache_page_write_begin+0x23/0x40
[   94.263490]  iomap_write_begin+0x61/0xf0
[   94.265539]  ? xfs_file_iomap_begin+0x5fe/0x1140 [xfs]
[   94.268007]  iomap_write_actor+0xb5/0x1a0
[   94.270056]  ? iomap_write_end+0x80/0x80
[   94.272298]  iomap_apply+0xb3/0x130
[   94.274176]  iomap_file_buffered_write+0x68/0xa0
[   94.276458]  ? iomap_write_end+0x80/0x80
[   94.278537]  xfs_file_buffered_aio_write+0x132/0x380 [xfs]
[   94.281220]  xfs_file_write_iter+0x90/0x130 [xfs]
[   94.283590]  __vfs_write+0xe5/0x140
[   94.285902]  vfs_write+0xc7/0x1f0
[   94.287798]  ? syscall_trace_enter+0x1d0/0x380
[   94.289987]  SyS_write+0x58/0xc0
[   94.291757]  do_int80_syscall_32+0x6c/0x1f0
[   94.293988]  entry_INT80_compat+0x38/0x50
[   94.296137] RIP: 0023:0x8048076
[   94.297902] RSP: 002b:00000000ffcaa850 EFLAGS: 00000246 ORIG_RAX: 0000000000000004
[   94.301303] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000008048000
[   94.304796] RDX: 0000000000001000 RSI: 0000000000000000 RDI: 0000000000000000
[   94.307941] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
[   94.311254] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[   94.314330] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   94.317880] ---[ end trace 862e2b8f4e16a1f3 ]---
[   94.327989] page:ffff8800755e1da0 count:0 mapcount:32 mapping:0000000400000004 index:0xba00000001
[   94.332031] flags: 0xff0004(referenced|mappedtodisk|reclaim|swapbacked|unevictable|mlocked|uncached|hwpoison)
[   94.336156] raw: 0000000000ff0004 0000000400000004 000000ba00000001 000000000000001f
[   94.339445] raw: dead000000000100 dead000000000200 ffff8800755e1dd0 ffff8800755e1dd0
[   94.342737] page dumped because: VM_BUG_ON_PAGE(page->flags & (((1UL << 23) - 1) & ~(1UL << PG_hwpoison)))
[   94.346802] page->mem_cgroup:ffff8800755e1dd0
[   94.348891] ------------[ cut here ]------------
[   94.351256] kernel BUG at mm/page_alloc.c:796!
[   94.353488] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   94.355963] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper vmw_balloon ppdev sg vmw_vmci pcspkr parport_pc i2c_piix4 parport shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt ahci fb_sys_fops
[   94.385766]  mptspi ttm scsi_transport_spi drm mptscsih ata_piix libahci e1000 mptbase i2c_core libata
[   94.389913] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W       4.10.0-rc7-next-20170207+ #55
[   94.393877] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   94.398510] task: ffff8800745cca40 task.stack: ffffc90000394000
[   94.401474] RIP: 0010:__free_one_page.part.86+0x10/0x12
[   94.404135] RSP: 0000:ffff880075403ea0 EFLAGS: 00010082
[   94.406742] RAX: 0000000000000021 RBX: ffff8800755e1dc0 RCX: 0000000000000006
[   94.410134] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800755ce300
[   94.413503] RBP: ffff880075403ea0 R08: 0000000000000000 R09: 0000000000000001
[   94.416892] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
[   94.420339] R13: fffffe7801d57876 R14: 0000000000000001 R15: ffff88007ffdd740
[   94.423701] FS:  0000000000000000(0000) GS:ffff880075400000(0000) knlGS:0000000000000000
[   94.427483] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   94.430297] CR2: 00007fff41eedd78 CR3: 000000006f77c000 CR4: 00000000001406e0
[   94.433718] Call Trace:
[   94.435428]  <IRQ>
[   94.436893]  free_pcppages_bulk+0x8ea/0x920
[   94.439151]  drain_pages_zone+0x82/0x90
[   94.441283]  ? page_alloc_cpu_dead+0x30/0x30
[   94.443736]  drain_pages+0x3f/0x60
[   94.445712]  drain_local_pages+0x25/0x30
[   94.447849]  flush_smp_call_function_queue+0x7b/0x170
[   94.450390]  generic_smp_call_function_single_interrupt+0x13/0x30
[   94.453340]  smp_call_function_interrupt+0x27/0x40
[   94.455795]  call_function_interrupt+0x9d/0xb0
[   94.458142] RIP: 0010:native_safe_halt+0x6/0x10
[   94.460488] RSP: 0000:ffffc90000397e70 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff03
[   94.464031] RAX: ffff8800745cca40 RBX: 0000000000000000 RCX: 0000000000000000
[   94.467473] RDX: ffff8800745cca40 RSI: 0000000000000001 RDI: ffff8800745cca40
[   94.470799] RBP: ffffc90000397e70 R08: 0000000000000000 R09: 0000000000000000
[   94.474175] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000001
[   94.477493] R13: ffff8800745cca40 R14: ffff8800745cca40 R15: 0000000000000000
[   94.480821]  </IRQ>
[   94.482313]  default_idle+0x23/0x1d0
[   94.484330]  arch_cpu_idle+0xf/0x20
[   94.486293]  default_idle_call+0x23/0x40
[   94.488411]  do_idle+0x162/0x230
[   94.490261]  cpu_startup_entry+0x71/0x80
[   94.492350]  start_secondary+0x17f/0x1f0
[   94.494452]  start_cpu+0x14/0x14
[   94.496304] Code: 89 e5 e8 2a 27 f9 ff 0f 0b 55 48 c7 c6 00 76 c2 81 48 89 e5 e8 18 27 f9 ff 0f 0b 55 48 c7 c6 20 9a c5 81 48 89 e5 e8 06 27 f9 ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 57 45 31 ff 41 56 41 89 fe 
[   94.504620] RIP: __free_one_page.part.86+0x10/0x12 RSP: ffff880075403ea0
----------------------------------------

serial-20170208-2.txt
----------------------------------------
[  691.342826] page:ffff8800753e1dc0 count:-30720 mapcount:0 mapping:ffff8800753e1dc0 index:0xffff8800753e1dd0
[  691.344885] flags: 0xffff8800753e1dc0(waiters|active|slab|arch_1|reserved|private|reclaim|swapbacked|unevictable|mlocked|uncached)
[  691.346980] raw: ffff8800753e1dc0 ffff8800753e1dc0 ffff8800753e1dd0 ffff8800753e1dd0
[  691.348253] raw: dead000000000100 dead000000000200 001a000000101e00 0000000000ec001e
[  691.349542] page dumped because: VM_BUG_ON_PAGE(page->flags & (((1UL << 23) - 1) & ~(1UL << PG_hwpoison)))
[  691.351159] page->mem_cgroup:0000000000ec001e
[  691.351923] ------------[ cut here ]------------
[  691.352695] kernel BUG at mm/page_alloc.c:796!
[  691.353439] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  691.354354] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev parport_pc vmw_balloon vmw_vmci sg pcspkr parport i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm
[  691.366004]  ahci libahci drm ata_piix mptspi e1000 scsi_transport_spi mptscsih mptbase libata i2c_core
[  691.379817] CPU: 0 PID: 67 Comm: kswapd0 Tainted: G        W       4.10.0-rc7-next-20170207+ #55
[  691.381269] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  691.383011] task: ffff880071382540 task.stack: ffffc9000073c000
[  691.383997] RIP: 0010:__free_one_page.part.86+0x10/0x12
[  691.384864] RSP: 0000:ffff880075203ea0 EFLAGS: 00010082
[  691.385881] RAX: 0000000000000021 RBX: ffff8800753e1de0 RCX: 0000000000000006
[  691.387050] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800753ce300
[  691.388223] RBP: ffff880075203ea0 R08: 0000000000000000 R09: 0000000000000001
[  691.389391] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007ffdd8f8
[  691.390587] R13: fffffe7801d4f877 R14: ffffea0000efb880 R15: ffff88007ffdd740
[  691.391779] FS:  0000000000000000(0000) GS:ffff880075200000(0000) knlGS:0000000000000000
[  691.393098] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  691.394045] CR2: 0000000008048060 CR3: 0000000068b52000 CR4: 00000000001406f0
[  691.395265] Call Trace:
[  691.395685]  <IRQ>
[  691.396049]  free_pcppages_bulk+0x8ea/0x920
[  691.397467]  ? trace_hardirqs_off+0xd/0x10
[  691.398865]  drain_pages_zone+0x82/0x90
[  691.400239]  ? page_alloc_cpu_dead+0x30/0x30
[  691.401665]  drain_pages+0x3f/0x60
[  691.402926]  drain_local_pages+0x25/0x30
[  691.404257]  flush_smp_call_function_queue+0x7b/0x170
[  691.405876]  generic_smp_call_function_single_interrupt+0x13/0x30
[  691.407570]  smp_call_function_interrupt+0x27/0x40
[  691.409060]  call_function_interrupt+0x9d/0xb0
[  691.410526] RIP: 0010:_raw_spin_unlock_irqrestore+0x3b/0x60
[  691.412204] RSP: 0000:ffffc9000073fae0 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff03
[  691.414168] RAX: ffff880071382540 RBX: 0000000000000282 RCX: 0000000000000007
[  691.416084] RDX: 00000000000005b0 RSI: ffff8800713831c8 RDI: 0000000000000282
[  691.417969] RBP: ffffc9000073faf0 R08: 0000000000000000 R09: 0000000000000000
[  691.419849] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88007ffddd00
[  691.421733] R13: ffffea0000ee5e20 R14: ffffea0000ee5e00 R15: ffff88007ffdd740
[  691.423598]  </IRQ>
[  691.424762]  free_pcppages_bulk+0x631/0x920
[  691.426131]  free_hot_cold_page+0x373/0x460
[  691.427499]  __free_pages+0x69/0x80
[  691.428788]  ? xfs_buf_rele+0x3ab/0x7e0 [xfs]
[  691.430171]  xfs_buf_free+0xb7/0x290 [xfs]
[  691.431517]  xfs_buf_rele+0x3ab/0x7e0 [xfs]
[  691.432871]  ? xfs_buf_rele+0x1e8/0x7e0 [xfs]
[  691.434428]  xfs_buftarg_shrink_scan+0x8d/0xc0 [xfs]
[  691.435875]  shrink_slab+0x29f/0x6d0
[  691.437068]  shrink_node+0x2fa/0x310
[  691.438238]  kswapd+0x362/0x9b0
[  691.439324]  kthread+0x10f/0x150
[  691.440439]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[  691.441709]  ? kthread_create_on_node+0x70/0x70
[  691.442948]  ret_from_fork+0x31/0x40
[  691.444028] Code: 89 e5 e8 2a 27 f9 ff 0f 0b 55 48 c7 c6 00 76 c2 81 48 89 e5 e8 18 27 f9 ff 0f 0b 55 48 c7 c6 20 9a c5 81 48 89 e5 e8 06 27 f9 ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 57 45 31 ff 41 56 41 89 fe 
[  691.448082] RIP: __free_one_page.part.86+0x10/0x12 RSP: ffff880075203ea0
----------------------------------------

serial-20170208-3.txt
----------------------------------------
[   51.776548] page:ffff8800753e1dc0 count:-30720 mapcount:0 mapping:ffff8800753e1dc0 index:0xffff8800753e1dd0
[   51.778562] flags: 0xffff8800753e1dc0(waiters|active|slab|arch_1|reserved|private|reclaim|swapbacked|unevictable|mlocked|uncached)
[   51.780466] raw: ffff8800753e1dc0 ffff8800753e1dc0 ffff8800753e1dd0 ffff8800753e1dd0
[   51.781729] raw: dead000000000100 dead000000000200 00000000000f1e03 0000000010000000
[   51.782987] page dumped because: VM_BUG_ON_PAGE(page->flags & (((1UL << 23) - 1) & ~(1UL << PG_hwpoison)))
[   51.784551] page->mem_cgroup:0000000010000000
[   51.785290] ------------[ cut here ]------------
[   51.786305] kernel BUG at mm/page_alloc.c:796!
[   51.787041] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   51.787927] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev parport_pc vmw_balloon pcspkr parport i2c_piix4 shpchp sg vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm
[   51.799489]  mptspi ata_piix scsi_transport_spi ahci drm libahci mptscsih e1000 libata mptbase i2c_core
[   51.801022] CPU: 0 PID: 66 Comm: kswapd0 Tainted: G        W       4.10.0-rc7-next-20170207+ #55
[   51.802479] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   51.804226] task: ffff88006f2b0040 task.stack: ffffc90000734000
[   51.805419] RIP: 0010:__free_one_page.part.86+0x10/0x12
[   51.806283] RSP: 0000:ffff880075203ea0 EFLAGS: 00010082
[   51.807149] RAX: 0000000000000021 RBX: ffff8800753e1de0 RCX: 0000000000000006
[   51.808312] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8800753ce300
[   51.809475] RBP: ffff880075203ea0 R08: 0000000000000000 R09: 0000000000000001
[   51.810645] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007ffdd890
[   51.811807] R13: fffffe7801d4f877 R14: ffffea0001bc8c80 R15: ffff88007ffdd740
[   51.813061] FS:  0000000000000000(0000) GS:ffff880075200000(0000) knlGS:0000000000000000
[   51.814547] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   51.815500] CR2: 0000000008048060 CR3: 000000005a7ef000 CR4: 00000000001406f0
[   51.816720] Call Trace:
[   51.817148]  <IRQ>
[   51.817736]  free_pcppages_bulk+0x8ea/0x920
[   51.818427]  drain_pages_zone+0x82/0x90
[   51.819085]  ? page_alloc_cpu_dead+0x30/0x30
[   51.819810]  drain_pages+0x3f/0x60
[   51.820379]  drain_local_pages+0x25/0x30
[   51.821053]  flush_smp_call_function_queue+0x7b/0x170
[   51.822137]  generic_smp_call_function_single_interrupt+0x13/0x30
[   51.823873]  smp_call_function_interrupt+0x27/0x40
[   51.825439]  call_function_interrupt+0x9d/0xb0
[   51.826985] RIP: 0010:_raw_spin_unlock_irqrestore+0x3b/0x60
[   51.828809] RSP: 0000:ffffc90000737ae0 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff03
[   51.830791] RAX: ffff88006f2b0040 RBX: 0000000000000282 RCX: 0000000000000007
[   51.832680] RDX: 00000000000005b0 RSI: ffff88006f2b0cc8 RDI: 0000000000000282
[   51.834561] RBP: ffffc90000737af0 R08: 0000000000000000 R09: 0000000000000000
[   51.836438] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88007ffddd00
[   51.838329] R13: ffffea0001c423e0 R14: ffffea0001c423c0 R15: ffff88007ffdd740
[   51.840229]  </IRQ>
[   51.841305]  free_pcppages_bulk+0x631/0x920
[   51.842754]  free_hot_cold_page+0x373/0x460
[   51.844320]  __free_pages+0x69/0x80
[   51.845603]  ? xfs_buf_rele+0x3ab/0x7e0 [xfs]
[   51.847003]  xfs_buf_free+0xb7/0x290 [xfs]
[   51.848411]  xfs_buf_rele+0x3ab/0x7e0 [xfs]
[   51.849768]  ? xfs_buf_rele+0x1e8/0x7e0 [xfs]
[   51.851147]  xfs_buftarg_shrink_scan+0x8d/0xc0 [xfs]
[   51.852609]  shrink_slab+0x29f/0x6d0
[   51.853818]  shrink_node+0x2fa/0x310
[   51.855001]  kswapd+0x362/0x9b0
[   51.856098]  kthread+0x10f/0x150
[   51.857266]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[   51.858554]  ? kthread_create_on_node+0x70/0x70
[   51.859846]  ret_from_fork+0x31/0x40
[   51.860922] Code: 89 e5 e8 2a 27 f9 ff 0f 0b 55 48 c7 c6 00 76 c2 81 48 89 e5 e8 18 27 f9 ff 0f 0b 55 48 c7 c6 20 9a c5 81 48 89 e5 e8 06 27 f9 ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 57 45 31 ff 41 56 41 89 fe 
[   51.865072] RIP: __free_one_page.part.86+0x10/0x12 RSP: ffff880075203ea0
----------------------------------------

serial-20170208-4.txt
----------------------------------------
[  223.719281] ------------[ cut here ]------------
[  223.724364] WARNING: CPU: 3 PID: 7972 at lib/list_debug.c:55 __list_del_entry_valid+0xf4/0x100
[  223.730523] list_del corruption. next->prev should be ffffea00011201a0, but was ffff88007ffde7f8
[  223.737255] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev vmw_balloon pcspkr i2c_piix4 sg vmw_vmci shpchp parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw mptspi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops
[  223.784322]  scsi_transport_spi ttm mptscsih ata_piix drm ahci libahci i2c_core libata e1000 mptbase
[  223.791398] CPU: 3 PID: 7972 Comm: oom-write Tainted: G        W       4.10.0-rc7-next-20170207+ #56
[  223.798366] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  223.805941] Call Trace:
[  223.810667]  dump_stack+0x86/0xcf
[  223.815544]  __warn+0x111/0x130
[  223.820386]  warn_slowpath_fmt+0xad/0xe0
[  223.825654]  ? __warn+0x130/0x130
[  223.830260]  ? __list_del_entry_valid+0x5c/0x100
[  223.835260]  ? __asan_load8+0x2f/0x70
[  223.839751]  __list_del_entry_valid+0xf4/0x100
[  223.844746]  get_page_from_freelist+0xa46/0x14a0
[  223.849526]  ? unwind_get_return_address+0x9d/0x180
[  223.854596]  __alloc_pages_slowpath+0x370/0x18b0
[  223.859342]  ? __lock_acquire+0x6e2/0x1860
[  223.863830]  ? __zone_watermark_ok+0xae/0x1c0
[  223.868279]  ? gfp_pfmemalloc_allowed+0x90/0x90
[  223.872737]  ? get_page_from_freelist+0x174/0x14a0
[  223.877207]  ? ___might_sleep+0x1f1/0x290
[  223.881583]  __alloc_pages_nodemask+0x437/0x530
[  223.885690]  ? __alloc_pages_slowpath+0x18b0/0x18b0
[  223.890213]  ? sched_clock+0x9/0x10
[  223.893961]  alloc_pages_vma+0xc2/0x3c0
[  223.897794]  __handle_mm_fault+0x125e/0x1890
[  223.901743]  ? debug_check_no_locks_freed+0x1d0/0x1d0
[  223.906542]  ? __pmd_alloc+0x1f0/0x1f0
[  223.910415]  ? sched_clock+0x9/0x10
[  223.914056]  ? sched_clock_cpu+0x1b/0x100
[  223.918126]  handle_mm_fault+0x1f4/0x490
[  223.922024]  ? handle_mm_fault+0x5c/0x490
[  223.925927]  __do_page_fault+0x330/0x690
[  223.929784]  do_page_fault+0x30/0x80
[  223.933570]  page_fault+0x28/0x30
[  223.937143] RIP: 0033:0x4006a0
[  223.940864] RSP: 002b:00007ffc306cccb0 EFLAGS: 00010206
[  223.945122] RAX: 00000000231ef000 RBX: 0000000040000000 RCX: 00007f39b5660650
[  223.950016] RDX: 0000000000000000 RSI: 00007ffc306ccad0 RDI: 00007ffc306ccad0
[  223.954880] RBP: 00007f3935798010 R08: 00007ffc306ccbe0 R09: 00007ffc306cca20
[  223.959802] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000008
[  223.964720] R13: 00007f3935798010 R14: 0000000000000000 R15: 0000000000000000
[  223.969638] ---[ end trace db725fca1b5242d8 ]---
[  224.013416] ------------[ cut here ]------------
[  224.017494] WARNING: CPU: 2 PID: 7972 at lib/list_debug.c:55 __list_del_entry_valid+0xf4/0x100
[  224.022932] list_del corruption. next->prev should be ffffea0000f0f620, but was ffffea0000e83ea0
[  224.028356] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev vmw_balloon pcspkr i2c_piix4 sg vmw_vmci shpchp parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw mptspi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops
[  224.068466]  scsi_transport_spi ttm mptscsih ata_piix drm ahci libahci i2c_core libata e1000 mptbase
[  224.074510] CPU: 2 PID: 7972 Comm: oom-write Tainted: G        W       4.10.0-rc7-next-20170207+ #56
[  224.080629] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  224.087056] Call Trace:
[  224.090431]  dump_stack+0x86/0xcf
[  224.093935]  __warn+0x111/0x130
[  224.097512]  warn_slowpath_fmt+0xad/0xe0
[  224.101298]  ? __warn+0x130/0x130
[  224.105080]  ? sched_clock_cpu+0x1b/0x100
[  224.108896]  ? __lock_acquire+0x6e2/0x1860
[  224.112761]  __list_del_entry_valid+0xf4/0x100
[  224.116871]  get_page_from_freelist+0xa46/0x14a0
[  224.121241]  __alloc_pages_nodemask+0x1d3/0x530
[  224.125471]  ? __alloc_pages_slowpath+0x18b0/0x18b0
[  224.129975]  ? sched_clock+0x9/0x10
[  224.133620]  alloc_pages_vma+0xc2/0x3c0
[  224.137452]  __handle_mm_fault+0x125e/0x1890
[  224.141641]  ? debug_check_no_locks_freed+0x1d0/0x1d0
[  224.145996]  ? __pmd_alloc+0x1f0/0x1f0
[  224.149882]  ? finish_task_switch+0x95/0x320
[  224.153844]  ? sched_clock+0x9/0x10
[  224.157884]  ? sched_clock_cpu+0x1b/0x100
[  224.161871]  handle_mm_fault+0x1f4/0x490
[  224.165611]  ? handle_mm_fault+0x5c/0x490
[  224.169459]  __do_page_fault+0x330/0x690
[  224.173207]  do_page_fault+0x30/0x80
[  224.176807]  page_fault+0x28/0x30
[  224.180325] RIP: 0033:0x4006a0
[  224.183723] RSP: 002b:00007ffc306cccb0 EFLAGS: 00010206
[  224.187979] RAX: 0000000024332000 RBX: 0000000040000000 RCX: 00007f39b5660650
[  224.192910] RDX: 0000000000000000 RSI: 00007ffc306ccad0 RDI: 00007ffc306ccad0
[  224.197944] RBP: 00007f3935798010 R08: 00007ffc306ccbe0 R09: 00007ffc306cca20
[  224.202903] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000008
[  224.207933] R13: 00007f3935798010 R14: 0000000000000000 R15: 0000000000000000
[  224.213914] ---[ end trace db725fca1b5242d9 ]---
[  224.219866] ------------[ cut here ]------------
[  224.225890] WARNING: CPU: 2 PID: 7987 at lib/list_debug.c:46 __list_del_entry_valid+0x8f/0x100
[  224.233023] list_del corruption, ffffea0000f0f620->next is LIST_POISON1 (dead000000000100)
[  224.238859] ------------[ cut here ]------------
[  224.239564] WARNING: CPU: 2 PID: 7987 at lib/list_debug.c:52 __list_del_entry_valid+0xd5/0x100
[  224.239566] list_del corruption. prev->next should be ffffea0000dd29e0, but was ffffea0000dd29a0
[  224.239568] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev vmw_balloon pcspkr i2c_piix4 sg vmw_vmci shpchp parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw mptspi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops
[  224.239634]  scsi_transport_spi ttm mptscsih ata_piix drm ahci libahci i2c_core libata e1000 mptbase
[  224.239647] CPU: 2 PID: 7987 Comm: pickup Tainted: G        W       4.10.0-rc7-next-20170207+ #56
[  224.239648] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  224.239649] Call Trace:
[  224.239650]  <IRQ>
[  224.239653]  dump_stack+0x86/0xcf
[  224.239656]  __warn+0x111/0x130
[  224.239661]  warn_slowpath_fmt+0xad/0xe0
[  224.239663]  ? __warn+0x130/0x130
[  224.239667]  ? debug_lockdep_rcu_enabled+0x35/0x40
[  224.239670]  ? __lock_is_held+0x9a/0x100
[  224.239674]  __list_del_entry_valid+0xd5/0x100
[  224.239677]  free_pcppages_bulk+0x15d/0xcc0
[  224.239685]  drain_pages_zone+0xa0/0xb0
[  224.239688]  ? page_alloc_cpu_dead+0x30/0x30
[  224.239690]  drain_pages+0x49/0x60
[  224.239693]  drain_local_pages+0x24/0x30
[  224.239697]  flush_smp_call_function_queue+0xb7/0x210
[  224.239701]  generic_smp_call_function_single_interrupt+0x13/0x30
[  224.239704]  smp_call_function_single_interrupt+0x40/0x50
[  224.239707]  smp_call_function_interrupt+0xe/0x10
[  224.239709]  call_function_interrupt+0x9d/0xb0
[  224.239712] RIP: 0010:console_unlock+0x550/0x7d0
[  224.239713] RSP: 0000:ffff88005d0bf000 EFLAGS: 00000283 ORIG_RAX: ffffffffffffff03
[  224.239716] RAX: ffffed000bc41630 RBX: 0000000000000000 RCX: ffffffff81184f57
[  224.239717] RDX: dffffc0000000000 RSI: ffff88005e20b1f8 RDI: 0000000000000283
[  224.239719] RBP: ffff88005d0bf068 R08: 0000000000000003 R09: 0000000000000000
[  224.239720] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
[  224.239722] R13: ffffffff82892dc0 R14: ffffffff82892d90 R15: 0000000000000000
[  224.239723]  </IRQ>
[  224.239728]  ? trace_hardirqs_on_caller+0x187/0x280
[  224.239735]  vprintk_emit+0x337/0x3c0
[  224.239739]  ? __list_del_entry_valid+0x8f/0x100
[  224.239742]  vprintk_default+0x3e/0x70
[  224.239745]  vprintk_func+0x20/0x50
[  224.239747]  vprintk+0xe/0x10
[  224.239749]  __warn+0x9b/0x130
[  224.239753]  warn_slowpath_fmt+0xad/0xe0
[  224.239756]  ? __warn+0x130/0x130
[  224.239760]  ? mempool_alloc+0x118/0x2c0
[  224.239765]  __list_del_entry_valid+0x8f/0x100
[  224.239768]  get_page_from_freelist+0xa46/0x14a0
[  224.239777]  __alloc_pages_slowpath+0x370/0x18b0
[  224.239786]  ? __zone_watermark_ok+0xae/0x1c0
[  224.239789]  ? gfp_pfmemalloc_allowed+0x90/0x90
[  224.239792]  ? get_page_from_freelist+0x174/0x14a0
[  224.239798]  ? ___might_sleep+0x1f1/0x290
[  224.239804]  __alloc_pages_nodemask+0x437/0x530
[  224.239807]  ? __alloc_pages_slowpath+0x18b0/0x18b0
[  224.239814]  alloc_pages_vma+0xc2/0x3c0
[  224.239820]  __handle_mm_fault+0x125e/0x1890
[  224.239822]  ? debug_check_no_locks_freed+0x1d0/0x1d0
[  224.239826]  ? __pmd_alloc+0x1f0/0x1f0
[  224.239828]  ? mark_lock+0xcf/0x810
[  224.239831]  ? sched_clock+0x9/0x10
[  224.239834]  ? sched_clock_cpu+0x1b/0x100
[  224.239836]  ? mark_lock+0xcf/0x810
[  224.239843]  handle_mm_fault+0x1f4/0x490
[  224.239846]  ? handle_mm_fault+0x5c/0x490
[  224.239850]  __do_page_fault+0x330/0x690
[  224.239855]  do_page_fault+0x30/0x80
[  224.239859]  page_fault+0x28/0x30
[  224.239863] RIP: 0010:copy_user_generic_unrolled+0x41/0xc0
[  224.239864] RSP: 0000:ffff88005d0bf9f0 EFLAGS: 00010206
[  224.239866] RAX: ffffed0009657061 RBX: ffff88005d0bfd90 RCX: 000000000000000c
[  224.239868] RDX: 0000000000000004 RSI: ffff88004b2b8000 RDI: 00007fdfbf9b9000
[  224.239869] RBP: ffff88005d0bfa58 R08: 303a783a746f6f72 R09: 3a783a6e69620a3a
[  224.239871] R10: 6f6d6561640a3a31 R11: 730a3a323a783a6e R12: ffff88005d0bfcf0
[  224.239872] R13: 0000000000000304 R14: 0000000000000000 R15: ffff88004b2b8000
[  224.239879]  ? copy_page_to_iter_iovec+0x10c/0x240
[  224.239884]  copy_page_to_iter+0x46/0x350
[  224.239888]  ? mark_page_accessed+0xae/0x230
[  224.239891]  generic_file_read_iter+0x560/0xe40
[  224.239898]  ? generic_file_write_iter+0x2c0/0x2c0
[  224.239979]  ? xfs_file_buffered_aio_read+0x7d/0x270 [xfs]
[  224.239981]  ? down_read_nested+0x96/0xd0
[  224.240062]  ? xfs_ilock+0x31a/0x3e0 [xfs]
[  224.240145]  xfs_file_buffered_aio_read+0x88/0x270 [xfs]
[  224.240149]  ? fsnotify+0x963/0xad0
[  224.240241]  xfs_file_read_iter+0x110/0x1d0 [xfs]
[  224.240245]  __vfs_read+0x252/0x340
[  224.240249]  ? do_loop_readv_writev+0x120/0x120
[  224.240252]  ? mark_held_locks+0x22/0xc0
[  224.240256]  ? trace_hardirqs_on_caller+0x187/0x280
[  224.240259]  ? __fsnotify_parent+0x30/0x140
[  224.240264]  ? rw_verify_area+0x78/0x150
[  224.240267]  vfs_read+0xd4/0x1e0
[  224.240271]  SyS_read+0xb3/0x140
[  224.240274]  ? vfs_copy_file_range+0x420/0x420
[  224.240276]  ? mark_held_locks+0x22/0xc0
[  224.240280]  ? do_syscall_64+0x41/0x2b0
[  224.240283]  ? vfs_copy_file_range+0x420/0x420
[  224.240286]  do_syscall_64+0xef/0x2b0
[  224.240291]  entry_SYSCALL64_slow_path+0x25/0x25
[  224.240292] RIP: 0033:0x7fdfbd598c00
[  224.240294] RSP: 002b:00007ffda95988a8 EFLAGS: 00000202 ORIG_RAX: 0000000000000000
[  224.240296] RAX: ffffffffffffffda RBX: 0000555d70f6db80 RCX: 00007fdfbd598c00
[  224.240298] RDX: 0000000000001000 RSI: 00007fdfbf9b9000 RDI: 0000000000000008
[  224.240299] RBP: 000000000000000a R08: ffffffffffffffff R09: 0000000000000000
[  224.240300] R10: 0000000000000022 R11: 0000000000000202 R12: 0000000000000000
[  224.240301] R13: 0000000000000000 R14: 0000555d70f6db80 R15: 00000000000003ff
[  224.240308] ---[ end trace db725fca1b5242da ]---
[  224.240311] page:ffffea0000dd29c0 count:0 mapcount:-127 mapping:          (null) index:0x1
[  224.240313] flags: 0x1fffff80000000()
[  224.240317] raw: 001fffff80000000 0000000000000000 0000000000000001 00000000ffffff80
[  224.240319] raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
[  224.240321] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1)
[  224.240339] ------------[ cut here ]------------
[  224.240341] kernel BUG at ./include/linux/page-flags.h:662!
[  224.240343] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
[  224.240344] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev vmw_balloon pcspkr i2c_piix4 sg vmw_vmci shpchp parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw mptspi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops
[  224.240395]  scsi_transport_spi ttm mptscsih ata_piix drm ahci libahci i2c_core libata e1000 mptbase
[  224.240405] CPU: 2 PID: 7987 Comm: pickup Tainted: G        W       4.10.0-rc7-next-20170207+ #56
[  224.240407] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  224.240408] task: ffff88005e20a500 task.stack: ffff88005d0b8000
[  224.240411] RIP: 0010:free_pcppages_bulk+0xbfb/0xcc0
[  224.240412] RSP: 0000:ffff880065607e58 EFLAGS: 00010092
[  224.240414] RAX: fffff940001ba53f RBX: 00000000000374a7 RCX: ffffffff813479d8
[  224.240416] RDX: dffffc0000000000 RSI: 0000000000000000 RDI: ffffea0000dd29f8
[  224.240417] RBP: ffff880065607f18 R08: 0000000000000003 R09: 0000000000000001
[  224.240419] R10: ffff880065607a17 R11: fffffbfff078540e R12: ffffea0000dd29d8
[  224.240420] R13: 0000000000000000 R14: ffffea0000dd29c0 R15: 0000000000000000
[  224.240422] FS:  00007fdfbf996840(0000) GS:ffff880065600000(0000) knlGS:0000000000000000
[  224.240423] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  224.240425] CR2: 00007fdfbf9b9000 CR3: 0000000046e33000 CR4: 00000000001406e0
[  224.240451] Call Trace:
[  224.240452]  <IRQ>
[  224.240460]  drain_pages_zone+0xa0/0xb0
[  224.240463]  ? page_alloc_cpu_dead+0x30/0x30
[  224.240466]  drain_pages+0x49/0x60
[  224.240469]  drain_local_pages+0x24/0x30
[  224.240472]  flush_smp_call_function_queue+0xb7/0x210
[  224.240476]  generic_smp_call_function_single_interrupt+0x13/0x30
[  224.240479]  smp_call_function_single_interrupt+0x40/0x50
[  224.240482]  smp_call_function_interrupt+0xe/0x10
[  224.240484]  call_function_interrupt+0x9d/0xb0
[  224.240486] RIP: 0010:console_unlock+0x550/0x7d0
[  224.240488] RSP: 0000:ffff88005d0bf000 EFLAGS: 00000283 ORIG_RAX: ffffffffffffff03
[  224.240490] RAX: ffffed000bc41630 RBX: 0000000000000000 RCX: ffffffff81184f57
[  224.240492] RDX: dffffc0000000000 RSI: ffff88005e20b1f8 RDI: 0000000000000283
[  224.240493] RBP: ffff88005d0bf068 R08: 0000000000000003 R09: 0000000000000000
[  224.240494] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
[  224.240495] R13: ffffffff82892dc0 R14: ffffffff82892d90 R15: 0000000000000000
[  224.240496]  </IRQ>
[  224.240501]  ? trace_hardirqs_on_caller+0x187/0x280
[  224.240508]  vprintk_emit+0x337/0x3c0
[  224.240512]  ? __list_del_entry_valid+0x8f/0x100
[  224.240515]  vprintk_default+0x3e/0x70
[  224.240518]  vprintk_func+0x20/0x50
[  224.240520]  vprintk+0xe/0x10
[  224.240523]  __warn+0x9b/0x130
[  224.240527]  warn_slowpath_fmt+0xad/0xe0
[  224.240529]  ? __warn+0x130/0x130
[  224.240533]  ? mempool_alloc+0x118/0x2c0
[  224.240538]  __list_del_entry_valid+0x8f/0x100
[  224.240541]  get_page_from_freelist+0xa46/0x14a0
[  224.240550]  __alloc_pages_slowpath+0x370/0x18b0
[  224.240558]  ? __zone_watermark_ok+0xae/0x1c0
[  224.240561]  ? gfp_pfmemalloc_allowed+0x90/0x90
[  224.240565]  ? get_page_from_freelist+0x174/0x14a0
[  224.240570]  ? ___might_sleep+0x1f1/0x290
[  224.240575]  __alloc_pages_nodemask+0x437/0x530
[  224.240579]  ? __alloc_pages_slowpath+0x18b0/0x18b0
[  224.240586]  alloc_pages_vma+0xc2/0x3c0
[  224.240591]  __handle_mm_fault+0x125e/0x1890
[  224.240594]  ? debug_check_no_locks_freed+0x1d0/0x1d0
[  224.240597]  ? __pmd_alloc+0x1f0/0x1f0
[  224.240600]  ? mark_lock+0xcf/0x810
[  224.240602]  ? sched_clock+0x9/0x10
[  224.240605]  ? sched_clock_cpu+0x1b/0x100
[  224.240607]  ? mark_lock+0xcf/0x810
[  224.240614]  handle_mm_fault+0x1f4/0x490
[  224.240616]  ? handle_mm_fault+0x5c/0x490
[  224.240621]  __do_page_fault+0x330/0x690
[  224.240625]  do_page_fault+0x30/0x80
[  224.240629]  page_fault+0x28/0x30
[  224.240632] RIP: 0010:copy_user_generic_unrolled+0x41/0xc0
[  224.240633] RSP: 0000:ffff88005d0bf9f0 EFLAGS: 00010206
[  224.240635] RAX: ffffed0009657061 RBX: ffff88005d0bfd90 RCX: 000000000000000c
[  224.240636] RDX: 0000000000000004 RSI: ffff88004b2b8000 RDI: 00007fdfbf9b9000
[  224.240638] RBP: ffff88005d0bfa58 R08: 303a783a746f6f72 R09: 3a783a6e69620a3a
[  224.240639] R10: 6f6d6561640a3a31 R11: 730a3a323a783a6e R12: ffff88005d0bfcf0
[  224.240641] R13: 0000000000000304 R14: 0000000000000000 R15: ffff88004b2b8000
[  224.240647]  ? copy_page_to_iter_iovec+0x10c/0x240
[  224.240652]  copy_page_to_iter+0x46/0x350
[  224.240655]  ? mark_page_accessed+0xae/0x230
[  224.240659]  generic_file_read_iter+0x560/0xe40
[  224.240665]  ? generic_file_write_iter+0x2c0/0x2c0
[  224.240747]  ? xfs_file_buffered_aio_read+0x7d/0x270 [xfs]
[  224.240749]  ? down_read_nested+0x96/0xd0
[  224.240830]  ? xfs_ilock+0x31a/0x3e0 [xfs]
[  224.240912]  xfs_file_buffered_aio_read+0x88/0x270 [xfs]
[  224.240916]  ? fsnotify+0x963/0xad0
[  224.240997]  xfs_file_read_iter+0x110/0x1d0 [xfs]
[  224.241001]  __vfs_read+0x252/0x340
[  224.241004]  ? do_loop_readv_writev+0x120/0x120
[  224.241008]  ? mark_held_locks+0x22/0xc0
[  224.241011]  ? trace_hardirqs_on_caller+0x187/0x280
[  224.241014]  ? __fsnotify_parent+0x30/0x140
[  224.241019]  ? rw_verify_area+0x78/0x150
[  224.241022]  vfs_read+0xd4/0x1e0
[  224.241025]  SyS_read+0xb3/0x140
[  224.241028]  ? vfs_copy_file_range+0x420/0x420
[  224.241031]  ? mark_held_locks+0x22/0xc0
[  224.241033]  ? do_syscall_64+0x41/0x2b0
[  224.241037]  ? vfs_copy_file_range+0x420/0x420
[  224.241039]  do_syscall_64+0xef/0x2b0
[  224.241044]  entry_SYSCALL64_slow_path+0x25/0x25
[  224.241045] RIP: 0033:0x7fdfbd598c00
[  224.241046] RSP: 002b:00007ffda95988a8 EFLAGS: 00000202 ORIG_RAX: 0000000000000000
[  224.241049] RAX: ffffffffffffffda RBX: 0000555d70f6db80 RCX: 00007fdfbd598c00
[  224.241050] RDX: 0000000000001000 RSI: 00007fdfbf9b9000 RDI: 0000000000000008
[  224.241051] RBP: 000000000000000a R08: ffffffffffffffff R09: 0000000000000000
[  224.241053] R10: 0000000000000022 R11: 0000000000000202 R12: 0000000000000000
[  224.241054] R13: 0000000000000000 R14: 0000555d70f6db80 R15: 00000000000003ff
[  224.241059] Code: 40 ff ff ff e8 d7 80 a0 00 48 81 c4 98 00 00 00 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 8b 7d b8 48 c7 c6 00 39 ef 81 e8 15 20 05 00 <0f> 0b 4c 89 e7 e8 8b f7 0a 00 48 89 df 4d 8b 24 24 e8 7f f7 0a 
[  224.241102] RIP: free_pcppages_bulk+0xbfb/0xcc0 RSP: ffff880065607e58
----------------------------------------

serial-20170208-5.txt
----------------------------------------
[  101.849371] page:ffff8800653eae10 count:-30720 mapcount:1698606625 mapping:ffff8800653eae10 index:0xffff8800653eae20 compound_mapcount: 31
[  101.854839] flags: 0xffff8800653eae10(dirty|owner_priv_1|arch_1|reserved|private_2|head|reclaim|swapbacked|unevictable|mlocked|uncached)
[  101.859030] raw: ffff8800653eae10 ffff8800653eae10 ffff8800653eae20 ffff8800653eae20
[  101.862804] raw: dead000000000100 dead000000000200 00000000000d1e00 0000000001000004
[  101.866363] page dumped because: VM_BUG_ON_PAGE(page->flags & (((1UL << 23) - 1) & ~(1UL << PG_hwpoison)))
[  101.870200] page->mem_cgroup:0000000001000004
[  101.873229] ------------[ cut here ]------------
[  101.876264] kernel BUG at mm/page_alloc.c:796!
[  101.879301] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
[  101.882600] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci parport i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt ahci fb_sys_fops
[  101.911129]  libahci ata_piix ttm drm libata mptspi e1000 scsi_transport_spi mptscsih mptbase i2c_core
[  101.915559] CPU: 0 PID: 68 Comm: kswapd0 Tainted: G        W       4.10.0-rc7-next-20170207+ #56
[  101.919894] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  101.924588] task: ffff88005d3c49c0 task.stack: ffff88005d3f8000
[  101.928572] RIP: 0010:free_pcppages_bulk+0xb35/0xcc0
[  101.932390] RSP: 0000:ffff880065207e58 EFLAGS: 00010092
[  101.936212] RAX: 0000000000000021 RBX: ffff8800653eae30 RCX: 0000000000000006
[  101.940358] RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff8800653d7300
[  101.944505] RBP: ffff880065207f18 R08: 0000000000000003 R09: 0000000000000001
[  101.948686] R10: ffff880065207a17 R11: ffffed000ca40f4b R12: ffff8800653eae38
[  101.952837] R13: ffff8800653eae30 R14: fffffe780194fab8 R15: ffff8800653eae30
[  101.956985] FS:  0000000000000000(0000) GS:ffff880065200000(0000) knlGS:0000000000000000
[  101.961302] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  101.965234] CR2: 0000000008048060 CR3: 0000000057160000 CR4: 00000000001406f0
[  101.969400] Call Trace:
[  101.972740]  <IRQ>
[  101.976047]  drain_pages_zone+0xa0/0xb0
[  101.979621]  ? page_alloc_cpu_dead+0x30/0x30
[  101.983232]  drain_pages+0x49/0x60
[  101.986683]  drain_local_pages+0x24/0x30
[  101.990212]  flush_smp_call_function_queue+0xb7/0x210
[  101.993909]  generic_smp_call_function_single_interrupt+0x13/0x30
[  101.997810]  smp_call_function_single_interrupt+0x40/0x50
[  102.001591]  smp_call_function_interrupt+0xe/0x10
[  102.005215]  call_function_interrupt+0x9d/0xb0
[  102.008792] RIP: 0010:_raw_spin_unlock_irqrestore+0x3b/0x60
[  102.012598] RSP: 0000:ffff88005d3ff738 EFLAGS: 00000296 ORIG_RAX: ffffffffffffff03
[  102.016685] RAX: ffffed000ba78ac8 RBX: 0000000000000296 RCX: ffffffff81184f57
[  102.020707] RDX: dffffc0000000000 RSI: ffff88005d3c5648 RDI: 0000000000000296
[  102.024718] RBP: ffff88005d3ff748 R08: 0000000000000003 R09: 0000000000000000
[  102.028751] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007ffdec00
[  102.032756] R13: ffffea00017d1720 R14: ffff88007ffde6c0 R15: ffffea00017e2b40
[  102.036749]  </IRQ>
[  102.039840]  ? trace_hardirqs_on_caller+0x187/0x280
[  102.043339]  free_pcppages_bulk+0xbd9/0xcc0
[  102.047586]  free_hot_cold_page+0x59c/0x680
[  102.050877]  __free_pages+0x6a/0x90
[  102.054083]  xfs_buf_free+0x125/0x380 [xfs]
[  102.057368]  xfs_buf_rele+0x513/0xa30 [xfs]
[  102.060612]  ? xfs_buf_rele+0x2ea/0xa30 [xfs]
[  102.063901]  xfs_buftarg_shrink_scan+0x144/0x1a0 [xfs]
[  102.067303]  ? xfs_buf_rele+0xa30/0xa30 [xfs]
[  102.070416]  shrink_slab.part.47+0x31e/0x8f0
[  102.073431]  ? sched_clock+0x9/0x10
[  102.076201]  ? sched_clock_cpu+0x1b/0x100
[  102.078968]  ? trace_event_raw_event_mm_shrink_slab_start+0x220/0x220
[  102.082066]  ? mem_cgroup_iter+0x25e/0x7b0
[  102.084693]  ? mem_cgroup_iter+0x144/0x7b0
[  102.087245]  shrink_node+0x632/0x650
[  102.089668]  ? shrink_node_memcg+0xb80/0xb80
[  102.092147]  ? zone_watermark_ok_safe+0x18e/0x1a0
[  102.094650]  kswapd+0x5c3/0xdd0
[  102.096874]  ? mem_cgroup_shrink_node+0x540/0x540
[  102.099363]  ? trace_hardirqs_on+0xd/0x10
[  102.101710]  ? _raw_spin_unlock_irq+0x2c/0x40
[  102.104117]  ? finish_task_switch+0xe6/0x320
[  102.106498]  ? remove_wait_queue+0xc0/0xc0
[  102.108837]  ? __kthread_parkme+0xe8/0x100
[  102.111186]  kthread+0x192/0x1e0
[  102.113340]  ? mem_cgroup_shrink_node+0x540/0x540
[  102.115738]  ? kthread_create_on_node+0xc0/0xc0
[  102.118076]  ret_from_fork+0x31/0x40
[  102.120225] Code: c1 f8 06 48 89 c6 49 89 c6 e8 78 e0 ff ff 89 45 c8 e9 db f6 ff ff 0f 0b 48 8b bd 78 ff ff ff 48 c7 c6 c0 36 ef 81 e8 db 20 05 00 <0f> 0b 65 ff 05 d2 09 d2 7e 48 c7 c7 50 48 a1 82 e8 46 f8 0a 00 
[  102.126847] RIP: free_pcppages_bulk+0xb35/0xcc0 RSP: ffff880065207e58
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
