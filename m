Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8916B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:54:03 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w11so6175712itb.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:54:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m9si7524762iod.66.2017.03.29.03.54.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 03:54:01 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v3] mm: Allow calling vfree() from non-schedulable context.
Date: Wed, 29 Mar 2017 19:51:52 +0900
Message-Id: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@elte.hu>, Jisheng Zhang <jszhang@marvell.com>, Joel Fernandes <joelaf@google.com>, John Dias <joaodias@google.com>, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem
as potentially sleeping") added might_sleep() to remove_vm_area() from
vfree(), and commit 763b218ddfaf5676 ("mm: add preempt points into
__purge_vmap_area_lazy()") actually made vfree() potentially sleeping on
non-preemptible kernels.

  commit bf22e37a641327e3 ("mm: add vfree_atomic()")
  commit 0f110a9b956c1678 ("kernel/fork: use vfree_atomic() to free thread stack")
  commit 8d5341a6260a59cf ("x86/ldt: use vfree_atomic() to free ldt entries")
  commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")
  commit f9e09977671b618a ("mm: turn vmap_purge_lock into a mutex")
  commit 763b218ddfaf5676 ("mm: add preempt points into __purge_vmap_area_lazy()")

But these commits did not take appropriate precautions for changing
non-sleeping API to sleeping API. Only two callers are updated to use
non-sleeping version, and remaining callers are silently using sleeping
version which might cause problems. For example, if we try

----------
 void kvfree(const void *addr)
 {
+	/* Detect errors before kvmalloc() falls back to vmalloc(). */
+	if (addr) {
+		WARN_ON(in_nmi());
+		if (likely(!in_interrupt()))
+			might_sleep();
+	}
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
----------

change, we can find a caller who is calling kvfree() with a spinlock held.

[   23.635540] BUG: sleeping function called from invalid context at mm/util.c:338
[   23.638701] in_atomic(): 1, irqs_disabled(): 0, pid: 478, name: kworker/0:1H
[   23.641516] 3 locks held by kworker/0:1H/478:
[   23.643476]  #0:  ("xfs-log/%s"mp->m_fsname){.+.+..}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
[   23.647176]  #1:  ((&bp->b_ioend_work)){+.+...}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
[   23.650939]  #2:  (&(&pag->pagb_lock)->rlock){+.+...}, at: [<ffffffffc02b42ee>] xfs_extent_busy_clear+0x9e/0xe0 [xfs]
[   23.655132] CPU: 0 PID: 478 Comm: kworker/0:1H Not tainted 4.11.0-rc4+ #212
[   23.657974] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   23.662041] Workqueue: xfs-log/sda1 xfs_buf_ioend_work [xfs]
[   23.664463] Call Trace:
[   23.665866]  dump_stack+0x85/0xc9
[   23.667538]  ___might_sleep+0x184/0x250
[   23.669371]  __might_sleep+0x4a/0x90
[   23.671137]  kvfree+0x41/0x90
[   23.672748]  xfs_extent_busy_clear_one+0x51/0x190 [xfs]
[   23.675110]  xfs_extent_busy_clear+0xbb/0xe0 [xfs]
[   23.677278]  xlog_cil_committed+0x241/0x420 [xfs]
[   23.679431]  xlog_state_do_callback+0x170/0x2d0 [xfs]
[   23.681717]  xlog_state_done_syncing+0x7f/0xa0 [xfs]
[   23.683971]  ? xfs_buf_ioend_work+0x15/0x20 [xfs]
[   23.686112]  xlog_iodone+0x86/0xc0 [xfs]
[   23.688007]  xfs_buf_ioend+0xd3/0x440 [xfs]
[   23.689999]  xfs_buf_ioend_work+0x15/0x20 [xfs]
[   23.692060]  process_one_work+0x21c/0x6c0
[   23.694177]  ? process_one_work+0x194/0x6c0
[   23.696120]  worker_thread+0x137/0x4b0
[   23.697973]  kthread+0x10f/0x150
[   23.699607]  ? process_one_work+0x6c0/0x6c0
[   23.701561]  ? kthread_create_on_node+0x70/0x70
[   23.703617]  ret_from_fork+0x31/0x40

It is not trivial to audit all vfree()/kvfree() users and correct them
not to use spin_lock()/preempt_disable()/rcu_read_lock() etc. before
calling vfree()/kvfree(). At least it is not doable for 4.10-stable and
4.11-rc fixes. Therefore, we must choose from either reverting these
commits or keeping vfree() as non-sleeping API for 4.10-stable and 4.11.
I assume that the latter is less painful for future development.

This patch updates the condition to use __vfree_deferred() in order to
make sure that all vfree()/kvfree() users who did not notice these
commits will remain safe.

console_unlock() is a function which is prepared for being called from
non-schedulable context (e.g. spinlock held, inside RCU). It is using

  !oops_in_progress && preemptible() && !rcu_preempt_depth()

as a condition for whether it is safe to schedule. This patch uses that
condition with oops_in_progress check (which is not important for
__vunmap() case) removed.

Straightforward change will be

-	if (unlikely(in_interrupt()))
+	if (unlikely(in_interrupt() || !(preemptible() && !rcu_preempt_depth())))

in vfree(). But we can remove in_interrupt() check due to reasons below.

If CONFIG_PREEMPT_COUNT=y, in_interrupt() and preemptible() are defined as

  #define in_interrupt() (irq_count())
  #define irq_count()    (preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK))
  #define preemptible()  (preempt_count() == 0 && !irqs_disabled())

and therefore this condition can be rewritten as below.

-	if (unlikely(in_interrupt() || !(preemptible() && !rcu_preempt_depth())))
+	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
+		     !(preempt_count() == 0 && !irqs_disabled()) || rcu_preempt_depth()))

