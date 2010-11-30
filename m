From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 05/18] x86: Use this_cpu_inc_return for nmi counter
Date: Tue, 30 Nov 2010 13:07:12 -0600
Message-ID: <20101130190844.025319634@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZT-0000K6-Ft
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:08:59 +0100
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC3AB6B008A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:47 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_add_nmi
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

this_cpu_inc_return() saves us a memory access there.

Reviewed-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Pekka Enberg <penberg@kernel.org>
Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/kernel/apic/nmi.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/arch/x86/kernel/apic/nmi.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/apic/nmi.c	2010-11-23 16:35:19.000000000 -0600
+++ linux-2.6/arch/x86/kernel/apic/nmi.c	2010-11-23 16:38:29.000000000 -0600
@@ -432,8 +432,7 @@ nmi_watchdog_tick(struct pt_regs *regs,
 		 * Ayiee, looks like this CPU is stuck ...
 		 * wait a few IRQs (5 seconds) before doing the oops ...
 		 */
-		__this_cpu_inc(alert_counter);
-		if (__this_cpu_read(alert_counter) == 5 * nmi_hz)
+		if (__this_cpu_inc_return(alert_counter) == 5 * nmi_hz)
 			/*
 			 * die_nmi will return ONLY if NOTIFY_STOP happens..
 			 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
