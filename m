Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22CF46B026C
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 09:11:30 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id w3so1484170ote.6
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:11:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n7si5023774oib.213.2018.01.11.06.11.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 06:11:22 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
	<201801102049.BGJ13564.OOOMtJLSFQFVHF@I-love.SAKURA.ne.jp>
	<20180110124519.GU1732@dhcp22.suse.cz>
	<201801102237.BED34322.QOOJMFFFHVLSOt@I-love.SAKURA.ne.jp>
	<20180111135721.GC1732@dhcp22.suse.cz>
In-Reply-To: <20180111135721.GC1732@dhcp22.suse.cz>
Message-Id: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
Date: Thu, 11 Jan 2018 23:11:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org

Michal Hocko wrote:
> On Wed 10-01-18 22:37:52, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 10-01-18 20:49:56, Tetsuo Handa wrote:
> > > > Tetsuo Handa wrote:
> > > > > I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
> > > > > So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
> > > > > Does anyone know what is happening?
> > > > 
> > > > I simplified the reproducer and succeeded to reproduce this bug with both
> > > > i7-2630QM (8 core) and i5-4440S (4 core). Thus, I think that this bug is
> > > > not architecture specific.
> > > 
> > > Can you see the same with 64b kernel?
> > 
> > No. I can hit this bug with only x86_32 kernels.
> > But if the cause is not specific to 32b, this might be silent memory corruption.
> > 
> > > It smells like a ref count imbalance and premature page free to me. Can
> > > you try to bisect this?
> > 
> > Too difficult to bisect, but at least I can hit this bug with 4.8+ kernels.

The bug in 4.8 kernel might be different from the bug in 4.15-rc7 kernel.
4.15-rc7 kernel hits the bug so trivially.

----------------------------------------
[  201.838763] Out of memory: Kill process 1131 (a.out) score 20 or sacrifice child
[  201.841780] Killed process 1131 (a.out) total-vm:2099264kB, anon-rss:66060kB, file-rss:8kB, shmem-rss:0kB
[  201.891026] ------------[ cut here ]------------
[  201.893343] kernel BUG at ./include/linux/swap.h:276!
[  201.895973] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  201.898707] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter intel_powerclamp coretemp vmw_balloon ppdev pcspkr sg vmw_vmci i2c_piix4 shpchp parport_pc parport ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[  201.924427] CPU: 0 PID: 3495 Comm: a.out Not tainted 4.8.0 #2
[  201.927017] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  201.932381] task: e47d3240 task.stack: ec032000
[  201.934796] EIP: 0060:[<c80f557e>] EFLAGS: 00010046 CPU: 0
[  201.937460] EIP is at page_cache_tree_insert+0xbe/0xc0
[  201.939766] EAX: f41663d8 EBX: f41f8930 ECX: 00000004 EDX: f41663f0
[  201.942672] ESI: f5243b38 EDI: 00000000 EBP: ec033d24 ESP: ec033d04
[  201.945483]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  201.948112] CR0: 80050033 CR2: b77792c9 CR3: 275d1000 CR4: 000406d0
[  201.950866] Stack:
[  201.952302]  ec033d0c ec033d10 f41663d8 f41663f0 ceaaa77b f5243b38 00000000 f41f8930
[  201.955563]  ec033d54 c80f5ef6 ec033d40 00000000 ec033d64 00000000 f41f8930 f44192e8
[  201.958862]  ceaaa77b f5243b38 0242134a f5243b38 ec033d78 c80f61dd 0242134a ec033d64
[  201.962307] Call Trace:
[  201.964005]  [<c80f5ef6>] __add_to_page_cache_locked+0xb6/0x1e0
[  201.966584]  [<c80f61dd>] add_to_page_cache_lru+0x4d/0xf0
[  201.968890]  [<c8198f6b>] mpage_readpages+0xcb/0x170
[  201.971104]  [<c80ff2e3>] ? __alloc_pages_nodemask+0x243/0x950
[  201.973560]  [<f8ae8050>] ? __xfs_get_blocks+0x690/0x690 [xfs]
[  201.975997]  [<c826713e>] ? __radix_tree_lookup+0x6e/0xd0
[  201.978531]  [<f8ae7070>] ? xfs_vm_bmap+0x60/0x60 [xfs]
[  201.981085]  [<f8ae7089>] xfs_vm_readpages+0x19/0x20 [xfs]
[  201.983488]  [<f8ae8050>] ? __xfs_get_blocks+0x690/0x690 [xfs]
[  201.985931]  [<c8103b10>] __do_page_cache_readahead+0x1a0/0x260
[  201.988386]  [<c80f959d>] filemap_fault+0x31d/0x540
[  201.990536]  [<c8266135>] ? radix_tree_next_chunk+0xe5/0x2e0
[  201.992916]  [<f8af1dfb>] xfs_filemap_fault+0x2b/0x40 [xfs]
[  201.995335]  [<c811fca5>] __do_fault+0x65/0xe0
[  201.997574]  [<c80f6a20>] ? find_lock_entry+0xb0/0xb0
[  201.999932]  [<c8124a30>] handle_mm_fault+0x810/0xa30
[  202.002104]  [<c80f6a20>] ? find_lock_entry+0xb0/0xb0
[  202.004240]  [<c8044519>] __do_page_fault+0x199/0x470
[  202.006396]  [<c80447f0>] ? __do_page_fault+0x470/0x470
[  202.008554]  [<c804480a>] do_page_fault+0x1a/0x20
[  202.010537]  [<c85e1727>] error_code+0x67/0x6c
[  202.012611] Code: 49 7f 02 00 31 c0 8b 5d f0 65 33 1d 14 00 00 00 75 12 83 c4 14 5b 5e 5f 5d c3 8d 76 00 b8 ef ff ff ff eb e2 e8 b4 b3 f5 ff 0f 0b <0f> 0b 55 89 e5 83 ec 28 65 8b 0d 14 00 00 00 89 4d fc 31 c9 c7
[  202.022555] EIP: [<c80f557e>] page_cache_tree_insert+0xbe/0xc0 SS:ESP 0068:ec033d04
[  202.025375] ---[ end trace 0a3a1155cbc67d7f ]---
----------------------------------------

> > 
> > The XXX in "count:XXX mapcount:XXX mapping:XXX index:XXX" are rather random
> > as if they are overwritten.
> > 
> > [   44.103192] page:5a5a0697 count:-1055023618 mapcount:-1055030029 mapping:26f4be11 index:0xc11d7c83
> 
> Yes, this looks like somebody is clobbering the page. I've seen one with
> refcount 0 so I though this would be a ref count issue. But the one
> below looks definitely like a memory corruption. A nasty one to debug :/
> 
> All of those seem to be file pages. So maybe try to use a different FS.

Maybe that's the next thing I should try.

> 
> > [   44.103196] flags: 0xc10528fe(waiters|error|referenced|uptodate|dirty|lru|active|reserved|private_2|mappedtodisk|swapbacked)
> > [   44.103200] raw: c10528fe c114fff7 c11d7c83 c11d84f2 c11d9dfe c11daa34 c11daaa0 c13e65df
> > [   44.103201] raw: c13e4a1c c13e4c62
> > [   44.103202] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
> > [   44.103203] page->mem_cgroup:35401b27
> > 
> > [  192.152510] BUG: Bad page state in process a.out  pfn:18566
> > [  192.152513] page:f72997f0 count:0 mapcount:8 mapping:f118f5a4 index:0x0
> > [  192.152516] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
> > [  192.152520] raw: 19010019 f118f5a4 00000000 00000007 00000000 f7299804 f7299804 00000000
> > [  192.152521] raw: 00000000 00000000
> > [  192.152521] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> > [  192.152522] bad because of flags: 0x1(locked)
> > 
> > [   77.872133] BUG: Bad page state in process a.out  pfn:1873a
> > [   77.872136] page:f729e110 count:0 mapcount:6 mapping:f1187224 index:0x0
> > [   77.872138] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
> > [   77.872141] raw: 19010019 f1187224 00000000 00000005 00000000 f729e124 f729e124 00000000
> > [   77.872141] raw: 00000000 00000000
> > [   77.872142] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> > [   77.872142] bad because of flags: 0x1(locked)
> > 
> > [  188.992549] BUG: Bad page state in process a.out  pfn:197ea
> > [  188.992551] page:f72c7c90 count:0 mapcount:12 mapping:f11b8ca4 index:0x0
> > [  188.992554] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
> > [  188.992557] raw: 19010019 f11b8ca4 00000000 0000000b 00000000 f72c7ca4 f72c7ca4 00000000
> > [  188.992557] raw: 00000000 00000000
> > [  188.992558] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> > [  188.992559] bad because of flags: 0x1(locked)
> 

