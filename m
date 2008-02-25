Date: Mon, 25 Feb 2008 12:18:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [7/7] per cpu fast
 lookup
Message-Id: <20080225121849.191ac900.kamezawa.hiroyu@jp.fujitsu.com>
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

Add per_cpu cache entry for avoiding taking rwlock in page_cgroup lookup.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/page_cgroup.h |   33 ++++++++++++++++++++++++++++++++-
 mm/page_cgroup.c            |   29 ++++++++++++++++++++++-------
 2 files changed, 54 insertions(+), 8 deletions(-)

Index: linux-2.6.25-rc2/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc2/mm/page_cgroup.c
@@ -17,6 +17,7 @@
 #include <linux/memcontrol.h>
 #include <linux/page_cgroup.h>
 #include <linux/err.h>
+#include <linux/interrupt.h>
 
 #define PCGRP_SHIFT	(8)
 #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
@@ -27,6 +28,7 @@ struct page_cgroup_root {
 };
 
 static struct page_cgroup_root *root_dir[MAX_NUMNODES];
+DEFINE_PER_CPU(struct page_cgroup_cache, pcpu_page_cgroup_cache);
 
 static void init_page_cgroup(struct page_cgroup *base, unsigned long pfn)
 {
@@ -68,13 +70,25 @@ void free_page_cgroup(struct page_cgroup
 }
 
 
+
+static void save_result(struct page_cgroup  *base, unsigned long idx)
+{
+	int hash = idx & (PAGE_CGROUP_NR_CACHE - 1);
+	struct page_cgroup_cache *pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
+	preempt_disable();
+	pcp->ents[hash].idx = idx;
+	pcp->ents[hash].base = base;
+	preempt_enable();
+}
+
+
 /*
  * Look up page_cgroup struct for struct page (page's pfn)
  * if (gfp_mask != 0), look up and allocate new one if necessary.
  * if (gfp_mask == 0), look up and return NULL if it cannot be found.
  */
 
-struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask)
+struct page_cgroup *__get_page_cgroup(struct page *page, gfp_t gfpmask)
 {
 	struct page_cgroup_root *root;
 	struct page_cgroup *pc, *base_addr;
@@ -96,8 +110,14 @@ retry:
 	pc = radix_tree_lookup(&root->root_node, idx);
 	rcu_read_unlock();
 
+	if (pc) {
+		if (!in_interrupt())
+			save_result(pc, idx);
+	}
+
 	if (likely(pc))
 		return pc + (pfn - base_pfn);
+
 	if (!gfpmask)
 		return NULL;
 
Index: linux-2.6.25-rc2/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/page_cgroup.h
+++ linux-2.6.25-rc2/include/linux/page_cgroup.h
@@ -24,6 +24,19 @@ struct page_cgroup {
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
 
+#define PAGE_CGROUP_NR_CACHE        (0x8)
+struct page_cgroup_cache {
+	struct	{
+		unsigned long idx;
+		struct page_cgroup *base;
+	} ents[PAGE_CGROUP_NR_CACHE];
+};
+
+DECLARE_PER_CPU(struct page_cgroup_cache, pcpu_page_cgroup_cache);
+
+#define PCGRP_SHIFT     (8)
+#define PCGRP_SIZE      (1 << PCGRP_SHIFT)
+
 /*
  * Lookup and return page_cgroup struct.
  * returns NULL when
@@ -32,7 +45,26 @@ struct page_cgroup {
  * return -ENOMEM if cannot allocate memory.
  */
 
-struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask);
+struct page_cgroup *__get_page_cgroup(struct page *page, gfp_t gfpmask);
+
+static inline struct page_cgroup *
+get_page_cgroup(struct page *page, gfp_t gfpmask)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct page_cgroup_cache *pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
+	struct page_cgroup *ret;
+	unsigned long idx = pfn >> PCGRP_SHIFT;
+	int hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
+
+	preempt_disable();
+	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
+		ret = pcp->ents[hnum].base + (pfn - (idx << PCGRP_SHIFT));
+	else
+		ret = NULL;
+	preempt_enable();
+
+	return (ret)? ret : __get_page_cgroup(page, gfpmask);
+}
 
 #else
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
