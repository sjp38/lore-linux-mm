Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B70D96B0035
	for <linux-mm@kvack.org>; Sat, 12 Jul 2014 14:04:09 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so3068617pde.12
        for <linux-mm@kvack.org>; Sat, 12 Jul 2014 11:04:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tx10si5622201pac.29.2014.07.12.11.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 12 Jul 2014 11:04:08 -0700 (PDT)
Message-ID: <53C1788D.9080800@oracle.com>
Date: Sat, 12 Jul 2014 14:03:57 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: slub/debugobjects: lockup when freeing memory
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <20140619202928.GG4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192230390.5170@nanos> <20140619205307.GL4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192331250.5170@nanos> <20140619220449.GT4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406201015440.5170@nanos> <20140620154014.GC4904@linux.vnet.ibm.com>
In-Reply-To: <20140620154014.GC4904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/20/2014 11:40 AM, Paul E. McKenney wrote:
> rcu: Export debug_init_rcu_head() and and debug_init_rcu_head()
> 
> Currently, call_rcu() relies on implicit allocation and initialization
> for the debug-objects handling of RCU callbacks.  If you hammer the
> kernel hard enough with Sasha's modified version of trinity, you can end
> up with the sl*b allocators recursing into themselves via this implicit
> call_rcu() allocation.
> 
> This commit therefore exports the debug_init_rcu_head() and
> debug_rcu_head_free() functions, which permits the allocators to allocated
> and pre-initialize the debug-objects information, so that there no longer
> any need for call_rcu() to do that initialization, which in turn prevents
> the recursion into the memory allocators.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Acked-by: Thomas Gleixner <tglx@linutronix.de>

Hi Paul,

Oddly enough, I still see the issue in -next (I made sure that this patch
was in the tree):

