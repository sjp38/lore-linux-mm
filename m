Date: Wed, 5 Mar 2008 21:01:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Preview] [PATCH] radix tree based page cgroup [6/6] boost by
 per-cpu
Message-Id: <20080305210145.7a9b6968.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080305205743.79856aa4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
	<20080305205743.79856aa4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "taka@valinux.co.jp" <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds per-cpu look up cache for get_page_cgroup().
Works well when nearby pages are accessed continuously.

TODO: add flush routine.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/page_cgroup.h |   37 +++++++++++++++++++++++++++++++++++--
 mm/page_cgroup.c            |   23 ++++++++++++++++++-----
 2 files changed, 53 insertions(+), 7 deletions(-)

Index: linux-2.6.25-rc4/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc4.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc4/mm/page_cgroup.c
@@ -17,11 +17,10 @@
 #include <linux/memcontrol.h>
 #include <linux/page_cgroup.h>
 #include <linux/err.h>
+#include <linux/interrupt.h>
 
 
-
-#define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
-#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
+DEFINE_PER_CPU(struct page_cgroup_cache, pcpu_page_cgroup_cache);
 
 struct page_cgroup_head {
 	struct page_cgroup pc[PCGRP_SIZE];
@@ -71,6 +70,19 @@ void free_page_cgroup(struct page_cgroup
 }
 
 
+static void save_result(struct page_cgroup  *base, unsigned long idx)
+{
+	int hash = idx & (PAGE_CGROUP_NR_CACHE - 1);
+	struct page_cgroup_cache *pcp;
+	/* look up is done under preempt_disable(). then, don't call
+	   this under interrupt(). */
+	preempt_disable();
+	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
+	pcp->ents[hash].idx = idx;
+	pcp->ents[hash].base = base;
+	preempt_enable();
+}
+
 /*
  * Look up page_cgroup struct for struct page (page's pfn)
  * if (allocate == true), look up and allocate new one if necessary.
@@ -78,7 +90,7 @@ void free_page_cgroup(struct page_cgroup
  */
 
 struct page_cgroup *
-get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
+__get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
 {
 	struct page_cgroup_root *root;
 	struct page_cgroup_head *head;
@@ -107,8 +119,12 @@ retry:
 	head = radix_tree_lookup(&root->root_node, idx);
 	rcu_read_unlock();
 
-	if (likely(head))
+	if (likely(head)) {
+		if (!in_interrupt())
+			save_result(&head->pc[0], idx);
 		return &head->pc[pfn - base_pfn];
+	}
+
 	if (allocate == false)
 		return NULL;
 
Index: linux-2.6.25-rc4/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.25-rc4.orig/include/linux/page_cgroup.h
+++ linux-2.6.25-rc4/include/linux/page_cgroup.h
@@ -24,6 +24,20 @@ struct page_cgroup {
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
 
+/* per cpu cashing for fast access */
+#define PAGE_CGROUP_NR_CACHE	(0x8)
+struct page_cgroup_cache {
+	struct {
+		unsigned long idx;
+		struct page_cgroup *base;
+	} ents[PAGE_CGROUP_NR_CACHE];
+};
+
+DECLARE_PER_CPU(struct page_cgroup_cache, pcpu_page_cgroup_cache);
+
+#define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
+#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
+
 /*
  * Lookup and return page_cgroup struct.
  * returns NULL when
@@ -32,9 +46,28 @@ struct page_cgroup {
  * return -ENOMEM if cannot allocate memory.
  * If allocate==false, gfpmask will be ignored as a result.
  */
-
 struct page_cgroup *
-get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate);
+__get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate);
+
+static inline struct page_cgroup *
+get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct page_cgroup_cache *pcp;
+	struct page_cgroup *ret;
+	unsigned long idx = pfn >> PCGRP_SHIFT;
+	int hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
+
+	preempt_disable();
+	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
+	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
+		ret = pcp->ents[hnum].base + (pfn - (idx << PCGRP_SHIFT));
+	else
+		ret = NULL;
+	preempt_enable();
+
+	return (ret)? ret : __get_page_cgroup(page, gfpmask, allocate);
+}
 
 #else
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
