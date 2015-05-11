Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2746B0085
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:21 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so31494348wic.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:20 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id mb19si405766wic.69.2015.05.11.08.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:53:01 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:53:00 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 661CD2190066
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:52:38 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqu7E61276340
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:56 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqtpG015440
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:56 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 15/15] uaccess: decouple preemption from the pagefault logic
Date: Mon, 11 May 2015 17:52:20 +0200
Message-Id: <1431359540-32227-16-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

As the fault handlers now all rely on the pagefault_disabled() checks
and implicit preempt_disable() calls by pagefault_disable() have been
made explicit, we can completely rely on the pagefault_disableD counter.

So let's no longer touch the preempt count when disabling/enabling
pagefaults. After a call to pagefault_disable(), pagefault_disabled()
will return true, but in_atomic() won't.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 include/linux/uaccess.h | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index 90786d2..ae572c1 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -1,7 +1,6 @@
 #ifndef __LINUX_UACCESS_H__
 #define __LINUX_UACCESS_H__
 
-#include <linux/preempt.h>
 #include <linux/sched.h>
 #include <asm/uaccess.h>
 
@@ -20,17 +19,11 @@ static __always_inline void pagefault_disabled_dec(void)
  * These routines enable/disable the pagefault handler. If disabled, it will
  * not take any locks and go straight to the fixup table.
  *
- * We increase the preempt and the pagefault count, to be able to distinguish
- * whether we run in simple atomic context or in a real pagefault_disable()
- * context.
- *
- * For now, after pagefault_disabled() has been called, we run in atomic
- * context. User access methods will not sleep.
- *
+ * User access methods will not sleep when called from a pagefault_disabled()
+ * environment.
  */
 static inline void pagefault_disable(void)
 {
-	preempt_count_inc();
 	pagefault_disabled_inc();
 	/*
 	 * make sure to have issued the store before a pagefault
@@ -47,11 +40,6 @@ static inline void pagefault_enable(void)
 	 */
 	barrier();
 	pagefault_disabled_dec();
-#ifndef CONFIG_PREEMPT
-	preempt_count_dec();
-#else
-	preempt_enable();
-#endif
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
