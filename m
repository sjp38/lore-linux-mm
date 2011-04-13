Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 739ED900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:17:17 -0400 (EDT)
Date: Wed, 13 Apr 2011 17:17:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110413215022.GI3987@mtj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104131712070.29766@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home> <alpine.DEB.2.00.1104131148070.20908@router.home> <20110413185618.GA3987@mtj.dyndns.org> <alpine.DEB.2.00.1104131521050.25812@router.home> <20110413215022.GI3987@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com, shaohua.li@intel.com

On Thu, 14 Apr 2011, Tejun Heo wrote:

> Hello,
>
> On Wed, Apr 13, 2011 at 03:22:36PM -0500, Christoph Lameter wrote:
> > +	do {
> > +		count = this_cpu_read(*fbc->counters);
> > +
> > +		new = count + amount;
> > +		/* In case of overflow fold it into the global counter instead */
> > +		if (new >= batch || new <= -batch) {
> > +			spin_lock(&fbc->lock);
> > +			fbc->count += __this_cpu_read(*fbc->counters) + amount;
> > +			spin_unlock(&fbc->lock);
> > +			amount = 0;
> > +			new = 0;
> > +		}
> > +
> > +	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
>
> Is this correct?  If the percpu count changes in the middle, doesn't
> the count get added twice?  Can you please use the cmpxchg() only in
> the fast path?  ie.

Oh gosh this is the old version. The fixed version should do this
differently.

We need to update the counter that is cpu specific as well otherwise it
will overflow again soon. Hmmm... Yes, it could be done while holding the
spinlock which disables preempt.



Subject: [PATCH] percpu: preemptless __per_cpu_counter_add

Use this_cpu_cmpxchg to avoid preempt_disable/enable in __percpu_add.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 lib/percpu_counter.c |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 15:19:54.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-13 15:20:04.000000000 -0500
@@ -71,19 +71,27 @@ EXPORT_SYMBOL(percpu_counter_set);

 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
 {
-	s64 count;
+	s64 count, new;

-	preempt_disable();
-	count = __this_cpu_read(*fbc->counters) + amount;
-	if (count >= batch || count <= -batch) {
-		spin_lock(&fbc->lock);
-		fbc->count += count;
-		__this_cpu_write(*fbc->counters, 0);
-		spin_unlock(&fbc->lock);
-	} else {
-		__this_cpu_write(*fbc->counters, count);
-	}
-	preempt_enable();
+	do {
+		count = this_cpu_read(*fbc->counters);
+
+		new = count + amount;
+		/* In case of overflow fold it into the global counter instead */
+		if (new >= batch || new <= -batch) {
+			spin_lock(&fbc->lock);
+			count = __this_cpu_read(*fbc->counters);
+			fbc->count += count + amount;
+			spin_unlock(&fbc->lock);
+			/*
+			 * If cmpxchg fails then we need to subtract the amount that
+			 * we found in the percpu value.
+			 */
+			amount = -count;
+			new = 0;
+		}
+
+	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
 }
 EXPORT_SYMBOL(__percpu_counter_add);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
