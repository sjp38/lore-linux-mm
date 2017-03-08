Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFB856B03A9
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:26:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so44507757pga.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:26:38 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y70si2425223plh.168.2017.03.07.23.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:26:38 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v6 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
Date: Wed,  8 Mar 2017 15:26:05 +0800
Message-Id: <20170308072613.17634-2-ying.huang@intel.com>
In-Reply-To: <20170308072613.17634-1-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

In this patch, the size of the swap cluster is changed to that of the
THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
the THP swap support on x86_64.  Where one swap cluster will be used to
hold the contents of each THP swapped out.  And some information of the
swapped out THP (such as compound map count) will be recorded in the
swap_cluster_info data structure.

For other architectures which want THP swap support,
ARCH_USES_THP_SWAP_CLUSTER need to be selected in the Kconfig file for
the architecture.

In effect, this will enlarge swap cluster size by 2 times on x86_64.
Which may make it harder to find a free cluster when the swap space
becomes fragmented.  So that, this may reduce the continuous swap space
allocation and sequential write in theory.  The performance test in 0day
shows no regressions caused by this.

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 arch/x86/Kconfig |  1 +
 mm/Kconfig       | 13 +++++++++++++
 mm/swapfile.c    |  4 ++++
 3 files changed, 18 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 005df7c825f5..94908127c83e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -176,6 +176,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_USES_THP_SWAP_CLUSTER	if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb969dc..7b708e200c29 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -499,6 +499,19 @@ config FRONTSWAP
 
 	  If unsure, say Y to enable frontswap.
 
+config ARCH_USES_THP_SWAP_CLUSTER
+	bool
+	default n
+
+config THP_SWAP_CLUSTER
+	bool
+	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
+	default y
+	help
+	  Use one swap cluster to hold the contents of the THP
+	  (Transparent Huge Page) swapped out.  The size of the swap
+	  cluster will be same as that of THP.
+
 config CMA
 	bool "Contiguous Memory Allocator"
 	depends on HAVE_MEMBLOCK && MMU
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5e1e9bffa3e2..2396e1a350c8 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -199,7 +199,11 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 	}
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
+#else
 #define SWAPFILE_CLUSTER	256
+#endif
 #define LATENCY_LIMIT		256
 
 static inline void cluster_set_flag(struct swap_cluster_info *info,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
