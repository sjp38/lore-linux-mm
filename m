Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 23B416B007D
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:38 -0400 (EDT)
Received: by wgso17 with SMTP id o17so75482442wgs.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si16838944wjb.101.2015.04.13.03.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:22 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/14] mm: meminit: Control parallel memory initialisation from command line and config
Date: Mon, 13 Apr 2015 11:17:03 +0100
Message-Id: <1428920226-18147-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Patch adds a defer_meminit=[enable|disable] kernel command line
option. Default is controlled by Kconfig.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/kernel-parameters.txt |  8 ++++++++
 include/linux/mmzone.h              | 14 ++++++++++++++
 init/main.c                         |  1 +
 mm/Kconfig                          | 10 ++++++++++
 mm/page_alloc.c                     | 24 ++++++++++++++++++++++++
 5 files changed, 57 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index bfcb1a62a7b4..867338fc5941 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -807,6 +807,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	debug_objects	[KNL] Enable object debugging
 
+	defer_meminit=	[KNL,X86] Enable or disable deferred memory init.
+			Large machine may take a long time to initialise
+			memory management structures. If this is enabled
+			then memory initialisation is deferred to kswapd
+			and each memory node is initialised in parallel.
+			In very early boot, there will be less memory that
+			will rapidly increase while it is initialised.
+
 	no_debug_objects
 			[KNL] Disable object debugging
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 20c2da89a14d..1275f9a8cb42 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -823,6 +823,20 @@ static inline struct zone *lruvec_zone(struct lruvec *lruvec)
 #endif
 }
 
+
+#ifdef CONFIG_DEFERRED_MEM_INIT
+extern bool deferred_mem_init_enabled;
+static inline void setup_deferred_meminit(void)
+{
+	if (IS_ENABLED(CONFIG_DEFERRED_MEM_INIT_DEFAULT_ENABLED))
+		deferred_mem_init_enabled = true;
+}
+#else
+static inline void setup_deferred_meminit(void)
+{
+}
+#endif /* CONFIG_DEFERRED_MEM_INIT */
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
index 463c7005c3d9..0eb9b1349cc2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -648,3 +648,13 @@ config DEFERRED_MEM_INIT
 	  of the system it will still be busy initialising struct pages. This
 	  has a potential performance impact on processes until kswapd finishes
 	  the initialisation.
+
+config DEFERRED_MEM_INIT_DEFAULT_ENABLED
+	bool "Automatically enable deferred memory initialisation"
+	default y
+	depends on DEFERRED_MEM_INIT
+	help
+	  If set, memory initialisation will be deferred by default on large
+	  memory configurations. If DEFERRED_MEM_INIT is set then it is a
+	  reasonable default to enable this too. User will need to disable
+	  this if allocate huge pages from the command line.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 21bb818aa3c4..cb38583063cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -236,6 +236,8 @@ EXPORT_SYMBOL(nr_online_nodes);
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_MEM_INIT
+bool __meminitdata deferred_mem_init_enabled;
+
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
 	pgdat->first_deferred_pfn = ULONG_MAX;
@@ -268,6 +270,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 					unsigned long pfn,
 					unsigned long *nr_initialised)
 {
+	if (!deferred_mem_init_enabled)
+		return true;
+
 	if (pgdat->first_deferred_pfn != ULONG_MAX)
 		return false;
 
@@ -281,6 +286,25 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 
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
