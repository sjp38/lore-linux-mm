From: Sasha Levin <levinsasha928@gmail.com>
Subject: mm,numad,rcu: hang on OOM
Date: Fri, 29 Jun 2012 18:44:41 +0200
Message-ID: <1340988281.2936.58.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: paulmck <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi all,

While fuzzing using trinity on a KVM tools guest with todays linux-next, I've hit the following lockup:

[  362.261729] INFO: task numad/2:27 blocked for more than 120 seconds.
[  362.263974] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  362.271684] numad/2         D 0000000000000001  5672    27      2 0x00000000
[  362.280052]  ffff8800294c7c58 0000000000000046 ffff8800294c7c08 ffffffff81163dba
[  362.294477]  ffff8800294c6000 ffff8800294c6010 ffff8800294c7fd8 ffff8800294c6000
[  362.306631]  ffff8800294c6010 ffff8800294c7fd8 ffff88000d5c3000 ffff8800294c8000
[  362.315395] Call Trace:
[  362.318556]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
[  362.325411]  [<ffffffff8372ab75>] schedule+0x55/0x60
[  362.328844]  [<ffffffff8372b965>] rwsem_down_failed_common+0xf5/0x130
[  362.332501]  [<ffffffff8115d38e>] ? put_lock_stats+0xe/0x40
[  362.334496]  [<ffffffff81160135>] ? __lock_contended+0x1f5/0x230
[  362.336723]  [<ffffffff8372b9d5>] rwsem_down_read_failed+0x15/0x17
[  362.339297]  [<ffffffff81985e34>] call_rwsem_down_read_failed+0x14/0x30
[  362.341768]  [<ffffffff83729a29>] ? down_read+0x79/0xa0
[  362.343669]  [<ffffffff8122d262>] ? lazy_migrate_process+0x22/0x60
[  362.345616]  [<ffffffff8122d262>] lazy_migrate_process+0x22/0x60
[  362.347464]  [<ffffffff811453c0>] process_mem_migrate+0x10/0x20
[  362.349340]  [<ffffffff81145090>] move_processes+0x190/0x230
[  362.351398]  [<ffffffff81145b7a>] numad_thread+0x7a/0x120
[  362.353245]  [<ffffffff81145b00>] ? find_busiest_node+0x310/0x310
[  362.355396]  [<ffffffff81119e82>] kthread+0xb2/0xc0
[  362.356996]  [<ffffffff8372ea34>] kernel_thread_helper+0x4/0x10
[  362.359253]  [<ffffffff8372ccb4>] ? retint_restore_args+0x13/0x13
[  362.361168]  [<ffffffff81119dd0>] ? __init_kthread_worker+0x70/0x70
[  362.363277]  [<ffffffff8372ea30>] ? gs_change+0x13/0x13

I've hit sysrq-t to see what might be the cause, and it appears that an OOM was in progress, and was stuck on RCU:

