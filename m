From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 06/18] vmstat: Use this_cpu_inc_return for vm statistics
Date: Tue, 30 Nov 2010 13:07:13 -0600
Message-ID: <20101130190844.623370797@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZQ-0000HF-ID
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:08:56 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C809A6B0089
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:46 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_add_vmstat
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

this_cpu_inc_return() saves us a memory access there. Code
size does not change.

V1->V2:
	- Fixed the location of the __per_cpu pointer attributes
	- Sparse checked
V2->V3:
	- Move fixes to __percpu attribute usage to earlier patch

Reviewed-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/vmstat.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2010-11-29 10:36:16.000000000 -0600
+++ linux-2.6/mm/vmstat.c	2010-11-29 10:38:50.000000000 -0600
@@ -227,9 +227,7 @@ void __inc_zone_state(struct zone *zone,
 	s8 __percpu *p = pcp->vm_stat_diff + item;
 	s8 v, t;
 
-	__this_cpu_inc(*p);
-
-	v = __this_cpu_read(*p);
+	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v > t)) {
 		s8 overstep = t >> 1;
@@ -251,9 +249,7 @@ void __dec_zone_state(struct zone *zone,
 	s8 __percpu *p = pcp->vm_stat_diff + item;
 	s8 v, t;
 
-	__this_cpu_dec(*p);
-
-	v = __this_cpu_read(*p);
+	v = __this_cpu_dec_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v < - t)) {
 		s8 overstep = t >> 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