I retested with some debug printk() patch.
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-4.15-rc7.zip

----------------------------------------
diff --git a/kernel/exit.c b/kernel/exit.c
index 995453d..baa7cea 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -765,6 +765,7 @@ void __noreturn do_exit(long code)
 	struct task_struct *tsk = current;
 	int group_dead;
 
+	pr_info("exit(%s/%u): started do_exit()\n", tsk->comm, tsk->pid);
 	profile_task_exit(tsk);
 	kcov_task_exit(tsk);
 
@@ -808,7 +809,9 @@ void __noreturn do_exit(long code)
 		schedule();
 	}
 
+	pr_info("exit(%s/%u): started exit_signals()\n", tsk->comm, tsk->pid);
 	exit_signals(tsk);  /* sets PF_EXITING */
+	pr_info("exit(%s/%u): ended exit_signals()\n", tsk->comm, tsk->pid);
 	/*
 	 * Ensure that all new tsk->pi_lock acquisitions must observe
 	 * PF_EXITING. Serializes against futex.c:attach_to_pi_owner().
@@ -829,6 +832,7 @@ void __noreturn do_exit(long code)
 	}
 
 	/* sync mm's RSS info before statistics gathering */
+	pr_info("exit(%s/%u): started sync_mm_rss()\n", tsk->comm, tsk->pid);
 	if (tsk->mm)
 		sync_mm_rss(tsk->mm);
 	acct_update_integrals(tsk);
@@ -849,8 +853,10 @@ void __noreturn do_exit(long code)
 	tsk->exit_code = code;
 	taskstats_exit(tsk, group_dead);
 
+	pr_info("exit(%s/%u): started exit_mm()\n", tsk->comm, tsk->pid);
 	exit_mm();
-
+	pr_info("exit(%s/%u): ended exit_mm()\n", tsk->comm, tsk->pid);
+	
 	if (group_dead)
 		acct_process();
 	trace_sched_process_exit(tsk);
@@ -919,6 +925,7 @@ void __noreturn do_exit(long code)
 	exit_tasks_rcu_finish();
 
 	lockdep_free_task(tsk);
+	pr_info("exit(%s/%u): ended do_exit()\n", tsk->comm, tsk->pid);
 	do_task_dead();
 }
 EXPORT_SYMBOL_GPL(do_exit);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 29f8555..8bd3f25 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -505,6 +505,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 *				    # no TIF_MEMDIE task selects new victim
 	 *  unmap_page_range # frees some memory
 	 */
+	pr_info("oom_reaper: started reaping\n");
 	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
----------------------------------------

----------------------------------------
[   38.988178] Out of memory: Kill process 354 (b.out) score 7 or sacrifice child
[   38.991145] Killed process 354 (b.out) total-vm:2099260kB, anon-rss:23288kB, file-rss:8kB, shmem-rss:0kB
[   38.996277] oom_reaper: started reaping
[   38.999033] BUG: unable to handle kernel paging request at c130d86d
[   39.001802] IP: _raw_spin_lock_irqsave+0x1c/0x40
[   39.004069] *pde = 01f88063 *pte = 0130d161 
[   39.006250] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
[   39.008779] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi e1000 scsi_transport_spi mptscsih ata_piix mptbase libata
[   39.014942] CPU: 0 PID: 586 Comm: b.out Tainted: G        W        4.15.0-rc7+ #303
[   39.018014] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   39.022885] EIP: _raw_spin_lock_irqsave+0x1c/0x40
[   39.025233] EFLAGS: 00010046 CPU: 0
[   39.027220] EAX: 00000000 EBX: 00000001 ECX: c130d86d EDX: 00000000
[   39.030090] ESI: 00000202 EDI: f3102100 EBP: ef6dda78 ESP: ef6dda70
[   39.032714]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   39.035214] CR0: 80050033 CR2: c130d86d CR3: 2f726000 CR4: 000406d0
[   39.037889] Call Trace:
[   39.039470]  ? acpi_ps_parse_aml+0x85/0x25c
[   39.041542]  ? acpi_ps_parse_aml+0x1f9/0x25c
[   39.043562]  lock_page_memcg+0x25/0x80
[   39.045421]  page_remove_rmap+0x87/0x2e0
[   39.047315]  try_to_unmap_one+0x20e/0x590
[   39.049198]  rmap_walk_file+0x13c/0x250
[   39.051012]  rmap_walk+0x32/0x60
[   39.052619]  try_to_unmap+0x4d/0x100
[   39.054316]  ? page_remove_rmap+0x2e0/0x2e0
[   39.056196]  ? page_not_mapped+0x10/0x10
[   39.058001]  ? page_get_anon_vma+0x80/0x80
[   39.059849]  shrink_page_list+0x3a2/0x1000
[   39.061678]  shrink_inactive_list+0x1b2/0x440
[   39.063539]  shrink_node_memcg+0x34a/0x770
[   39.065297]  shrink_node+0xbb/0x2e0
[   39.066920]  do_try_to_free_pages+0xba/0x320
[   39.068752]  try_to_free_pages+0x11d/0x330
[   39.070499]  ? __wake_up+0x1a/0x20
[   39.072084]  __alloc_pages_slowpath+0x303/0x6d9
[   39.073910]  ? __accumulate_pelt_segments+0x32/0x50
[   39.075932]  __alloc_pages_nodemask+0x16d/0x180
[   39.077809]  do_anonymous_page+0xab/0x4f0
[   39.079551]  handle_mm_fault+0x531/0x8d0
[   39.081219]  ? __phys_addr+0x32/0x70
[   39.082797]  ? load_new_mm_cr3+0x6a/0x90
[   39.084422]  __do_page_fault+0x1ea/0x4d0
[   39.086034]  ? __do_page_fault+0x4d0/0x4d0
[   39.087666]  do_page_fault+0x1a/0x20
[   39.089184]  common_exception+0x6f/0x76
[   39.090708] EIP: 0x8048437
[   39.091964] EFLAGS: 00010202 CPU: 0
[   39.093435] EAX: 0018d000 EBX: 7ff00000 ECX: 38007008 EDX: 00000000
[   39.095587] ESI: 7ff00000 EDI: 00000000 EBP: bf9f5e98 ESP: bf9f5e60
[   39.097735]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   39.099687] Code: eb f2 8d b6 00 00 00 00 8d bc 27 00 00 00 00 55 89 c1 89 e5 56 53 9c 58 66 66 66 90 89 c6 fa 66 66 90 66 90 31 c0 bb 01 00 00 00 <3e> 0f b1 19 85 c0 75 06 89 f0 5b 5e 5d c3 89 c2 89 c8 e8 ad 4b
[   39.106164] EIP: _raw_spin_lock_irqsave+0x1c/0x40 SS:ESP: 0068:ef6dda70
[   39.108487] CR2: 00000000c130d86d
[   39.109981] ---[ end trace c89b8f16688d25d1 ]---
[   39.111763] exit(b.out/586): started do_exit()
(...snipped...)
[   39.167242] exit(b.out/586): started exit_signals()
[   39.169364] exit(b.out/586): ended exit_signals()
[   39.171473] exit(b.out/586): started sync_mm_rss()
[   39.173549] exit(b.out/586): started exit_mm()
[   39.181703] exit(b.out/354): started do_exit()
[   39.183740] exit(b.out/354): started exit_signals()
[   39.185798] exit(b.out/354): ended exit_signals()
[   39.187822] exit(b.out/354): started sync_mm_rss()
[   39.189813] exit(b.out/354): started exit_mm()
----------------------------------------

cccccccc sounds like a poison.

