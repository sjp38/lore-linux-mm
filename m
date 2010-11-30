From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 02/18] vmstat: Optimize zone counter modifications through the use of this cpu operations
Date: Tue, 30 Nov 2010 13:07:09 -0600
Message-ID: <20101130190842.265514747@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZK-0000DQ-Ea
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:08:50 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 59B9E6B0088
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:45 -0500 (EST)
Content-Disposition: inline; filename=vmstat_this_cpu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

this cpu operations can be used to slightly optimize the function. The
changes will avoid some address calculations and replace them with the
use of the percpu segment register.

If one would have this_cpu_inc_return and this_cpu_dec_return then it
would be possible to optimize inc_zone_page_state and dec_zone_page_state even
more.

V1->V2:
	- Fix __dec_zone_state overflow handling
	- Use s8 variables for temporary storage.

V2->V3:
	- Put __percpu annotations in correct places.

Reviewed-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/vmstat.c |   56 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 24 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2010-11-29 10:17:28.000000000 -0600
+++ linux-2.6/mm/vmstat.c	2010-11-29 10:36:16.000000000 -0600
@@ -167,18 +167,20 @@ static void refresh_zone_stat_thresholds
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
 {
-	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
-
-	s8 *p = pcp->vm_stat_diff + item;
+	struct per_cpu_pageset __percpu *pcp = zone->pageset;
+	s8 __percpu *p = pcp->vm_stat_diff + item;
 	long x;
+	long t;
+
+	x = delta + __this_cpu_read(*p);
 
-	x = delta + *p;
+	t = __this_cpu_read(pcp->stat_threshold);
 
-	if (unlikely(x > pcp->stat_threshold || x < -pcp->stat_threshold)) {
+	if (unlikely(x > t || x < -t)) {
 		zone_page_state_add(x, zone, item);
 		x = 0;
 	}
-	*p = x;
+	__this_cpu_write(*p, x);
 }
 EXPORT_SYMBOL(__mod_zone_page_state);
 
@@ -221,16 +223,19 @@ EXPORT_SYMBOL(mod_zone_page_state);
  */
 void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
-	s8 *p = pcp->vm_stat_diff + item;
-
-	(*p)++;
+	struct per_cpu_pageset __percpu *pcp = zone->pageset;
+	s8 __percpu *p = pcp->vm_stat_diff + item;
+	s8 v, t;
+
+	__this_cpu_inc(*p);
+
+	v = __this_cpu_read(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v > t)) {
+		s8 overstep = t >> 1;
 
-	if (unlikely(*p > pcp->stat_threshold)) {
-		int overstep = pcp->stat_threshold / 2;
-
-		zone_page_state_add(*p + overstep, zone, item);
-		*p = -overstep;
+		zone_page_state_add(v + overstep, zone, item);
+		__this_cpu_write(*p, - overstep);
 	}
 }
 
@@ -242,16 +247,19 @@ EXPORT_SYMBOL(__inc_zone_page_state);
 
 void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
-	s8 *p = pcp->vm_stat_diff + item;
-
-	(*p)--;
-
-	if (unlikely(*p < - pcp->stat_threshold)) {
-		int overstep = pcp->stat_threshold / 2;
+	struct per_cpu_pageset __percpu *pcp = zone->pageset;
+	s8 __percpu *p = pcp->vm_stat_diff + item;
+	s8 v, t;
+
+	__this_cpu_dec(*p);
+
+	v = __this_cpu_read(*p);
+	t = __this_cpu_read(pcp->stat_threshold);
+	if (unlikely(v < - t)) {
+		s8 overstep = t >> 1;
 
-		zone_page_state_add(*p - overstep, zone, item);
-		*p = overstep;
+		zone_page_state_add(v - overstep, zone, item);
+		__this_cpu_write(*p, overstep);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
