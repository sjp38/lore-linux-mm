Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 64ACF6B0055
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 01:56:35 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 21CC582C731
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:06:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UKMjudmqNazn for <linux-mm@kvack.org>;
	Fri,  2 Oct 2009 02:06:44 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A9D2782C805
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:06:34 -0400 (EDT)
Message-Id: <20091001174119.925240512@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:35 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 02/19] this_cpu: X86 optimized this_cpu operations
Content-Disposition: inline; filename=this_cpu_x86_ops
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Basically the existing percpu ops can be used for this_cpu variants that allow
operations also on dynamically allocated percpu data. However, we do not pass a
reference to a percpu variable in. Instead a dynamically or statically
allocated percpu variable is provided.

Preempt, the non preempt and the irqsafe operations generate the same code.
It will always be possible to have the requires per cpu atomicness in a single
RMW instruction with segment override on x86.

64 bit this_cpu operations are not supported on 32 bit.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/x86/include/asm/percpu.h |   78 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2009-10-01 09:08:37.000000000 -0500
+++ linux-2.6/arch/x86/include/asm/percpu.h	2009-10-01 09:29:43.000000000 -0500
@@ -153,6 +153,84 @@ do {							\
 #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)
 #define percpu_xor(var, val)	percpu_to_op("xor", per_cpu__##var, val)
 
+#define __this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define __this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define __this_cpu_read_4(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+
+#define __this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define __this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define __this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define __this_cpu_add_1(pcp, val)	percpu_to_op("add", (pcp), val)
+#define __this_cpu_add_2(pcp, val)	percpu_to_op("add", (pcp), val)
+#define __this_cpu_add_4(pcp, val)	percpu_to_op("add", (pcp), val)
+#define __this_cpu_and_1(pcp, val)	percpu_to_op("and", (pcp), val)
+#define __this_cpu_and_2(pcp, val)	percpu_to_op("and", (pcp), val)
+#define __this_cpu_and_4(pcp, val)	percpu_to_op("and", (pcp), val)
+#define __this_cpu_or_1(pcp, val)	percpu_to_op("or", (pcp), val)
+#define __this_cpu_or_2(pcp, val)	percpu_to_op("or", (pcp), val)
+#define __this_cpu_or_4(pcp, val)	percpu_to_op("or", (pcp), val)
+#define __this_cpu_xor_1(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define __this_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define __this_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#define this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define this_cpu_read_4(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define this_cpu_add_1(pcp, val)	percpu_to_op("add", (pcp), val)
+#define this_cpu_add_2(pcp, val)	percpu_to_op("add", (pcp), val)
+#define this_cpu_add_4(pcp, val)	percpu_to_op("add", (pcp), val)
+#define this_cpu_and_1(pcp, val)	percpu_to_op("and", (pcp), val)
+#define this_cpu_and_2(pcp, val)	percpu_to_op("and", (pcp), val)
+#define this_cpu_and_4(pcp, val)	percpu_to_op("and", (pcp), val)
+#define this_cpu_or_1(pcp, val)		percpu_to_op("or", (pcp), val)
+#define this_cpu_or_2(pcp, val)		percpu_to_op("or", (pcp), val)
+#define this_cpu_or_4(pcp, val)		percpu_to_op("or", (pcp), val)
+#define this_cpu_xor_1(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define this_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define this_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#define irqsafe_cpu_add_1(pcp, val)	percpu_to_op("add", (pcp), val)
+#define irqsafe_cpu_add_2(pcp, val)	percpu_to_op("add", (pcp), val)
+#define irqsafe_cpu_add_4(pcp, val)	percpu_to_op("add", (pcp), val)
+#define irqsafe_cpu_and_1(pcp, val)	percpu_to_op("and", (pcp), val)
+#define irqsafe_cpu_and_2(pcp, val)	percpu_to_op("and", (pcp), val)
+#define irqsafe_cpu_and_4(pcp, val)	percpu_to_op("and", (pcp), val)
+#define irqsafe_cpu_or_1(pcp, val)	percpu_to_op("or", (pcp), val)
+#define irqsafe_cpu_or_2(pcp, val)	percpu_to_op("or", (pcp), val)
+#define irqsafe_cpu_or_4(pcp, val)	percpu_to_op("or", (pcp), val)
+#define irqsafe_cpu_xor_1(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define irqsafe_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
+#define irqsafe_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+/*
+ * Per cpu atomic 64 bit operations are only available under 64 bit.
+ * 32 bit must fall back to generic operations.
+ */
+#ifdef CONFIG_X86_64
+#define __this_cpu_read_8(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define __this_cpu_write_8(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define __this_cpu_add_8(pcp, val)	percpu_to_op("add", (pcp), val)
+#define __this_cpu_and_8(pcp, val)	percpu_to_op("and", (pcp), val)
+#define __this_cpu_or_8(pcp, val)	percpu_to_op("or", (pcp), val)
+#define __this_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#define this_cpu_read_8(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
+#define this_cpu_write_8(pcp, val)	percpu_to_op("mov", (pcp), val)
+#define this_cpu_add_8(pcp, val)	percpu_to_op("add", (pcp), val)
+#define this_cpu_and_8(pcp, val)	percpu_to_op("and", (pcp), val)
+#define this_cpu_or_8(pcp, val)		percpu_to_op("or", (pcp), val)
+#define this_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#define irqsafe_cpu_add_8(pcp, val)	percpu_to_op("add", (pcp), val)
+#define irqsafe_cpu_and_8(pcp, val)	percpu_to_op("and", (pcp), val)
+#define irqsafe_cpu_or_8(pcp, val)	percpu_to_op("or", (pcp), val)
+#define irqsafe_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)
+
+#endif
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
