Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 72D976B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 11:34:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so2835970pde.8
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 08:34:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b7si16313308pdj.57.2014.09.22.08.34.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 08:34:49 -0700 (PDT)
Message-ID: <5420407E.8040406@oracle.com>
Date: Mon, 22 Sep 2014 11:30:06 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: NULL ptr deref in migrate_page_move_mapping
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 5028.149987] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 5028.151644] IP: migrate_page_move_mapping (mm/migrate.c:358)
[ 5028.152912] PGD 562e72067 PUD 549f93067 PMD 0
[ 5028.158109] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 5028.159419] Dumping ftrace buffer:
[ 5028.159555]    (ftrace buffer empty)
[ 5028.159555] Modules linked in:
[ 5028.159555] CPU: 14 PID: 19517 Comm: trinity-main Not tainted 3.17.0-rc5-next-20140919-sasha-00031-gc150a84 #1208
[ 5028.159555] task: ffff8802ca820000 ti: ffff880526dc8000 task.ti: ffff880526dc8000
[ 5028.159555] RIP: migrate_page_move_mapping (mm/migrate.c:358)
[ 5028.159555] RSP: 0000:ffff880526dcb708  EFLAGS: 00010002
[ 5028.159555] RAX: 0000000000000001 RBX: ffffea0015926e00 RCX: 0000000000000001
[ 5028.159555] RDX: 0000000000000001 RSI: ffff880047f570d0 RDI: 0000000000000082
[ 5028.159555] RBP: ffff880526dcb758 R08: 0000000000000038 R09: 0000000000000001
[ 5028.159555] R10: 0000000000000038 R11: 00000000000003be R12: ffff880047f570a0
[ 5028.159555] R13: 0000000000000002 R14: ffffea0014790fc0 R15: 0000000000000000
[ 5028.159555] FS:  00007f93eff4a700(0000) GS:ffff880488800000(0000) knlGS:0000000000000000
[ 5028.159555] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 5028.159555] CR2: 0000000000000000 CR3: 0000000525f41000 CR4: 00000000000006a0
[ 5028.159555] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 5028.159555] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 5028.159555] Stack:
[ 5028.159555]  ffff880526dcb718 0000000000000000 0000000026dcb748 ffff880047f570b8
[ 5028.159555]  ffffea0014790fc0 ffffea0014790fc0 ffffea0015926e00 0000000000000001
[ 5028.159555]  ffff880047f570a0 ffffea0014790fc0 ffff880526dcb788 ffffffffa530bcfb
[ 5028.159555] Call Trace:
[ 5028.159555] migrate_page (mm/migrate.c:601)
[ 5028.159555] move_to_new_page (mm/migrate.c:775)
[ 5028.159555] ? try_to_unmap (mm/rmap.c:1527)
[ 5028.159555] ? try_to_unmap_nonlinear (mm/rmap.c:1124)
[ 5028.159555] ? invalid_migration_vma (mm/rmap.c:1483)
[ 5028.159555] ? page_remove_rmap (mm/rmap.c:1391)
[ 5028.159555] ? __put_anon_vma (mm/rmap.c:448)
[ 5028.159555] migrate_pages (mm/migrate.c:904 mm/migrate.c:941 mm/migrate.c:1122)
[ 5028.159555] ? isolate_freepages_block (mm/compaction.c:918)
[ 5028.159555] ? arch_local_save_flags (./arch/x86/include/asm/paravirt.h:819)
[ 5028.159555] compact_zone (mm/compaction.c:1209)
[ 5028.159555] compact_zone_order (mm/compaction.c:1256)
[ 5028.159555] try_to_compact_pages (mm/compaction.c:1323)
[ 5028.159555] __alloc_pages_direct_compact (./arch/x86/include/asm/current.h:14 mm/page_alloc.c:2313)
[ 5028.159555] __alloc_pages_nodemask (mm/page_alloc.c:2653 mm/page_alloc.c:2838)
[ 5028.159555] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 5028.159555] alloc_pages_vma (include/linux/mempolicy.h:76 include/linux/mempolicy.h:81 mm/mempolicy.c:2036)
[ 5028.159555] ? do_huge_pmd_wp_page (mm/huge_memory.c:774 mm/huge_memory.c:1123)
[ 5028.159555] do_huge_pmd_wp_page (mm/huge_memory.c:774 mm/huge_memory.c:1123)
[ 5028.159555] ? __mem_cgroup_count_vm_event (include/linux/rcupdate.h:423 include/linux/rcupdate.h:918 mm/memcontrol.c:1306)
[ 5028.159555] ? __mem_cgroup_count_vm_event (mm/memcontrol.c:1307)
[ 5028.159555] ? __mem_cgroup_count_vm_event (mm/memcontrol.c:1287)
[ 5028.159555] handle_mm_fault (mm/memory.c:3312 mm/memory.c:3370)
[ 5028.159555] ? __lock_is_held (kernel/locking/lockdep.c:3518)
[ 5028.159555] __do_page_fault (arch/x86/mm/fault.c:1249)
[ 5028.159555] ? vtime_account_user (kernel/sched/cputime.c:691)
[ 5028.159555] ? preempt_count_sub (kernel/sched/core.c:2634)
[ 5028.159555] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[ 5028.159555] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 5028.159555] trace_do_page_fault (arch/x86/mm/fault.c:1332 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1333)
[ 5028.159555] do_async_page_fault (arch/x86/kernel/kvm.c:280)
[ 5028.159555] async_page_fault (arch/x86/kernel/entry_64.S:1301)
[ 5028.159555] Code: 0f 85 00 02 00 00 4c 89 f0 8b 40 1c 41 39 c5 0f 85 31 01 00 00 e8 2c 03 ed ff 85 c0 74 0d 80 3d a4 0d cc 05 00 0f 84 8b 01 00 00 <4d> 3b 37 0f 85 12 01 00 00 44 89 e8 31 d2 f0 41 0f b1 56 1c 41
All code
========
   0:	0f 85 00 02 00 00    	jne    0x206
   6:	4c 89 f0             	mov    %r14,%rax
   9:	8b 40 1c             	mov    0x1c(%rax),%eax
   c:	41 39 c5             	cmp    %eax,%r13d
   f:	0f 85 31 01 00 00    	jne    0x146
  15:	e8 2c 03 ed ff       	callq  0xffffffffffed0346
  1a:	85 c0                	test   %eax,%eax
  1c:	74 0d                	je     0x2b
  1e:	80 3d a4 0d cc 05 00 	cmpb   $0x0,0x5cc0da4(%rip)        # 0x5cc0dc9
  25:	0f 84 8b 01 00 00    	je     0x1b6
  2b:*	4d 3b 37             	cmp    (%r15),%r14		<-- trapping instruction
  2e:	0f 85 12 01 00 00    	jne    0x146
  34:	44 89 e8             	mov    %r13d,%eax
  37:	31 d2                	xor    %edx,%edx
  39:	f0 41 0f b1 56 1c    	lock cmpxchg %edx,0x1c(%r14)
  3f:	41                   	rex.B
	...

