Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 422526B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 07:29:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so132094085lfe.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:29:56 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m6si13059581wjc.227.2016.08.04.04.29.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 04:29:55 -0700 (PDT)
Message-ID: <57A325CA.9050707@huawei.com>
Date: Thu, 4 Aug 2016 19:23:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mem-hotplug: introduce movablenode option
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new boot option movablenode.

To support memory hotplug, boot option "movable_node" is needed. And to
support debug memory hotplug, boot option "movable_node" and "movablenode"
are both needed.

e.g. movable_node movablenode=1,2,4

It means node 1,2,4 will be set to movable nodes, the other nodes are
unmovable nodes. Usually movable nodes are parsed from SRAT table which
offered by BIOS, so this boot option is used for debug.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 Documentation/kernel-parameters.txt |  4 ++++
 arch/x86/mm/srat.c                  | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 82b42c9..f8726f8 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2319,6 +2319,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	movable_node	[KNL,X86] Boot-time switch to enable the effects
 			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
+	movablenode=	[KNL,X86] Boot-time switch to set which node is
+			movable node.
+			Format: <movable nid>,...,<movable nid>
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index b5f8218..c4cd81a 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -157,6 +157,38 @@ static inline int save_add_info(void) {return 1;}
 static inline int save_add_info(void) {return 0;}
 #endif
 
+static nodemask_t movablenode_mask;
+
+static void __init parse_movablenode_one(char *p)
+{
+	int node;
+
+	get_option(&p, &node);
+	node_set(node, movablenode_mask);
+}
+
+/*
+ * movablenode=<movable nid>,...,<movable nid> sets which node is movable
+ * node.
+ */
+static int __init parse_movablenode_opt(char *str)
+{
+#ifdef CONFIG_MOVABLE_NODE
+	while (str) {
+		char *k = strchr(str, ',');
+
+		if (k)
+			*k++ = 0;
+		parse_movablenode_one(str);
+		str = k;
+	}
+#else
+	pr_warn("movable_node option not supported\n");
+#endif
+	return 0;
+}
+early_param("movablenode", parse_movablenode_opt);
+
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
@@ -205,6 +237,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
 
+	if (node_isset(node, movablenode_mask) && memblock_mark_hotplug(start, ma->length))
+		pr_warn("SRAT debug: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
+			(unsigned long long)start, (unsigned long long)end - 1);
+
 	return 0;
 out_err_bad_srat:
 	bad_srat();
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
