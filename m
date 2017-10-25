Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DABB46B0261
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:56:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so20522385pfr.3
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:56:33 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z13si1669087pfe.416.2017.10.25.01.56.32
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 01:56:32 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 6/9] locking/lockdep: Introduce CONFIG_BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK
Date: Wed, 25 Oct 2017 17:56:02 +0900
Message-Id: <1508921765-15396-7-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

The boot parameter, crossrelease_fullstack, was introduced to control
whether to enable unwind in cross-release or not. Add a Kconfig doing
the same thing.

Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c |  4 ++++
 lib/Kconfig.debug        | 15 +++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 160b5d6..db933d0 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -76,7 +76,11 @@
 #define lock_stat 0
 #endif
 
+#ifdef CONFIG_BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK
+static int crossrelease_fullstack = 1;
+#else
 static int crossrelease_fullstack;
+#endif
 static int __init allow_crossrelease_fullstack(char *str)
 {
 	crossrelease_fullstack = 1;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4bef610..e4b54a5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1225,6 +1225,21 @@ config LOCKDEP_COMPLETIONS
 	 A deadlock caused by wait_for_completion() and complete() can be
 	 detected by lockdep using crossrelease feature.
 
+config BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK
+	bool "Enable the boot parameter, crossrelease_fullstack"
+	depends on LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 The lockdep "cross-release" feature needs to record stack traces
+	 (of calling functions) for all acquisitions, for eventual later
+	 use during analysis. By default only a single caller is recorded,
+	 because the unwind operation can be very expensive with deeper
+	 stack chains.
+
+	 However a boot parameter, crossrelease_fullstack, was
+	 introduced since sometimes deeper traces are required for full
+	 analysis. This option turns on the boot parameter.
+
 config DEBUG_LOCKDEP
 	bool "Lock dependency engine debugging"
 	depends on DEBUG_KERNEL && LOCKDEP
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
