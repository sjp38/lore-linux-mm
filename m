Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EDCA06B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 10:14:36 -0400 (EDT)
Date: Sun, 14 Jun 2009 10:14:59 -0400
From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] swapper: possible circular locking
	dependency detected
Message-ID: <20090614141459.GA5543@jukie.net>
References: <20090613182721.GA24072@jukie.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090613182721.GA24072@jukie.net>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

yesterday [1] I reported a kswapd hanging in D state when using fscache
for nfs.

[1] http://article.gmane.org/gmane.linux.kernel.mm/35601

Since then I rebuilt the kernel with lockdep and booted to find out that
by default...

        BUG: MAX_LOCK_DEPTH too low!
        turning off the locking correctness validator.

... lockdep wasn't going to help.  I increased the value by 128 (hence
the 'dirty' in the version) and now I am seeing the following report
shortly after boot.

If you scroll down past the locking report, you'll see 'CacheFiles:
Lookup failed'.  This shows up after heavy use (with cat) of my nfs
filesystem with fscache enabled.  Around that time I saw my user space
program report 'Permission denied'.

Let me know if you need more info.

-Bart

---- 8< ----

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.30-kvm3-dirty #4
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&cwq->lock){..-...}, at: [<ffffffff80256c37>] __queue_work+0x1d/0x43

but task is already holding lock:
 (&q->lock){-.-.-.}, at: [<ffffffff80235b6a>] __wake_up+0x27/0x55

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&q->lock){-.-.-.}:
       [<ffffffff8026b7f6>] __lock_acquire+0x1350/0x16b4
       [<ffffffff8026bc21>] lock_acquire+0xc7/0xf3
       [<ffffffff805a22e1>] _spin_lock_irqsave+0x4f/0x86
       [<ffffffff80235b6a>] __wake_up+0x27/0x55
       [<ffffffff8025620b>] insert_work+0x9a/0xa6
       [<ffffffff80256c49>] __queue_work+0x2f/0x43
       [<ffffffff80256cec>] queue_work_on+0x4a/0x53
       [<ffffffff80256e49>] queue_work+0x1f/0x21
       [<ffffffff80255a2c>] call_usermodehelper_exec+0x8e/0xbc
       [<ffffffff803be29d>] kobject_uevent_env+0x3b0/0x3ee
       [<ffffffff803be2e6>] kobject_uevent+0xb/0xd
       [<ffffffff803bd796>] kset_register+0x37/0x3f
       [<ffffffff804402f7>] bus_register+0xf3/0x280
       [<ffffffff80a2b7af>] platform_bus_init+0x2c/0x44
       [<ffffffff80a2b865>] driver_init+0x1d/0x29
       [<ffffffff80a04663>] kernel_init+0x123/0x18c
       [<ffffffff8020ce8a>] child_rip+0xa/0x20
       [<ffffffffffffffff>] 0xffffffffffffffff