----------------------------------------
[   64.763544] Out of memory: Kill process 645 (b.out) score 17 or sacrifice child
[   64.766900] Killed process 645 (b.out) total-vm:2099260kB, anon-rss:56292kB, file-rss:8kB, shmem-rss:0kB
[   64.772670] oom_reaper: started reaping
[   64.786642] exit(b.out/645): started do_exit()
[   64.789145] exit(b.out/645): started exit_signals()
[   64.791624] exit(b.out/645): ended exit_signals()
[   64.794173] exit(b.out/645): started sync_mm_rss()
[   64.796730] exit(b.out/645): started exit_mm()
[   64.822147] exit(b.out/859): ended exit_mm()
[   64.834061] exit(b.out/859): ended do_exit()
[   64.920253] exit(b.out/645): ended exit_mm()
[   64.950084] exit(b.out/645): ended do_exit()
[   64.980290] WARNING: CPU: 0 PID: 696 at arch/x86/mm/tlb.c:576 flush_tlb_mm_range+0xfe/0x110
[   64.983665] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi e1000 scsi_transport_spi mptscsih mptbase ata_piix libata
[   64.989842] CPU: 0 PID: 696 Comm: b.out Tainted: G        W        4.15.0-rc7+ #303
[   64.993148] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   64.998050] EIP: flush_tlb_mm_range+0xfe/0x110
[   65.000282] EFLAGS: 00010046 CPU: 0
[   65.002171] EAX: 00000046 EBX: f051ac40 ECX: 00000000 EDX: 00000000
[   65.005030] ESI: f051adc0 EDI: 74002000 EBP: f15778d8 ESP: f15778ac
[   65.007793]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   65.010390] CR0: 80050033 CR2: 740010bf CR3: 2fee1000 CR4: 000406d0
[   65.013060] Call Trace:
[   65.014621]  ptep_clear_flush+0x48/0x60
[   65.016480]  wp_page_copy+0x23d/0x650
[   65.018430]  do_wp_page+0x82/0x440
[   65.020263]  handle_mm_fault+0x522/0x8d0
[   65.022251]  __do_page_fault+0x1ea/0x4d0
[   65.024281]  ? __do_page_fault+0x4d0/0x4d0
[   65.026208]  do_page_fault+0x1a/0x20
[   65.028043]  common_exception+0x6f/0x76
[   65.029925] EIP: mem_cgroup_page_lruvec+0x30/0x40
[   65.032134] EFLAGS: 00010082 CPU: 0
[   65.033953] EAX: 7400107f EBX: c18ede80 ECX: c18ee540 EDX: c18ed840
[   65.036746] ESI: f317a8f8 EDI: f48a4650 EBP: f1577a5c ESP: f1577a5c
[   65.039399]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   65.041890]  isolate_lru_page+0x70/0x260
[   65.043917]  clear_page_mlock+0x71/0xc0
[   65.045619]  page_remove_rmap+0x2a9/0x2e0
[   65.047665]  try_to_unmap_one+0x20e/0x590
[   65.049707]  rmap_walk_file+0x13c/0x250
[   65.051596]  rmap_walk+0x32/0x60
[   65.053326]  try_to_unmap+0x4d/0x100
[   65.055154]  ? page_remove_rmap+0x2e0/0x2e0
[   65.057403]  ? page_not_mapped+0x10/0x10
[   65.059331]  ? page_get_anon_vma+0x80/0x80
[   65.061324]  shrink_page_list+0x3a2/0x1000
[   65.063292]  shrink_inactive_list+0x1b2/0x440
[   65.065356]  shrink_node_memcg+0x34a/0x770
[   65.067326]  shrink_node+0xbb/0x2e0
[   65.069117]  do_try_to_free_pages+0xba/0x320
[   65.071107]  try_to_free_pages+0x11d/0x330
[   65.072968]  ? __wake_up+0x1a/0x20
[   65.074681]  __alloc_pages_slowpath+0x303/0x6d9
[   65.076685]  __alloc_pages_nodemask+0x16d/0x180
[   65.078661]  do_anonymous_page+0xab/0x4f0
[   65.080485]  handle_mm_fault+0x531/0x8d0
[   65.082211]  ? pick_next_task_fair+0xe1/0x490
[   65.084092]  ? irq_exit+0x45/0xb0
[   65.085644]  ? smp_apic_timer_interrupt+0x4b/0x80
[   65.087729]  __do_page_fault+0x1ea/0x4d0
[   65.089568]  ? __do_page_fault+0x4d0/0x4d0
[   65.091463]  do_page_fault+0x1a/0x20
[   65.093168]  common_exception+0x6f/0x76
[   65.094898] EIP: 0x8048437
[   65.096248] EFLAGS: 00010202 CPU: 0
[   65.097863] EAX: 03667000 EBX: 7ff00000 ECX: 3b557008 EDX: 00000000
[   65.100286] ESI: 7ff00000 EDI: 00000000 EBP: bf8212e8 ESP: bf8212b0
[   65.102815]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   65.105050] Code: 90 8d 74 26 00 9c 58 66 66 66 90 f6 c4 02 74 1b fa 66 66 90 66 90 8d 45 dc e8 4f fb ff ff fb 66 66 90 66 90 eb 81 e8 12 57 00 00 <0f> ff eb e1 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 55 b9 01
[   65.112209] ---[ end trace c89b8f16688d25d1 ]---
[   65.114373] page:f317a8f8 count:-216553848 mapcount:-217582360 mapping:0100060f index:0x36414550
[   65.117522] flags: 0xf2c75628(uptodate|lru|owner_priv_1|arch_1|private|writeback|mappedtodisk|reclaim|swapbacked)
[   65.122013] raw: f2c75628 0100060f 36414550 f307f4e7 f317a688 f317c688 cccccccc f317a828
[   65.125340] raw: c1308381 c1150c19
[   65.127185] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
[   65.130063] page->mem_cgroup:c1308381
[   65.131938] There is not page extension available.
[   65.134188] ------------[ cut here ]------------
[   65.136372] kernel BUG at ./include/linux/mm.h:844!
[   65.138762] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   65.141176] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi e1000 scsi_transport_spi mptscsih mptbase ata_piix libata
[   65.147105] CPU: 0 PID: 696 Comm: b.out Tainted: G        W        4.15.0-rc7+ #303
[   65.150162] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   65.155193] EIP: isolate_lru_page+0x234/0x260
[   65.157420] EFLAGS: 00010096 CPU: 0
[   65.159268] EAX: 00000000 EBX: c18ede80 ECX: c1a2e988 EDX: 00000082
[   65.162161] ESI: f317a8f8 EDI: 7400107f EBP: f1577a80 ESP: f1577a64
[   65.165020]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   65.167742] CR0: 80050033 CR2: 740010bf CR3: 2fee1000 CR4: 000406d0
[   65.170715] Call Trace:
[   65.172504]  clear_page_mlock+0x71/0xc0
[   65.174751]  page_remove_rmap+0x2a9/0x2e0
[   65.176915]  try_to_unmap_one+0x20e/0x590
[   65.179087]  rmap_walk_file+0x13c/0x250
[   65.181198]  rmap_walk+0x32/0x60
[   65.183229]  try_to_unmap+0x4d/0x100
[   65.185211]  ? page_remove_rmap+0x2e0/0x2e0
[   65.187407]  ? page_not_mapped+0x10/0x10
[   65.189516]  ? page_get_anon_vma+0x80/0x80
[   65.191681]  shrink_page_list+0x3a2/0x1000
[   65.193901]  shrink_inactive_list+0x1b2/0x440
[   65.196125]  shrink_node_memcg+0x34a/0x770
[   65.198331]  shrink_node+0xbb/0x2e0
[   65.200235]  do_try_to_free_pages+0xba/0x320
[   65.202464]  try_to_free_pages+0x11d/0x330
[   65.204527]  ? __wake_up+0x1a/0x20
[   65.206434]  __alloc_pages_slowpath+0x303/0x6d9
[   65.208569]  __alloc_pages_nodemask+0x16d/0x180
[   65.210620]  do_anonymous_page+0xab/0x4f0
[   65.212610]  handle_mm_fault+0x531/0x8d0
[   65.214611]  ? pick_next_task_fair+0xe1/0x490
[   65.216640]  ? irq_exit+0x45/0xb0
[   65.218250]  ? smp_apic_timer_interrupt+0x4b/0x80
[   65.220496]  __do_page_fault+0x1ea/0x4d0
[   65.222465]  ? __do_page_fault+0x4d0/0x4d0
[   65.224285]  do_page_fault+0x1a/0x20
[   65.226110]  common_exception+0x6f/0x76
[   65.227912] EIP: 0x8048437
[   65.229483] EFLAGS: 00010202 CPU: 0
[   65.231535] EAX: 03667000 EBX: 7ff00000 ECX: 3b557008 EDX: 00000000
[   65.234106] ESI: 7ff00000 EDI: 00000000 EBP: bf8212e8 ESP: bf8212b0
[   65.236517]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   65.238687] Code: fe ff ff 83 e8 01 e9 6b fe ff ff ba 9c 23 7f c1 89 f0 e8 00 67 01 00 0f 0b 83 e8 01 e9 ac fe ff ff ba c4 83 7d c1 e8 ec 66 01 00 <0f> 0b 83 e8 01 e9 b4 fe ff ff 89 f0 e8 1c 3a 00 00 83 e8 01 e9
[   65.245838] EIP: isolate_lru_page+0x234/0x260 SS:ESP: 0068:f1577a64
[   65.248344] ---[ end trace c89b8f16688d25d2 ]---
[   65.250488] exit(b.out/696): started do_exit()
----------------------------------------

