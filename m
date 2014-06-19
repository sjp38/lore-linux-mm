From: Sasha Levin <sasha.levin@oracle.com>
Subject: slub/debugobjects: lockup when freeing memory
Date: Thu, 19 Jun 2014 10:30:30 -0400
Message-ID: <53A2F406.4010109@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew. It seems to cause an actual lockup
as hung task messages followed soon after.

[  690.762537] =============================================
[  690.764196] [ INFO: possible recursive locking detected ]
[  690.765247] 3.16.0-rc1-next-20140618-sasha-00029-g9e4acf8-dirty #664 Tainted: G        W
[  690.766457] ---------------------------------------------
[  690.767237] kworker/u95:0/256 is trying to acquire lock:
[  690.767886] (&(&n->list_lock)->rlock){-.-.-.}, at: get_partial_node.isra.35 (mm/slub.c:1630)
[  690.769162]
[  690.769162] but task is already holding lock:
[  690.769851] (&(&n->list_lock)->rlock){-.-.-.}, at: kmem_cache_close (mm/slub.c:3209 mm/slub.c:3233)
[  690.770137]
[  690.770137] other info that might help us debug this:
[  690.770137]  Possible unsafe locking scenario:
[  690.770137]
[  690.770137]        CPU0
[  690.770137]        ----
[  690.770137]   lock(&(&n->list_lock)->rlock);
[  690.770137]   lock(&(&n->list_lock)->rlock);
[  690.770137]
[  690.770137]  *** DEADLOCK ***
[  690.770137]
[  690.770137]  May be due to missing lock nesting notation
[  690.770137]
[  690.770137] 7 locks held by kworker/u95:0/256:
[  690.770137] #0: ("%s"("netns")){.+.+.+}, at: process_one_work (include/linux/workqueue.h:185 kernel/workqueue.c:599 kernel/workqueue.c:626 kernel/workqueue.c:2074)
[  690.770137] #1: (net_cleanup_work){+.+.+.}, at: process_one_work (include/linux/workqueue.h:185 kernel/workqueue.c:599 kernel/workqueue.c:626 kernel/workqueue.c:2074)
[  690.770137] #2: (net_mutex){+.+.+.}, at: cleanup_net (net/core/net_namespace.c:287)
[  690.770137] #3: (cpu_hotplug.lock){++++++}, at: get_online_cpus (kernel/cpu.c:90)
[  690.770137] #4: (mem_hotplug.lock){.+.+.+}, at: get_online_mems (mm/memory_hotplug.c:83)
[  690.770137] #5: (slab_mutex){+.+.+.}, at: kmem_cache_destroy (mm/slab_common.c:343)
[  690.770137] #6: (&(&n->list_lock)->rlock){-.-.-.}, at: kmem_cache_close (mm/slub.c:3209 mm/slub.c:3233)
[  690.770137]
[  690.770137] stack backtrace:
[  690.770137] CPU: 18 PID: 256 Comm: kworker/u95:0 Tainted: G        W     3.16.0-rc1-next-20140618-sasha-00029-g9e4acf8-dirty #664
[  690.770137] Workqueue: netns cleanup_net
[  690.770137]  ffff8808a172b000 ffff8808a1737628 ffffffff9d5179a0 0000000000000003
[  690.770137]  ffffffffa0b499c0 ffff8808a1737728 ffffffff9a1cac52 ffff8808a1737668
[  690.770137]  ffffffff9a1a74f8 23e00d8075e32f12 ffff8808a172b000 23e00d8000000001
[  690.770137] Call Trace:
[  690.770137] dump_stack (lib/dump_stack.c:52)
[  690.770137] __lock_acquire (kernel/locking/lockdep.c:3034 kernel/locking/lockdep.c:3180)
[  690.770137] ? sched_clock_cpu (kernel/sched/clock.c:311)
[  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  690.770137] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  690.770137] ? get_partial_node.isra.35 (mm/slub.c:1630)
[  690.770137] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  690.770137] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[  690.770137] ? get_partial_node.isra.35 (mm/slub.c:1630)
[  690.770137] get_partial_node.isra.35 (mm/slub.c:1630)
[  690.770137] ? __slab_alloc (mm/slub.c:2304)
[  690.770137] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  690.770137] __slab_alloc (mm/slub.c:1732 mm/slub.c:2205 mm/slub.c:2369)
[  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  690.770137] kmem_cache_alloc (mm/slub.c:2442 mm/slub.c:2484 mm/slub.c:2489)
[  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  690.770137] ? debug_object_activate (lib/debugobjects.c:439)
[  690.770137] __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  690.770137] debug_object_init (lib/debugobjects.c:365)
[  690.770137] rcuhead_fixup_activate (kernel/rcu/update.c:231)
[  690.770137] debug_object_activate (lib/debugobjects.c:280 lib/debugobjects.c:439)
[  690.770137] ? discard_slab (mm/slub.c:1486)
[  690.770137] __call_rcu (kernel/rcu/rcu.h:76 (discriminator 2) kernel/rcu/tree.c:2585 (discriminator 2))
[  690.770137] call_rcu (kernel/rcu/tree_plugin.h:679)
[  690.770137] discard_slab (mm/slub.c:1515 mm/slub.c:1523)
[  690.770137] kmem_cache_close (mm/slub.c:3212 mm/slub.c:3233)
[  690.770137] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  690.770137] __kmem_cache_shutdown (mm/slub.c:3245)
[  690.770137] kmem_cache_destroy (mm/slab_common.c:349)
[  690.770137] nf_conntrack_cleanup_net_list (net/netfilter/nf_conntrack_core.c:1569 (discriminator 2))
[  690.770137] nf_conntrack_pernet_exit (net/netfilter/nf_conntrack_standalone.c:558)
[  690.770137] ops_exit_list.isra.1 (net/core/net_namespace.c:135)
[  690.770137] cleanup_net (net/core/net_namespace.c:302 (discriminator 2))
[  690.770137] process_one_work (kernel/workqueue.c:2081 include/linux/jump_label.h:115 include/trace/events/workqueue.h:111 kernel/workqueue.c:2086)
[  690.770137] ? process_one_work (include/linux/workqueue.h:185 kernel/workqueue.c:599 kernel/workqueue.c:626 kernel/workqueue.c:2074)
[  690.770137] worker_thread (kernel/workqueue.c:2213)
[  690.770137] ? rescuer_thread (kernel/workqueue.c:2157)
[  690.770137] kthread (kernel/kthread.c:210)
[  690.770137] ? kthread_create_on_node (kernel/kthread.c:176)
[  690.770137] ret_from_fork (arch/x86/kernel/entry_64.S:349)


Thanks,
Sasha
