Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0346B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:18:52 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so10940076pdb.21
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:18:52 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id gh5si28470577pbc.245.2014.07.01.17.18.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 17:18:51 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so10897215pdb.7
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:18:50 -0700 (PDT)
Date: Tue, 1 Jul 2014 17:17:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shmem: hang in shmem_fault (WAS: mm: shm: hang in
 shmem_fallocate)
In-Reply-To: <53B3381B.8000601@oracle.com>
Message-ID: <alpine.LSU.2.11.1407011705030.14301@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz>
 <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53AC383F.3010007@oracle.com> <alpine.LSU.2.11.1406262236370.27670@eggly.anvils> <53AD84CE.20806@oracle.com> <alpine.LSU.2.11.1406271043270.28744@eggly.anvils> <53B3381B.8000601@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 1 Jul 2014, Sasha Levin wrote:

> Hi Hugh,
> 
> I've been observing a very nonspecific hang involving some mutexes from fs/ but
> without any lockdep output or a concrete way to track it down.
> 
> It seems that today was my lucky day, and after enough tinkering I've managed
> to get output out of lockdep, which pointed me to shmem:
> 
> [ 1871.989131] =============================================
> [ 1871.990028] [ INFO: possible recursive locking detected ]
> [ 1871.992591] 3.16.0-rc3-next-20140630-sasha-00023-g44434d4-dirty #758 Tainted: G        W
> [ 1871.992591] ---------------------------------------------
> [ 1871.992591] trinity-c84/27757 is trying to acquire lock:
> [ 1871.992591] (&sb->s_type->i_mutex_key#17){+.+.+.}, at: shmem_fault (mm/shmem.c:1289)
> [ 1871.992591]
> [ 1871.992591] but task is already holding lock:
> [ 1871.992591] (&sb->s_type->i_mutex_key#17){+.+.+.}, at: generic_file_write_iter (mm/filemap.c:2633)
> [ 1871.992591]
> [ 1871.992591] other info that might help us debug this:
> [ 1871.992591]  Possible unsafe locking scenario:
> [ 1871.992591]
> [ 1871.992591]        CPU0
> [ 1871.992591]        ----
> [ 1871.992591]   lock(&sb->s_type->i_mutex_key#17);
> [ 1871.992591]   lock(&sb->s_type->i_mutex_key#17);
> [ 1872.013889]
> [ 1872.013889]  *** DEADLOCK ***
> [ 1872.013889]
> [ 1872.013889]  May be due to missing lock nesting notation
> [ 1872.013889]
> [ 1872.013889] 3 locks held by trinity-c84/27757:
> [ 1872.013889] #0: (&f->f_pos_lock){+.+.+.}, at: __fdget_pos (fs/file.c:714)
> [ 1872.030221] #1: (sb_writers#13){.+.+.+}, at: do_readv_writev (include/linux/fs.h:2264 fs/read_write.c:830)
> [ 1872.030221] #2: (&sb->s_type->i_mutex_key#17){+.+.+.}, at: generic_file_write_iter (mm/filemap.c:2633)
> [ 1872.030221]
> [ 1872.030221] stack backtrace:
> [ 1872.030221] CPU: 6 PID: 27757 Comm: trinity-c84 Tainted: G        W      3.16.0-rc3-next-20140630-sasha-00023-g44434d4-dirty #758
> [ 1872.030221]  ffffffff9fc112b0 ffff8803c844f5d8 ffffffff9c531022 0000000000000002
> [ 1872.030221]  ffffffff9fc112b0 ffff8803c844f6d8 ffffffff991d1a8d ffff8803c5da3000
> [ 1872.030221]  ffff8803c5da3d70 ffff880300000001 ffff8803c5da3000 ffff8803c5da3da8
> [ 1872.030221] Call Trace:
> [ 1872.030221] dump_stack (lib/dump_stack.c:52)
> [ 1872.030221] __lock_acquire (kernel/locking/lockdep.c:3034 kernel/locking/lockdep.c:3180)
> [ 1872.030221] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [ 1872.030221] ? shmem_fault (mm/shmem.c:1289)
> [ 1872.030221] mutex_lock_nested (kernel/locking/mutex.c:486 kernel/locking/mutex.c:587)
> [ 1872.030221] ? shmem_fault (mm/shmem.c:1289)
> [ 1872.030221] ? shmem_fault (mm/shmem.c:1288)
> [ 1872.030221] ? shmem_fault (mm/shmem.c:1289)
> [ 1872.030221] shmem_fault (mm/shmem.c:1289)
> [ 1872.030221] __do_fault (mm/memory.c:2705)
> [ 1872.030221] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> [ 1872.030221] do_read_fault.isra.40 (mm/memory.c:2896)
> [ 1872.030221] ? get_parent_ip (kernel/sched/core.c:2550)
> [ 1872.030221] __handle_mm_fault (mm/memory.c:3037 mm/memory.c:3198 mm/memory.c:3322)
> [ 1872.030221] handle_mm_fault (mm/memory.c:3345)
> [ 1872.030221] __do_page_fault (arch/x86/mm/fault.c:1230)
> [ 1872.030221] ? retint_restore_args (arch/x86/kernel/entry_64.S:829)
> [ 1872.030221] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 1872.030221] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
> [ 1872.030221] ? context_tracking_user_exit (kernel/context_tracking.c:184)
> [ 1872.030221] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 1872.030221] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
> [ 1872.030221] trace_do_page_fault (arch/x86/mm/fault.c:1313 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1314)
> [ 1872.030221] do_async_page_fault (arch/x86/kernel/kvm.c:264)
> [ 1872.030221] async_page_fault (arch/x86/kernel/entry_64.S:1322)
> [ 1872.030221] ? iov_iter_fault_in_readable (include/linux/pagemap.h:598 mm/iov_iter.c:267)
> [ 1872.030221] generic_perform_write (mm/filemap.c:2461)
> [ 1872.030221] ? __mnt_drop_write (./arch/x86/include/asm/preempt.h:98 fs/namespace.c:455)
> [ 1872.030221] __generic_file_write_iter (mm/filemap.c:2608)
> [ 1872.030221] ? generic_file_llseek (fs/read_write.c:467)
> [ 1872.030221] generic_file_write_iter (mm/filemap.c:2634)
> [ 1872.030221] do_iter_readv_writev (fs/read_write.c:666)
> [ 1872.030221] do_readv_writev (fs/read_write.c:834)
> [ 1872.030221] ? __generic_file_write_iter (mm/filemap.c:2627)
> [ 1872.030221] ? __generic_file_write_iter (mm/filemap.c:2627)
> [ 1872.030221] ? mutex_lock_nested (./arch/x86/include/asm/preempt.h:98 kernel/locking/mutex.c:570 kernel/locking/mutex.c:587)
> [ 1872.030221] ? __fdget_pos (fs/file.c:714)
> [ 1872.030221] ? __fdget_pos (fs/file.c:714)
> [ 1872.030221] ? __fget_light (include/linux/rcupdate.h:402 include/linux/fdtable.h:80 fs/file.c:684)
> [ 1872.101905] vfs_writev (fs/read_write.c:879)
> [ 1872.101905] SyS_writev (fs/read_write.c:912 fs/read_write.c:904)
> [ 1872.101905] tracesys (arch/x86/kernel/entry_64.S:542)
> 
> It seems like it was introduced by your fix to the shmem_fallocate hang, and is
> triggered in shmem_fault():
> 
> +               if (shmem_falloc) {
> +                       if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
> +                          !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
> +                               up_read(&vma->vm_mm->mmap_sem);
> +                               mutex_lock(&inode->i_mutex);		<=== HERE
> +                               mutex_unlock(&inode->i_mutex);
> +                               return VM_FAULT_RETRY;
> +                       }
> +                       /* cond_resched? Leave that to GUP or return to user */
> +                       return VM_FAULT_NOPAGE;

That is very very helpful: many thanks, Sasha.

Yes, of course, it's a standard pattern, that the write syscall from
userspace has to fault in a page of the buffer from kernel mode, while
holding i_mutex.  Danger of deadlock if I take any i_mutex down there
in the fault.

Shame on me for forgetting that one, and you've saved me from some egg
on my face.  Though I'll give myself a little pat for holding this one
back from rushing into stable.

And how convenient to have a really good strong reason to revert this
"fix", when we wanted to revert it anyway, to meet Vlastimil's backport
concerns.  I'll get on with that, and give an update in that thread.

Thanks again,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