[  578.086230] trinity-child69 D ffff8800277a54c8  3968  6658   6580 0x00000000
[  578.086230]  ffff880022c5f518 0000000000000046 ffff880022c5f4c8 ffff88001b9d6e00
[  578.086230]  ffff880022c5e000 ffff880022c5e010 ffff880022c5ffd8 ffff880022c5e000
[  578.086230]  ffff880022c5e010 ffff880022c5ffd8 ffff880023c08000 ffff880022c33000
[  578.086230] Call Trace:
[  578.086230]  [<ffffffff8372ab75>] schedule+0x55/0x60
[  578.086230]  [<ffffffff837285c8>] schedule_timeout+0x38/0x2c0
[  578.086230]  [<ffffffff81161d16>] ? mark_held_locks+0xf6/0x120
[  578.086230]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
[  578.086230]  [<ffffffff8372c67b>] ? _raw_spin_unlock_irq+0x2b/0x80
[  578.086230]  [<ffffffff8372a06f>] wait_for_common+0xff/0x170
[  578.086230]  [<ffffffff81132c10>] ? try_to_wake_up+0x290/0x290
[  578.086230]  [<ffffffff8372a188>] wait_for_completion+0x18/0x20
[  578.086230]  [<ffffffff811a5de7>] _rcu_barrier+0x4a7/0x4e0
[  578.086230]  [<ffffffff810705bd>] ? sched_clock+0x1d/0x30
[  578.086230]  [<ffffffff81134c95>] ? sched_clock_local+0x25/0x90
[  578.086230]  [<ffffffff81134e08>] ? sched_clock_cpu+0x108/0x120
[  578.086230]  [<ffffffff8116369c>] ? __lock_acquire+0x42c/0x4b0
[  578.086230]  [<ffffffff811a58d0>] ? rcu_barrier_func+0x70/0x70
[  578.086230]  [<ffffffff8115d38e>] ? put_lock_stats+0xe/0x40
[  578.086230]  [<ffffffff8115fe14>] ? __lock_acquired+0x2a4/0x2e0
[  578.086230]  [<ffffffff811a5e70>] rcu_barrier_bh+0x10/0x20
[  578.086230]  [<ffffffff811a5e96>] rcu_oom_notify+0x16/0x30
[  578.086230]  [<ffffffff81121f3e>] notifier_call_chain+0xee/0x130
[  578.086230]  [<ffffffff81122326>] __blocking_notifier_call_chain+0xa6/0xd0
[  578.086230]  [<ffffffff81122361>] blocking_notifier_call_chain+0x11/0x20
[  578.086230]  [<ffffffff811e3f14>] out_of_memory+0x44/0x240
[  578.086230]  [<ffffffff8372c560>] ? _raw_spin_unlock+0x30/0x60
[  578.086230]  [<ffffffff811eaabf>] __alloc_pages_slowpath+0x55f/0x6a0
[  578.086230]  [<ffffffff811ea305>] ? get_page_from_freelist+0x625/0x660
[  578.086230]  [<ffffffff811eae46>] __alloc_pages_nodemask+0x246/0x330
[  578.086230]  [<ffffffff8122cd0d>] alloc_pages_current+0xdd/0x110
[  578.086230]  [<ffffffff811df077>] __page_cache_alloc+0xc7/0xe0
[  578.086230]  [<ffffffff811e110f>] filemap_fault+0x35f/0x4c0
[  578.086230]  [<ffffffff8120e26e>] __do_fault+0xae/0x560
[  578.086230]  [<ffffffff8120ed81>] handle_pte_fault+0x81/0x1f0
[  578.086230]  [<ffffffff8120f219>] handle_mm_fault+0x329/0x350
[  578.086230]  [<ffffffff810a5211>] do_page_fault+0x421/0x450
[  578.086230]  [<ffffffff81208b6e>] ? might_fault+0x4e/0xa0
[  578.086230]  [<ffffffff81208b6e>] ? might_fault+0x4e/0xa0
[  578.086230]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
[  578.086230]  [<ffffffff81208b6e>] ? might_fault+0x4e/0xa0
[  578.086230]  [<ffffffff8109d301>] do_async_page_fault+0x31/0xb0
[  578.086230]  [<ffffffff8372cf95>] async_page_fault+0x25/0x30

Other than that, there are several threads stuck in hugepage related code trying to allocate:

[  578.086230] trinity-child72 D ffff880022cd84c8  3264  6661   6580 0x00000004
[  578.086230]  ffff880022ccd848 0000000000000046 ffff880022ccd7f8 ffffffff81163dba
[  578.086230]  ffff880022ccc000 ffff880022ccc010 ffff880022ccdfd8 ffff880022ccc000
[  578.086230]  ffff880022ccc010 ffff880022ccdfd8 ffff880027733000 ffff880022cd0000
[  578.086230] Call Trace:
[  578.086230]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
[  578.086230]  [<ffffffff8372ab75>] schedule+0x55/0x60
[  578.086230]  [<ffffffff83728806>] schedule_timeout+0x276/0x2c0
[  578.086230]  [<ffffffff810fe110>] ? lock_timer_base+0x70/0x70
[  578.086230]  [<ffffffff83728869>] schedule_timeout_uninterruptible+0x19/0x20
[  578.086230]  [<ffffffff811eaa4f>] __alloc_pages_slowpath+0x4ef/0x6a0
[  578.086230]  [<ffffffff811ea305>] ? get_page_from_freelist+0x625/0x660
[  578.086230]  [<ffffffff811eae46>] __alloc_pages_nodemask+0x246/0x330
[  578.086230]  [<ffffffff8122cd0d>] alloc_pages_current+0xdd/0x110
[  578.086230]  [<ffffffff810a9a16>] pte_alloc_one+0x16/0x40
[  578.086230]  [<ffffffff812099bd>] __pte_alloc+0x2d/0x1e0
[  578.086230]  [<ffffffff81245831>] do_huge_pmd_anonymous_page+0x151/0x230
[  578.086230]  [<ffffffff8120f0d3>] handle_mm_fault+0x1e3/0x350
[  578.086230]  [<ffffffff8120b0b7>] ? follow_page+0xe7/0x5a0
[  578.086230]  [<ffffffff8120f738>] __get_user_pages+0x438/0x5d0
[  578.086230]  [<ffffffff81210826>] __mlock_vma_pages_range+0xc6/0xd0
[  578.086230]  [<ffffffff81210a25>] mlock_vma_pages_range+0x75/0xb0
[  578.086230]  [<ffffffff8121463c>] mmap_region+0x4bc/0x5f0
[  578.086230]  [<ffffffff81214a29>] do_mmap_pgoff+0x2b9/0x350
[  578.086230]  [<ffffffff811ff39c>] ? vm_mmap_pgoff+0x6c/0xb0
[  578.086230]  [<ffffffff811ff3b4>] vm_mmap_pgoff+0x84/0xb0
[  578.086230]  [<ffffffff81211f32>] sys_mmap_pgoff+0x182/0x190
[  578.086230]  [<ffffffff81985efe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  578.086230]  [<ffffffff8106d4dd>] sys_mmap+0x1d/0x20
[  578.086230]  [<ffffffff8372d579>] system_call_fastpath+0x16/0x1b

