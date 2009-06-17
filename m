Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 847806B004D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:36:06 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5783582C572
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:53:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DdlcIwso9HPx for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 21:53:25 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 93DB182C509
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:45:13 -0400 (EDT)
Message-Id: <20090617203444.921262487@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:48 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 11/19] Use this_cpu ops for VM statistics.
Content-Disposition: inline; filename=this_cpu_vmstats
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/vmstat.h |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: linux-2.6/include/linux/vmstat.h
===================================================================
--- linux-2.6.orig/include/linux/vmstat.h	2009-06-11 10:50:59.000000000 -0500
+++ linux-2.6/include/linux/vmstat.h	2009-06-11 11:10:48.000000000 -0500
@@ -75,24 +75,22 @@ DECLARE_PER_CPU(struct vm_event_state, v
 
 static inline void __count_vm_event(enum vm_event_item item)
 {
-	__get_cpu_var(vm_event_states).event[item]++;
+	__this_cpu_inc(per_cpu_var(vm_event_states).event[item]);
 }
 
 static inline void count_vm_event(enum vm_event_item item)
 {
-	get_cpu_var(vm_event_states).event[item]++;
-	put_cpu();
+	this_cpu_inc(per_cpu_var(vm_event_states).event[item]);
 }
 
 static inline void __count_vm_events(enum vm_event_item item, long delta)
 {
-	__get_cpu_var(vm_event_states).event[item] += delta;
+	__this_cpu_add(per_cpu_var(vm_event_states).event[item], delta);
 }
 
 static inline void count_vm_events(enum vm_event_item item, long delta)
 {
-	get_cpu_var(vm_event_states).event[item] += delta;
-	put_cpu();
+	this_cpu_add(per_cpu_var(vm_event_states).event[item], delta);
 }
 
 extern void all_vm_events(unsigned long *);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