-	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
-		     !(preempt_count() == 0 && !irqs_disabled()) || rcu_preempt_depth()))
+	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
+		     (preempt_count() != 0 || irqs_disabled()) || rcu_preempt_depth()))

-	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
-		     (preempt_count() != 0 || irqs_disabled()) || rcu_preempt_depth()))
+	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
+		     preempt_count() != 0 || irqs_disabled() || rcu_preempt_depth()))

-	if (unlikely((preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | NMI_MASK)) ||
-		     preempt_count() != 0 || irqs_disabled() || rcu_preempt_depth()))
+	if (unlikely(preempt_count() != 0 || irqs_disabled() || rcu_preempt_depth()))

-	if (unlikely(preempt_count() != 0 || irqs_disabled() || rcu_preempt_depth()))
+	if (unlikely(!(preempt_count() == 0 && !irqs_disabled()) || rcu_preempt_depth()))

-	if (unlikely(!(preempt_count() == 0 && !irqs_disabled()) || rcu_preempt_depth()))
+	if (unlikely(!preemptible() || rcu_preempt_depth()))

If CONFIG_PREEMPT_COUNT=n, preemptible() is defined as

  #define preemptible() 0

and therefore this condition can be rewritten as below.

-       if (unlikely(in_interrupt() || !(preemptible() && !rcu_preempt_depth())))
+       if (unlikely(in_interrupt() || !(0 && !rcu_preempt_depth())))

-       if (unlikely(in_interrupt() || !(0 && !rcu_preempt_depth())))
+       if (unlikely(in_interrupt() || !(0)))

-       if (unlikely(in_interrupt() || !(0)))
+       if (unlikely(in_interrupt() || 1))

-       if (unlikely(in_interrupt() || 1))
+       if (unlikely(1))

Also drop unlikely() part because caller being inside non-schedulable
context is not such uncommon cases.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jisheng Zhang <jszhang@marvell.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: John Dias <joaodias@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: <stable@vger.kernel.org> # v4.10
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0b05762..36334ff 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1589,7 +1589,7 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt()))
+	if (!preemptible() || rcu_preempt_depth())
 		__vfree_deferred(addr);
 	else
 		__vunmap(addr, 1);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
