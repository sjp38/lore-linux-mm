Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD3E86B0260
	for <linux-mm@kvack.org>; Sun, 21 Aug 2016 23:04:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so173666761pfx.0
        for <linux-mm@kvack.org>; Sun, 21 Aug 2016 20:04:23 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id bg10si23342414pab.12.2016.08.21.20.04.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Aug 2016 20:04:23 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH v2 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
Date: Mon, 22 Aug 2016 10:56:42 +0800
Message-ID: <1471834603-27053-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Avoid making ifdef get pretty unwieldy if many ARCHs support gigantic page.
No functional change with this patch.

Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>
---
 arch/s390/Kconfig | 1 +
 arch/x86/Kconfig  | 1 +
 fs/Kconfig        | 4 ++++
 mm/hugetlb.c      | 2 +-
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index e751fe2..a8c8fa3 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -72,6 +72,7 @@ config S390
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c580d8c..5cf959c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -29,6 +29,7 @@ config X86
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_GIGANTIC_PAGE		if X86_64
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_PMEM_API		if X86_64
 	select ARCH_HAS_MMIO_FLUSH
diff --git a/fs/Kconfig b/fs/Kconfig
index 2bc7ad7..b77ad0f 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -199,6 +199,10 @@ config HUGETLBFS
 config HUGETLB_PAGE
 	def_bool HUGETLBFS
 
+config ARCH_HAS_GIGANTIC_PAGE
+	depends on HUGETLB_PAGE
+	bool
+
 source "fs/configfs/Kconfig"
 source "fs/efivarfs/Kconfig"
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..8488dcc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1022,7 +1022,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
+#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) && \
 	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
 	defined(CONFIG_CMA))
 static void destroy_compound_gigantic_page(struct page *page,
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
