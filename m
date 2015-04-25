Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 564566B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 22:16:24 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so64331268pdb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 19:16:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q9si19932199pds.196.2015.04.24.19.16.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 19:16:23 -0700 (PDT)
Message-ID: <553AF8D4.7070703@oracle.com>
Date: Fri, 24 Apr 2015 22:15:48 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
References: <20140624201606.18273.44270.stgit@zurg>	<20140624201614.18273.39034.stgit@zurg>	<54BB9A32.7080703@oracle.com> <CALYGNiPbTpTNme_Cp4AF0cDjRB=rQ2FJ=qRJ+G5cihQMhzsZEw@mail.gmail.com>
In-Reply-To: <CALYGNiPbTpTNme_Cp4AF0cDjRB=rQ2FJ=qRJ+G5cihQMhzsZEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 01/18/2015 01:36 PM, Konstantin Khlebnikov wrote:
> On Sun, Jan 18, 2015 at 2:34 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
>> On 06/24/2014 04:16 PM, Konstantin Khlebnikov wrote:
>>> This patch prints warning (if CONFIG_DEBUG_VM=y) when
>>> memory commitment becomes too negative.
>>>
>>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>>
>> Hi Konstantin,
>>
>> I seem to be hitting this warning when fuzzing on the latest -next kernel:
> 
> That might be unexpected change of shmem file which holds anon-vma data,
> thanks to checkpoint-restore they are expoted via /proc/.../map_files
> 
> I've fixed truncate (https://lkml.org/lkml/2014/6/24/729) but there
> are some other ways
> to change i_size: write, fallocate and maybe something else.

deja vu!

With the latest -next:

