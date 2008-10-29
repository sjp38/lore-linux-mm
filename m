Date: Wed, 29 Oct 2008 13:58:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.28-rc2-mm1: possible circular locking
Message-Id: <20081029135840.0a50e19c.akpm@linux-foundation.org>
In-Reply-To: <200810292146.03967.m.kozlowski@tuxland.pl>
References: <20081028233836.8b1ff9ae.akpm@linux-foundation.org>
	<200810292146.03967.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 21:46:03 +0100
Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:

> Hello,
> 
> 	Happens on every startup when psi starts as well.

Thanks.

> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.28-rc2-mm1 #1
> -------------------------------------------------------
> psi/4733 is trying to acquire lock:
>  (events){--..}, at: [<c012a330>] flush_work+0x2d/0xcb
> 
> but task is already holding lock:
>  (&mm->mmap_sem){----}, at: [<c0158588>] sys_mlock+0x2c/0xb6
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #4 (&mm->mmap_sem){----}:
>        [<c013ac05>] validate_chain+0xacb/0xfe0
>        [<c013b388>] __lock_acquire+0x26e/0x98d
>        [<c013bb03>] lock_acquire+0x5c/0x74
>        [<c015728a>] might_fault+0x74/0x90
>        [<c01e5cf8>] copy_to_user+0x28/0x40
>        [<c01768aa>] filldir64+0xaa/0xcd
>        [<c01a46d9>] sysfs_readdir+0x118/0x1dd
>        [<c01769fb>] vfs_readdir+0x70/0x85
>        [<c0176a70>] sys_getdents64+0x60/0xa8
>        [<c0102f91>] sysenter_do_call+0x12/0x35
>        [<ffffffff>] 0xffffffff
> 
> -> #3 (sysfs_mutex){--..}:
>        [<c013ac05>] validate_chain+0xacb/0xfe0
>        [<c013b388>] __lock_acquire+0x26e/0x98d
>        [<c013bb03>] lock_acquire+0x5c/0x74
>        [<c02bc360>] mutex_lock_nested+0x8d/0x297
>        [<c01a495a>] sysfs_addrm_start+0x26/0x9e
>        [<c01a4e25>] create_dir+0x3a/0x83
>        [<c01a4e99>] sysfs_create_dir+0x2b/0x43
>        [<c01e09a0>] kobject_add_internal+0xb4/0x186
>        [<c01e0b2f>] kobject_add_varg+0x41/0x4d
>        [<c01e0dbc>] kobject_add+0x2f/0x57
>        [<c023d074>] device_add+0xa4/0x58f
>        [<c0276a53>] netdev_register_kobject+0x65/0x6a
>        [<c026bed0>] register_netdevice+0x209/0x2fb
>        [<c026bff4>] register_netdev+0x32/0x3f
>        [<c03c4344>] loopback_net_init+0x33/0x6f
>        [<c02690ff>] register_pernet_operations+0x13/0x15
>        [<c026916a>] register_pernet_device+0x1f/0x4c
>        [<c03c430f>] loopback_init+0xd/0xf
>        [<c0101027>] _stext+0x27/0x147
>        [<c03ac7af>] kernel_init+0x7d/0xd6
>        [<c0103cc3>] kernel_thread_helper+0x7/0x14
>        [<ffffffff>] 0xffffffff
> 
> -> #2 (rtnl_mutex){--..}:
>        [<c013ac05>] validate_chain+0xacb/0xfe0
>        [<c013b388>] __lock_acquire+0x26e/0x98d
>        [<c013bb03>] lock_acquire+0x5c/0x74
>        [<c02bc360>] mutex_lock_nested+0x8d/0x297
>        [<c02746d3>] rtnl_lock+0xf/0x11
>        [<c0275ab3>] linkwatch_event+0x8/0x27
>        [<c0129d40>] run_workqueue+0x15c/0x1e3
>        [<c012a70e>] worker_thread+0x71/0xa4
>        [<c012cc62>] kthread+0x37/0x59
>        [<c0103cc3>] kernel_thread_helper+0x7/0x14
>        [<ffffffff>] 0xffffffff
> 
> -> #1 ((linkwatch_work).work){--..}:
>        [<c013ac05>] validate_chain+0xacb/0xfe0
>        [<c013b388>] __lock_acquire+0x26e/0x98d
>        [<c013bb03>] lock_acquire+0x5c/0x74
>        [<c0129d3b>] run_workqueue+0x157/0x1e3
>        [<c012a70e>] worker_thread+0x71/0xa4
>        [<c012cc62>] kthread+0x37/0x59
>        [<c0103cc3>] kernel_thread_helper+0x7/0x14
>        [<ffffffff>] 0xffffffff
> 
> -> #0 (events){--..}:
>        [<c013a6e4>] validate_chain+0x5aa/0xfe0
>        [<c013b388>] __lock_acquire+0x26e/0x98d
>        [<c013bb03>] lock_acquire+0x5c/0x74
>        [<c012a35c>] flush_work+0x59/0xcb
>        [<c012a7a6>] schedule_on_each_cpu+0x65/0x7f
>        [<c014fb7e>] lru_add_drain_all+0xd/0xf
>        [<c0157fb2>] __mlock_vma_pages_range+0x44/0x206
>        [<c01582d1>] mlock_fixup+0x15d/0x1c9
>        [<c0158479>] do_mlock+0x96/0xc8
>        [<c015860e>] sys_mlock+0xb2/0xb6
>        [<c0102f91>] sysenter_do_call+0x12/0x35
>        [<ffffffff>] 0xffffffff
> 
> other info that might help us debug this:
> 
> 1 lock held by psi/4733:
>  #0:  (&mm->mmap_sem){----}, at: [<c0158588>] sys_mlock+0x2c/0xb6
> 
> stack backtrace:
> Pid: 4733, comm: psi Not tainted 2.6.28-rc2-mm1 #1
> Call Trace:
>  [<c013a0fd>] print_circular_bug_tail+0x78/0xb5
>  [<c0137a31>] ? print_circular_bug_entry+0x43/0x4b
>  [<c013a6e4>] validate_chain+0x5aa/0xfe0
>  [<c0118465>] ? hrtick_update+0x23/0x25
>  [<c013b388>] __lock_acquire+0x26e/0x98d
>  [<c0118ac0>] ? default_wake_function+0xb/0xd
>  [<c013bb03>] lock_acquire+0x5c/0x74
>  [<c012a330>] ? flush_work+0x2d/0xcb
>  [<c012a35c>] flush_work+0x59/0xcb
>  [<c012a330>] ? flush_work+0x2d/0xcb
>  [<c0139ae6>] ? trace_hardirqs_on+0xb/0xd
>  [<c012a531>] ? __queue_work+0x26/0x2b
>  [<c012a58c>] ? queue_work_on+0x37/0x47
>  [<c014fda7>] ? lru_add_drain_per_cpu+0x0/0xa
>  [<c014fda7>] ? lru_add_drain_per_cpu+0x0/0xa
>  [<c012a7a6>] schedule_on_each_cpu+0x65/0x7f
>  [<c014fb7e>] lru_add_drain_all+0xd/0xf
>  [<c0157fb2>] __mlock_vma_pages_range+0x44/0x206
>  [<c0159438>] ? vma_adjust+0x17e/0x384
>  [<c015971f>] ? split_vma+0xe1/0xf7
>  [<c01582d1>] mlock_fixup+0x15d/0x1c9
>  [<c0158479>] do_mlock+0x96/0xc8
>  [<c02bcb2a>] ? down_write+0x42/0x68
>  [<c015860e>] sys_mlock+0xb2/0xb6
>  [<c0102f91>] sysenter_do_call+0x12/0x35
> 

This is similar to the problem which
mm-move-migrate_prep-out-from-under-mmap_sem.patch was supposed to fix.

We've been calling schedule_on_each_cpu() from within
lru_add_drain_all() for ages.  What changed to cause all this
to start happening?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
