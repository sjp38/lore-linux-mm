Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AF6536B006E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 18:35:13 -0500 (EST)
Received: by wwf10 with SMTP id 10so1669184wwf.26
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 15:35:10 -0800 (PST)
Subject: INFO: possible recursive locking detected: get_partial_node() on 3.2-rc1
Date: Thu, 10 Nov 2011 23:35:05 +0000
References: <20111109090556.GA5949@zhy>
In-Reply-To: <20111109090556.GA5949@zhy>
MIME-Version: 1.0
From: Julie Sullivan <kernelmail.jms@gmail.com>
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201111102335.06046.kernelmail.jms@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org

(was '3.2-rc1: INFO: possible recursive locking detect')

On Wednesday 09 November 2011 09:05:57 Yong Zhang wrote:
> 
>Hi,
>Just get below waring when doing:
>for i in `seq 1 10`; do ./perf bench -f simple sched messaging -g 40; done

>And kernel config is attached.

>Thanks,
>Yong

>---
>[  350.148020] =============================================
[  350.148020] [ INFO: possible recursive locking detected ]
[  350.148020] 3.2.0-rc1-10791-g76a4b59-dirty #2
[  350.148020] ---------------------------------------------
[  350.148020] perf/9439 is trying to acquire lock:
[  350.148020]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff8113847f>] get_partial_node+0x5f/0x360
[  350.148020] 
[  350.148020] but task is already holding lock:
[  350.148020]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff811380c9>] unfreeze_partials+0x199/0x3c0
[  350.148020] 
[  350.148020] other info that might help us debug this:
[  350.148020]  Possible unsafe locking scenario:
[  350.148020] 
[  350.148020]        CPU0
[  350.148020]        ----
[  350.148020]   lock(&(&n->list_lock)->rlock);
[  350.148020]   lock(&(&n->list_lock)->rlock);
[  350.148020] 
[  350.148020]  *** DEADLOCK ***
[  350.148020] 
[  350.148020]  May be due to missing lock nesting notation
[  350.148020] 
[  350.148020] 2 locks held by perf/9439:
[  350.148020]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff810552ee>] release_task+0x9e/0x500
>[  350.148020]  #1:  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff811380c9>] unfreeze_partials+0x199/0x3c0


Hi Yong

I've been getting a similar report not when using perf though, just in my dmesg at startup:
(if people want my .config please ask, I'm not including it else in case it's just unhelpful noise)

Cheers
Julie

