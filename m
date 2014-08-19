Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 903F16B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 06:04:32 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so9844312pab.29
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 03:04:32 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id rj6si26079672pdb.194.2014.08.19.03.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 03:04:26 -0700 (PDT)
Message-ID: <53F320B7.30002@huawei.com>
Date: Tue, 19 Aug 2014 18:02:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mem-hotplug: introduce movablenodes boot option for memory
 hotplug debugging
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new boot option "movablenodes". This parameter
depends on movable_node, it is used for debugging memory hotplug.
Instead SRAT specifies which memory is hotpluggable.

e.g. movable_node movablenodes=1,2,4

It means nodes 1,2,4 will be set to movable nodes, the other nodes are
unmovable nodes. Usually movable nodes are parsed from SRAT table which
offered by BIOS.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 Documentation/kernel-parameters.txt |    5 ++++
 arch/x86/mm/srat.c                  |   36 +++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 5ae8608..e072ccf 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1949,6 +1949,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	movable_node	[KNL,X86] Boot-time switch to enable the effects
 			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
+	movablenodes=	[KNL,X86] This parameter depends on movable_node, it
+			is used for debugging memory hotplug. Instead SRAT
+			specifies which memory is hotpluggable.
+			e.g. movablenodes=1,2,4
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 66338a6..523e58b 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -157,6 +157,37 @@ static inline int save_add_info(void) {return 1;}
 static inline int save_add_info(void) {return 0;}
 #endif
 
+static nodemask_t movablenodes_mask;
+
+static void __init parse_movablenodes_one(char *p)
+{
+	int node;
+
+	get_option(&p, &node);
+	node_set(node, movablenodes_mask);
+}
+
+static int __init parse_movablenodes_opt(char *str)
+{
+	nodes_clear(movablenodes_mask);
+
+#ifdef CONFIG_MOVABLE_NODE
+	while (str) {
+		char *k = strchr(str, ',');
+
+		if (k)
+			*k++ = 0;
+		parse_movablenodes_one(str);
+		str = k;
+	}
+#else
+	pr_warn("movable_node option not supported\n");
+#endif
+
+	return 0;
+}
+early_param("movablenodes", parse_movablenodes_opt);
+
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
@@ -202,6 +233,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
 			(unsigned long long)start, (unsigned long long)end - 1);
 
+	if (node_isset(node, movablenodes_mask) &&
+		memblock_mark_hotplug(start, ma->length))
+		pr_warn("SRAT debug: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
+			(unsigned long long)start, (unsigned long long)end - 1);
+
 	return 0;
 out_err_bad_srat:
 	bad_srat();
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