This bug can occur before the OOM killer is invoked.
Thus, at least this is not a race with the OOM reaper.

----------------------------------------
[   92.247160] exit(b.out/1893): started do_exit()
[   92.249129] exit(b.out/1893): started exit_signals()
[   92.250896] exit(b.out/1893): ended exit_signals()
[   92.252621] exit(b.out/1893): started sync_mm_rss()
[   92.254339] exit(b.out/1893): started exit_mm()
[   92.397291] exit(b.out/1894): started do_exit()
[   92.398984] exit(b.out/1894): started exit_signals()
[   92.400974] exit(b.out/1894): ended exit_signals()
[   92.402792] exit(b.out/1894): started sync_mm_rss()
[   92.404595] exit(b.out/1894): started exit_mm()
[   92.407241] exit(b.out/1830): started do_exit()
[   92.409055] exit(b.out/1830): started exit_signals()
[   92.410958] exit(b.out/1830): ended exit_signals()
[   92.412649] exit(b.out/1830): started sync_mm_rss()
[   92.414442] exit(b.out/1830): started exit_mm()
[   92.623678] BUG: unable to handle kernel paging request at 89c08510
[   92.625824] IP: debug_object_deactivate.part.4+0x5b/0x110
[   92.628103] *pde = 00000000 
[   92.629531] Thread overran stack, or stack corrupted
[   92.631420] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   92.633204] Modules linked in: xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
[   92.638390] CPU: 0 PID: 32 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #303
[   92.641071] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   92.645127] EIP: debug_object_deactivate.part.4+0x5b/0x110
[   92.647368] EFLAGS: 00010006 CPU: 0
[   92.649021] EAX: 89c08500 EBX: f7430240 ECX: 00000003 EDX: 00000005
[   92.651385] ESI: c1b435b4 EDI: 00000426 EBP: f29034e8 ESP: f29034b8
[   92.653810]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   92.655974] CR0: 80050033 CR2: 89c08510 CR3: 01a1f000 CR4: 000406d0
[   92.658504] Call Trace:
[   92.659865] Code: e8 bb 81 3b 00 89 c1 8b 04 fd 80 14 b4 c1 85 c0 0f 84 ba 00 00 00 3b 58 10 74 65 ba 01 00 00 00 eb 0e 8d b6 00 00 00 00 83 c2 01 <3b> 58 10 74 50 8b 00 85 c0 75 f2 39 15 c4 67 90 c1 7c 3a 31 c0
[   92.667155] EIP: debug_object_deactivate.part.4+0x5b/0x110 SS:ESP: 0068:f29034b8
[   92.669965] CR2: 0000000089c08510
[   92.671657] ---[ end trace c89b8f16688d25d1 ]---
[   92.673717] Kernel panic - not syncing: Fatal exception in interrupt
[   92.676240] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc0000000-0xf7ffdfff)
[   92.679311] Rebooting in 5 seconds..
[   97.758198] ACPI MEMORY or I/O RESET_REG.
----------------------------------------

----------------------------------------
[   13.672160] Out of memory: Kill process 395 (b.out) score 8 or sacrifice child
[   13.708418] Killed process 395 (b.out) total-vm:2099260kB, anon-rss:27776kB, file-rss:28kB, shmem-rss:0kB
[   13.713193] oom_reaper: started reaping
[   13.716851] exit(b.out/395): started do_exit()
[   13.719041] exit(b.out/395): started exit_signals()
[   13.721397] exit(b.out/395): ended exit_signals()
[   13.756917] exit(b.out/395): started sync_mm_rss()
[   13.759208] exit(b.out/395): started exit_mm()
[   13.814381] exit(b.out/599): ended exit_mm()
[   13.821208] exit(b.out/601): ended exit_mm()
[   13.863622] exit(b.out/599): ended do_exit()
[   14.018589] BUG: unable to handle kernel paging request at 32d0a01a
[   14.021835] IP: page_remove_rmap+0x17/0x280
[   14.057429] *pde = 00000000 
[   14.059233] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   14.061456] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi e1000 mptspi scsi_transport_spi mptscsih ata_piix mptbase libata serio_raw
[   14.067501] CPU: 0 PID: 30 Comm: kswapd0 Tainted: G        W        4.15.0-rc7+ #304
[   14.070580] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   14.108859] EIP: page_remove_rmap+0x17/0x280
[   14.110748] EFLAGS: 00010202 CPU: 0
[   14.112417] EAX: 32d0a016 EBX: f2d5dfa8 ECX: 00000010 EDX: 00000000
[   14.114868] ESI: 0000000f EDI: f4931d60 EBP: f2c53c48 ESP: f2c53c3c
[   14.117266]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   14.119394] CR0: 80050033 CR2: 32d0a01a CR3: 01a06000 CR4: 000406d0
[   14.121795] Call Trace:
[   14.156545]  try_to_unmap_one+0x206/0x540
[   14.158371]  rmap_walk_file+0xf0/0x1e0
[   14.160080]  rmap_walk+0x32/0x60
[   14.161606]  try_to_unmap+0x4d/0xd0
[   14.163176]  ? page_remove_rmap+0x280/0x280
[   14.164931]  ? page_not_mapped+0x10/0x10
[   14.166600]  ? page_get_anon_vma+0x80/0x80
[   14.168351]  shrink_page_list+0x3e2/0xe80
[   14.170176]  shrink_inactive_list+0x1b2/0x440
[   14.172137]  shrink_node_memcg+0x34a/0x770
[   14.207197]  shrink_node+0xbb/0x2e0
[   14.208761]  kswapd+0x23f/0x5b0
[   14.210220]  kthread+0xd1/0x100
[   14.211637]  ? mem_cgroup_shrink_node+0xa0/0xa0
[   14.213514]  ? kthread_associate_blkcg+0x80/0x80
[   14.215311]  ret_from_fork+0x19/0x24
[   14.216836] Code: ff ff 83 e8 01 e9 4f ff ff ff 8d 76 00 8d bc 27 00 00 00 00 55 89 e5 56 53 89 c3 83 ec 04 8b 40 14 a8 01 0f 85 18 02 00 00 89 d8 <f6> 40 04 01 74 6b 84 d2 0f 85 5b 01 00 00 3e 83 43 0c ff 78 0c
[   14.257635] EIP: page_remove_rmap+0x17/0x280 SS:ESP: 0068:f2c53c3c
[   14.260467] CR2: 0000000032d0a01a
[   14.262535] ---[ end trace c89b8f16688d25d1 ]---
[   14.264713] exit(kswapd0/30): started do_exit()
----------------------------------------

"Bad rss-counter state" messages can appear before the OOM killer is invoked.