[   34.545934] =============================================
[   34.545936] [ INFO: possible recursive locking detected ]
[   34.545939] 3.2.0-rc1 #103
[   34.545940] ---------------------------------------------
[   34.545943] kdeinit4/2559 is trying to acquire lock:
[   34.545945]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff8110aaa4>] get_partial_node+0x3f/0x17a
[   34.545954] 
[   34.545955] but task is already holding lock:
[   34.545957]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff81109efe>] unfreeze_partials+0xc4/0x193
[   34.545963] 
[   34.545964] other info that might help us debug this:
[   34.545966]  Possible unsafe locking scenario:
[   34.545966] 
[   34.545968]        CPU0
[   34.545969]        ----
[   34.545971]   lock(&(&n->list_lock)->rlock);
[   34.545974]   lock(&(&n->list_lock)->rlock);
[   34.545977] 
[   34.545978]  *** DEADLOCK ***
[   34.545978] 
[   34.545980]  May be due to missing lock nesting notation
[   34.545981] 
[   34.545983] 1 lock held by kdeinit4/2559:
[   34.545985]  #0:  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff81109efe>] unfreeze_partials+0xc4/0x193
[   34.545992] 
[   34.545992] stack backtrace:
[   34.545995] Pid: 2559, comm: kdeinit4 Not tainted 3.2.0-rc1 #103
[   34.545997] Call Trace:
[   34.546003]  [<ffffffff81076548>] __lock_acquire+0x9d8/0xdf7
[   34.546008]  [<ffffffff8105fdf5>] ? __kernel_text_address+0x26/0x4c
[   34.546010]  [<ffffffff81004c57>] ? print_context_stack+0x9c/0xb2
[   34.546010]  [<ffffffff8110aaa4>] ? get_partial_node+0x3f/0x17a
[   34.546010]  [<ffffffff81076e4a>] lock_acquire+0xd8/0xfe
[   34.546010]  [<ffffffff8110aaa4>] ? get_partial_node+0x3f/0x17a
[   34.546010]  [<ffffffff8107e092>] ? __module_text_address+0x12/0x5f
[   34.546010]  [<ffffffff815af2d3>] _raw_spin_lock+0x45/0x7a
[   34.546010]  [<ffffffff8110aaa4>] ? get_partial_node+0x3f/0x17a
[   34.546010]  [<ffffffff8110aaa4>] get_partial_node+0x3f/0x17a
[   34.546010]  [<ffffffff810733fb>] ? look_up_lock_class+0x5f/0xbe
[   34.546010]  [<ffffffff8107e092>] ? __module_text_address+0x12/0x5f
[   34.546010]  [<ffffffff8110ad4e>] __slab_alloc+0x16f/0x3ae
[   34.546010]  [<ffffffff81008529>] ? native_sched_clock+0x3b/0x3d
[   34.546010]  [<ffffffff81112d46>] ? create_object+0x39/0x283
[   34.546010]  [<ffffffff81008529>] ? native_sched_clock+0x3b/0x3d
[   34.546010]  [<ffffffff81072655>] ? arch_local_irq_save+0x9/0xc
[   34.546010]  [<ffffffff81112d46>] ? create_object+0x39/0x283
[   34.546010]  [<ffffffff8110c54c>] kmem_cache_alloc+0x5b/0x12b
[   34.546010]  [<ffffffff81112d46>] create_object+0x39/0x283
[   34.546010]  [<ffffffff8159655c>] kmemleak_alloc+0x73/0x98
[   34.546010]  [<ffffffff81250c3c>] ? __debug_object_init+0x43/0x2e7
[   34.546010]  [<ffffffff8110c5b4>] kmem_cache_alloc+0xc3/0x12b
[   34.546010]  [<ffffffff810679c7>] ? sched_clock_local+0x12/0x75
[   34.546010]  [<ffffffff81250c3c>] __debug_object_init+0x43/0x2e7
[   34.546010]  [<ffffffff81067b92>] ? local_clock+0x2b/0x3c
[   34.546010]  [<ffffffff81073b06>] ? lock_release_holdtime+0x59/0x60
[   34.546010]  [<ffffffff81250ef4>] debug_object_init+0x14/0x16
[   34.546010]  [<ffffffff8105fc57>] rcuhead_fixup_activate+0x27/0x5f
[   34.546010]  [<ffffffff81250943>] debug_object_fixup+0x1e/0x2b
[   34.546010]  [<ffffffff81250fdb>] debug_object_activate+0xcc/0xd9
[   34.546010]  [<ffffffff8110939f>] ? discard_slab+0x4e/0x4e
[   34.546010]  [<ffffffff810a8b77>] __call_rcu+0x4f/0x18e
[   34.546010]  [<ffffffff810a8ce2>] call_rcu_sched+0x15/0x17
[   34.546010]  [<ffffffff81109396>] discard_slab+0x45/0x4e
[   34.546010]  [<ffffffff81109fa4>] unfreeze_partials+0x16a/0x193
[   34.546010]  [<ffffffff81073b06>] ? lock_release_holdtime+0x59/0x60
[   34.546010]  [<ffffffff815afd87>] ? _raw_spin_unlock_irqrestore+0x3f/0x55
[   34.546010]  [<ffffffff8110a020>] put_cpu_partial+0x53/0xbd
[   34.546010]  [<ffffffff8110a197>] __slab_free+0x10d/0x229
[   34.546010]  [<ffffffff810f5e08>] ? anon_vma_free+0x3d/0x41
[   34.546010]  [<ffffffff810f5e08>] ? anon_vma_free+0x3d/0x41
[   34.546010]  [<ffffffff8110a44b>] kmem_cache_free+0x7d/0xc4
[   34.546010]  [<ffffffff810f5e08>] anon_vma_free+0x3d/0x41
[   34.546010]  [<ffffffff810f6d9e>] __put_anon_vma+0x38/0x3d
[   34.546010]  [<ffffffff810f6dcc>] put_anon_vma+0x29/0x2d
[   34.546010]  [<ffffffff810f6f28>] unlink_anon_vmas+0xf5/0x14c
[   34.546010]  [<ffffffff815ae4c4>] ? mutex_unlock+0xe/0x10
[   34.546010]  [<ffffffff810ed096>] free_pgtables+0x73/0xd0
[   34.546010]  [<ffffffff810f30ad>] exit_mmap+0xac/0xe5
[   34.546010]  [<ffffffff81043d05>] mmput+0x60/0x108
[   34.546010]  [<ffffffff81048323>] exit_mm+0x119/0x126
[   34.546010]  [<ffffffff815afd34>] ? _raw_spin_unlock_irq+0x30/0x44
[   34.546010]  [<ffffffff81049a59>] do_exit+0x233/0x80f
[   34.546010]  [<ffffffff81073330>] ? trace_hardirqs_off_caller+0x33/0x90
[   34.546010]  [<ffffffff815affca>] ? retint_swapgs+0xe/0x13
[   34.546010]  [<ffffffff8104a2dd>] do_group_exit+0x88/0xb6
[   34.546010]  [<ffffffff8104a322>] sys_exit_group+0x17/0x1b
[   34.546010]  [<ffffffff815b662b>] system_call_fastpath+0x16/0x1b




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
