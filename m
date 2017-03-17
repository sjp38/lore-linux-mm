Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D28CB6B038D
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:25:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j127so77180272qke.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:25:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n29si3484982qtc.29.2017.03.17.11.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:25:19 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 1/2] mm/hmm: Fix build on 32 bit systems
Date: Fri, 17 Mar 2017 15:27:02 -0400
Message-Id: <1489778823-8694-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489778823-8694-1-git-send-email-jglisse@redhat.com>
References: <1489778823-8694-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

From: Balbir Singh <bsingharora@gmail.com>

Fix build breakage of hmm-v18 in the current mmotm by
making the migrate_vma() and related functions 64
bit only. The 32 bit variant will return -EINVAL.
There are other approaches to solving this problem,
but we can enable 32 bit systems as we need them.

This patch tries to limit the impact on 32 bit systems
by turning HMM off on them and not enabling the migrate
functions.

I've built this on ppc64/i386 and x86_64

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/migrate.h | 18 +++++++++++++++++-
 mm/Kconfig              |  4 +++-
 mm/migrate.c            |  3 ++-
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 01f4945..1888a70 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -124,7 +124,7 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 }
 #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
 
-
+#ifdef CONFIG_64BIT
 #define MIGRATE_PFN_VALID	(1UL << (BITS_PER_LONG_LONG - 1))
 #define MIGRATE_PFN_MIGRATE	(1UL << (BITS_PER_LONG_LONG - 2))
 #define MIGRATE_PFN_HUGE	(1UL << (BITS_PER_LONG_LONG - 3))
@@ -145,6 +145,7 @@ static inline unsigned long migrate_pfn_size(unsigned long mpfn)
 {
 	return mpfn & MIGRATE_PFN_HUGE ? PMD_SIZE : PAGE_SIZE;
 }
+#endif
 
 /*
  * struct migrate_vma_ops - migrate operation callback
@@ -194,6 +195,7 @@ struct migrate_vma_ops {
 				 void *private);
 };
 
+#ifdef CONFIG_64BIT
 int migrate_vma(const struct migrate_vma_ops *ops,
 		struct vm_area_struct *vma,
 		unsigned long mentries,
@@ -202,5 +204,19 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 		unsigned long *src,
 		unsigned long *dst,
 		void *private);
+#else
+static inline int migrate_vma(const struct migrate_vma_ops *ops,
+				struct vm_area_struct *vma,
+				unsigned long mentries,
+				unsigned long start,
+				unsigned long end,
+				unsigned long *src,
+				unsigned long *dst,
+				void *private)
+{
+	return -EINVAL;
+}
+#endif
+
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index a430d51..c13677f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -291,7 +291,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 
 config HMM
 	bool
-	depends on MMU
+	depends on MMU && 64BIT
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
@@ -307,6 +307,7 @@ config HMM_MIRROR
 	  Second side of the equation is replicating CPU page table content for
 	  range of virtual address. This require careful synchronization with
 	  CPU page table update.
+	depends on 64BIT
 
 config HMM_DEVMEM
 	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
@@ -314,6 +315,7 @@ config HMM_DEVMEM
 	help
 	  HMM devmem are helpers to leverage new ZONE_DEVICE feature. This is
 	  just to avoid device driver to replicate boiler plate code.
+	depends on 64BIT
 
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
diff --git a/mm/migrate.c b/mm/migrate.c
index b03158c..d8ed57a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2082,7 +2082,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 #endif /* CONFIG_NUMA */
 
-
+#ifdef CONFIG_64BIT
 struct migrate_vma {
 	struct vm_area_struct	*vma;
 	unsigned long		*dst;
@@ -2789,3 +2789,4 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	return 0;
 }
 EXPORT_SYMBOL(migrate_vma);
+#endif
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
