Date: Mon, 25 Feb 2008 12:19:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [8/7] vmalloc for large
 machines
Message-Id: <20080225121959.32977eb4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 64bit arch (and some others?) we have prenty of vmalloc area.

This patch uses vmalloc() for allocating continuous big area and
reduces entries in radix-tree.
Each entry covers 256Mbytes of area.

Note: because of vmallc, we don't allocate new entry in interrupt().


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/page_cgroup.h |    6 ++++++
 init/Kconfig                |    4 ++++
 mm/page_cgroup.c            |   29 ++++++++++++++++++++++++++++-
 3 files changed, 38 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc2/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/page_cgroup.h
+++ linux-2.6.25-rc2/include/linux/page_cgroup.h
@@ -34,7 +34,13 @@ struct page_cgroup_cache {
 
 DECLARE_PER_CPU(struct page_cgroup_cache, pcpu_page_cgroup_cache);
 
+#ifdef CONFIG_PAGE_CGROUP_VMALLOC
+#define PCGRUP_BASE_SHIFT	(28)	/* covers 256M per entry */
+#define PCGRP_SHIFT		(PCGROUP_PAGE_SHIFT - PCGRP_SHIFT)
+#else
 #define PCGRP_SHIFT     (8)
+#endif
+
 #define PCGRP_SIZE      (1 << PCGRP_SHIFT)
 
 /*
Index: linux-2.6.25-rc2/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc2/mm/page_cgroup.c
@@ -18,6 +18,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/err.h>
 #include <linux/interrupt.h>
+#include <linux/vmalloc.h>
 
 #define PCGRP_SHIFT	(8)
 #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
@@ -43,6 +44,29 @@ static void init_page_cgroup(struct page
 	}
 }
 
+#ifndef CONFIG_PAGE_CGROUP_VMALLOC
+static struct page_cgroup *alloc_init_page_cgroup(unsigned long pfn, int nid,
+				gfp_t mask)
+{
+	int size, order;
+	struct page_cgroup *base;
+
+	size = PCGRP_SIZE * sizeof(struct page_cgroup);
+	order = get_order(PAGE_ALIGN(size));
+	base = vmalloc_node(size, nid);
+
+	init_page_cgroup(base, pfn);
+	return base;
+}
+
+void free_page_cgroup(struct page_cgroup *pc)
+{
+	vfree(pc);
+}
+
+#else
+
+
 
 
 static struct page_cgroup *alloc_init_page_cgroup(unsigned long pfn, int nid,
@@ -68,7 +92,7 @@ void free_page_cgroup(struct page_cgroup
 	int order = get_order(PAGE_ALIGN(size));
 	__free_pages(virt_to_page(pc), order);
 }
-
+#endif
 
 
 static void save_result(struct page_cgroup  *base, unsigned long idx)
@@ -121,6 +145,9 @@ retry:
 	if (!gfpmask)
 		return NULL;
 
+	if (in_interrupt())
+		return NULL;
+
 	/* Very Slow Path. On demand allocation. */
 	gfpmask = gfpmask & ~(__GFP_HIGHMEM | __GFP_MOVABLE);
 
Index: linux-2.6.25-rc2/init/Kconfig
===================================================================
--- linux-2.6.25-rc2.orig/init/Kconfig
+++ linux-2.6.25-rc2/init/Kconfig
@@ -394,6 +394,10 @@ config CGROUP_MEM_CONT
 	  Provides a memory controller that manages both page cache and
 	  RSS memory.
 
+config CGROUP_PAGE_CGROUP_VMALLOC
+	def_bool y
+	depends on CGROUP_MEM_CONT && 64BIT
+
 config PROC_PID_CPUSET
 	bool "Include legacy /proc/<pid>/cpuset file"
 	depends on CPUSETS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