----------------------------------------
[   17.057515] exit(b.out/661): started do_exit()
[   17.059220] exit(b.out/661): started exit_signals()
[   17.060974] exit(b.out/661): ended exit_signals()
[   17.062663] exit(b.out/661): started sync_mm_rss()
[   17.064455] exit(b.out/661): started exit_mm()
[   17.311701] exit(b.out/664): started do_exit()
[   17.313880] exit(b.out/664): started exit_signals()
[   17.315714] exit(b.out/664): ended exit_signals()
[   17.317471] exit(b.out/664): started sync_mm_rss()
[   17.352606] exit(b.out/664): started exit_mm()
[   17.807363] exit(b.out/661): ended exit_mm()
[   17.810459] exit(b.out/659): ended exit_mm()
[   17.819504] exit(b.out/659): ended do_exit()
[   17.855075] exit(b.out/661): ended do_exit()
[   17.863491] BUG: Bad rss-counter state mm:3a10ce4a idx:0 val:1
[   17.865642] BUG: Bad rss-counter state mm:3a10ce4a idx:1 val:-1
[   17.867663] exit(b.out/664): ended exit_mm()
[   17.917000] exit(b.out/664): ended do_exit()
[   17.961639] BUG: unable to handle kernel paging request at 0e200f90
[   17.963906] IP: lock_page_memcg+0x3c/0x80
[   17.965528] *pde = 00000000 
[   17.966811] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   17.968543] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi e1000 mptspi scsi_transport_spi mptscsih ata_piix mptbase libata serio_raw
[   18.006806] CPU: 0 PID: 367 Comm: b.out Tainted: G        W        4.15.0-rc7+ #304
[   18.009450] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   18.013417] EIP: lock_page_memcg+0x3c/0x80
[   18.015138] EFLAGS: 00010202 CPU: 0
[   18.016746] EAX: f2db0b90 EBX: 0e200e20 ECX: 00000011 EDX: 00000000
[   18.052561] ESI: 00000010 EDI: f2db0b90 EBP: f2c2fab4 ESP: f2c2faa8
[   18.054954]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   18.057013] CR0: 80050033 CR2: 0e200f90 CR3: 3298f000 CR4: 000406d0
[   18.059343] Call Trace:
[   18.060655]  page_remove_rmap+0x92/0x280
[   18.062360]  try_to_unmap_one+0x206/0x540
[   18.064109]  rmap_walk_file+0xf0/0x1e0
[   18.065839]  rmap_walk+0x32/0x60
[   18.067475]  try_to_unmap+0x4d/0xd0
[   18.102537]  ? page_remove_rmap+0x280/0x280
[   18.104313]  ? page_not_mapped+0x10/0x10
[   18.106001]  ? page_get_anon_vma+0x80/0x80
[   18.107680]  shrink_page_list+0x3e2/0xe80
[   18.109338]  shrink_inactive_list+0x1b2/0x440
[   18.111074]  shrink_node_memcg+0x34a/0x770
[   18.112743]  shrink_node+0xbb/0x2e0
[   18.114255]  do_try_to_free_pages+0xb2/0x300
[   18.116057]  try_to_free_pages+0x20b/0x330
[   18.117777]  __alloc_pages_slowpath+0x2fb/0x6d3
[   18.152982]  ? hrtimer_interrupt+0x9e/0x170
[   18.154768]  ? irq_exit+0x45/0xb0
[   18.156268]  ? smp_apic_timer_interrupt+0x4b/0x80
[   18.158126]  ? __pagevec_lru_add_fn+0xdb/0x190
[   18.159906]  __alloc_pages_nodemask+0x14a/0x170
[   18.161797]  handle_mm_fault+0x5a5/0xcd0
[   18.163515]  ? pick_next_task_fair+0xe1/0x490
[   18.165358]  __do_page_fault+0x1ea/0x4d0
[   18.167043]  ? __do_page_fault+0x4d0/0x4d0
[   18.202081]  do_page_fault+0x1a/0x20
[   18.203600]  common_exception+0x6f/0x76
[   18.205187] EIP: 0x8048437
[   18.206504] EFLAGS: 00010202 CPU: 0
[   18.207974] EAX: 00229000 EBX: 7ff00000 ECX: 3811f008 EDX: 00000000
[   18.210139] ESI: 7ff00000 EDI: 00000000 EBP: bffedf28 ESP: bffedef0
[   18.212290]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   18.214217] Code: db 75 28 eb 5c 66 90 8d b3 74 01 00 00 89 f0 e8 3b 37 4e 00 8b 4f 20 39 d9 74 2c 89 c2 89 f0 e8 db 33 4e 00 8b 5f 20 85 db 74 36 <8b> 83 70 01 00 00 85 c0 7f d2 89 d9 5b 89 c8 5e 5f 5d c3 90 31
[   18.254093] EIP: lock_page_memcg+0x3c/0x80 SS:ESP: 0068:f2c2faa8
[   18.256263] CR2: 000000000e200f90
[   18.257948] ---[ end trace c89b8f16688d25d1 ]---
[   18.259817] exit(b.out/367): started do_exit()
----------------------------------------

page_has_buffers() assertion can fail when the OOM killer is invoked.

----------------------------------------
[   41.581473] Out of memory: Kill process 456 (b.out) score 18 or sacrifice child
[   41.584500] Killed process 456 (b.out) total-vm:2099260kB, anon-rss:59724kB, file-rss:8kB, shmem-rss:0kB
[   41.589503] oom_reaper: started reaping
[   41.600128] XFS: Assertion failed: page_has_buffers(page), file: fs/xfs/xfs_aops.c, line: 1060
[   41.603529] WARNING: CPU: 0 PID: 45 at fs/xfs/xfs_message.c:105 asswarn+0x26/0x30 [xfs]
[   41.606787] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic pata_acpi sd_mod serio_raw ata_piix e1000 mptspi scsi_transport_spi mptscsih mptbase libata
[   41.612889] CPU: 0 PID: 45 Comm: kworker/u2:1 Tainted: G        W        4.15.0-rc7+ #304
[   41.616116] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   41.621016] Workqueue: writeback wb_workfn (flush-8:0)
[   41.623407] EIP: asswarn+0x26/0x30 [xfs]
[   41.625445] EFLAGS: 00010246 CPU: 0
[   41.627382] EAX: 00000000 EBX: f48a5950 ECX: 00000021 EDX: f2d13bac
[   41.630143] ESI: 00000000 EDI: f48a5950 EBP: f2d13c28 ESP: f2d13c14
[   41.632803]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   41.635197] CR0: 80050033 CR2: 38211008 CR3: 2fed6000 CR4: 000406d0
[   41.637854] Call Trace:
[   41.639428]  xfs_do_writepage+0x635/0x670 [xfs]
[   41.641581]  ? rmap_walk_file+0x133/0x1e0
[   41.643527]  ? rmap_walk+0x32/0x60
[   41.645311]  ? clear_page_dirty_for_io+0x156/0x1d0
[   41.647457]  ? xfs_vm_set_page_dirty+0x210/0x210 [xfs]
[   41.649746]  write_cache_pages+0x1ea/0x3f0
[   41.651713]  ? xfs_vm_set_page_dirty+0x210/0x210 [xfs]
[   41.653878]  ? __enqueue_entity+0x63/0x70
[   41.655733]  xfs_vm_writepages+0x48/0x80 [xfs]
[   41.657677]  do_writepages+0x1a/0x70
[   41.659361]  __writeback_single_inode+0x27/0x160
[   41.661377]  writeback_sb_inodes+0x1bd/0x320
[   41.663310]  __writeback_inodes_wb+0x74/0xb0
[   41.665216]  wb_writeback+0x169/0x190
[   41.666971]  wb_workfn+0x22c/0x2f0
[   41.668618]  ? __switch_to+0xa2/0x220
[   41.670352]  process_one_work+0xe7/0x240
[   41.672834]  worker_thread+0x31/0x360
[   41.674704]  kthread+0xd1/0x100
[   41.676313]  ? rescuer_thread+0x2d0/0x2d0
[   41.678103]  ? kthread_associate_blkcg+0x80/0x80
[   41.680057]  ret_from_fork+0x19/0x24
[   41.681712] Code: 90 90 90 90 90 55 89 e5 83 ec 14 89 4c 24 10 89 54 24 0c 89 44 24 08 c7 44 24 04 9c 7b a4 f8 c7 04 24 00 00 00 00 e8 ba fd ff ff <0f> ff c9 c3 8d b6 00 00 00 00 55 89 e5 83 ec 14 89 4c 24 10 89
[   41.688711] ---[ end trace c89b8f16688d25d1 ]---
[   41.690645] ------------[ cut here ]------------
[   41.692546] kernel BUG at fs/xfs/xfs_aops.c:911!
[   41.694446] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   41.696522] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic pata_acpi sd_mod serio_raw ata_piix e1000 mptspi scsi_transport_spi mptscsih mptbase libata
[   41.701631] CPU: 0 PID: 45 Comm: kworker/u2:1 Tainted: G        W        4.15.0-rc7+ #304
[   41.704495] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   41.708742] Workqueue: writeback wb_workfn (flush-8:0)
[   41.710865] EIP: xfs_do_writepage+0x641/0x670 [xfs]
[   41.712874] EFLAGS: 00010246 CPU: 0
[   41.714510] EAX: 00001000 EBX: f48a5950 ECX: 0000000c EDX: be01006d
[   41.716924] ESI: 00000001 EDI: f48a5950 EBP: f2d13cb0 ESP: f2d13c30
[   41.719308]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   41.721487] CR0: 80050033 CR2: 38211008 CR3: 2fed6000 CR4: 000406d0
[   41.723922] Call Trace:
[   41.725325]  ? rmap_walk_file+0x133/0x1e0
[   41.727146]  ? clear_page_dirty_for_io+0x156/0x1d0
[   41.729206]  ? xfs_vm_set_page_dirty+0x210/0x210 [xfs]
[   41.731314]  write_cache_pages+0x1ea/0x3f0
[   41.733159]  ? xfs_vm_set_page_dirty+0x210/0x210 [xfs]
[   41.735275]  ? __enqueue_entity+0x63/0x70
[   41.737120]  xfs_vm_writepages+0x48/0x80 [xfs]
[   41.739048]  do_writepages+0x1a/0x70
[   41.740788]  __writeback_single_inode+0x27/0x160
[   41.742769]  writeback_sb_inodes+0x1bd/0x320
[   41.744655]  __writeback_inodes_wb+0x74/0xb0
[   41.746621]  wb_writeback+0x169/0x190
[   41.748374]  wb_workfn+0x22c/0x2f0
[   41.750029]  ? __switch_to+0xa2/0x220
[   41.751776]  process_one_work+0xe7/0x240
[   41.753592]  worker_thread+0x31/0x360
[   41.755297]  kthread+0xd1/0x100
[   41.756889]  ? rescuer_thread+0x2d0/0x2d0
[   41.758682]  ? kthread_associate_blkcg+0x80/0x80
[   41.760624]  ret_from_fork+0x19/0x24
[   41.762274] Code: 4a fb ff ff 0f ff e9 71 fb ff ff b9 24 04 00 00 ba 01 db a3 f8 b8 f1 db a3 f8 e8 7b e7 01 00 e9 f9 f9 ff ff f3 90 e9 1d fa ff ff <0f> 0b 0f ff 8d 74 26 00 8d bc 27 00 00 00 00 e9 3d fb ff ff ba
[   41.769434] EIP: xfs_do_writepage+0x641/0x670 [xfs] SS:ESP: 0068:f2d13c30
[   41.771966] ---[ end trace c89b8f16688d25d2 ]---
[   41.774051] exit(kworker/u2:1/45): started do_exit()
----------------------------------------

