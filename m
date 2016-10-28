Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 885806B027B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:56:26 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id rf5so37188049pab.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 22:56:26 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ub3si9907965pab.52.2016.10.27.22.56.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 22:56:25 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v4 RESEND 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
Date: Fri, 28 Oct 2016 13:56:00 +0800
Message-Id: <20161028055608.1736-2-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-1-ying.huang@intel.com>
References: <20161028055608.1736-1-ying.huang@intel.com>
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
index bada636..a8446bc 100644
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
index be0ee11..2da8128 100644
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
index 2210de2..18e247b 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
