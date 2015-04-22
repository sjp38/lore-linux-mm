Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 558BA6B007B
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:08:22 -0400 (EDT)
Received: by widdi4 with SMTP id di4so185925049wid.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:08:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga17si9996023wic.36.2015.04.22.10.08.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 10:08:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/13] x86: mm: Enable deferred struct page initialisation on x86-64
Date: Wed, 22 Apr 2015 18:07:50 +0100
Message-Id: <1429722473-28118-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1429722473-28118-1-git-send-email-mgorman@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch adds the Kconfig logic to add deferred struct page initialisation
to x86-64 if NUMA is enabled. Other architectures may enable on a
case-by-case basis after auditing early_pfn_to_nid and testing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/kernel-parameters.txt |  6 ++++++
 arch/x86/Kconfig                    |  1 +
 include/linux/mmzone.h              | 14 ++++++++++++++
 init/main.c                         |  1 +
 mm/Kconfig                          | 28 ++++++++++++++++++++++++++++
 mm/page_alloc.c                     | 21 +++++++++++++++++++++
 6 files changed, 71 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index bfcb1a62a7b4..e7c6f7486214 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -807,6 +807,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	debug_objects	[KNL] Enable object debugging
 
+	defer_meminit=	[KNL,X86] Enable or disable deferred struct page init.
+			Large machine may take a long time to initialise
+			memory management structures. If enabled then a
+			subset of struct pages are initialised and kswapd
+			initialses the rest in parallel.
+
 	no_debug_objects
 			[KNL] Disable object debugging
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca55187..d15d74a052d5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -32,6 +32,7 @@ config X86
 	select HAVE_UNSTABLE_SCHED_CLOCK
 	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
+	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT if X86_64 && NUMA
 	select HAVE_IDE
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 821f5000dec9..8ac074db364f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -822,6 +822,20 @@ static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 #endif
 }
 
+
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+extern bool deferred_mem_init_enabled;
+static inline void setup_deferred_meminit(void)
+{
+	if (IS_ENABLED(CONFIG_DEFERRED_STRUCT_PAGE_INIT_DEFAULT_ENABLED))
+		deferred_mem_init_enabled = true;
+}
+#else
+static inline void setup_deferred_meminit(void)
+{
+}
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
 #else
diff --git a/init/main.c b/init/main.c
index 6f0f1c5ff8cc..f339d37a43e8 100644
--- a/init/main.c
+++ b/init/main.c
@@ -506,6 +506,7 @@ asmlinkage __visible void __init start_kernel(void)
 	boot_init_stack_canary();
 
 	cgroup_init_early();
+	setup_deferred_meminit();
 
 	local_irq_disable();
 	early_boot_irqs_disabled = true;
diff --git a/mm/Kconfig b/mm/Kconfig
index a03131b6ba8e..87a4535e0df4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -629,3 +629,31 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+# For architectures that support deferred memory initialisation
+config ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
+	bool
+
+config DEFERRED_STRUCT_PAGE_INIT
+	bool "Defer initialisation of struct pages to kswapd"
+	default n
+	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
+	depends on MEMORY_HOTPLUG
+	help
+	  Ordinarily all struct pages are initialised during early boot in a
+	  single thread. On very large machines this can take a considerable
+	  amount of time. If this option is set, large machines will bring up
+	  a subset of memmap at boot and then initialise the rest in parallel
+	  when kswapd starts. This has a potential performance impact on
+	  processes running early in the lifetime of the systemm until kswapd
+	  finishes the initialisation.
+
+config DEFERRED_STRUCT_PAGE_INIT_DEFAULT_ENABLED
+	bool "Automatically enable deferred struct page initialisation"
+	default y
+	depends on DEFERRED_STRUCT_PAGE_INIT
+	help
+	  If set, struct page initialisation will be deferred by default on
+	  large memory configurations. If DEFERRED_STRUCT_PAGE_INIT is set
+	  then it is a reasonable default to enable this too. User may need
+	  to disable this if allocating huge pages from the command line.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 839e4c73ce6d..6b2f6c21b70f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -236,6 +236,8 @@ EXPORT_SYMBOL(nr_online_nodes);
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+bool __meminitdata deferred_mem_init_enabled;
+
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
 	pgdat->first_deferred_pfn = ULONG_MAX;
@@ -285,6 +287,25 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 
 	return true;
 }
+
+static int __init setup_deferred_mem_init(char *str)
+{
+	if (!str)
+		return -1;
+
+	if (!strcmp(str, "enable")) {
+		deferred_mem_init_enabled = true;
+	} else if (!strcmp(str, "disable")) {
+		deferred_mem_init_enabled = false;
+	} else {
+		pr_warn("Unable to parse deferred_mem_init=\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+early_param("defer_meminit", setup_deferred_mem_init);
 #else
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
