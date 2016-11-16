Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFBBE6B0314
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 22:12:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so129640751pgd.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:12:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 23si29455179pgb.38.2016.11.15.19.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 19:12:22 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v5 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
Date: Wed, 16 Nov 2016 11:10:49 +0800
Message-Id: <20161116031057.12977-2-ying.huang@intel.com>
In-Reply-To: <20161116031057.12977-1-ying.huang@intel.com>
References: <20161116031057.12977-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

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
index 8b93519..59dc488 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -165,6 +165,7 @@ config X86
 	select HAVE_STACK_VALIDATION		if X86_64
 	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
 	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
+	select ARCH_USES_THP_SWAP_CLUSTER	if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/mm/Kconfig b/mm/Kconfig
index 86e3e0e..5a63c87 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -503,6 +503,19 @@ config FRONTSWAP
 
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
index f304389..34888e5b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -196,7 +196,11 @@ static void discard_swap_cluster(struct swap_info_struct *si,
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
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
