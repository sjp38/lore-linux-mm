Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D5DE66B0075
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 05:24:04 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC V3 PATCH 19/25] numa: add CONFIG_MOVABLE_NODE for movable-dedicated node
Date: Mon, 6 Aug 2012 17:23:13 +0800
Message-Id: <1344244999-5081-20-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
 <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Lameter <cl@linux.com>, Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

All are prepared, we can actually introduce N_MEMORY.
add CONFIG_MOVABLE_NODE make we can use it for movable-dedicated node

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 drivers/base/node.c      |    6 ++++++
 include/linux/nodemask.h |    4 ++++
 mm/Kconfig               |    8 ++++++++
 mm/page_alloc.c          |    3 +++
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 4c3aa7c..653b5e2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -620,6 +620,9 @@ static struct node_attr node_state_attr[] = {
 #ifdef CONFIG_HIGHMEM
 	[N_HIGH_MEMORY] = _NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
 #endif
+#ifdef CONFIG_MOVABLE_NODE
+	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
+#endif
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
 };
 
@@ -630,6 +633,9 @@ static struct attribute *node_state_attrs[] = {
 #ifdef CONFIG_HIGHMEM
 	&node_state_attr[N_HIGH_MEMORY].attr.attr,
 #endif
+#ifdef CONFIG_MOVABLE_NODE
+	&node_state_attr[N_MEMORY].attr.attr,
+#endif
 	&node_state_attr[N_CPU].attr.attr,
 	NULL
 };
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index c6ebdc9..4e2cbfa 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -380,7 +380,11 @@ enum node_states {
 #else
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
+#ifdef CONFIG_MOVABLE_NODE
+	N_MEMORY,		/* The node has memory(regular, high, movable) */
+#else
 	N_MEMORY = N_HIGH_MEMORY,
+#endif
 	N_CPU,		/* The node has one or more cpus */
 	NR_NODE_STATES
 };
diff --git a/mm/Kconfig b/mm/Kconfig
index 82fed4e..4371c65 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -140,6 +140,14 @@ config ARCH_DISCARD_MEMBLOCK
 config NO_BOOTMEM
 	boolean
 
+config MOVABLE_NODE
+	boolean "Enable to assign a node has only movable memory"
+	depends on HAVE_MEMBLOCK
+	depends on NO_BOOTMEM
+	depends on X86_64
+	depends on NUMA
+	default y
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index edffc35..03ad63d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -91,6 +91,9 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
 #ifdef CONFIG_HIGHMEM
 	[N_HIGH_MEMORY] = { { [0] = 1UL } },
 #endif
+#ifdef CONFIG_MOVABLE_NODE
+	[N_MEMORY] = { { [0] = 1UL } },
+#endif
 	[N_CPU] = { { [0] = 1UL } },
 #endif	/* NUMA */
 };
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
