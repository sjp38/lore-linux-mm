Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E7E506B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 03:03:20 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0683JFQ001483
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 03:03:19 -0500
Date: Thu, 6 Jan 2011 03:03:19 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1647057595.150391.1294300999587.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: known oom issues on numa in -mm tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Did anyone notice the oom issues on numa systems in -mm tree? There are several of oom tests using cpuset and memcg are either waiting for a long time to trigger oom or hung completely. Here were some sysrq-t output while those were happening.

CAI Qian


oom02           R  running task        0  2057   2053 0x00000088
 0000000000000282 ffffffffffffff10 ffffffff81098272 0000000000000010
 0000000000000202 ffff8802159d7a18 0000000000000018 ffffffff81098252
 01ff8802159d7a28 0000000000000000 0000000000000000 ffffffff810ffd60
Call Trace:
 [<ffffffff81098272>] ? smp_call_function_many+0x1b2/0x210
 [<ffffffff81098252>] ? smp_call_function_many+0x192/0x210
 [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
 [<ffffffff810982f2>] ? smp_call_function+0x22/0x30
 [<ffffffff81067df4>] ? on_each_cpu+0x24/0x50
 [<ffffffff810fdbec>] ? drain_all_pages+0x1c/0x20
 [<ffffffff811003eb>] ? __alloc_pages_nodemask+0x4fb/0x800
 [<ffffffff81138b59>] ? alloc_page_vma+0x89/0x140
 [<ffffffff8111c011>] ? handle_mm_fault+0x871/0xd80
 [<ffffffff8149fd6b>] ? schedule+0x3eb/0x9b0
 [<ffffffff811187a0>] ? follow_page+0x220/0x370
 [<ffffffff8111c68b>] ? __get_user_pages+0x16b/0x4d0
 [<ffffffff8111eaa0>] ? __mlock_vma_pages_range+0xe0/0x250
 [<ffffffff8111eecb>] ? mlock_fixup+0x16b/0x200
 [<ffffffff8111f219>] ? do_mlock+0xc9/0x100
 [<ffffffff8111f398>] ? sys_mlock+0xb8/0x100
 [<ffffffff8100bfc2>] ? system_call_fastpath+0x16/0x1b

oom04           D ffff880218416b50     0  2027   2025 0x00000080
 ffff88021b0c5498 0000000000000086 0000000000000001 0000000000000000
 ffff8802184165c0 0000000000014d80 ffff88021b0c5fd8 ffff88021b0c4010
 ffff88021b0c5fd8 0000000000014d80 ffff88021f2055c0 ffff8802184165c0
Call Trace:
 [<ffffffff814a03a0>] io_schedule+0x70/0xc0
 [<ffffffff8120a1a8>] get_request_wait+0xc8/0x1a0
 [<ffffffff81082930>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff812030a7>] ? elv_merge+0x47/0x210
 [<ffffffff8120a2eb>] __make_request+0x6b/0x4d0
 [<ffffffff81208144>] generic_make_request+0x214/0x5a0
 [<ffffffff810f9f95>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810fa133>] ? mempool_alloc+0x63/0x150
 [<ffffffff81208556>] submit_bio+0x86/0x110
 [<ffffffff811027e2>] ? test_set_page_writeback+0xf2/0x1a0
 [<ffffffff8112aeb3>] swap_writepage+0x83/0xd0
 [<ffffffff811070ee>] pageout+0x12e/0x310
 [<ffffffff81108efb>] shrink_page_list+0x32b/0x600
 [<ffffffff81109336>] shrink_inactive_list+0x166/0x480
 [<ffffffff811478d9>] ? mem_cgroup_get_local_zonestat+0x99/0xc0
 [<ffffffff8110112a>] ? determine_dirtyable_memory+0x1a/0x30
 [<ffffffff811099b3>] shrink_zone+0x363/0x510
 [<ffffffff8108cca9>] ? ktime_get_ts+0xa9/0xe0
 [<ffffffff81109c23>] do_try_to_free_pages+0xc3/0x500
 [<ffffffff8110a1b9>] try_to_free_mem_cgroup_pages+0xa9/0x130
 [<ffffffff81148eae>] mem_cgroup_hierarchical_reclaim+0x29e/0x430
 [<ffffffff8114ada0>] __mem_cgroup_try_charge+0x480/0x5a0
 [<ffffffff8114b792>] mem_cgroup_charge_common+0x52/0x90
 [<ffffffff8114b955>] mem_cgroup_newpage_charge+0x55/0x60
 [<ffffffff8111c043>] handle_mm_fault+0x8a3/0xd80
 [<ffffffff8103ea89>] ? kernel_map_pages+0x109/0x110
 [<ffffffff8100c9ae>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff8100c9ae>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff814a5f23>] do_page_fault+0x143/0x4d0
 [<ffffffff8105a1fc>] ? pick_next_task_fair+0xfc/0x130
 [<ffffffff8149fafb>] ? schedule+0x17b/0x9b0
 [<ffffffff814a2995>] page_fault+0x25/0x30

oom02           R  running task        0  2375   2373 0x00000088
 ffff88010ded2f40 0000000000000086 ffff88041a75b5a8 ffffffff81215541
 ffff8801e6065e90 ffff8801e6065e90 ffff88041a75b5c8 ffffffff81203054
 ffff88041a75b5c8 ffff880214e1a8f8 0000000000000001 ffff8801e6065e90
Call Trace:
 [<ffffffff81215541>] ? blkiocg_update_io_merged_stats+0x61/0x90
 [<ffffffff81203054>] ? elv_merged_request+0x84/0x90
 [<ffffffff8120a6be>] ? __make_request+0x43e/0x4d0
 [<ffffffff81208144>] ? generic_make_request+0x214/0x5a0
 [<ffffffff810f9f95>] ? mempool_alloc_slab+0x15/0x20
 [<ffffffff810fa133>] ? mempool_alloc+0x63/0x150
 [<ffffffff81208556>] ? submit_bio+0x86/0x110
 [<ffffffff811027e2>] ? test_set_page_writeback+0xf2/0x1a0
 [<ffffffff81103b92>] ? pagevec_move_tail+0x112/0x130
 [<ffffffff81104216>] ? __pagevec_release+0x26/0x40
 [<ffffffff811080bb>] ? putback_lru_pages+0x26b/0x2c0
 [<ffffffff8103e467>] ? __change_page_attr_set_clr+0x807/0xd20
 [<ffffffff8103e467>] ? __change_page_attr_set_clr+0x807/0xd20
 [<ffffffff81109415>] ? shrink_inactive_list+0x245/0x480
 [<ffffffff81101303>] ? throttle_vm_writeout+0x43/0xb0
 [<ffffffff814a2192>] ? _raw_spin_lock+0x12/0x30
 [<ffffffff8103ea89>] ? kernel_map_pages+0x109/0x110
 [<ffffffff8113e95e>] ? cache_free_debugcheck+0x2ce/0x370
 [<ffffffff8121e769>] ? free_cpumask_var+0x9/0x10
 [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
 [<ffffffff8100c9ae>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff81098272>] ? smp_call_function_many+0x1b2/0x210
 [<ffffffff81098252>] ? smp_call_function_many+0x192/0x210
 [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
 [<ffffffff810982f2>] ? smp_call_function+0x22/0x30
 [<ffffffff81067df4>] ? on_each_cpu+0x24/0x50
 [<ffffffff810fdbec>] ? drain_all_pages+0x1c/0x20
 [<ffffffff811003eb>] ? __alloc_pages_nodemask+0x4fb/0x800
 [<ffffffff81138b59>] ? alloc_page_vma+0x89/0x140
 [<ffffffff8111c011>] ? handle_mm_fault+0x871/0xd80
 [<ffffffff8149fafb>] ? schedule+0x17b/0x9b0
 [<ffffffff8100ca8e>] ? invalidate_interrupt5+0xe/0x20
 [<ffffffff8100c9ae>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff814a5f23>] ? do_page_fault+0x143/0x4d0
 [<ffffffff8100a7b4>] ? __switch_to+0x194/0x320
 [<ffffffff8149fd6b>] ? schedule+0x3eb/0x9b0
 [<ffffffff814a2995>] ? page_fault+0x25/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
