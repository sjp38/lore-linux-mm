Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAB56B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 10:54:02 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id e131so625065oig.11
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 07:54:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ov6si4508615oeb.64.2014.08.28.07.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 07:54:01 -0700 (PDT)
Message-ID: <53FF4280.1040402@oracle.com>
Date: Thu, 28 Aug 2014 10:53:52 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: slub: circular dependency between slab_mutex and cpu_hotplug
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@gentwo.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "davej >> Dave Jones" <davej@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 7841.260266] ======================================================
[ 7841.261467] [ INFO: possible circular locking dependency detected ]
[ 7841.264485] 3.17.0-rc2-next-20140827-sasha-00031-g9ff673f-dirty #1081 Not tainted
[ 7841.264893] -------------------------------------------------------
[ 7841.264893] trinity-c936/25602 is trying to acquire lock:
[ 7841.264893] (slab_mutex){+.+.+.}, at: slab_cpuup_callback (mm/slub.c:3767)
[ 7841.264893]
[ 7841.264893] but task is already holding lock:
[ 7841.264893] (cpu_hotplug.lock#2){+.+.+.}, at: cpu_hotplug_begin (kernel/cpu.c:144)
[ 7841.280309]
[ 7841.280309] which lock already depends on the new lock.
[ 7841.280309]
[ 7841.280309]
[ 7841.280309] the existing dependency chain (in reverse order) is:
[ 7841.280309]
-> #4 (cpu_hotplug.lock#2){+.+.+.}:
[ 7841.280309] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.280309] down_read (./arch/x86/include/asm/rwsem.h:83 kernel/locking/rwsem.c:44)
[ 7841.280309] __blocking_notifier_call_chain (kernel/notifier.c:317)
[ 7841.280309] blocking_notifier_call_chain (kernel/notifier.c:329)
[ 7841.294971] out_of_memory (mm/oom_kill.c:626)
[ 7841.294971] __alloc_pages_slowpath (mm/page_alloc.c:2288 mm/page_alloc.c:2715)
[ 7841.294971] __alloc_pages_nodemask (mm/page_alloc.c:2835)
[ 7841.294971] alloc_pages_current (mm/mempolicy.c:2098)
[ 7841.294971] default_file_splice_read (fs/splice.c:643)
[ 7841.294971] do_splice_to (fs/splice.c:1154)
[ 7841.294971] splice_direct_to_actor (fs/splice.c:1226)
[ 7841.294971] do_splice_direct (fs/splice.c:1328)
[ 7841.294971] do_sendfile (fs/read_write.c:1365 fs/read_write.c:1265)
[ 7841.294971] SyS_sendfile64 (fs/read_write.c:1325 fs/read_write.c:1311)
[ 7841.294971] tracesys (arch/x86/kernel/entry_64.S:542)
[ 7841.294971]
-> #3 ((oom_notify_list).rwsem){.+.+..}:
[ 7841.294971] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.294971] down_read (./arch/x86/include/asm/rwsem.h:83 kernel/locking/rwsem.c:44)
[ 7841.294971] __blocking_notifier_call_chain (kernel/notifier.c:317)
[ 7841.323177] blocking_notifier_call_chain (kernel/notifier.c:329)
[ 7841.323177] out_of_memory (mm/oom_kill.c:626)
[ 7841.323177] __alloc_pages_slowpath (mm/page_alloc.c:2288 mm/page_alloc.c:2715)
[ 7841.323177] __alloc_pages_nodemask (mm/page_alloc.c:2835)
[ 7841.323177] alloc_pages_current (mm/mempolicy.c:2098)
[ 7841.323177] new_slab (include/linux/gfp.h:336 mm/slub.c:1301 mm/slub.c:1338 mm/slub.c:1392)
[ 7841.323177] __slab_alloc (mm/slub.c:2181 mm/slub.c:2339)
[ 7841.323177] kmem_cache_alloc_trace (mm/slub.c:2412 mm/slub.c:2454 mm/slub.c:2471)
[ 7841.323177] kernfs_iattrs.isra.1 (fs/kernfs/inode.c:61)
[ 7841.323177] kernfs_iop_getxattr (fs/kernfs/inode.c:230)
[ 7841.323177] cap_inode_need_killpriv (security/commoncap.c:310)
[ 7841.323177] security_inode_need_killpriv (security/security.c:652)
[ 7841.323177] notify_change (fs/attr.c:223)
[ 7841.323177] chown_common (fs/open.c:581)
[ 7841.323177] SyS_lchown (fs/open.c:612 fs/open.c:592 fs/open.c:630 fs/open.c:628)
[ 7841.323177] tracesys (arch/x86/kernel/entry_64.S:542)
[ 7841.323177]
-> #2 (iattr_mutex){+.+.+.}:
[ 7841.323177] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.323177] mutex_lock_nested (kernel/locking/mutex.c:511 kernel/locking/mutex.c:616)
[ 7841.323177] kernfs_iattrs.isra.1 (fs/kernfs/inode.c:57)
[ 7841.323177] __kernfs_setattr (fs/kernfs/inode.c:85)
[ 7841.323177] kernfs_iop_setattr (fs/kernfs/inode.c:139)
[ 7841.323177] notify_change (fs/attr.c:266)
[ 7841.323177] do_truncate (fs/open.c:62)
[ 7841.323177] do_last (fs/namei.c:2595 fs/namei.c:3072)
[ 7841.323177] path_openat (fs/namei.c:3200)
[ 7841.323177] do_filp_open (fs/namei.c:3249)
[ 7841.323177] do_sys_open (fs/open.c:980)
[ 7841.323177] SyS_open (fs/open.c:992)
[ 7841.323177] tracesys (arch/x86/kernel/entry_64.S:542)
[ 7841.323177]
-> #1 (kernfs_mutex){+.+.+.}:
[ 7841.323177] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.323177] mutex_lock_nested (kernel/locking/mutex.c:511 kernel/locking/mutex.c:616)
[ 7841.323177] kernfs_add_one (fs/kernfs/dir.c:578)
[ 7841.323177] kernfs_create_dir_ns (fs/kernfs/dir.c:770)
[ 7841.323177] sysfs_create_dir_ns (fs/sysfs/dir.c:57)
[ 7841.323177] kobject_add_internal (lib/kobject.c:72 lib/kobject.c:229)
[ 7841.323177] kset_register (lib/kobject.c:797)
[ 7841.323177] kset_create_and_add (lib/kobject.c:924)
[ 7841.323177] slab_sysfs_init (mm/slub.c:5252)
[ 7841.323177] do_one_initcall (init/main.c:793)
[ 7841.323177] kernel_init_freeable (init/main.c:858 init/main.c:867 init/main.c:886 init/main.c:1007)
[ 7841.323177] kernel_init (init/main.c:939)
[ 7841.323177] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[ 7841.323177]
-> #0 (slab_mutex){+.+.+.}:
[ 7841.323177] __lock_acquire (kernel/locking/lockdep.c:1842 kernel/locking/lockdep.c:1947 kernel/locking/lockdep.c:2133 kernel/locking/lockdep.c:3184)
[ 7841.323177] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.323177] mutex_lock_nested (kernel/locking/mutex.c:511 kernel/locking/mutex.c:616)
[ 7841.323177] slab_cpuup_callback (mm/slub.c:3767)
[ 7841.323177] notifier_call_chain (kernel/notifier.c:95)
[ 7841.323177] __raw_notifier_call_chain (kernel/notifier.c:395)
[ 7841.323177] __cpu_notify (kernel/cpu.c:202)
[ 7841.323177] cpu_notify (kernel/cpu.c:211)
[ 7841.323177] cpu_notify_nofail (kernel/cpu.c:217)
[ 7841.323177] _cpu_down (kernel/cpu.c:281 kernel/cpu.c:397)
[ 7841.323177] cpu_down (kernel/cpu.c:417)
[ 7841.323177] cpu_subsys_offline (drivers/base/cpu.c:69)
[ 7841.323177] device_offline (drivers/base/core.c:1429)
[ 7841.323177] online_store (drivers/base/core.c:451 (discriminator 2))
[ 7841.323177] dev_attr_store (drivers/base/core.c:138)
[ 7841.323177] sysfs_kf_write (fs/sysfs/file.c:115)
[ 7841.323177] kernfs_fop_write (fs/kernfs/file.c:308)
[ 7841.323177] vfs_write (fs/read_write.c:532)
[ 7841.323177] SyS_write (fs/read_write.c:584 fs/read_write.c:576)
[ 7841.323177] tracesys (arch/x86/kernel/entry_64.S:542)
[ 7841.323177]
[ 7841.323177] other info that might help us debug this:
[ 7841.323177]
[ 7841.323177] Chain exists of:
slab_mutex --> (oom_notify_list).rwsem --> cpu_hotplug.lock#2