[  393.810123] =============================================
[  393.810123] [ INFO: possible recursive locking detected ]
[  393.810123] 3.16.0-rc4-next-20140711-sasha-00046-g07d3099-dirty #813 Not tainted
[  393.810123] ---------------------------------------------
[  393.810123] trinity-c32/9762 is trying to acquire lock:
[  393.810123] (&(&n->list_lock)->rlock){-.-...}, at: get_partial_node.isra.39 (mm/slub.c:1628)
[  393.810123]
[  393.810123] but task is already holding lock:
[  393.810123] (&(&n->list_lock)->rlock){-.-...}, at: __kmem_cache_shutdown (mm/slub.c:3210 mm/slub.c:3233 mm/slub.c:3244)
[  393.810123]
[  393.810123] other info that might help us debug this:
[  393.810123]  Possible unsafe locking scenario:
[  393.810123]
[  393.810123]        CPU0
[  393.810123]        ----
[  393.810123]   lock(&(&n->list_lock)->rlock);
[  393.810123]   lock(&(&n->list_lock)->rlock);
[  393.810123]
[  393.810123]  *** DEADLOCK ***
[  393.810123]
[  393.810123]  May be due to missing lock nesting notation
[  393.810123]
[  393.810123] 5 locks held by trinity-c32/9762:
[  393.810123] #0: (net_mutex){+.+.+.}, at: copy_net_ns (net/core/net_namespace.c:254)
[  393.810123] #1: (cpu_hotplug.lock){++++++}, at: get_online_cpus (kernel/cpu.c:90)
[  393.810123] #2: (mem_hotplug.lock){.+.+.+}, at: get_online_mems (mm/memory_hotplug.c:83)
[  393.810123] #3: (slab_mutex){+.+.+.}, at: kmem_cache_destroy (mm/slab_common.c:344)
[  393.810123] #4: (&(&n->list_lock)->rlock){-.-...}, at: __kmem_cache_shutdown (mm/slub.c:3210 mm/slub.c:3233 mm/slub.c:3244)
[  393.810123]
[  393.810123] stack backtrace:
[  393.810123] CPU: 32 PID: 9762 Comm: trinity-c32 Not tainted 3.16.0-rc4-next-20140711-sasha-00046-g07d3099-dirty #813
[  393.843284]  ffff880bc26730e0 0000000000000000 ffffffffb4ae7ff0 ffff880bc26a3848
[  393.843284]  ffffffffb0e47068 ffffffffb4ae7ff0 ffff880bc26a38f0 ffffffffac258586
[  393.843284]  ffff880bc2673e30 000000050000000a ffffffffb444dee0 ffff880bc2673e48
[  393.843284] Call Trace:
[  393.843284] dump_stack (lib/dump_stack.c:52)
[  393.843284] __lock_acquire (kernel/locking/lockdep.c:1739 kernel/locking/lockdep.c:1783 kernel/locking/lockdep.c:2115 kernel/locking/lockdep.c:3182)
[  393.843284] lock_acquire (kernel/locking/lockdep.c:3602)
[  393.843284] ? get_partial_node.isra.39 (mm/slub.c:1628)
[  393.843284] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[  393.843284] ? get_partial_node.isra.39 (mm/slub.c:1628)
[  393.843284] get_partial_node.isra.39 (mm/slub.c:1628)
[  393.843284] ? check_irq_usage (kernel/locking/lockdep.c:1638)
[  393.843284] ? __slab_alloc (mm/slub.c:2307)
[  393.843284] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  393.843284] __slab_alloc (mm/slub.c:1730 mm/slub.c:2208 mm/slub.c:2372)
[  393.843284] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  393.843284] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  393.843284] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[  393.843284] kmem_cache_alloc (mm/slub.c:2445 mm/slub.c:2487 mm/slub.c:2492)
[  393.843284] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  393.843284] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  393.843284] ? check_chain_key (kernel/locking/lockdep.c:2188)
[  393.843284] __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
[  393.843284] ? _raw_spin_unlock_irqrestore (include/linux/spinlock_api_smp.h:160 kernel/locking/spinlock.c:191)
[  393.843284] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  393.843284] debug_object_init (lib/debugobjects.c:365)
[  393.843284] rcuhead_fixup_activate (kernel/rcu/update.c:260)
[  393.843284] debug_object_activate (lib/debugobjects.c:280 lib/debugobjects.c:439)
[  393.843284] ? preempt_count_sub (kernel/sched/core.c:2600)
[  393.843284] ? slab_cpuup_callback (mm/slub.c:1484)
[  393.843284] __call_rcu (kernel/rcu/rcu.h:76 (discriminator 8) kernel/rcu/tree.c:2665 (discriminator 8))
[  393.843284] ? __kmem_cache_shutdown (mm/slub.c:3210 mm/slub.c:3233 mm/slub.c:3244)
[  393.843284] call_rcu (kernel/rcu/tree_plugin.h:679)
[  393.843284] discard_slab (mm/slub.c:1522)
[  393.843284] __kmem_cache_shutdown (mm/slub.c:3210 mm/slub.c:3233 mm/slub.c:3244)
[  393.843284] kmem_cache_destroy (mm/slab_common.c:350)
[  393.843284] nf_conntrack_cleanup_net_list (net/netfilter/nf_conntrack_core.c:1569 (discriminator 3))
[  393.843284] nf_conntrack_pernet_exit (net/netfilter/nf_conntrack_standalone.c:558)
[  393.843284] ops_exit_list.isra.1 (net/core/net_namespace.c:135)
[  393.843284] setup_net (net/core/net_namespace.c:180 (discriminator 3))
[  393.843284] copy_net_ns (net/core/net_namespace.c:255)
[  393.843284] create_new_namespaces (kernel/nsproxy.c:95)
[  393.843284] unshare_nsproxy_namespaces (kernel/nsproxy.c:190 (discriminator 4))
[  393.843284] SyS_unshare (kernel/fork.c:1865 kernel/fork.c:1814)
[  393.843284] tracesys (arch/x86/kernel/entry_64.S:542)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
