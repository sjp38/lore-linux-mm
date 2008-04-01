Date: Tue, 1 Apr 2008 17:31:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 2/6] boost by per_cpu
Message-Id: <20080401173108.93f7400c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

This patch adds per-cpu look up cache for get_page_cgroup().
Works well when nearby pages are accessed continuously.

Changeloc v2 -> v3:
  * added prefetch.

Changelog v1 -> v2:
  * avoid inlining by adding function to page_cgroup.h
  * set to be cacheline-aligned.
  * added hashfunc() macro.
  * changed what should be remembered in cache.
    This version rememvers base address, not "head".


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/page_cgroup.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

Index: mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/page_cgroup.c
+++ mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/radix-tree.h>
 #include <linux/memcontrol.h>
+#include <linux/interrupt.h>
 #include <linux/err.h>
 
 static int page_cgroup_order __read_mostly;
@@ -80,6 +81,49 @@ init_page_cgroup_head(struct page_cgroup
 	}
 }
 
+#define PCGRP_CACHE_SIZE	(0x10)
+#define PCGRP_CACHE_MASK	(PCGRP_CACHE_SIZE - 1)
+struct page_cgroup_cache {
+	struct {
+		unsigned long idx;
+		struct page_cgroup *base;
+	} ents[PCGRP_CACHE_SIZE];
+};
+DEFINE_PER_CPU(struct page_cgroup_cache, pcpu_pcgroup_cache) ____cacheline_aligned;
+
+#define hashfunc(idx)	((idx) & PCGRP_CACHE_MASK)
+
+static struct page_cgroup *pcp_lookup(unsigned long pfn, unsigned long idx)
+{
+	struct page_cgroup *ret = NULL;
+	struct page_cgroup_cache *pcp;
+	int hnum = hashfunc(idx);
+
+	pcp = &get_cpu_var(pcpu_pcgroup_cache);
+	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base) {
+		ret = pcp->ents[hnum].base + pfn;
+		prefetchw(ret);
+	}
+	put_cpu_var(pcpu_pcgroup_cache);
+	return ret;
+}
+
+static void cache_result(unsigned long idx, struct page_cgroup_head *head)
+{
+	struct page_cgroup_cache *pcp;
+	int hnum = hashfunc(idx);
+
+	/*
+	 * Because look up is done under preempt_disable, don't modifies
+	 * an entry in interrupt.
+	 */
+	if (in_interrupt())
+		return;
+	pcp = &get_cpu_var(pcpu_pcgroup_cache);
+	pcp->ents[hnum].idx = idx;
+	pcp->ents[hnum].base = &head->pc[0] - (idx << PCGRP_SHIFT);
+	put_cpu_var(pcpu_pcgroup_cache);
+}
 
 struct kmem_cache *page_cgroup_cachep;
 
@@ -126,6 +170,11 @@ struct page_cgroup *get_page_cgroup(stru
 	struct page_cgroup *ret = NULL;
 	unsigned long pfn, idx;
 
+	pfn = page_to_pfn(page);
+	idx = pfn >> PCGRP_SHIFT;
+	ret = pcp_lookup(pfn, idx);
+	if (ret)
+		return ret;
 	/*
 	 * NULL can be returned before initialization
 	 */
@@ -133,8 +182,6 @@ struct page_cgroup *get_page_cgroup(stru
 	if (unlikely(!root))
 		return ret;
 
-	pfn = page_to_pfn(page);
-	idx = pfn >> PCGRP_SHIFT;
 	/*
 	 * We don't need lock here because no one deletes this head.
 	 * (Freeing routtine will be added later.)
@@ -143,8 +190,10 @@ struct page_cgroup *get_page_cgroup(stru
 	head = radix_tree_lookup(&root->root_node, idx);
 	rcu_read_unlock();
 
-	if (likely(head))
+	if (likely(head)) {
+		cache_result(idx, head);
 		ret = &head->pc[pfn & PCGRP_MASK];
+	}
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