-> #0 (&cwq->lock){..-...}:
       [<ffffffffffffffff>] 0xffffffffffffffff

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (&q->lock){-.-.-.}, at: [<ffffffff80235b6a>] __wake_up+0x27/0x55

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.30-kvm3-dirty #4
Call Trace:
 <IRQ>  [<ffffffff80269ffe>] print_circular_bug_tail+0xc1/0xcc
 [<ffffffff8026b52b>] __lock_acquire+0x1085/0x16b4
 [<ffffffff802685b4>] ? save_trace+0x3f/0xa6
 [<ffffffff8026ba78>] ? __lock_acquire+0x15d2/0x16b4
 [<ffffffff8026bc21>] lock_acquire+0xc7/0xf3
 [<ffffffff80256c37>] ? __queue_work+0x1d/0x43
 [<ffffffff805a22e1>] _spin_lock_irqsave+0x4f/0x86
 [<ffffffff80256c37>] ? __queue_work+0x1d/0x43
 [<ffffffff80256c37>] __queue_work+0x1d/0x43
 [<ffffffff80256cec>] queue_work_on+0x4a/0x53
 [<ffffffff80256e49>] queue_work+0x1f/0x21
 [<ffffffff80256e66>] schedule_work+0x1b/0x1d
 [<ffffffffa00e9268>] fscache_enqueue_operation+0xec/0x11e [fscache]
 [<ffffffffa00fd662>] cachefiles_read_waiter+0xee/0x102 [cachefiles]
 [<ffffffff80233a55>] __wake_up_common+0x4b/0x7a
 [<ffffffff80235b80>] __wake_up+0x3d/0x55
 [<ffffffff8025a2f1>] __wake_up_bit+0x31/0x33
 [<ffffffff802a52af>] unlock_page+0x27/0x2b
 [<ffffffff80300b21>] mpage_end_io_read+0x60/0x77
 [<ffffffff802fbb93>] bio_endio+0x2f/0x31
 [<ffffffff804bf170>] raid_end_bio_io+0x3c/0x8c
 [<ffffffff804c0123>] raid1_end_read_request+0xb4/0x13b
 [<ffffffff802124aa>] ? native_sched_clock+0x32/0x60
 [<ffffffff802fbb93>] bio_endio+0x2f/0x31
 [<ffffffff803ac3e2>] req_bio_endio+0xa7/0xc6
 [<ffffffff803ac5b1>] __end_that_request_first+0x1b0/0x2ca
 [<ffffffff803ac4d3>] ? __end_that_request_first+0xd2/0x2ca
 [<ffffffff803ac6f5>] end_that_request_data+0x2a/0x5f
 [<ffffffff803ad29e>] blk_end_io+0x22/0x7c
 [<ffffffff803ad333>] blk_end_request+0x13/0x15
 [<ffffffff8044e36e>] scsi_io_completion+0x1d8/0x458
 [<ffffffff804475bf>] scsi_finish_command+0xf1/0xfa
 [<ffffffff8044e728>] scsi_softirq_done+0x125/0x12e
 [<ffffffff803b1ac5>] blk_done_softirq+0x81/0x91
 [<ffffffff8024a714>] __do_softirq+0xbc/0x198
 [<ffffffff8020cf8c>] call_softirq+0x1c/0x28
 [<ffffffff8020e974>] do_softirq+0x50/0xb1
 [<ffffffff8024a26c>] irq_exit+0x53/0x8d
 [<ffffffff805a2e69>] do_IRQ+0xb1/0xc8
 [<ffffffff8020c793>] ret_from_intr+0x0/0x16
 <EOI>  [<ffffffff8023fcf9>] finish_task_switch+0x40/0x111
 [<ffffffff8025e71b>] ? __atomic_notifier_call_chain+0x0/0x87
 [<ffffffff802259c5>] ? native_safe_halt+0xb/0xd
 [<ffffffff802697d1>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff8021345b>] default_idle+0x71/0xc2
 [<ffffffff8025e793>] ? __atomic_notifier_call_chain+0x78/0x87
 [<ffffffff8025e71b>] ? __atomic_notifier_call_chain+0x0/0x87
 [<ffffffff802136e0>] c1e_idle+0x11e/0x125
 [<ffffffff8025e7b1>] ? atomic_notifier_call_chain+0xf/0x11
 [<ffffffff8020af32>] cpu_idle+0x62/0xa3
 [<ffffffff8059ac0c>] start_secondary+0x1c1/0x1c5

---- 8< ----

CacheFiles: Lookup failed error -105
CacheFiles: Lookup failed error -105

INFO: task cat:8884 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
cat           D ffff880028012d00     0  8884   8832
 ffff880436243998 0000000000000046 0000000000000000 ffff880028012d18
 ffff880028012d00 00000000001d3000 000000000000d4e0 ffff880436378000
 ffff88043f0d8000 ffff880436378598 0000000700000046 ffffc20000ead018
