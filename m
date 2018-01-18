Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8766B6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 03:13:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a9so13967172pgf.12
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 00:13:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c1si6175727plz.801.2018.01.18.00.13.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 00:13:32 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
	<CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
	<201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
	<CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
	<201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
Message-Id: <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
Date: Thu, 18 Jan 2018 17:12:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com
Cc: dave.hansen@linux.intel.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Tetsuo Handa wrote:
> OK. I missed the mark. I overlooked that 4.11 already has this problem.
> 
> I needed to bisect between 4.10 and 4.11, and I got plausible culprit.
> 
> I haven't completed bisecting between b4fb8f66f1ae2e16 and c470abd4fde40ea6, but
> b4fb8f66f1ae2e16 ("mm, page_alloc: Add missing check for memory holes") and
> 13ad59df67f19788 ("mm, page_alloc: avoid page_to_pfn() when merging buddies")
> are talking about memory holes, which matches the situation that I'm trivially
> hitting the bug if CONFIG_SPARSEMEM=y .
> 
> Thus, I call for an attention by speculative execution. ;-)

Speculative execution failed. I was confused by jiffies precision bug.
The final culprit is c7ab0d2fdc840266 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()").

----------------------------------------
[  103.132986] BUG: unable to handle kernel paging request at b6c00171
[  103.132996] IP: lock_page_memcg+0x3a/0x70
[  103.132997] *pde = 00000000 
[  103.132997] 
[  103.132999] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  103.133000] Modules linked in: pcspkr shpchp serio_raw
[  103.133006] CPU: 3 PID: 62 Comm: kswapd0 Not tainted 4.10.0-09628-gc7ab0d2-dirty #359
[  103.133007] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  103.133008] task: f4559b00 task.stack: f2c74000
[  103.133011] EIP: lock_page_memcg+0x3a/0x70
[  103.133012] EFLAGS: 00010282 CPU: 3
[  103.133013] EAX: f3108060 EBX: b6c00001 ECX: 01c8e5a0 EDX: 00000000
[  103.133014] ESI: f4afe5a0 EDI: f3108060 EBP: f2c75c10 ESP: f2c75c04
[  103.133015]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  103.133017] CR0: 80050033 CR2: b6c00171 CR3: 0170a000 CR4: 000406d0
[  103.133098] Call Trace:
[  103.133104]  page_remove_rmap+0x92/0x260
[  103.133106]  try_to_unmap_one+0x210/0x4b0
[  103.133108]  rmap_walk_file+0xf0/0x200
[  103.133111]  rmap_walk+0x32/0x60
[  103.133112]  try_to_unmap+0x95/0x120
[  103.133114]  ? page_remove_rmap+0x260/0x260
[  103.133116]  ? page_not_mapped+0x10/0x10
[  103.133118]  ? page_get_anon_vma+0x90/0x90
[  103.133120]  shrink_page_list+0x3af/0xc40
[  103.133123]  shrink_inactive_list+0x173/0x370
[  103.133125]  shrink_node_memcg+0x572/0x7d0
[  103.133128]  ? __list_lru_count_one.isra.5+0x14/0x40
[  103.133130]  shrink_node+0xb3/0x2c0
[  103.133132]  kswapd+0x27f/0x5a0
[  103.133137]  kthread+0xd1/0x100
[  103.133139]  ? mem_cgroup_shrink_node+0xa0/0xa0
[  103.133140]  ? kthread_park+0x70/0x70
[  103.133144]  ret_from_fork+0x21/0x2c
[  103.133145] Code: 20 85 db 75 26 eb 2e 66 90 8d b3 74 01 00 00 89 f0 e8 9b 5a 37 00 3b 5f 20 74 26 89 c2 89 f0 e8 3d 57 37 00 8b 5f 20 85 db 74 0a <8b> 83 70 01 00 00 85 c0 7f d4 5b 5e 5f 5d f3 c3 8d b6 00 00 00
[  103.133171] EIP: lock_page_memcg+0x3a/0x70 SS:ESP: 0068:f2c75c04
[  103.133172] CR2: 00000000b6c00171
[  103.133175] ---[ end trace fa59c5a5ab752d7a ]---
----------------------------------------