xfs_vm_set_page_dirty() hits warning after the OOM killer is invoked.

----------------------------------------
[   35.662606] Out of memory: Kill process 383 (b.out) score 18 or sacrifice child
[   35.665550] Killed process 383 (b.out) total-vm:2099260kB, anon-rss:58668kB, file-rss:8kB, shmem-rss:0kB
[   35.683131] WARNING: CPU: 0 PID: 830 at fs/xfs/xfs_aops.c:1468 xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[   35.687796] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix e1000 libata mptscsih mptbase
[   35.693698] CPU: 0 PID: 830 Comm: b.out Tainted: G        W        4.15.0-rc7+ #305
[   35.696759] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   35.701695] EIP: xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[   35.704206] EFLAGS: 00010046 CPU: 0
[   35.706137] EAX: be000010 EBX: f3c81d58 ECX: f3c81d58 EDX: f3c81d4c
[   35.708790] ESI: 00000246 EDI: f4895528 EBP: ee215abc ESP: ee215a98
[   35.711394]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   35.713772] CR0: 80050033 CR2: 38572008 CR3: 2e2a6000 CR4: 000406d0
[   35.716429] Call Trace:
[   35.718094]  set_page_dirty+0x3d/0x90
[   35.720160]  try_to_unmap_one+0x373/0x540
[   35.722204]  rmap_walk_file+0xf0/0x1e0
[   35.724125]  rmap_walk+0x32/0x60
[   35.725845]  try_to_unmap+0x4d/0xd0
[   35.727618]  ? page_remove_rmap+0x280/0x280
[   35.729584]  ? page_not_mapped+0x10/0x10
[   35.731418]  ? page_get_anon_vma+0x80/0x80
[   35.733271]  shrink_page_list+0x3e2/0xe80
[   35.735153]  shrink_inactive_list+0x1b2/0x440
[   35.737132]  shrink_node_memcg+0x34a/0x770
[   35.738987]  shrink_node+0xbb/0x2e0
[   35.740626]  do_try_to_free_pages+0xb2/0x300
[   35.742459]  try_to_free_pages+0x20b/0x330
[   35.744248]  ? schedule_timeout+0x10c/0x1d0
[   35.746055]  __alloc_pages_slowpath+0x2fb/0x6d3
[   35.747980]  __alloc_pages_nodemask+0x14a/0x170
[   35.749913]  handle_mm_fault+0x5a5/0xcd0
[   35.751695]  ? pick_next_task_fair+0xe1/0x490
[   35.753582]  ? sched_clock_cpu+0x13/0x120
[   35.755387]  __do_page_fault+0x1ea/0x4d0
[   35.757106]  ? __do_page_fault+0x4d0/0x4d0
[   35.758861]  do_page_fault+0x1a/0x20
[   35.760468]  common_exception+0x6f/0x76
[   35.762612] EIP: 0x8048437
[   35.764088] EFLAGS: 00010202 CPU: 0
[   35.765737] EAX: 00096000 EBX: 7ff00000 ECX: 37f10008 EDX: 00000000
[   35.768028] ESI: 7ff00000 EDI: 00000000 EBP: bf96e078 ESP: bf96e040
[   35.770370]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   35.772393] Code: e4 8d 58 0c 89 d8 e8 8b c3 c4 c8 89 c6 8b 45 e8 8b 50 04 85 d2 74 5b 8b 40 14 a8 01 0f 85 ce 00 00 00 8b 45 e8 8b 00 a8 08 75 7b <0f> ff 8b 7d e8 8b 55 e4 89 f8 e8 4c 76 71 c8 8b 47 14 a8 01 0f
[   35.779201] ---[ end trace c89b8f16688d25d1 ]---
[   35.781296] BUG: unable to handle kernel paging request at 06000170
[   35.783805] IP: lock_page_memcg+0x3c/0x80
[   35.785616] *pde = 00000000 
[   35.787117] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   35.789110] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix e1000 libata mptscsih mptbase
[   35.794654] CPU: 0 PID: 830 Comm: b.out Tainted: G        W        4.15.0-rc7+ #305
[   35.797605] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   35.802203] EIP: lock_page_memcg+0x3c/0x80
[   35.804174] EFLAGS: 00010206 CPU: 0
[   35.805960] EAX: f2dc6850 EBX: 06000000 ECX: 00000012 EDX: 00000000
[   35.808433] ESI: 00000010 EDI: f2dc6850 EBP: ee215ab4 ESP: ee215aa8
[   35.810887]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   35.813095] CR0: 80050033 CR2: 06000170 CR3: 2e2a6000 CR4: 000406d0
[   35.815719] Call Trace:
[   35.817167]  page_remove_rmap+0x92/0x280
[   35.819046]  try_to_unmap_one+0x206/0x540
[   35.820965]  rmap_walk_file+0xf0/0x1e0
[   35.822785]  rmap_walk+0x32/0x60
[   35.824457]  try_to_unmap+0x4d/0xd0
[   35.826209]  ? page_remove_rmap+0x280/0x280
[   35.828203]  ? page_not_mapped+0x10/0x10
[   35.830025]  ? page_get_anon_vma+0x80/0x80
[   35.831952]  shrink_page_list+0x3e2/0xe80
[   35.833800]  shrink_inactive_list+0x1b2/0x440
[   35.835761]  shrink_node_memcg+0x34a/0x770
[   35.837679]  shrink_node+0xbb/0x2e0
[   35.839432]  do_try_to_free_pages+0xb2/0x300
[   35.841411]  try_to_free_pages+0x20b/0x330
[   35.843356]  ? schedule_timeout+0x10c/0x1d0
[   35.845301]  __alloc_pages_slowpath+0x2fb/0x6d3
[   35.847302]  __alloc_pages_nodemask+0x14a/0x170
[   35.849279]  handle_mm_fault+0x5a5/0xcd0
[   35.851066]  ? pick_next_task_fair+0xe1/0x490
[   35.852981]  ? sched_clock_cpu+0x13/0x120
[   35.854801]  __do_page_fault+0x1ea/0x4d0
[   35.856515]  ? __do_page_fault+0x4d0/0x4d0
[   35.858326]  do_page_fault+0x1a/0x20
[   35.860004]  common_exception+0x6f/0x76
[   35.861705] EIP: 0x8048437
[   35.863114] EFLAGS: 00010202 CPU: 0
[   35.864687] EAX: 00096000 EBX: 7ff00000 ECX: 37f10008 EDX: 00000000
[   35.867027] ESI: 7ff00000 EDI: 00000000 EBP: bf96e078 ESP: bf96e040
[   35.869348]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   35.871349] Code: db 75 28 eb 5c 66 90 8d b3 74 01 00 00 89 f0 e8 3b 37 4e 00 8b 4f 20 39 d9 74 2c 89 c2 89 f0 e8 db 33 4e 00 8b 5f 20 85 db 74 36 <8b> 83 70 01 00 00 85 c0 7f d2 89 d9 5b 89 c8 5e 5f 5d c3 90 31
[   35.879102] EIP: lock_page_memcg+0x3c/0x80 SS:ESP: 0068:ee215aa8
[   35.881510] CR2: 0000000006000170
[   35.883126] ---[ end trace c89b8f16688d25d2 ]---
[   35.885122] exit(b.out/830): started do_exit()
----------------------------------------

But xfs_vm_set_page_dirty() hits warning before the OOM killer is invoked.

