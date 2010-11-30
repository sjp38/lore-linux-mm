From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 07/18] highmem: Use this_cpu_xx_return() operations
Date: Tue, 30 Nov 2010 13:07:14 -0600
Message-ID: <20101130190845.216537525@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVan-0001Kq-N3
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:10:22 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 528486B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:10:20 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_highmem
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Use this_cpu operations to optimize access primitives for highmem.

The main effect is the avoidance of address calculations through the
use of a segment prefix.

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/highmem.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h	2010-11-22 14:43:40.000000000 -0600
+++ linux-2.6/include/linux/highmem.h	2010-11-22 14:45:02.000000000 -0600
@@ -81,7 +81,8 @@ DECLARE_PER_CPU(int, __kmap_atomic_idx);
 
 static inline int kmap_atomic_idx_push(void)
 {
-	int idx = __get_cpu_var(__kmap_atomic_idx)++;
+	int idx = __this_cpu_inc_return(__kmap_atomic_idx) - 1;
+
 #ifdef CONFIG_DEBUG_HIGHMEM
 	WARN_ON_ONCE(in_irq() && !irqs_disabled());
 	BUG_ON(idx > KM_TYPE_NR);
@@ -91,12 +92,12 @@ static inline int kmap_atomic_idx_push(v
 
 static inline int kmap_atomic_idx(void)
 {
-	return __get_cpu_var(__kmap_atomic_idx) - 1;
+	return __this_cpu_read(__kmap_atomic_idx) - 1;
 }
 
 static inline int kmap_atomic_idx_pop(void)
 {
-	int idx = --__get_cpu_var(__kmap_atomic_idx);
+	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
 	BUG_ON(idx < 0);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
