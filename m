Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3AB39900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:38:07 -0400 (EDT)
Date: Mon, 18 Apr 2011 09:38:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110415235222.GA18694@mtj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104180930580.23207@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home> <alpine.DEB.2.00.1104131148070.20908@router.home> <20110413185618.GA3987@mtj.dyndns.org> <alpine.DEB.2.00.1104131521050.25812@router.home> <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home> <20110414211522.GE21397@mtj.dyndns.org> <alpine.DEB.2.00.1104151235350.8055@router.home> <20110415182734.GB15916@mtj.dyndns.org> <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Sat, 16 Apr 2011, Tejun Heo wrote:

> Maybe, I don't know.  On x86, it shouldn't be a problem on both 32 and
> 64bit.  Even on archs which lack local cmpxchg, preemption flips are
> cheap anyway so yeah maybe.

Preemption flips are not cheap since enabling preemption may mean a call
into the scheduler. On RT things get more expensive.

Preempt_enable means at least one additional branch. We are saving a
branch by not using preempt.

> > The branches are not an issue since they are forward branches over one
> > (after converting to an atomic operation) or two instructions each. A
> > possible stall is only possible in case of the cmpxchg failing.
>
> It's slow path and IMHO it's needlessly complex.  I really don't care
> whether the counter is reloaded once more or the task gets migrated to
> another cpu before spin_lock() and ends up flushing local counter on a
> cpu where it isn't strictly necessary.  Let's keep it simple.

In order to make it simple I avoided an preempt enable/disable. With
Shaohua's patches there will be a simple atomic_add within the last if
cluase. I was able to consolidate multiple code paths into the cmpxchg
loop with this approach.

The one below avoids the #ifdef that is ugly...



Subject: percpu: preemptless __per_cpu_counter_add V4

Use this_cpu_cmpxchg to avoid preempt_disable/enable in __percpu_add.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 lib/percpu_counter.c |   24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-15 15:34:23.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-18 09:31:37.000000000 -0500
@@ -71,19 +71,25 @@ EXPORT_SYMBOL(percpu_counter_set);

 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
 {
-	s64 count;
+	s64 count, new, overflow;

-	preempt_disable();
-	count = __this_cpu_read(*fbc->counters) + amount;
-	if (count >= batch || count <= -batch) {
+	do {
+		count = this_cpu_read(*fbc->counters);
+
+		new = count + amount;
+		/* In case of overflow fold it into the global counter instead */
+		if (new >= batch || new <= -batch) {
+			overflow = new;
+			new = 0;
+		} else
+			overflow = 0;
+	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
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
