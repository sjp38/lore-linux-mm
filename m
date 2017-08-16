Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C23CD6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:05:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t80so50379718pgb.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:05:16 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id i1si7065539pld.128.2017.08.15.21.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 21:05:15 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c65so259003pfl.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:05:15 -0700 (PDT)
Date: Wed, 16 Aug 2017 12:05:31 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816035842.p33z5st3rr2gwssh@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816001637.GN20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 16, 2017 at 09:16:37AM +0900, Byungchul Park wrote:
> On Tue, Aug 15, 2017 at 10:20:20AM +0200, Ingo Molnar wrote:
> > 
> > So with the latest fixes there's a new lockdep warning on one of my testboxes:
> > 
> > [   11.322487] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
> > 
> > [   11.495661] ======================================================
> > [   11.502093] WARNING: possible circular locking dependency detected
> > [   11.508507] 4.13.0-rc5-00497-g73135c58-dirty #1 Not tainted
> > [   11.514313] ------------------------------------------------------
> > [   11.520725] umount/533 is trying to acquire lock:
> > [   11.525657]  ((complete)&barr->done){+.+.}, at: [<ffffffff810fdbb3>] flush_work+0x213/0x2f0
> > [   11.534411] 
> >                but task is already holding lock:
> > [   11.540661]  (lock#3){+.+.}, at: [<ffffffff8122678d>] lru_add_drain_all_cpuslocked+0x3d/0x190
> > [   11.549613] 
> >                which lock already depends on the new lock.
> > 
> > The full splat is below. The kernel config is nothing fancy - distro derived, 
> > pretty close to defconfig, with lockdep enabled.
> 
> I see...
> 
> Worker A : acquired of wfc.work -> wait for cpu_hotplug_lock to be released
> Task   B : acquired of cpu_hotplug_lock -> wait for lock#3 to be released
> Task   C : acquired of lock#3 -> wait for completion of barr->done

>From the stack trace below, this barr->done is for flush_work() in
lru_add_drain_all_cpuslocked(), i.e. for work "per_cpu(lru_add_drain_work)"

> Worker D : wait for wfc.work to be released -> will complete barr->done

and this barr->done is for work "wfc.work".

So those two barr->done could not be the same instance, IIUC. Therefore
the deadlock case is not possible.

The problem here is all barr->done instances are initialized at
insert_wq_barrier() and they belongs to the same lock class, to fix
this, we need to differ barr->done with different lock classes based on
the corresponding works.

How about the this(only compilation test):

----------------->8
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index e86733a8b344..d14067942088 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2431,6 +2431,27 @@ struct wq_barrier {
 	struct task_struct	*task;	/* purely informational */
 };
 
+#ifdef CONFIG_LOCKDEP_COMPLETE
+# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
+do {										\
+	INIT_WORK_ONSTACK(&(barr)->work, func);					\
+	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
+	lockdep_init_map_crosslock((struct lockdep_map *)&(barr)->done.map,	\
+				   "(complete)" #barr,				\
+				   (target)->lockdep_map.key, 1); 		\
+	__init_completion(&barr->done);						\
+	barr->task = current;							\
+} while (0)
+#else
+# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
+do {										\
+	INIT_WORK_ONSTACK(&(barr)->work, func);					\
+	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
+	init_completion(&barr->done);						\
+	barr->task = current;							\
+} while (0)
+#endif
+
 static void wq_barrier_func(struct work_struct *work)
 {
 	struct wq_barrier *barr = container_of(work, struct wq_barrier, work);
@@ -2474,10 +2495,7 @@ static void insert_wq_barrier(struct pool_workqueue *pwq,
 	 * checks and call back into the fixup functions where we
 	 * might deadlock.
 	 */
-	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
-	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
-	init_completion(&barr->done);
-	barr->task = current;
+	INIT_WQ_BARRIER_ONSTACK(barr, wq_barrier_func, target);
 
 	/*
 	 * If @target is currently being executed, schedule the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
