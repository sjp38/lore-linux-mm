Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 81FA0900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:37:20 -0400 (EDT)
Date: Fri, 15 Apr 2011 12:37:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110414211522.GE21397@mtj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104151235350.8055@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home> <alpine.DEB.2.00.1104131148070.20908@router.home> <20110413185618.GA3987@mtj.dyndns.org> <alpine.DEB.2.00.1104131521050.25812@router.home> <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home> <20110414211522.GE21397@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Fri, 15 Apr 2011, Tejun Heo wrote:

> > The preempt on/off seems to be a bigger deal for realtime.
>
> Also, the cmpxchg used is local one w/o LOCK prefix.  It might not
> bring anything to table on !PREEMPT kernels but at the same time it
> shouldn't hurt either.  One way or the other, some benchmark numbers
> showing that it at least doesn't hurt would be nice.

Maybe just fall back to this_cpu_write()?
> > > Maybe use here latest cmpxchg16b stuff instead and get rid of spinlock ?
> >
> > Shaohua already got an atomic in there. You mean get rid of his preempt
> > disable/enable in the slow path?
>
> I personally care much less about slow path.  According to Shaohua,
> atomic64_t behaves pretty nice and it isn't too complex, so I'd like
> to stick with that unless complex this_cpu ops can deliver something
> much better.

Ok here is a new patch that will allow Shaohua to simply convert the
slowpath to a single atomic op. No preemption anymore anywhere.



Subject: percpu: preemptless __per_cpu_counter_add V3

Use this_cpu_cmpxchg to avoid preempt_disable/enable in __percpu_add.

V3 - separate out the slow path so that the slowpath can also be done with
	a simple atomic add without preemption enable/disable.
   - Fallback in the !PREEMPT case to a simple this_cpu_write().

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 lib/percpu_counter.c |   29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 17:12:59.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-15 12:34:39.000000000 -0500
@@ -71,19 +71,30 @@ EXPORT_SYMBOL(percpu_counter_set);

 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
 {
-	s64 count;
+	s64 count, new, overflow;

-	preempt_disable();
-	count = __this_cpu_read(*fbc->counters) + amount;
-	if (count >= batch || count <= -batch) {
+	do {
+		overflow = 0;
+		count = this_cpu_read(*fbc->counters);
+
+		new = count + amount;
+		/* In case of overflow fold it into the global counter instead */
+		if (new >= batch || new <= -batch) {
+			overflow = new;
+			new = 0;
+		}
+#ifdef CONFIG_PREEMPT
+	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
+#else
+	} while (0);
+	this_cpu_write(*fbc->counters, new);
+#endif
+
+	if (unlikely(overflow)) {
 		spin_lock(&fbc->lock);
-		fbc->count += count;
-		__this_cpu_write(*fbc->counters, 0);
+		fbc->count += overflow;
 		spin_unlock(&fbc->lock);
-	} else {
-		__this_cpu_write(*fbc->counters, count);
 	}
-	preempt_enable();
 }
 EXPORT_SYMBOL(__percpu_counter_add);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
