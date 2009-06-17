Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 71B516B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 16:34:00 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DDF2C82C4F3
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 16:51:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nlCRFbTR5YK8 for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 16:51:19 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 15E5E82C4F6
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 16:51:09 -0400 (EDT)
Message-Id: <20090617203444.731295080@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:47 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu operations
Content-Disposition: inline; filename=this_cpu_x86_ops
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Basically the existing percpu ops can be used. However, we do not pass a
reference to a percpu variable in. Instead an address of a percpu variable
is provided.

Both preempt, the non preempt and the irqsafe operations generate the same code.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/x86/include/asm/percpu.h |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2009-06-04 13:38:01.000000000 -0500
+++ linux-2.6/arch/x86/include/asm/percpu.h	2009-06-04 14:21:22.000000000 -0500
@@ -140,6 +140,28 @@ do {							\
 #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)
 #define percpu_xor(var, val)	percpu_to_op("xor", per_cpu__##var, val)
 
+#define __this_cpu_read(pcp)		percpu_from_op("mov", pcp)
+#define __this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define __this_cpu_add(pcp, val)	percpu_to_op("add", (pcp), val)
+#define __this_cpu_sub(pcp, val)	percpu_to_op("sub", (pcp), val)
+#define __this_cpu_and(pcp, val)	percpu_to_op("and", (pcp), val)
+#define __this_cpu_or(pcp, val)		percpu_to_op("or", (pcp), val)
+#define __this_cpu_xor(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#define this_cpu_read(pcp)		percpu_from_op("mov", (pcp))
+#define this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define this_cpu_add(pcp, val)		percpu_to_op("add", (pcp), val)
+#define this_cpu_sub(pcp, val)		percpu_to_op("sub", (pcp), val)
+#define this_cpu_and(pcp, val)		percpu_to_op("and", (pcp), val)
+#define this_cpu_or(pcp, val)		percpu_to_op("or", (pcp), val)
+#define this_cpu_xor(pcp, val)		percpu_to_op("xor", (pcp), val)
+
+#define irqsafe_cpu_add(pcp, val)	percpu_to_op("add", (pcp), val)
+#define irqsafe_cpu_sub(pcp, val)	percpu_to_op("sub", (pcp), val)
+#define irqsafe_cpu_and(pcp, val)	percpu_to_op("and", (pcp), val)
+#define irqsafe_cpu_or(pcp, val)	percpu_to_op("or", (pcp), val)
+#define irqsafe_cpu_xor(pcp, val)	percpu_to_op("xor", (pcp), val)
+
 /* This is not atomic against other CPUs -- CPU preemption needs to be off */
 #define x86_test_and_clear_bit_percpu(bit, var)				\
 ({									\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