----------------------------------------
# bad: [86292b33d4b79ee03e2f43ea0381ef85f077c760] Merge branch 'akpm' (patches from Andrew)
# good: [13ad59df67f19788f6c22985b1a33e466eceb643] mm, page_alloc: avoid page_to_pfn() when merging buddies
git bisect start '86292b33d4b79ee03e2f43ea0381ef85f077c760' '13ad59df67f19788' 'mm/'
# good: [0262d9c845ec349edf93f69688a5129c36cc2232] memblock: embed memblock type name within struct memblock_type
git bisect good 0262d9c845ec349edf93f69688a5129c36cc2232
# good: [0262d9c845ec349edf93f69688a5129c36cc2232] memblock: embed memblock type name within struct memblock_type
git bisect good 0262d9c845ec349edf93f69688a5129c36cc2232
# bad: [897ab3e0c49e24b62e2d54d165c7afec6bbca65b] userfaultfd: non-cooperative: add event for memory unmaps
git bisect bad 897ab3e0c49e24b62e2d54d165c7afec6bbca65b
# good: [c791ace1e747371658237f0d30234fef56c39669] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
git bisect good c791ace1e747371658237f0d30234fef56c39669
# good: [8eaedede825a02dbe2420b9c9be9b5b2d7515496] mm: fix handling PTE-mapped THPs in page_referenced()
git bisect good 8eaedede825a02dbe2420b9c9be9b5b2d7515496
# bad: [36eaff3364e8cd35552a77ee426a8170f4f5fde9] mm, ksm: convert write_protect_page() to use page_vma_mapped_walk()
git bisect bad 36eaff3364e8cd35552a77ee426a8170f4f5fde9
# good: [a8fa41ad2f6f7ca08edd1afcf8149ae5a4dcf654] mm, rmap: check all VMAs that PTE-mapped THP can be part of
git bisect good a8fa41ad2f6f7ca08edd1afcf8149ae5a4dcf654
# bad: [c7ab0d2fdc840266b39db94538f74207ec2afbf6] mm: convert try_to_unmap_one() to use page_vma_mapped_walk()
git bisect bad c7ab0d2fdc840266b39db94538f74207ec2afbf6
# good: [f27176cfc363d395eea8dc5c4a26e5d6d7d65eaf] mm: convert page_mkclean_one() to use page_vma_mapped_walk()
git bisect good f27176cfc363d395eea8dc5c4a26e5d6d7d65eaf
# first bad commit: [c7ab0d2fdc840266b39db94538f74207ec2afbf6] mm: convert try_to_unmap_one() to use page_vma_mapped_walk()

bad 4.10.0-10531-g86292b3-dirty  # 86292b33d4b79ee0 ("Merge branch 'akpm' (patches from Andrew)")
bad 4.10.0-09635-g897ab3e-dirty
bad 4.10.0-09629-g36eaff3-dirty
bad 4.10.0-09628-gc7ab0d2-dirty
good 4.10.0-09627-gf27176c-dirty
good 4.10.0-09626-ga8fa41ad-dirty
good 4.10.0-09624-g8eaeded-dirty
good 4.10.0-09611-gc791ace-dirty
good 4.10.0-09588-g0262d9c-dirty
good 4.10.0-06032-g13ad59d-dirty # 13ad59df67f19788 ("mm, page_alloc: avoid page_to_pfn() when merging buddies")
----------------------------------------

The "-dirty" part is due to testing with below patch (jiffies fix,
warn_alloc() lockup avoidance and disabling the OOM reaper).

----------------------------------------
--- a/kernel/time/jiffies.c
+++ b/kernel/time/jiffies.c
@@ -125,7 +125,7 @@ int register_refined_jiffies(long cycles_per_second)
 	shift_hz += cycles_per_tick/2;
 	do_div(shift_hz, cycles_per_tick);
 	/* Calculate nsec_per_tick using shift_hz */
-	nsec_per_tick = (u64)TICK_NSEC << 8;
+	nsec_per_tick = (u64)NSEC_PER_SEC << 8;
 	nsec_per_tick += (u32)shift_hz/2;
 	do_div(nsec_per_tick, (u32)shift_hz);
 
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -553,7 +553,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	//while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3765,7 +3765,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
+	if (0 && time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
----------------------------------------

Michal Hocko wrote:
> Yes, this looks like somebody is clobbering the page. I've seen one with
> refcount 0 so I though this would be a ref count issue. But the one
> below looks definitely like a memory corruption. A nasty one to debug :/

Yes, I guess that c7ab0d2fdc840266 is somewhere doing wrong ref count check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