[  884.898243] ------------[ cut here ]------------
[  884.899983] ------------[ cut here ]------------
[  884.900013] WARNING: CPU: 5 PID: 17543 at mm/mmap.c:159 __vm_enough_memory+0x3b7/0x440()
[  884.900017] ------------[ cut here ]------------
[  884.900155] memory commitment underflow
[  884.900158] Modules linked in:
[  884.900167] CPU: 5 PID: 17543 Comm: trinity-c102 Not tainted 4.0.0-next-20150424-sasha-00038-ga61bf14 #2171
[  884.900180] WARNING: CPU: 0 PID: 18483 at mm/mmap.c:159 __vm_enough_memory+0x3b7/0x440()
[  884.900185]  ffff88017e180000
[  884.900188] memory commitment underflow
[  884.900190]  0000000012331894
[  884.900193] Modules linked in:
[  884.900195]  ffff8807dd8bf5a8
[  884.900196]
[  884.900200]  ffffffffa9abbf32
[  884.900211]  0000000000000000 ffff8807dd8bf628 ffff8807dd8bf5f8 ffffffff9f1f1c2a
[  884.900222]  ffff8807dd8bf5d8 ffffffff9f5efb27 ffff8807dd8bf628 ffffed00fbb17ec1
[  884.900230] Call Trace:
[  884.900247] dump_stack (lib/dump_stack.c:52)
[  884.900260] warn_slowpath_common (kernel/panic.c:447)
[  884.900270] ? __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  884.900278] warn_slowpath_fmt (kernel/panic.c:453)
[  884.900286] ? warn_slowpath_common (kernel/panic.c:453)
[  884.900300] ? find_get_entry (include/linux/rcupdate.h:969 mm/filemap.c:1003)
[  884.900310] __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  884.900317] ? find_get_entry (mm/filemap.c:967)
[  884.900334] cap_vm_enough_memory (security/commoncap.c:954)
[  884.900344] security_vm_enough_memory_mm (security/security.c:235)
[  884.900355] shmem_getpage_gfp (mm/shmem.c:1156)
[  884.900369] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[  884.900382] ? lockdep_init (include/linux/list.h:28 kernel/locking/lockdep.c:4065)
[  884.900391] ? shmem_add_to_page_cache (mm/shmem.c:1034)
[  884.900402] ? __wake_up_locked_key (kernel/sched/wait.c:456)
[  884.900414] ? __bdi_update_bandwidth (mm/page-writeback.c:1579)
[  884.900422] ? __lock_is_held (kernel/locking/lockdep.c:3572)
[  884.900432] ? iov_iter_single_seg_count (lib/iov_iter.c:310)
[  884.900441] shmem_write_begin (mm/shmem.c:1492)
[  884.900450] generic_perform_write (mm/filemap.c:2467)
[  884.900461] ? generic_write_checks (mm/filemap.c:2427)
[  884.900475] ? file_update_time (fs/inode.c:1746)
[  884.900483] ? file_remove_suid (fs/inode.c:1718)
[  884.900492] ? generic_file_write_iter (include/linux/sched.h:3091 include/linux/sched.h:3102 mm/filemap.c:2269 mm/filemap.c:2622)
[  884.900501] ? mutex_trylock (kernel/locking/mutex.c:615)
[  884.900510] __generic_file_write_iter (mm/filemap.c:2597)
[  884.900521] ? get_parent_ip (kernel/sched/core.c:2556)
[  884.900531] generic_file_write_iter (mm/filemap.c:2625)
[  884.900543] do_iter_readv_writev (fs/read_write.c:665)
[  884.900551] ? do_readv_writev (include/linux/fs.h:2417 fs/read_write.c:804)
[  884.900558] ? do_loop_readv_writev (fs/read_write.c:657)
[  884.900567] ? rw_verify_area (fs/read_write.c:406 (discriminator 4))
[  884.900576] do_readv_writev (fs/read_write.c:808)
[  884.900583] ? __generic_file_write_iter (mm/filemap.c:2616)
[  884.900591] ? vfs_write (fs/read_write.c:777)
[  884.900601] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  884.900609] ? get_lock_stats (kernel/locking/lockdep.c:249)
[  884.900621] ? vtime_account_user (kernel/sched/cputime.c:701)
[  884.900630] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  884.900639] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[  884.900646] ? trace_hardirqs_on (kernel/locking/lockdep.c:2644)
[  884.900654] vfs_writev (fs/read_write.c:848)
[  884.900663] SyS_writev (fs/read_write.c:881 fs/read_write.c:872)
[  884.900671] ? SyS_readv (fs/read_write.c:872)
[  884.900684] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[  884.900693] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[  884.900703] tracesys_phase2 (arch/x86/kernel/entry_64.S:337)
[  884.900716] ? __percpu_counter_sum (lib/percpu_counter.c:107)
[  884.900723] ---[ end trace 957b1b1a507acb40 ]---
[  884.900730] CPU: 0 PID: 18483 Comm: trinity-c39 Not tainted 4.0.0-next-20150424-sasha-00038-ga61bf14 #2171
[  884.900746]  ffff880077ba3000 000000005dbf6d8b ffff88007bd8f5b8 ffffffffa9abbf32
[  884.900759]  0000000000000000 ffff88007bd8f638 ffff88007bd8f608 ffffffff9f1f1c2a
[  884.900771]  ffff88007bd8f618 ffffffff9f5efb27 ffffffff9f2700d0 ffffed000f7b1ec3
[  884.900774] Call Trace:
[  884.900787] dump_stack (lib/dump_stack.c:52)
[  884.900796] warn_slowpath_common (kernel/panic.c:447)
[  884.900807] ? __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  884.900820] ? finish_task_switch (kernel/sched/sched.h:1077 kernel/sched/core.c:2245)
[  884.900830] warn_slowpath_fmt (kernel/panic.c:453)
[  884.900838] ? warn_slowpath_common (kernel/panic.c:453)
[  884.900846] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  884.900863] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[  884.900873] __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  884.900883] ? find_get_entry (mm/filemap.c:967)
[  884.900895] cap_vm_enough_memory (security/commoncap.c:954)
[  884.900905] security_vm_enough_memory_mm (security/security.c:235)
[  884.900912] ? security_vm_enough_memory_mm (security/security.c:234)
[  884.900922] shmem_getpage_gfp (mm/shmem.c:1156)
[  884.900931] ? lockdep_init (include/linux/list.h:28 kernel/locking/lockdep.c:4065)
[  884.900940] ? shmem_add_to_page_cache (mm/shmem.c:1034)
[  884.900950] ? __wake_up_locked_key (kernel/sched/wait.c:456)
[  884.900960] ? __bdi_update_bandwidth (mm/page-writeback.c:1579)
[  884.900968] ? __lock_is_held (kernel/locking/lockdep.c:3572)
[  884.900977] ? iov_iter_single_seg_count (lib/iov_iter.c:310)
[  884.900986] shmem_write_begin (mm/shmem.c:1492)
[  884.900996] generic_perform_write (mm/filemap.c:2467)
[  884.901011] ? generic_write_checks (mm/filemap.c:2427)
[  884.901173] ? file_update_time (fs/inode.c:1746)
[  884.901182] ? file_remove_suid (fs/inode.c:1718)
[  884.901190] ? generic_file_write_iter (include/linux/sched.h:3091 include/linux/sched.h:3102 mm/filemap.c:2269 mm/filemap.c:2622)
[  884.901199] ? mutex_trylock (kernel/locking/mutex.c:615)
[  884.901207] __generic_file_write_iter (mm/filemap.c:2597)
[  884.901217] ? get_parent_ip (kernel/sched/core.c:2556)
[  884.901228] generic_file_write_iter (mm/filemap.c:2625)
[  884.901240] do_iter_readv_writev (fs/read_write.c:665)
[  884.901248] ? do_readv_writev (include/linux/fs.h:2417 fs/read_write.c:804)
[  884.901257] ? do_loop_readv_writev (fs/read_write.c:657)
[  884.901269] ? rw_verify_area (fs/read_write.c:406 (discriminator 4))
[  884.901278] do_readv_writev (fs/read_write.c:808)
[  884.901288] ? __generic_file_write_iter (mm/filemap.c:2616)
[  884.901297] ? vfs_write (fs/read_write.c:777)
[  884.901306] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  884.901314] ? get_lock_stats (kernel/locking/lockdep.c:249)
[  884.901326] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  884.901336] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[  884.901345] ? trace_hardirqs_on (kernel/locking/lockdep.c:2644)
[  884.901355] vfs_writev (fs/read_write.c:848)
[  884.901365] ? __fdget_pos (fs/file.c:717)
[  884.901374] SyS_pwritev (include/linux/file.h:38 fs/read_write.c:937 fs/read_write.c:922)
[  884.901382] ? SyS_preadv (fs/read_write.c:922)
[  884.901393] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[  884.901404] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[  884.901414] tracesys_phase2 (arch/x86/kernel/entry_64.S:337)
[  884.901423] ---[ end trace 957b1b1a507acb41 ]---
[  885.133658] WARNING: CPU: 6 PID: 17218 at mm/mmap.c:159 __vm_enough_memory+0x3b7/0x440()
[  885.136475] memory commitment underflow
[  885.137807] Modules linked in:
[  885.139002] CPU: 6 PID: 17218 Comm: trinity-c296 Tainted: G        W       4.0.0-next-20150424-sasha-00038-ga61bf14 #2171
[  885.142889]  ffff88078e4a8000 0000000057b5e6a5 ffff88078e6275a8 ffffffffa9abbf32
[  885.145640]  0000000000000000 ffff88078e627628 ffff88078e6275f8 ffffffff9f1f1c2a
[  885.148334]  ffff88078e6275d8 ffffffff9f5efb27 ffff88078e627628 ffffed00f1cc4ec1
[  885.150427] Call Trace:
[  885.151080] dump_stack (lib/dump_stack.c:52)
[  885.152771] warn_slowpath_common (kernel/panic.c:447)
[  885.154819] ? __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  885.156674] warn_slowpath_fmt (kernel/panic.c:453)
[  885.158168] ? warn_slowpath_common (kernel/panic.c:453)
[  885.159853] ? find_get_entry (include/linux/rcupdate.h:969 mm/filemap.c:1003)
[  885.161311] __vm_enough_memory (mm/mmap.c:157 (discriminator 3))
[  885.162823] ? find_get_entry (mm/filemap.c:967)
[  885.164599] cap_vm_enough_memory (security/commoncap.c:954)
[  885.166588] security_vm_enough_memory_mm (security/security.c:235)
[  885.168923] shmem_getpage_gfp (mm/shmem.c:1156)
[  885.170990] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[  885.173230] ? lockdep_init (include/linux/list.h:28 kernel/locking/lockdep.c:4065)
[  885.175228] ? shmem_add_to_page_cache (mm/shmem.c:1034)
[  885.177492] ? __wake_up_locked_key (kernel/sched/wait.c:456)
[  885.179648] ? __bdi_update_bandwidth (mm/page-writeback.c:1579)
[  885.181288] ? __lock_is_held (kernel/locking/lockdep.c:3572)
[  885.182750] ? __wake_up_bit (kernel/sched/wait.c:456)
[  885.184418] ? iov_iter_single_seg_count (lib/iov_iter.c:310)
[  885.186728] shmem_write_begin (mm/shmem.c:1492)
[  885.188751] generic_perform_write (mm/filemap.c:2467)
[  885.190906] ? generic_write_checks (mm/filemap.c:2427)
[  885.193252] ? file_update_time (fs/inode.c:1746)
[  885.195344] ? file_remove_suid (fs/inode.c:1718)
[  885.196996] ? generic_file_write_iter (include/linux/sched.h:3091 include/linux/sched.h:3102 mm/filemap.c:2269 mm/filemap.c:2622)
[  885.198672] ? mutex_trylock (kernel/locking/mutex.c:615)
[  885.200440] __generic_file_write_iter (mm/filemap.c:2597)
[  885.202666] ? get_parent_ip (kernel/sched/core.c:2556)
[  885.204647] generic_file_write_iter (mm/filemap.c:2625)
[  885.206875] do_iter_readv_writev (fs/read_write.c:665)
[  885.209242] ? do_readv_writev (include/linux/fs.h:2417 fs/read_write.c:804)
[  885.211306] ? do_loop_readv_writev (fs/read_write.c:657)
[  885.213414] ? rw_verify_area (fs/read_write.c:406 (discriminator 4))
[  885.215263] do_readv_writev (fs/read_write.c:808)
[  885.216855] ? __generic_file_write_iter (mm/filemap.c:2616)
[  885.218482] ? vfs_write (fs/read_write.c:777)
[  885.219931] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  885.222062] ? get_lock_stats (kernel/locking/lockdep.c:249)
[  885.224275] ? vtime_account_user (kernel/sched/cputime.c:701)
[  885.226375] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  885.228472] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[  885.230673] ? trace_hardirqs_on (kernel/locking/lockdep.c:2644)
[  885.232751] vfs_writev (fs/read_write.c:848)
[  885.234490] SyS_writev (fs/read_write.c:881 fs/read_write.c:872)
[  885.236473] ? SyS_readv (fs/read_write.c:872)
[  885.238300] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[  885.240677] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[  885.242909] tracesys_phase2 (arch/x86/kernel/entry_64.S:337)
[  885.246363] ---[ end trace 957b1b1a507acb42 ]---


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
