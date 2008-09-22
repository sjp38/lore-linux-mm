Date: Mon, 22 Sep 2008 20:13:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 10/13] memcg: page_cgroup look aside table
Message-Id: <20080922201355.2d4bd72b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Use per-cpu cache for fast access to page_cgroup.
This patch is for making fastpath faster.

Because page_cgroup is accessed when the page is allocated/freed,
we can assume several of continuous page_cgroup will be accessed soon.
(If not interleaved on NUMA...but in such case, alloc/free itself is slow.)

We cache some set of page_cgroup's base pointer on per-cpu area and
use it when we hit.

Changelong: v3 -> v4
 - rewrite noinline -> noinline_for_stack.
 - added cpu hotplug support.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/page_cgroup.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 70 insertions(+), 3 deletions(-)

Index: mmotm-2.6.27-rc6+/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/page_cgroup.c
+++ mmotm-2.6.27-rc6+/mm/page_cgroup.c
@@ -6,7 +6,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/hash.h>
 #include <linux/memory.h>
-
+#include <linux/cpu.h>
 
 
 struct pcg_hash_head {
@@ -44,15 +44,26 @@ static int pcg_hashmask  __read_mostly;
 #define PCG_HASHMASK		(pcg_hashmask)
 #define PCG_HASHSIZE		(1 << pcg_hashshift)
 
+#define PCG_CACHE_MAX_SLOT	(32)
+#define PCG_CACHE_MASK		(PCG_CACHE_MAX_SLOT - 1)
+struct percpu_page_cgroup_cache {
+	struct {
+		unsigned long	index;
+		struct page_cgroup *base;
+	} slots[PCG_CACHE_MAX_SLOT];
+};
+DEFINE_PER_CPU(struct percpu_page_cgroup_cache, pcg_cache);
+
 static int pcg_hashfun(unsigned long index)
 {
 	return hash_long(index, pcg_hashshift);
 }
 
-struct page_cgroup *lookup_page_cgroup(struct page *page)
+noinline_for_stack static struct page_cgroup *
+__lookup_page_cgroup(struct percpu_page_cgroup_cache *pcc,unsigned long pfn)
 {
-	unsigned long pfn = page_to_pfn(page);
 	unsigned long index = pfn >> ENTS_PER_CHUNK_SHIFT;
+	int s = index & PCG_CACHE_MASK;
 	struct pcg_hash *ent;
 	struct pcg_hash_head *head;
 	struct hlist_node *node;
@@ -65,6 +76,8 @@ struct page_cgroup *lookup_page_cgroup(s
 	hlist_for_each_entry(ent, node, &head->head, node) {
 		if (ent->index == index) {
 			pc = ent->map + pfn;
+			pcc->slots[s].index = ent->index;
+			pcc->slots[s].base = ent->map;
 			break;
 		}
 	}
@@ -123,6 +136,56 @@ static int __meminit alloc_page_cgroup(i
 	return 0;
 }
 
+struct page_cgroup *lookup_page_cgroup(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct percpu_page_cgroup_cache *pcc;
+	struct page_cgroup *ret;
+	unsigned long index = pfn >> ENTS_PER_CHUNK_SHIFT;
+	int hnum = index & PCG_CACHE_MASK;
+
+	pcc = &get_cpu_var(pcg_cache);
+	if (likely(pcc->slots[hnum].index == index))
+		ret = pcc->slots[hnum].base + pfn;
+	else
+		ret = __lookup_page_cgroup(pcc, pfn);
+	put_cpu_var(pcg_cache);
+	return ret;
+}
+
+
+
+void __cpuinit clear_page_cgroup_cache_pcg(int cpu)
+{
+	struct percpu_page_cgroup_cache *pcc;
+	int i;
+
+	pcc = &per_cpu(pcg_cache, cpu);
+	for (i = 0; i <  PCG_CACHE_MAX_SLOT; i++)
+		pcc->slots[i].index = -1;
+}
+
+static int __cpuinit cpu_page_cgroup_callback(struct notifier_block *nb,
+			unsigned long action, void *hcpu)
+{
+	int cpu = (long)hcpu;
+
+	switch(action){
+		case CPU_UP_PREPARE:
+			clear_page_cgroup_cache_pcg(cpu);
+			break;
+		default:
+			break;
+	}
+	return NOTIFY_OK;
+}
+
+struct notifier_block cpu_page_cgroup_nb = {
+	.notifier_call = cpu_page_cgroup_callback,
+};
+
+
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 int online_page_cgroup(unsigned long start_pfn,
@@ -227,6 +290,10 @@ void __init page_cgroup_init(void)
 		if (fail)
 			break;
 	}
+	cpu_page_cgroup_callback(&cpu_page_cgroup_nb,
+				(unsigned long)CPU_UP_PREPARE,
+				(void *)(long)smp_processor_id());
+	register_hotcpu_notifier(&cpu_page_cgroup_nb);
 
 	hotplug_memory_notifier(pcg_memory_callback, 0);
 nomem:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