[ 7841.323177]  Possible unsafe locking scenario:
[ 7841.323177]
[ 7841.323177]        CPU0                    CPU1
[ 7841.323177]        ----                    ----
[ 7841.323177]   lock(cpu_hotplug.lock#2);
[ 7841.323177]                                lock((oom_notify_list).rwsem);
[ 7841.323177]                                lock(cpu_hotplug.lock#2);
[ 7841.323177]   lock(slab_mutex);
[ 7841.323177]
[ 7841.323177]  *** DEADLOCK ***
[ 7841.323177]
[ 7841.323177] 9 locks held by trinity-c936/25602:
[ 7841.323177] #0: (&f->f_pos_lock){+.+.+.}, at: __fdget_pos (fs/file.c:714)
[ 7841.323177] #1: (sb_writers#5){.+.+.+}, at: vfs_write (include/linux/fs.h:2272 fs/read_write.c:530)
[ 7841.323177] #2: (&of->mutex){+.+.+.}, at: kernfs_fop_write (fs/kernfs/file.c:296)
[ 7841.323177] #3: (s_active#23){.+.+.+}, at: kernfs_fop_write (fs/kernfs/file.c:296)
[ 7841.323177] #4: (device_hotplug_lock){+.+.+.}, at: lock_device_hotplug_sysfs (drivers/base/core.c:67)
[ 7841.323177] #5: (&dev->mutex){......}, at: device_offline (drivers/base/core.c:2128 drivers/base/core.c:1423)
[ 7841.323177] #6: (cpu_add_remove_lock){+.+.+.}, at: cpu_maps_update_begin (kernel/cpu.c:41)
[ 7841.323177] #7: (cpu_hotplug.lock){++++++}, at: cpu_hotplug_begin (kernel/cpu.c:138)
[ 7841.323177] #8: (cpu_hotplug.lock#2){+.+.+.}, at: cpu_hotplug_begin (kernel/cpu.c:144)
[ 7841.323177]
[ 7841.323177] stack backtrace:
[ 7841.323177] CPU: 6 PID: 25602 Comm: trinity-c936 Not tainted 3.17.0-rc2-next-20140827-sasha-00031-g9ff673f-dirty #1081
[ 7841.323177]  ffffffff99a3f440 ffff880063c9fa48 ffffffff964bd6a6 0000000000000002
[ 7841.323177]  ffffffff99955500 ffff880063c9fa98 ffffffff964b15a3 0000000000000009
[ 7841.323177]  ffff880063c9fb28 ffff880063c9fa98 ffff880762493ea8 ffff880762493000
[ 7841.323177] Call Trace:
[ 7841.323177] dump_stack (lib/dump_stack.c:52)
[ 7841.323177] print_circular_bug (kernel/locking/lockdep.c:1218)
[ 7841.323177] __lock_acquire (kernel/locking/lockdep.c:1842 kernel/locking/lockdep.c:1947 kernel/locking/lockdep.c:2133 kernel/locking/lockdep.c:3184)
[ 7841.323177] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 7841.323177] ? trace_hardirqs_on (kernel/locking/lockdep.c:2609)
[ 7841.323177] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3610)
[ 7841.323177] ? slab_cpuup_callback (mm/slub.c:3767)
[ 7841.323177] mutex_lock_nested (kernel/locking/mutex.c:511 kernel/locking/mutex.c:616)
[ 7841.323177] ? slab_cpuup_callback (mm/slub.c:3767)
[ 7841.323177] ? slab_cpuup_callback (mm/slub.c:3767)
[ 7841.323177] ? __lock_is_held (kernel/locking/lockdep.c:3518)
[ 7841.323177] slab_cpuup_callback (mm/slub.c:3767)
[ 7841.323177] notifier_call_chain (kernel/notifier.c:95)
[ 7841.323177] __raw_notifier_call_chain (kernel/notifier.c:395)
[ 7841.323177] __cpu_notify (kernel/cpu.c:202)
[ 7841.323177] cpu_notify (kernel/cpu.c:211)
[ 7841.323177] cpu_notify_nofail (kernel/cpu.c:217)
[ 7841.323177] _cpu_down (kernel/cpu.c:281 kernel/cpu.c:397)
[ 7841.323177] ? klist_next (lib/klist.c:361)
[ 7841.323177] cpu_down (kernel/cpu.c:417)
[ 7841.323177] cpu_subsys_offline (drivers/base/cpu.c:69)
[ 7841.323177] device_offline (drivers/base/core.c:1429)
[ 7841.323177] online_store (drivers/base/core.c:451 (discriminator 2))
[ 7841.323177] dev_attr_store (drivers/base/core.c:138)
[ 7841.323177] sysfs_kf_write (fs/sysfs/file.c:115)
[ 7841.323177] kernfs_fop_write (fs/kernfs/file.c:308)
[ 7841.323177] vfs_write (fs/read_write.c:532)
[ 7841.323177] SyS_write (fs/read_write.c:584 fs/read_write.c:576)
[ 7841.323177] tracesys (arch/x86/kernel/entry_64.S:542)


Thanks,
Sashape

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