And with one, trying to do the following:

[  578.086230] trinity-child70 R  running task     3440  6659   6580 0x00000004
[  578.086230]  ffff880022c7f5e8 0000000000000046 ffff880022c7f5b8 ffffffff81161d16
[  578.086230]  ffff880022c7e000 ffff880022c7e010 ffff880022c7ffd8 ffff880022c7e000
[  578.086230]  ffff880022c7e010 ffff880022c7ffd8 ffff880028e13000 ffff880022c80000
[  578.086230] Call Trace:
[  578.086230]  [<ffffffff81161d16>] ? mark_held_locks+0xf6/0x120
[  578.086230]  [<ffffffff8372af94>] preempt_schedule_irq+0x94/0xd0
[  578.086230]  [<ffffffff8372cde6>] retint_kernel+0x26/0x30
[  578.086230]  [<ffffffff8305c9a5>] ? shrink_zcache_memory+0xe5/0x110
[  578.086230]  [<ffffffff811f6c10>] shrink_slab+0xd0/0x520
[  578.086230]  [<ffffffff811f6b10>] ? shrink_zones+0x1f0/0x220
[  578.086230]  [<ffffffff811f7ee9>] do_try_to_free_pages+0x1c9/0x3e0
[  578.086230]  [<ffffffff811f8323>] try_to_free_pages+0x143/0x200
[  578.086230]  [<ffffffff8372c5f5>] ? _raw_spin_unlock_irqrestore+0x65/0xc0
[  578.086230]  [<ffffffff811e60db>] __perform_reclaim+0x8b/0xe0
[  578.086230]  [<ffffffff811ea967>] __alloc_pages_slowpath+0x407/0x6a0
[  578.086230]  [<ffffffff811ea305>] ? get_page_from_freelist+0x625/0x660
[  578.086230]  [<ffffffff811eae46>] __alloc_pages_nodemask+0x246/0x330
[  578.086230]  [<ffffffff8122cd0d>] alloc_pages_current+0xdd/0x110
[  578.086230]  [<ffffffff810a9a16>] pte_alloc_one+0x16/0x40
[  578.086230]  [<ffffffff812099bd>] __pte_alloc+0x2d/0x1e0
[  578.086230]  [<ffffffff81245831>] do_huge_pmd_anonymous_page+0x151/0x230
[  578.086230]  [<ffffffff8120f0d3>] handle_mm_fault+0x1e3/0x350
[  578.086230]  [<ffffffff8120b0b7>] ? follow_page+0xe7/0x5a0
[  578.086230]  [<ffffffff8120f738>] __get_user_pages+0x438/0x5d0
[  578.086230]  [<ffffffff81210826>] __mlock_vma_pages_range+0xc6/0xd0
[  578.086230]  [<ffffffff81210a25>] mlock_vma_pages_range+0x75/0xb0
[  578.086230]  [<ffffffff8121463c>] mmap_region+0x4bc/0x5f0
[  578.086230]  [<ffffffff81214a29>] do_mmap_pgoff+0x2b9/0x350
[  578.086230]  [<ffffffff811ff39c>] ? vm_mmap_pgoff+0x6c/0xb0
[  578.086230]  [<ffffffff811ff3b4>] vm_mmap_pgoff+0x84/0xb0
[  578.086230]  [<ffffffff81211f32>] sys_mmap_pgoff+0x182/0x190
[  578.086230]  [<ffffffff81985efe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  578.086230]  [<ffffffff8106d4dd>] sys_mmap+0x1d/0x20
[  578.086230]  [<ffffffff8372d579>] system_call_fastpath+0x16/0x1b

The rest of the threads weren't particularly interesting, so I guess that the problem in one of the above.