Code starting with the faulting instruction
===========================================
   0:	4d 3b 37             	cmp    (%r15),%r14
   3:	0f 85 12 01 00 00    	jne    0x11b
   9:	44 89 e8             	mov    %r13d,%eax
   c:	31 d2                	xor    %edx,%edx
   e:	f0 41 0f b1 56 1c    	lock cmpxchg %edx,0x1c(%r14)
  14:	41                   	rex.B
	...
[ 5028.159555] RIP migrate_page_move_mapping (mm/migrate.c:358)
[ 5028.159555]  RSP <ffff880526dcb708>
[ 5028.159555] CR2: 0000000000000000

Codewise, it seems pretty straightforward:

	int migrate_page_move_mapping(struct address_space *mapping,
	                struct page *newpage, struct page *page,
	                struct buffer_head *head, enum migrate_mode mode,
	                int extra_count)
	{
	        int expected_count = 1 + extra_count;
	        void **pslot;
	
	        if (!mapping) {
	                /* Anonymous page without mapping */
	                if (page_count(page) != expected_count)
	                        return -EAGAIN;
	                return MIGRATEPAGE_SUCCESS;
	        }
	
	        spin_lock_irq(&mapping->tree_lock);
	
	        pslot = radix_tree_lookup_slot(&mapping->page_tree,
	                                        page_index(page));  <==== Returned NULL
	
	        expected_count += 1 + page_has_private(page);
	        if (page_count(page) != expected_count ||
	                radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) { <==== Dereferenced that NULL
	                spin_unlock_irq(&mapping->tree_lock);
	                return -EAGAIN;
	        }

I don't think it's just a missing '!= NULL' check but I'm not sure what went wrong.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
