Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D781B6B003B
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:08:41 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so3241903pdj.26
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:08:41 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dv5si8444918pbb.253.2014.01.16.16.08.40
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 16:08:40 -0800 (PST)
Subject: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1389890175.git.tim.c.chen@linux.intel.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jan 2014 16:08:36 -0800
Message-ID: <1389917316.3138.16.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

This patch adds Kconfig entries to allow architectures to hook into the
MCS lock/unlock functions in the contended case.

From: Will Deacon <will.deacon@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/Kconfig                 | 3 +++
 include/linux/mcs_spinlock.h | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 80bbb8c..8a2a056 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -303,6 +303,9 @@ config HAVE_CMPXCHG_LOCAL
 config HAVE_CMPXCHG_DOUBLE
 	bool
 
+config HAVE_ARCH_MCS_LOCK
+	bool
+
 config ARCH_WANT_IPC_PARSE_VERSION
 	bool
 
diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index d54bb23..d2c02ad 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -12,6 +12,14 @@
 #ifndef __LINUX_MCS_SPINLOCK_H
 #define __LINUX_MCS_SPINLOCK_H
 
+/*
+ * An architecture may provide its own lock/unlock functions for the
+ * contended case.
+ */
+#ifdef CONFIG_HAVE_ARCH_MCS_LOCK
+#include <asm/mcs_spinlock.h>
+#endif
+
 struct mcs_spinlock {
 	struct mcs_spinlock *next;
 	int locked; /* 1 if lock acquired */
-- 
1.7.11.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
