Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2E8BE6B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 05:46:53 -0400 (EDT)
Date: Wed, 3 Oct 2012 11:46:42 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH v2] [RFC] mm, slab: release slab_mutex earlier in
 kmem_cache_destroy()
In-Reply-To: <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
Message-ID: <alpine.LNX.2.00.1210031143260.23544@pobox.suse.cz>
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz>
 <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 3 Oct 2012, Jiri Kosina wrote:

> Good question. I believe it should be safe to drop slab_mutex earlier, as 
> cachep has already been unlinked. I am adding slab people and linux-mm to 
> CC (the whole thread on LKML can be found at 
> https://lkml.org/lkml/2012/10/2/296 for reference).
> 
> How about the patch below? Pekka, Christoph, please?

It turns out that lockdep is actually getting this wrong, so the changelog 
in the previous version wasn't accurate.

Please find patch with updated changelog below. Pekka, Christoph, could 
you please check whether it makes sense to you as well? Thanks.




From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] mm, slab: release slab_mutex earlier in kmem_cache_destroy()

Commit 1331e7a1bbe1 ("rcu: Remove _rcu_barrier() dependency on
__stop_machine()") introduced slab_mutex -> cpu_hotplug.lock
dependency through kmem_cache_destroy() -> rcu_barrier() ->
_rcu_barrier() -> get_online_cpus().

Lockdep thinks that this might actually result in ABBA deadlock,
and reports it as below:

=== [ cut here ] ===
 ======================================================
 [ INFO: possible circular locking dependency detected ]
 3.6.0-rc5-00004-g0d8ee37 #143 Not tainted
 -------------------------------------------------------
 kworker/u:2/40 is trying to acquire lock:
  (rcu_sched_state.barrier_mutex){+.+...}, at: [<ffffffff810f2126>] _rcu_barrier+0x26/0x1e0

 but task is already holding lock:
  (slab_mutex){+.+.+.}, at: [<ffffffff81176e15>] kmem_cache_destroy+0x45/0xe0

 which lock already depends on the new lock.

 the existing dependency chain (in reverse order) is:

 -> #2 (slab_mutex){+.+.+.}:
        [<ffffffff810ae1e2>] validate_chain+0x632/0x720
        [<ffffffff810ae5d9>] __lock_acquire+0x309/0x530
        [<ffffffff810ae921>] lock_acquire+0x121/0x190
        [<ffffffff8155d4cc>] __mutex_lock_common+0x5c/0x450
        [<ffffffff8155d9ee>] mutex_lock_nested+0x3e/0x50
        [<ffffffff81558cb5>] cpuup_callback+0x2f/0xbe
        [<ffffffff81564b83>] notifier_call_chain+0x93/0x140
        [<ffffffff81076f89>] __raw_notifier_call_chain+0x9/0x10
        [<ffffffff8155719d>] _cpu_up+0xba/0x14e
        [<ffffffff815572ed>] cpu_up+0xbc/0x117
        [<ffffffff81ae05e3>] smp_init+0x6b/0x9f
        [<ffffffff81ac47d6>] kernel_init+0x147/0x1dc
        [<ffffffff8156ab44>] kernel_thread_helper+0x4/0x10

 -> #1 (cpu_hotplug.lock){+.+.+.}:
        [<ffffffff810ae1e2>] validate_chain+0x632/0x720
        [<ffffffff810ae5d9>] __lock_acquire+0x309/0x530
        [<ffffffff810ae921>] lock_acquire+0x121/0x190
        [<ffffffff8155d4cc>] __mutex_lock_common+0x5c/0x450
        [<ffffffff8155d9ee>] mutex_lock_nested+0x3e/0x50
        [<ffffffff81049197>] get_online_cpus+0x37/0x50
        [<ffffffff810f21bb>] _rcu_barrier+0xbb/0x1e0
        [<ffffffff810f22f0>] rcu_barrier_sched+0x10/0x20
        [<ffffffff810f2309>] rcu_barrier+0x9/0x10
        [<ffffffff8118c129>] deactivate_locked_super+0x49/0x90
        [<ffffffff8118cc01>] deactivate_super+0x61/0x70
        [<ffffffff811aaaa7>] mntput_no_expire+0x127/0x180
        [<ffffffff811ab49e>] sys_umount+0x6e/0xd0
        [<ffffffff81569979>] system_call_fastpath+0x16/0x1b

 -> #0 (rcu_sched_state.barrier_mutex){+.+...}:
        [<ffffffff810adb4e>] check_prev_add+0x3de/0x440
        [<ffffffff810ae1e2>] validate_chain+0x632/0x720
        [<ffffffff810ae5d9>] __lock_acquire+0x309/0x530
        [<ffffffff810ae921>] lock_acquire+0x121/0x190
        [<ffffffff8155d4cc>] __mutex_lock_common+0x5c/0x450
        [<ffffffff8155d9ee>] mutex_lock_nested+0x3e/0x50
        [<ffffffff810f2126>] _rcu_barrier+0x26/0x1e0
        [<ffffffff810f22f0>] rcu_barrier_sched+0x10/0x20
        [<ffffffff810f2309>] rcu_barrier+0x9/0x10
        [<ffffffff81176ea1>] kmem_cache_destroy+0xd1/0xe0
        [<ffffffffa04c3154>] nf_conntrack_cleanup_net+0xe4/0x110 [nf_conntrack]
        [<ffffffffa04c31aa>] nf_conntrack_cleanup+0x2a/0x70 [nf_conntrack]
        [<ffffffffa04c42ce>] nf_conntrack_net_exit+0x5e/0x80 [nf_conntrack]
        [<ffffffff81454b79>] ops_exit_list+0x39/0x60
        [<ffffffff814551ab>] cleanup_net+0xfb/0x1b0
        [<ffffffff8106917b>] process_one_work+0x26b/0x4c0
        [<ffffffff81069f3e>] worker_thread+0x12e/0x320
        [<ffffffff8106f73e>] kthread+0x9e/0xb0
        [<ffffffff8156ab44>] kernel_thread_helper+0x4/0x10

 other info that might help us debug this:

 Chain exists of:
   rcu_sched_state.barrier_mutex --> cpu_hotplug.lock --> slab_mutex

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(slab_mutex);
                                lock(cpu_hotplug.lock);
                                lock(slab_mutex);
   lock(rcu_sched_state.barrier_mutex);

  *** DEADLOCK ***
=== [ cut here ] ===

This is actually a false positive. Lockdep has no way of knowing the fact
that the ABBA can actually never happen, because of special semantics of
cpu_hotplug.refcount and itss handling in cpu_hotplug_begin(); the mutual
exclusion there is not achieved through mutex, but through
cpu_hotplug.refcount.

The "neither cpu_up() nor cpu_down() will proceed past cpu_hotplug_begin()
until everyone who called get_online_cpus() will call put_online_cpus()"
semantics is totally invisible to lockdep.

This patch therefore moves the unlock of slab_mutex so that rcu_barrier()
is being called with it unlocked. It has two advantages:

- it slightly reduces hold time of slab_mutex; as it's used to protect
  the cachep list, it's not necessary to hold it over __kmem_cache_destroy()
  call any more
- it silences the lockdep false positive warning, as it avoids lockdep ever
  learning about slab_mutex -> cpu_hotplug.lock dependency

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1133911..693c7cb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2801,12 +2801,12 @@ void kmem_cache_destroy(struct kmem_cache *cachep)
 		put_online_cpus();
 		return;
 	}
+	mutex_unlock(&slab_mutex);
 
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
 		rcu_barrier();
 
 	__kmem_cache_destroy(cachep);
-	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
