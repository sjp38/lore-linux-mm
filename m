Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 17BBC900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 20:52:52 -0400 (EDT)
Received: by oihb142 with SMTP id b142so74414723oih.3
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 17:52:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a203si2377419oih.8.2015.06.06.17.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jun 2015 17:52:51 -0700 (PDT)
Message-ID: <55739536.5040509@oracle.com>
Date: Sat, 06 Jun 2015 20:49:58 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/51] writeback: move backing_dev_info->wb_lock and ->worklist
 into bdi_writeback
References: <1432329245-5844-1-git-send-email-tj@kernel.org> <1432329245-5844-17-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-17-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On 05/22/2015 05:13 PM, Tejun Heo wrote:
> Currently, a bdi (backing_dev_info) embeds single wb (bdi_writeback)
> and the role of the separation is unclear.  For cgroup support for
> writeback IOs, a bdi will be updated to host multiple wb's where each
> wb serves writeback IOs of a different cgroup on the bdi.  To achieve
> that, a wb should carry all states necessary for servicing writeback
> IOs for a cgroup independently.
> 
> This patch moves bdi->wb_lock and ->worklist into wb.
> 
> * The lock protects bdi->worklist and bdi->wb.dwork scheduling.  While
>   moving, rename it to wb->work_lock as wb->wb_lock is confusing.
>   Also, move wb->dwork downwards so that it's colocated with the new
>   ->work_lock and ->work_list fields.
> 
> * bdi_writeback_workfn()		-> wb_workfn()
>   bdi_wakeup_thread_delayed(bdi)	-> wb_wakeup_delayed(wb)
>   bdi_wakeup_thread(bdi)		-> wb_wakeup(wb)
>   bdi_queue_work(bdi, ...)		-> wb_queue_work(wb, ...)
>   __bdi_start_writeback(bdi, ...)	-> __wb_start_writeback(wb, ...)
>   get_next_work_item(bdi)		-> get_next_work_item(wb)
> 
> * bdi_wb_shutdown() is renamed to wb_shutdown() and now takes @wb.
>   The function contained parts which belong to the containing bdi
>   rather than the wb itself - testing cap_writeback_dirty and
>   bdi_remove_from_list() invocation.  Those are moved to
>   bdi_unregister().
> 
> * bdi_wb_{init|exit}() are renamed to wb_{init|exit}().
>   Initializations of the moved bdi->wb_lock and ->work_list are
>   relocated from bdi_init() to wb_init().
> 
> * As there's still only one bdi_writeback per backing_dev_info, all
>   uses of bdi->state are mechanically replaced with bdi->wb.state
>   introducing no behavior changes.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Wu Fengguang <fengguang.wu@intel.com>

Hi Tejun,

I'm now seeing:

[619070.603554] WARNING: CPU: 10 PID: 8316 at lib/list_debug.c:56 __list_del_entry+0x104/0x1a0()
[619070.604573] list_del corruption, ffff880540ad6fb8->prev is LIST_POISON2 (dead000000200200)
[619070.605501] Modules linked in:
[619070.606103] CPU: 10 PID: 8316 Comm: mount Not tainted 4.1.0-rc6-next-20150604-sasha-00039-g07bbbaf #2
268
[619070.607386]  ffff8800c9aeb000 0000000061727ceb ffff8800c9387a38 ffffffffa3a02988
[619070.608791]  0000000000000000 ffff8800c9387ab8 ffff8800c9387a88 ffffffff9a1e5336
[619070.610029]  ffff8802b6008680 ffffffff9bdae994 ffff8800c9387a68 ffffed0019270f53
[619070.610978] Call Trace:
[619070.611357] dump_stack (lib/dump_stack.c:52)
[619070.612019] warn_slowpath_common (kernel/panic.c:448)
[619070.612666] ? __list_del_entry (lib/list_debug.c:54 (discriminator 1))
[619070.613435] warn_slowpath_fmt (kernel/panic.c:454)
[619070.614102] ? warn_slowpath_common (kernel/panic.c:454)
[619070.614900] ? lock_acquired (kernel/locking/lockdep.c:3890)
[619070.615642] __list_del_entry (lib/list_debug.c:54 (discriminator 1))
[619070.616474] ? bdi_destroy (include/linux/rculist.h:131 mm/backing-dev.c:803 mm/backing-dev.c:812)
[619070.617273] bdi_destroy (include/linux/rculist.h:132 mm/backing-dev.c:803 mm/backing-dev.c:812)
[619070.618261] v9fs_session_close (include/linux/spinlock.h:312 fs/9p/v9fs.c:455)
[619070.619121] v9fs_mount (fs/9p/vfs_super.c:200)
[619070.619785] ? lockdep_init_map (kernel/locking/lockdep.c:3055)
[619070.620507] mount_fs (fs/super.c:1109)
[619070.621153] vfs_kern_mount (fs/namespace.c:948)
[619070.621867] ? get_fs_type (fs/filesystems.c:278 (discriminator 2))
[619070.622412] do_mount (fs/namespace.c:2385 fs/namespace.c:2701)
[619070.623035] ? copy_mount_string (fs/namespace.c:2634)
[619070.623610] ? __might_fault (mm/memory.c:3775 (discriminator 1))
[619070.624389] ? __might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3773)
[619070.625029] ? memdup_user (./arch/x86/include/asm/uaccess.h:718)
[619070.625833] SyS_mount (fs/namespace.c:2894 fs/namespace.c:2869)
[619070.626442] ? copy_mnt_ns (fs/namespace.c:2869)
[619070.627131] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[619070.628088] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[619070.629095] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:39)
[619070.629847] system_call_fastpath (arch/x86/kernel/entry_64.S:195)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
