Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A37498D0006
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:06 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:06 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 15/33] sched, numa, mm, arch: Add variable locality exception
Date: Thu, 22 Nov 2012 23:49:36 +0100
Message-Id: <1353624594-1118-16-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Some architectures (ab)use NUMA to represent different memory
regions all cpu-local but of different latencies, such as SuperH.

The naming comes from Mel Gorman.

Named-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/sh/mm/Kconfig | 1 +
 init/Kconfig       | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index cb8f992..5d2a4df 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -111,6 +111,7 @@ config VSYSCALL
 config NUMA
 	bool "Non Uniform Memory Access (NUMA) Support"
 	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
+	select ARCH_WANTS_NUMA_VARIABLE_LOCALITY
 	default n
 	help
 	  Some SH systems have many various memories scattered around
diff --git a/init/Kconfig b/init/Kconfig
index f36c83d..b8a4a58 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -718,6 +718,13 @@ config ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE
 	depends on ARCH_USES_NUMA_GENERIC_PGPROT
 	depends on TRANSPARENT_HUGEPAGE
 
+#
+# For architectures that (ab)use NUMA to represent different memory regions
+# all cpu-local but of different latencies, such as SuperH.
+#
+config ARCH_WANTS_NUMA_VARIABLE_LOCALITY
+	bool
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
