Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF00E6B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:18:16 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o68so37275943oik.23
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 03:18:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v32si84177otf.47.2017.03.27.03.18.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 03:18:15 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
	<201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
	<fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
	<201703250747.IAJ39022.HJSOtFFLVOFOMQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201703250747.IAJ39022.HJSOtFFLVOFOMQ@I-love.SAKURA.ne.jp>
Message-Id: <201703271916.FBI69340.SQFtOFVJHOLOMF@I-love.SAKURA.ne.jp>
Date: Mon, 27 Mar 2017 19:16:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, linux-mm@kvack.org
Cc: willy@infradead.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu

Tetsuo Handa wrote:
> . This patch will not break CONFIG_PREEMPT_COUNT=n case because
> in_interrupt() is evaluated as false because preempt_count() is always 0.

> -	if (unlikely(in_interrupt()))
> +	if (unlikely(preempt_count() || irqs_disabled() || rcu_preempt_depth()))

Oops, I got confused. preemptible() is always 0 for CONFIG_PREEMPT_COUNT=n case.
I think above condition is wrong. Updated patch is shown below.

>From 3dd03c34ee45fbdb3c8fd31b558a76db3a562b22 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 27 Mar 2017 10:53:08 +0900
Subject: [PATCH v2] mm: Allow calling vfree() from non-schedulable context.

Commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem
as potentially sleeping") added might_sleep() to remove_vm_area() from
vfree(), and is causing

[    2.616064] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
[    2.616125] in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
[    2.616156] 2 locks held by plymouthd/341:
[    2.616158]  #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
[    2.616256]  #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
[    2.616270] CPU: 2 PID: 341 Comm: plymouthd Not tainted 4.11.0-0.rc3.git0.1.kmallocwd.fc25.x86_64+debug #1
[    2.616271] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[    2.616273] Call Trace:
[    2.616281]  dump_stack+0x86/0xc3
[    2.616285]  ___might_sleep+0x17d/0x250
[    2.616289]  __might_sleep+0x4a/0x80
[    2.616293]  remove_vm_area+0x22/0x90
[    2.616296]  __vunmap+0x2e/0x110
[    2.616299]  vfree+0x42/0x90
[    2.616304]  kvfree+0x2c/0x40
[    2.616312]  drm_ht_remove+0x1a/0x30 [drm]
[    2.616317]  ttm_object_file_release+0x50/0x90 [ttm]
[    2.616324]  vmw_postclose+0x47/0x60 [vmwgfx]
[    2.616331]  drm_release+0x290/0x3b0 [drm]
[    2.616338]  __fput+0xf8/0x210
[    2.616342]  ____fput+0xe/0x10
[    2.616345]  task_work_run+0x85/0xc0
[    2.616351]  exit_to_usermode_loop+0xb4/0xc0
[    2.616355]  do_syscall_64+0x185/0x1f0
[    2.616359]  entry_SYSCALL64_slow_path+0x25/0x25

warning.

And commit 763b218ddfaf5676 ("mm: add preempt points into
__purge_vmap_area_lazy()") actually made vfree() potentially sleeping on
non-preemptible kernels. But we want to keep vfree() being callable from
non-schedulable context as with kfree() because vfree() is called via
kvfree().

This patch updates the condition to use __vfree_deferred() in order to
make sure that all vfree()/kvfree() users who did not notice that commit
will remain safe.

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

Also drop unlikely() part because caller holding spinlock or inside RCU is not
such uncommon cases.

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
