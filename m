Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D31A96B025E
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:30:50 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l187so51013471oia.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:30:50 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 10si12948114otq.214.2016.09.30.02.30.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 02:30:42 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v4 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
Date: Fri, 30 Sep 2016 17:26:08 +0800
Message-ID: <1475227569-63446-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com>
References: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Avoid making ifdef get pretty unwieldy if many ARCHs support gigantic page.
No functional change with this patch.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@suse.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/s390/Kconfig | 1 +
 arch/x86/Kconfig  | 1 +
 fs/Kconfig        | 3 +++
 mm/hugetlb.c      | 2 +-
 4 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index c109f07..74a9e45 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -71,6 +71,7 @@ config S390
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2a1f0ce..aa0b26a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -28,6 +28,7 @@ config X86
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_GIGANTIC_PAGE		if X86_64
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_PMEM_API		if X86_64
 	select ARCH_HAS_MMIO_FLUSH
diff --git a/fs/Kconfig b/fs/Kconfig
index 2bc7ad7..b938205 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -199,6 +199,9 @@ config HUGETLBFS
 config HUGETLB_PAGE
 	def_bool HUGETLBFS
 
+config ARCH_HAS_GIGANTIC_PAGE
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
