Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B6DB76B0074
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:58:28 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id z2so848225wiv.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:58:28 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id x9si1581103wju.70.2015.01.15.00.58.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 00:58:18 -0800 (PST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 08:58:16 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D4D2C2190067
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:57:41 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0F8wEhP55246896
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:14 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0F8wDIJ012552
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 01:58:14 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 6/8] kernel: tighten rules for ACCESS ONCE
Date: Thu, 15 Jan 2015 09:58:32 +0100
Message-Id: <1421312314-72330-7-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>

Now that all non-scalar users of ACCESS_ONCE have been converted
to READ_ONCE or ASSIGN once, lets tighten ACCESS_ONCE to only
work on scalar types.
This variant was proposed by Alexei Starovoitov.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 include/linux/compiler.h | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index a1c81f8..5e186bf 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -447,12 +447,23 @@ static __always_inline void __assign_once_size(volatile void *p, void *res, int
  * to make the compiler aware of ordering is to put the two invocations of
  * ACCESS_ONCE() in different C statements.
  *
- * This macro does absolutely -nothing- to prevent the CPU from reordering,
- * merging, or refetching absolutely anything at any time.  Its main intended
- * use is to mediate communication between process-level code and irq/NMI
- * handlers, all running on the same CPU.
+ * ACCESS_ONCE will only work on scalar types. For union types, ACCESS_ONCE
+ * on a union member will work as long as the size of the member matches the
+ * size of the union and the size is smaller than word size.
+ *
+ * The major use cases of ACCESS_ONCE used to be (1) Mediating communication
+ * between process-level code and irq/NMI handlers, all running on the same CPU,
+ * and (2) Ensuring that the compiler does not  fold, spindle, or otherwise
+ * mutilate accesses that either do not require ordering or that interact
+ * with an explicit memory barrier or atomic instruction that provides the
+ * required ordering.
+ *
+ * If possible use READ_ONCE/ASSIGN_ONCE instead.
  */
-#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
+#define __ACCESS_ONCE(x) ({ \
+	 __maybe_unused typeof(x) __var = 0; \
+	(volatile typeof(x) *)&(x); })
+#define ACCESS_ONCE(x) (*__ACCESS_ONCE(x))
 
 /* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
 #ifdef CONFIG_KPROBES
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
