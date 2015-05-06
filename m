Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CC3F56B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:50:49 -0400 (EDT)
Received: by widdi4 with SMTP id di4so211774336wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:50:49 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id i2si3375403wie.61.2015.05.06.10.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:47 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:46 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3911117D8066
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:29 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46HoiAo49348754
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:44 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46Hoga4027430
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:43 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 01/15] uaccess: count pagefault_disable() levels in pagefault_disabled
Date: Wed,  6 May 2015 19:50:25 +0200
Message-Id: <1430934639-2131-2-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Until now, pagefault_disable()/pagefault_enabled() used the preempt
count to track whether in an environment with pagefaults disabled (can
be queried via in_atomic()).

This patch introduces a separate counter in task_struct to count the
level of pagefault_disable() calls. We'll keep manipulating the preempt
count to retain compatibility to existing pagefault handlers.

It is now possible to verify whether in a pagefault_disable() envionment
by calling pagefault_disabled(). In contrast to in_atomic() it will not
be influenced by preempt_enable()/preempt_disable().

This patch is based on a patch from Ingo Molnar.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 include/linux/sched.h   |  1 +
 include/linux/uaccess.h | 36 +++++++++++++++++++++++++++++-------
 kernel/fork.c           |  3 +++
 3 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ede26ca..75778cb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1724,6 +1724,7 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+	int pagefault_disabled;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index ecd3319..23290cc 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -2,20 +2,36 @@
 #define __LINUX_UACCESS_H__
 
 #include <linux/preempt.h>
+#include <linux/sched.h>
 #include <asm/uaccess.h>
 
+static __always_inline void pagefault_disabled_inc(void)
+{
+	current->pagefault_disabled++;
+}
+
+static __always_inline void pagefault_disabled_dec(void)
+{
+	current->pagefault_disabled--;
+	WARN_ON(current->pagefault_disabled < 0);
+}
+
 /*
- * These routines enable/disable the pagefault handler in that
- * it will not take any locks and go straight to the fixup table.
+ * These routines enable/disable the pagefault handler. If disabled, it will
+ * not take any locks and go straight to the fixup table.
+ *
+ * We increase the preempt and the pagefault count, to be able to distinguish
+ * whether we run in simple atomic context or in a real pagefault_disable()
+ * context.
+ *
+ * For now, after pagefault_disabled() has been called, we run in atomic
+ * context. User access methods will not sleep.
  *
- * They have great resemblance to the preempt_disable/enable calls
- * and in fact they are identical; this is because currently there is
- * no other way to make the pagefault handlers do this. So we do
- * disable preemption but we don't necessarily care about that.
  */
 static inline void pagefault_disable(void)
 {
 	preempt_count_inc();
+	pagefault_disabled_inc();
 	/*
 	 * make sure to have issued the store before a pagefault
 	 * can hit.
@@ -25,18 +41,24 @@ static inline void pagefault_disable(void)
 
 static inline void pagefault_enable(void)
 {
-#ifndef CONFIG_PREEMPT
 	/*
 	 * make sure to issue those last loads/stores before enabling
 	 * the pagefault handler again.
 	 */
 	barrier();
+	pagefault_disabled_dec();
+#ifndef CONFIG_PREEMPT
 	preempt_count_dec();
 #else
 	preempt_enable();
 #endif
 }
 
+/*
+ * Is the pagefault handler disabled? If so, user access methods will not sleep.
+ */
+#define pagefault_disabled() (current->pagefault_disabled != 0)
+
 #ifndef ARCH_HAS_NOCACHE_UACCESS
 
 static inline unsigned long __copy_from_user_inatomic_nocache(void *to,
diff --git a/kernel/fork.c b/kernel/fork.c
index 03c1eaa..c344d27 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1396,6 +1396,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->hardirq_context = 0;
 	p->softirq_context = 0;
 #endif
+
+	p->pagefault_disabled = 0;
+
 #ifdef CONFIG_LOCKDEP
 	p->lockdep_depth = 0; /* no locks held yet */
 	p->curr_chain_key = 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
