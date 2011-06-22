Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5512A90015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 03:02:24 -0400 (EDT)
Message-ID: <4E01937C.90609@cs.helsinki.fi>
Date: Wed, 22 Jun 2011 10:02:20 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: slab vs lockdep vs debugobjects
References: <1308592080.26237.114.camel@twins>
In-Reply-To: <1308592080.26237.114.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 6/20/11 8:48 PM, Peter Zijlstra wrote:
> Hi Pekka,
>
> Thomas found a fun lockdep splat, see below. Basically call_rcu() can
> end up in kmem_cache_alloc(), and call_rcu() is used under
> l3->list_lock, causing the splat. Since the debug kmem_cache isn't
> SLAB_DESTROY_BY_RCU this shouldn't ever actually recurse.
>
> Now, since this particular kmem_cache is created with
> SLAB_DEBUG_OBJECTS, we thought it might be easy enough to set a separate
> lockdep class for its l3->list_lock's.
>
> However I found that the existing lockdep annotation is for kmalloc only
> -- don't custom kmem_caches use OFF_SLAB?

Looks like a bug. Custom caches can use OFF_SLAB too.

> Anyway, I got lost in slab (again), but would it make sense to move all
> lockdep fixups into kmem_list3_init() or thereabouts?

Yup.

> ---
> =============================================
> [ INFO: possible recursive locking detected ]
> 3.0.0-rc3+ #37
> ---------------------------------------------
> udevd/124 is trying to acquire lock:
>   (&(&parent->list_lock)->rlock){......}, at: [<ffffffff81119619>] ____cache_alloc+0xc9/0x323
>
> but task is already holding lock:
>   (&(&parent->list_lock)->rlock){......}, at: [<ffffffff8111844e>] __cache_free+0x325/0x3ea
>
> other info that might help us debug this:
>   Possible unsafe locking scenario:
>
>         CPU0
>         ----
>    lock(&(&parent->list_lock)->rlock);
>    lock(&(&parent->list_lock)->rlock);
>
>   *** DEADLOCK ***
>
>   May be due to missing lock nesting notation
>
> 2 locks held by udevd/124:
>   #0:  (&(&(*({ do { const void *__vpp_verify = (typeof((&(slab_lock))))((void *)0); (void)__vpp_verify; } while (0); ({ unsigned long __ptr; __asm__ ("" : "=r"(__ptr) : "0"((typeof(*(&(slab_lock))) *)(&(slab_lock)))); (typeof((typeof(*(&(slab_lock))) *)(&(slab_lock)))) (__ptr + (((__per_cpu_offset[__cpu])))); }); })).lock)->rlock){..-...}, at: [<ffffffff811164cc>] __local_lock_irq+0x16/0x61
>   #1:  (&(&parent->list_lock)->rlock){......}, at: [<ffffffff8111844e>] __cache_free+0x325/0x3ea
>
> stack backtrace:
> Pid: 124, comm: udevd Not tainted 3.0.0-rc3+ #37
> Call Trace:
>   [<ffffffff81081e3d>] __lock_acquire+0x9ae/0xdc8
>   [<ffffffff8107f289>] ? look_up_lock_class+0x5f/0xbe
>   [<ffffffff810812e4>] ? mark_lock+0x2d/0x1d8
>   [<ffffffff81119619>] ? ____cache_alloc+0xc9/0x323
>   [<ffffffff81082774>] lock_acquire+0x103/0x12e
>   [<ffffffff81119619>] ? ____cache_alloc+0xc9/0x323
>   [<ffffffff8107f6b9>] ? register_lock_class+0x1e/0x2ca
>   [<ffffffff81247054>] ? __debug_object_init+0x43/0x2e7
>   [<ffffffff814a7730>] _raw_spin_lock+0x3b/0x4a
>   [<ffffffff81119619>] ? ____cache_alloc+0xc9/0x323
>   [<ffffffff81119619>] ____cache_alloc+0xc9/0x323
>   [<ffffffff8107f6b9>] ? register_lock_class+0x1e/0x2ca
>   [<ffffffff81247054>] ? __debug_object_init+0x43/0x2e7
>   [<ffffffff8111b0d5>] kmem_cache_alloc+0xc5/0x1fb
>   [<ffffffff81247054>] __debug_object_init+0x43/0x2e7
>   [<ffffffff8124735f>] ? debug_object_activate+0x38/0xdc
>   [<ffffffff810812e4>] ? mark_lock+0x2d/0x1d8
>   [<ffffffff8124730c>] debug_object_init+0x14/0x16
>   [<ffffffff8106bd26>] rcuhead_fixup_activate+0x2b/0xbc
>   [<ffffffff81246d6f>] debug_object_fixup+0x1e/0x2b
>   [<ffffffff812473f6>] debug_object_activate+0xcf/0xdc
>   [<ffffffff81118b93>] ? kmem_cache_shrink+0x68/0x68
>   [<ffffffff810b1fc0>] __call_rcu+0x4f/0x19e
>   [<ffffffff810b2124>] call_rcu+0x15/0x17
>   [<ffffffff81117c4a>] slab_destroy+0x11f/0x157
>   [<ffffffff81117dd4>] free_block+0x152/0x18d
>   [<ffffffff81118497>] __cache_free+0x36e/0x3ea
>   [<ffffffff81103b3b>] ? anon_vma_free+0x3d/0x41
>   [<ffffffff811164cc>] ? __local_lock_irq+0x16/0x61
>   [<ffffffff81117aad>] kmem_cache_free+0xa1/0x11f
>   [<ffffffff81103b3b>] anon_vma_free+0x3d/0x41
>   [<ffffffff81104a77>] __put_anon_vma+0x38/0x3d
>   [<ffffffff81104aa5>] put_anon_vma+0x29/0x2d
>   [<ffffffff81104b7e>] unlink_anon_vmas+0x72/0xa5
>   [<ffffffff810faa5b>] free_pgtables+0x6c/0xcb
>   [<ffffffff81100c96>] exit_mmap+0xc0/0xf7
>   [<ffffffff8104de1d>] mmput+0x60/0xd3
>   [<ffffffff81054112>] exit_mm+0x141/0x14e
>   [<ffffffff814a7d75>] ? _raw_spin_unlock_irq+0x54/0x61
>   [<ffffffff8105436a>] do_exit+0x24b/0x74f
>   [<ffffffff811289ae>] ? fput+0x1d4/0x1e3
>   [<ffffffff8107f539>] ? trace_hardirqs_off_caller+0x33/0x90
>   [<ffffffff814a847d>] ? retint_swapgs+0x13/0x1b
>   [<ffffffff81054ae2>] do_group_exit+0x82/0xad
>   [<ffffffff81054b24>] sys_exit_group+0x17/0x1b
>   [<ffffffff814ae182>] system_call_fastpath+0x16/0x1b
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
