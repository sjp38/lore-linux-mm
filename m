Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F3EC900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 10:45:20 -0400 (EDT)
Date: Wed, 13 Apr 2011 09:45:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: percpu: preemptless __per_cpu_counter_add
Message-ID: <alpine.DEB.2.00.1104130942500.16214@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com

Use this_cpu_cmpxchg to avoid preempt_disable/enable in
__percpu_counter_add.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 lib/percpu_counter.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 09:26:19.000000000 -0500
+++ linux-2.6/lib/percpu_counter.c	2011-04-13 09:36:37.000000000 -0500
@@ -71,19 +71,22 @@ EXPORT_SYMBOL(percpu_counter_set);

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
+			fbc->count += __this_cpu_read(*fbc->counters) + amount;
+			spin_unlock(&fbc->lock);
+			amount = 0;
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