Call Trace:
 [<ffffffff802697d1>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff8059f527>] schedule+0xe/0x22
 [<ffffffffa00e8136>] fscache_wait_bit+0xe/0x12 [fscache]
 [<ffffffff8059fbd0>] __wait_on_bit+0x4c/0x7e
 [<ffffffffa00e8128>] ? fscache_wait_bit+0x0/0x12 [fscache]
 [<ffffffffa00e8128>] ? fscache_wait_bit+0x0/0x12 [fscache]
 [<ffffffff8059fc71>] out_of_line_wait_on_bit+0x6f/0x7c
 [<ffffffff8025a358>] ? wake_bit_function+0x0/0x2f
 [<ffffffffa00eaaaa>] __fscache_read_or_alloc_pages+0x1a4/0x252 [fscache]
 [<ffffffffa01d66ca>] ? nfs_readpage_from_fscache_complete+0x0/0x6b [nfs]
 [<ffffffffa01d65dd>] __nfs_readpages_from_fscache+0x87/0x174 [nfs]
 [<ffffffffa01bc58e>] nfs_readpages+0x11f/0x1d4 [nfs]
 [<ffffffff802807d8>] ? cpuset_update_task_memory_state+0x6a/0x11e
 [<ffffffff8028076e>] ? cpuset_update_task_memory_state+0x0/0x11e
 [<ffffffff802cc566>] ? alloc_pages_current+0xbe/0xc7
 [<ffffffff802ad8d4>] __do_page_cache_readahead+0x164/0x1f1
 [<ffffffff802ad7f0>] ? __do_page_cache_readahead+0x80/0x1f1
 [<ffffffff8026bc6b>] ? print_lock_contention_bug+0x1e/0x110
 [<ffffffff802adc2d>] ondemand_readahead+0x1d4/0x1e9
 [<ffffffff802adce7>] page_cache_sync_readahead+0x1c/0x1e
 [<ffffffff802a6833>] generic_file_aio_read+0x23a/0x5d4
 [<ffffffffa01d36f9>] ? nfs_have_delegation+0x0/0x8a [nfs]
 [<ffffffffa01b2909>] nfs_file_read+0xeb/0xfe [nfs]
 [<ffffffff802d7f36>] do_sync_read+0xec/0x132
 [<ffffffff802dbb53>] ? cp_new_stat+0xe7/0xf4
 [<ffffffff8025a31b>] ? autoremove_wake_function+0x0/0x3d
 [<ffffffff8039ba1c>] ? security_file_permission+0x16/0x18
 [<ffffffff802d8b2e>] vfs_read+0xb0/0x159
 [<ffffffff802d8ca5>] sys_read+0x4c/0x74
 [<ffffffff8020bd72>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.

INFO: task top:10437 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
top           D ffff88024d238680     0 10437   5425
 ffff880085d53998 0000000000000046 0000000000000000 ffff88024d238698
 ffff88024d238680 00000000001d3000 000000000000d4e0 ffff8803fa5b0000
 ffff88043f0d8000 ffff8803fa5b0598 0000000700000046 ffffc20000ead018
Call Trace:
 [<ffffffff802697d1>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff8059f527>] schedule+0xe/0x22
 [<ffffffffa00e8136>] fscache_wait_bit+0xe/0x12 [fscache]
 [<ffffffff8059fbd0>] __wait_on_bit+0x4c/0x7e
 [<ffffffffa00e8128>] ? fscache_wait_bit+0x0/0x12 [fscache]
 [<ffffffffa00e8128>] ? fscache_wait_bit+0x0/0x12 [fscache]
 [<ffffffff8059fc71>] out_of_line_wait_on_bit+0x6f/0x7c
 [<ffffffff8025a358>] ? wake_bit_function+0x0/0x2f
 [<ffffffffa00eaaaa>] __fscache_read_or_alloc_pages+0x1a4/0x252 [fscache]
 [<ffffffffa01d66ca>] ? nfs_readpage_from_fscache_complete+0x0/0x6b [nfs]
 [<ffffffffa01d65dd>] __nfs_readpages_from_fscache+0x87/0x174 [nfs]
 [<ffffffffa01bc58e>] nfs_readpages+0x11f/0x1d4 [nfs]
 [<ffffffff802807d8>] ? cpuset_update_task_memory_state+0x6a/0x11e
 [<ffffffff8028076e>] ? cpuset_update_task_memory_state+0x0/0x11e
 [<ffffffff802cc566>] ? alloc_pages_current+0xbe/0xc7
 [<ffffffff802ad8d4>] __do_page_cache_readahead+0x164/0x1f1
 [<ffffffff802ad7f0>] ? __do_page_cache_readahead+0x80/0x1f1
 [<ffffffff802adc2d>] ondemand_readahead+0x1d4/0x1e9
 [<ffffffff802adce7>] page_cache_sync_readahead+0x1c/0x1e
 [<ffffffff802a6833>] generic_file_aio_read+0x23a/0x5d4
 [<ffffffffa01d36f9>] ? nfs_have_delegation+0x0/0x8a [nfs]
 [<ffffffffa01b2909>] nfs_file_read+0xeb/0xfe [nfs]
 [<ffffffff802d7f36>] do_sync_read+0xec/0x132
 [<ffffffff802d69bf>] ? nameidata_to_filp+0x46/0x57
 [<ffffffff8025a31b>] ? autoremove_wake_function+0x0/0x3d
 [<ffffffff802d63b7>] ? fd_install+0x35/0x64
 [<ffffffff8039ba1c>] ? security_file_permission+0x16/0x18
 [<ffffffff802d8b2e>] vfs_read+0xb0/0x159
 [<ffffffff802d8ca5>] sys_read+0x4c/0x74
 [<ffffffff8020bd72>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.


-- 
				WebSig: http://www.jukie.net/~bart/sig/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
