Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 934816B00BF
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 14:22:23 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so5640029ieb.26
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 11:22:23 -0700 (PDT)
Message-ID: <533077CE.6010204@oracle.com>
Date: Mon, 24 Mar 2014 14:22:06 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] aio: ensure access to ctx->ring_pages is correctly serialised
References: <532A80B1.5010002@cn.fujitsu.com> <20140320143207.GA3760@redhat.com> <20140320163004.GE28970@kvack.org> <532B9C54.80705@cn.fujitsu.com> <20140321183509.GC23173@kvack.org>
In-Reply-To: <20140321183509.GC23173@kvack.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, jmoyer@redhat.com, kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, miaox@cn.fujitsu.com, linux-aio@kvack.org, fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/21/2014 02:35 PM, Benjamin LaHaise wrote:
> Hi all,
>
> Based on the issues reported by Tang and Gu, I've come up with the an
> alternative fix that avoids adding additional locking in the event read
> code path.  The fix is to take the ring_lock mutex during page migration,
> which is already used to syncronize event readers and thus does not add
> any new locking requirements in aio_read_events_ring().  I've dropped
> the patches from Tang and Gu as a result.  This patch is now in my
> git://git.kvack.org/~bcrl/aio-next.git tree and will be sent to Linus
> once a few other people chime in with their reviews of this change.
> Please review Tang, Gu.  Thanks!

Hi Benjamin,

This patch seems to trigger:

[  433.476216] ======================================================
[  433.478468] [ INFO: possible circular locking dependency detected ]
[  433.480900] 3.14.0-rc7-next-20140324-sasha-00015-g1fb7de8 #267 Tainted: G        W
[  433.480900] -------------------------------------------------------
[  433.480900] trinity-c57/13776 is trying to acquire lock:
[  433.480900]  (&ctx->ring_lock){+.+.+.}, at: aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]
[  433.480900] but task is already holding lock:
[  433.480900]  (&mm->mmap_sem){++++++}, at: SYSC_move_pages (mm/migrate.c:1215 mm/migrate.c:1353 mm/migrate.c:1508)
[  433.480900]
[  433.480900] which lock already depends on the new lock.
[  433.480900]
[  433.480900]
[  433.480900] the existing dependency chain (in reverse order) is:
[  433.480900]
-> #1 (&mm->mmap_sem){++++++}:
[  433.480900]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  433.480900]        down_write (arch/x86/include/asm/rwsem.h:130 kernel/locking/rwsem.c:50)
[  433.480900]        SyS_io_setup (fs/aio.c:442 fs/aio.c:689 fs/aio.c:1201 fs/aio.c:1184)
[  433.480900]        tracesys (arch/x86/kernel/entry_64.S:749)
[  433.480900]
-> #0 (&ctx->ring_lock){+.+.+.}:
[  433.480900]        __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
[  433.480900]        lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  433.480900]        mutex_lock_nested (kernel/locking/mutex.c:486 kernel/locking/mutex.c:587)
[  433.480900]        aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]        move_to_new_page (mm/migrate.c:777)
[  433.480900]        migrate_pages (mm/migrate.c:921 mm/migrate.c:960 mm/migrate.c:1126)
[  433.480900]        SYSC_move_pages (mm/migrate.c:1278 mm/migrate.c:1353 mm/migrate.c:1508)
[  433.480900]        SyS_move_pages (mm/migrate.c:1456)
[  433.480900]        tracesys (arch/x86/kernel/entry_64.S:749)
[  433.480900]
[  433.480900] other info that might help us debug this:
[  433.480900]
[  433.480900]  Possible unsafe locking scenario:
[  433.480900]
[  433.480900]        CPU0                    CPU1
[  433.480900]        ----                    ----
[  433.480900]   lock(&mm->mmap_sem);
[  433.480900]                                lock(&ctx->ring_lock);
[  433.480900]                                lock(&mm->mmap_sem);
[  433.480900]   lock(&ctx->ring_lock);
[  433.480900]
[  433.480900]  *** DEADLOCK ***
[  433.480900]
[  433.480900] 1 lock held by trinity-c57/13776:
[  433.480900]  #0:  (&mm->mmap_sem){++++++}, at: SYSC_move_pages (mm/migrate.c:1215 mm/migrate.c:1353 mm/migrate.c:1508)
[  433.480900]
[  433.480900] stack backtrace:
[  433.480900] CPU: 4 PID: 13776 Comm: trinity-c57 Tainted: G        W     3.14.0-rc7-next-20140324-sasha-00015-g1fb7de8 #267
[  433.480900]  ffffffff87a80790 ffff8806abbbb9a8 ffffffff844bae02 0000000000000000
[  433.480900]  ffffffff87a80790 ffff8806abbbb9f8 ffffffff844ad86d 0000000000000001
[  433.480900]  ffff8806abbbba88 ffff8806abbbb9f8 ffff8806ab8fbcf0 ffff8806ab8fbd28
[  433.480900] Call Trace:
[  433.480900]  dump_stack (lib/dump_stack.c:52)
[  433.480900]  print_circular_bug (kernel/locking/lockdep.c:1216)
[  433.480900]  __lock_acquire (kernel/locking/lockdep.c:1840 kernel/locking/lockdep.c:1945 kernel/locking/lockdep.c:2131 kernel/locking/lockdep.c:3182)
[  433.480900]  ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  433.480900]  ? sched_clock_local (kernel/sched/clock.c:214)
[  433.480900]  ? sched_clock_cpu (kernel/sched/clock.c:311)
[  433.480900]  ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  433.480900]  lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  433.480900]  ? aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]  mutex_lock_nested (kernel/locking/mutex.c:486 kernel/locking/mutex.c:587)
[  433.480900]  ? aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]  ? aio_migratepage (fs/aio.c:303)
[  433.480900]  ? aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]  ? aio_migratepage (include/linux/rcupdate.h:324 include/linux/rcupdate.h:909 include/linux/percpu-refcount.h:117 fs/aio.c:297)
[  433.480900]  ? preempt_count_sub (kernel/sched/core.c:2527)
[  433.480900]  aio_migratepage (include/linux/spinlock.h:303 fs/aio.c:306)
[  433.480900]  ? aio_migratepage (include/linux/rcupdate.h:886 include/linux/percpu-refcount.h:108 fs/aio.c:297)
[  433.480900]  ? mutex_unlock (kernel/locking/mutex.c:220)
[  433.480900]  move_to_new_page (mm/migrate.c:777)
[  433.480900]  ? try_to_unmap (mm/rmap.c:1516)
[  433.480900]  ? try_to_unmap_nonlinear (mm/rmap.c:1113)
[  433.480900]  ? invalid_migration_vma (mm/rmap.c:1472)
[  433.480900]  ? page_remove_rmap (mm/rmap.c:1380)
[  433.480900]  ? anon_vma_fork (mm/rmap.c:446)
[  433.480900]  migrate_pages (mm/migrate.c:921 mm/migrate.c:960 mm/migrate.c:1126)
[  433.480900]  ? follow_page_mask (mm/memory.c:1544)
[  433.480900]  ? alloc_misplaced_dst_page (mm/migrate.c:1177)
[  433.480900]  SYSC_move_pages (mm/migrate.c:1278 mm/migrate.c:1353 mm/migrate.c:1508)
[  433.480900]  ? SYSC_move_pages (include/linux/rcupdate.h:800 mm/migrate.c:1472)
[  433.480900]  ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  433.480900]  SyS_move_pages (mm/migrate.c:1456)
[  433.480900]  tracesys (arch/x86/kernel/entry_64.S:749)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