----------------------------------------
[   40.752823] exit(b.out/687): started do_exit()
[   40.754594] exit(b.out/687): started exit_signals()
[   40.756434] exit(b.out/687): ended exit_signals()
[   40.758185] exit(b.out/687): started sync_mm_rss()
[   40.759974] exit(b.out/687): started exit_mm()
[   41.063943] exit(b.out/687): ended exit_mm()
[   41.065842] exit(b.out/687): ended do_exit()
[   41.787284] WARNING: CPU: 0 PID: 326 at fs/xfs/xfs_aops.c:1468 xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[   41.791206] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata serio_raw
[   41.796701] CPU: 0 PID: 326 Comm: b.out Tainted: G        W        4.15.0-rc7+ #305
[   41.799700] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   41.804302] EIP: xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[   41.806609] EFLAGS: 00010046 CPU: 0
[   41.808432] EAX: be000010 EBX: f3cb1d58 ECX: f3cb1d58 EDX: f3cb1d4c
[   41.811049] ESI: 00000246 EDI: f49320d0 EBP: f2c0f9cc ESP: f2c0f9a8
[   41.813671]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   41.816002] CR0: 80050033 CR2: b7e6a49a CR3: 324bb000 CR4: 000406d0
[   41.818649] Call Trace:
[   41.820063]  set_page_dirty+0x3d/0x90
[   41.821917]  try_to_unmap_one+0x373/0x540
[   41.823891]  rmap_walk_file+0xf0/0x1e0
[   41.825867]  rmap_walk+0x32/0x60
[   41.827672]  try_to_unmap+0x4d/0xd0
[   41.829456]  ? page_remove_rmap+0x280/0x280
[   41.831445]  ? page_not_mapped+0x10/0x10
[   41.833336]  ? page_get_anon_vma+0x80/0x80
[   41.835250]  shrink_page_list+0x3e2/0xe80
[   41.837169]  shrink_inactive_list+0x1b2/0x440
[   41.839157]  shrink_node_memcg+0x34a/0x770
[   41.841086]  shrink_node+0xbb/0x2e0
[   41.842878]  do_try_to_free_pages+0xb2/0x300
[   41.844841]  try_to_free_pages+0x20b/0x330
[   41.846807]  __alloc_pages_slowpath+0x2fb/0x6d3
[   41.848871]  ? _lookup_address_cpa.isra.24+0x25/0x30
[   41.851042]  ? __change_page_attr+0x1e4/0x6f0
[   41.853083]  __alloc_pages_nodemask+0x14a/0x170
[   41.855173]  __do_page_cache_readahead+0xd6/0x210
[   41.857315]  ? pagecache_get_page+0x1f/0x1f0
[   41.859360]  filemap_fault+0x234/0x570
[   41.861222]  ? filemap_map_pages+0x12f/0x340
[   41.863299]  ? filemap_fdatawait_keep_errors+0x50/0x50
[   41.865582]  __xfs_filemap_fault.isra.16+0x2d/0xb0 [xfs]
[   41.867887]  ? filemap_fdatawait_keep_errors+0x50/0x50
[   41.870156]  xfs_filemap_fault+0xa/0x10 [xfs]
[   41.872141]  __do_fault+0x11/0x30
[   41.873825]  handle_mm_fault+0x8f0/0xcd0
[   41.875632]  __do_page_fault+0x1ea/0x4d0
[   41.877426]  ? __do_page_fault+0x4d0/0x4d0
[   41.879264]  do_page_fault+0x1a/0x20
[   41.880907]  common_exception+0x6f/0x76
[   41.882638] EIP: 0xb7e6a49a
[   41.884016] EFLAGS: 00010246 CPU: 0
[   41.885639] EAX: fffffff4 EBX: 01200011 ECX: 00000000 EDX: 00000000
[   41.888093] ESI: 00000000 EDI: b7db0728 EBP: bf884358 ESP: bf884310
[   41.890744]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   41.893088] Code: e4 8d 58 0c 89 d8 e8 8b c3 c4 c8 89 c6 8b 45 e8 8b 50 04 85 d2 74 5b 8b 40 14 a8 01 0f 85 ce 00 00 00 8b 45 e8 8b 00 a8 08 75 7b <0f> ff 8b 7d e8 8b 55 e4 89 f8 e8 4c 76 71 c8 8b 47 14 a8 01 0f
[   41.900752] ---[ end trace c89b8f16688d25d1 ]---
----------------------------------------

----------------------------------------
[   41.378852] Out of memory: Kill process 360 (b.out) score 19 or sacrifice child
[   41.382162] Killed process 360 (b.out) total-vm:2099260kB, anon-rss:60512kB, file-rss:8kB, shmem-rss:0kB
[   41.392549] BUG: unable to handle kernel NULL pointer dereference at 00000004
[   41.395775] IP: page_remove_rmap+0x17/0x280
[   41.398033] *pde = 00000000 
[   41.399860] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   41.402116] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic pata_acpi sd_mod serio_raw e1000 ata_piix mptspi scsi_transport_spi mptscsih mptbase libata
[   41.408340] CPU: 0 PID: 326 Comm: b.out Tainted: G        W        4.15.0-rc7+ #305
[   41.411632] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   41.416729] EIP: page_remove_rmap+0x17/0x280
[   41.418931] EFLAGS: 00010246 CPU: 0
[   41.420865] EAX: 00000000 EBX: f2db8d40 ECX: 0000000e EDX: 00000000
[   41.423567] ESI: 0000000e EDI: f4930a50 EBP: f2fa79d8 ESP: f2fa79cc
[   41.426422]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   41.429016] CR0: 80050033 CR2: 00000004 CR3: 328ac000 CR4: 000406d0
[   41.431752] Call Trace:
[   41.433338]  try_to_unmap_one+0x206/0x540
[   41.435351]  rmap_walk_file+0xf0/0x1e0
[   41.437332]  rmap_walk+0x32/0x60
[   41.439218]  try_to_unmap+0x4d/0xd0
[   41.441141]  ? page_remove_rmap+0x280/0x280
[   41.443105]  ? page_not_mapped+0x10/0x10
[   41.444980]  ? page_get_anon_vma+0x80/0x80
[   41.447040]  shrink_page_list+0x3e2/0xe80
[   41.449005]  shrink_inactive_list+0x1b2/0x440
[   41.450909]  shrink_node_memcg+0x34a/0x770
[   41.452774]  shrink_node+0xbb/0x2e0
[   41.454570]  do_try_to_free_pages+0xb2/0x300
[   41.456589]  try_to_free_pages+0x20b/0x330
[   41.458479]  __alloc_pages_slowpath+0x2fb/0x6d3
[   41.460487]  ? ktime_get+0x47/0xf0
[   41.462192]  ? lapic_next_deadline+0x24/0x30
[   41.464117]  __alloc_pages_nodemask+0x14a/0x170
[   41.466131]  __do_page_cache_readahead+0xd6/0x210
[   41.468184]  ? pagecache_get_page+0x1f/0x1f0
[   41.470089]  ? apic_timer_interrupt+0x3c/0x44
[   41.471997]  filemap_fault+0x234/0x570
[   41.473717]  ? radix_tree_next_chunk+0xf1/0x2c0
[   41.475630]  ? filemap_map_pages+0x12f/0x340
[   41.477534]  ? filemap_fdatawait_keep_errors+0x50/0x50
[   41.479768]  __xfs_filemap_fault.isra.16+0x2d/0xb0 [xfs]
[   41.482018]  ? filemap_fdatawait_keep_errors+0x50/0x50
[   41.484138]  xfs_filemap_fault+0xa/0x10 [xfs]
[   41.485958]  __do_fault+0x11/0x30
[   41.487476]  handle_mm_fault+0x8f0/0xcd0
[   41.489108]  __do_page_fault+0x1ea/0x4d0
[   41.490739]  ? __do_page_fault+0x4d0/0x4d0
[   41.492408]  do_page_fault+0x1a/0x20
[   41.493989]  common_exception+0x6f/0x76
[   41.495687] EIP: 0xb7e8449a
[   41.497077] EFLAGS: 00010246 CPU: 0
[   41.498552] EAX: fffffff4 EBX: 01200011 ECX: 00000000 EDX: 00000000
[   41.500739] ESI: 00000000 EDI: b7dca728 EBP: bfc79c58 ESP: bfc79c10
[   41.502997]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   41.504987] Code: ff ff 83 e8 01 e9 4f ff ff ff 8d 76 00 8d bc 27 00 00 00 00 55 89 e5 56 53 89 c3 83 ec 04 8b 40 14 a8 01 0f 85 18 02 00 00 89 d8 <f6> 40 04 01 74 6b 84 d2 0f 85 5b 01 00 00 3e 83 43 0c ff 78 0c
[   41.511758] EIP: page_remove_rmap+0x17/0x280 SS:ESP: 0068:f2fa79cc
[   41.514034] CR2: 0000000000000004
[   41.515779] ---[ end trace c89b8f16688d25d1 ]---
[   41.517708] exit(b.out/326): started do_exit()
----------------------------------------

----------------------------------------
[   35.986299] Out of memory: Kill process 335 (b.out) score 18 or sacrifice child
[   35.988781] Killed process 335 (b.out) total-vm:2099260kB, anon-rss:57344kB, file-rss:8kB, shmem-rss:0kB
[   35.994786] BUG: unable to handle kernel NULL pointer dereference at 0000073c
[   35.996860] IP: page_remove_rmap+0x17/0x280
[   35.998175] *pde = 00000000 
[   35.999075] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   36.000472] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi e1000 mptspi scsi_transport_spi mptscsih ata_piix mptbase libata serio_raw
[   36.004711] CPU: 0 PID: 480 Comm: b.out Tainted: G        W        4.15.0-rc7+ #306
[   36.006905] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   36.009964] EIP: page_remove_rmap+0x17/0x280
[   36.011210] EFLAGS: 00010202 CPU: 0
[   36.012225] EAX: 00000738 EBX: f2d84040 ECX: 00000010 EDX: 00000000
[   36.014071] ESI: 0000000f EDI: f4932030 EBP: f159bac8 ESP: f159babc
[   36.016011]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   36.017657] CR0: 80050033 CR2: 0000073c CR3: 3153b000 CR4: 000406d0
[   36.019569] Call Trace:
[   36.020440]  try_to_unmap_one+0x206/0x540
[   36.021879]  rmap_walk_file+0xf0/0x1e0
[   36.023126]  rmap_walk+0x32/0x60
[   36.024169]  try_to_unmap+0x4d/0xd0
[   36.025245]  ? page_remove_rmap+0x280/0x280
[   36.026551]  ? page_not_mapped+0x10/0x10
[   36.027775]  ? page_get_anon_vma+0x80/0x80
[   36.029077]  shrink_page_list+0x3e2/0xe80
[   36.030341]  shrink_inactive_list+0x1b2/0x440
[   36.031763]  shrink_node_memcg+0x34a/0x770
[   36.033047]  shrink_node+0xbb/0x2e0
[   36.034152]  do_try_to_free_pages+0xb2/0x300
[   36.035567]  try_to_free_pages+0x20b/0x330
[   36.036853]  ? schedule_timeout+0x10c/0x1d0
[   36.038141]  __alloc_pages_slowpath+0x2fb/0x6d3
[   36.039521]  __alloc_pages_nodemask+0x14a/0x170
[   36.040897]  handle_mm_fault+0x5a5/0xcd0
[   36.042036]  ? pick_next_task_fair+0xe1/0x490
[   36.043376]  ? sched_clock_cpu+0x13/0x120
[   36.044600]  __do_page_fault+0x1ea/0x4d0
[   36.045760]  ? __do_page_fault+0x4d0/0x4d0
[   36.046964]  do_page_fault+0x1a/0x20
[   36.048043]  common_exception+0x6f/0x76
[   36.049280] EIP: 0x8048437
[   36.050135] EFLAGS: 00010202 CPU: 0
[   36.051219] EAX: 00615000 EBX: 7ff00000 ECX: 38420008 EDX: 00000000
[   36.053080] ESI: 7ff00000 EDI: 00000000 EBP: bf883de8 ESP: bf883db0
[   36.054876]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   36.056455] Code: ff ff 83 e8 01 e9 4f ff ff ff 8d 76 00 8d bc 27 00 00 00 00 55 89 e5 56 53 89 c3 83 ec 04 8b 40 14 a8 01 0f 85 18 02 00 00 89 d8 <f6> 40 04 01 74 6b 84 d2 0f 85 5b 01 00 00 3e 83 43 0c ff 78 0c
[   36.062043] EIP: page_remove_rmap+0x17/0x280 SS:ESP: 0068:f159babc
[   36.063847] CR2: 000000000000073c
[   36.064945] ---[ end trace c89b8f16688d25d1 ]---
[   36.066379] exit(b.out/480): started do_exit()
----------------------------------------

----------------------------------------
[   56.306933] Out of memory: Kill process 619 (b.out) score 15 or sacrifice child
[   56.309123] Killed process 619 (b.out) total-vm:2099260kB, anon-rss:48104kB, file-rss:8kB, shmem-rss:0kB
[   56.313607] BUG: unable to handle kernel NULL pointer dereference at 00000174
[   56.315623] IP: lock_page_memcg+0x3c/0x80
[   56.316758] *pde = 00000000 
[   56.317582] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   56.318858] Modules linked in: xfs libcrc32c sr_mod cdrom ata_generic pata_acpi sd_mod e1000 ata_piix mptspi scsi_transport_spi mptscsih mptbase libata serio_raw
[   56.323133] CPU: 0 PID: 782 Comm: b.out Tainted: G        W        4.15.0-rc7+ #306
[   56.325410] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   56.328521] EIP: lock_page_memcg+0x3c/0x80
[   56.329767] EFLAGS: 00010202 CPU: 0
[   56.330836] EAX: f2e97900 EBX: 00000004 ECX: 00000050 EDX: 00000000
[   56.332733] ESI: 0000004f EDI: f2e97900 EBP: f2365ab4 ESP: f2365aa8
[   56.334483]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   56.335984] CR0: 80050033 CR2: 00000174 CR3: 306f3000 CR4: 000406d0
[   56.337949] Call Trace:
[   56.338755]  page_remove_rmap+0x92/0x280
[   56.339969]  try_to_unmap_one+0x206/0x540
[   56.341199]  rmap_walk_file+0xf0/0x1e0
[   56.342359]  rmap_walk+0x32/0x60
[   56.343366]  try_to_unmap+0x4d/0xd0
[   56.344444]  ? page_remove_rmap+0x280/0x280
[   56.345716]  ? page_not_mapped+0x10/0x10
[   56.346893]  ? page_get_anon_vma+0x80/0x80
[   56.348070]  shrink_page_list+0x3e2/0xe80
[   56.349206]  ? depot_save_stack+0x122/0x3c0
[   56.350387]  shrink_inactive_list+0x1b2/0x440
[   56.351616]  shrink_node_memcg+0x34a/0x770
[   56.352776]  shrink_node+0xbb/0x2e0
[   56.353844]  do_try_to_free_pages+0xb2/0x300
[   56.355226]  try_to_free_pages+0x20b/0x330
[   56.356486]  __alloc_pages_slowpath+0x2fb/0x6d3
[   56.357875]  ? __accumulate_pelt_segments+0x32/0x50
[   56.359332]  ? update_load_avg+0xa30/0xa70
[   56.360504]  __alloc_pages_nodemask+0x14a/0x170
[   56.361782]  handle_mm_fault+0x5a5/0xcd0
[   56.362868]  ? pick_next_task_fair+0xe1/0x490
[   56.364113]  ? sched_clock_cpu+0x13/0x120
[   56.365240]  __do_page_fault+0x1ea/0x4d0
[   56.366352]  ? __do_page_fault+0x4d0/0x4d0
[   56.367483]  do_page_fault+0x1a/0x20
[   56.368540]  common_exception+0x6f/0x76
[   56.369694] EIP: 0x8048437
[   56.370525] EFLAGS: 00010202 CPU: 0
[   56.371650] EAX: 0030b000 EBX: 7ff00000 ECX: 38206008 EDX: 00000000
[   56.373812] ESI: 7ff00000 EDI: 00000000 EBP: bfdb7328 ESP: bfdb72f0
[   56.375702]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   56.377290] Code: db 75 28 eb 5c 66 90 8d b3 74 01 00 00 89 f0 e8 cb 25 46 00 8b 4f 20 39 d9 74 2c 89 c2 89 f0 e8 6b 22 46 00 8b 5f 20 85 db 74 36 <8b> 83 70 01 00 00 85 c0 7f d2 89 d9 5b 89 c8 5e 5f 5d c3 90 31
[   56.382432] EIP: lock_page_memcg+0x3c/0x80 SS:ESP: 0068:f2365aa8
[   56.384169] CR2: 0000000000000174
[   56.385191] ---[ end trace c89b8f16688d25d1 ]---
[   56.386495] exit(b.out/782): started do_exit()
----------------------------------------

Overall, memory corruption is strongly suspected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
