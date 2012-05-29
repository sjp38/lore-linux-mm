Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id A10F66B005C
	for <linux-mm@kvack.org>; Mon, 28 May 2012 22:56:26 -0400 (EDT)
From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Tue, 29 May 2012 10:56:54 +0800
Message-Id: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Gao feng <gaofeng@cn.fujitsu.com>

cgroup and namespaces are used for creating containers but some of
information is not isolated/virtualized. This patch is for isolating /proc/meminfo
information per container, which uses memory cgroup. By this, top,free
and other tools under container can work as expected(show container's
usage) without changes.

This patch is a trial to show memcg's info in /proc/meminfo if 'current'
is under a memcg other than root.

we show /proc/meminfo base on container's memory cgroup.
because there are lots of info can't be provide by memcg, and
the cmds such as top, free just use some entries of /proc/meminfo,
we replace those entries by memory cgroup.

if container has no memcg, we will show host's /proc/meminfo
as before.

there is no idea how to deal with Buffers,I just set it zero,
It's strange if Buffers bigger than MemTotal.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 fs/proc/meminfo.c          |   11 +++++---
 include/linux/memcontrol.h |   15 +++++++++++
 mm/memcontrol.c            |   56 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 78 insertions(+), 4 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 80e4645..29a1fcd 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -13,6 +13,7 @@
 #include <linux/atomic.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
@@ -27,7 +28,6 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	struct vmalloc_info vmi;
 	long cached;
 	unsigned long pages[NR_LRU_LISTS];
-	int lru;
 
 /*
  * display in kilobytes.
@@ -39,16 +39,19 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
+	memcg_meminfo(&i);
 	cached = global_page_state(NR_FILE_PAGES) -
 			total_swapcache_pages - i.bufferram;
+	/*
+	 * If 'current' is in root memory cgroup, returns global status.
+	 * If not, returns the status of memcg under which current runs.
+	 */
+	sys_page_state(pages, &cached);
 	if (cached < 0)
 		cached = 0;
 
 	get_vmalloc_info(&vmi);
 
-	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
-		pages[lru] = global_page_state(NR_LRU_BASE + lru);
-
 	/*
 	 * Tagged format, for easy grepping and expansion.
 	 */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0316197..6220764 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -21,6 +21,7 @@
 #define _LINUX_MEMCONTROL_H
 #include <linux/cgroup.h>
 #include <linux/vm_event_item.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -116,6 +117,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
+extern void memcg_meminfo(struct sysinfo *si);
+extern void sys_page_state(unsigned long *page, long *cached);
+
 /*
  * For memory reclaim.
  */
@@ -323,6 +327,17 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
+static inline void memcg_meminfo(struct sysinfo *si)
+{
+}
+
+static inline void sys_page_state(unsigned long *pages, long *cached)
+{
+	int lru;
+	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
+		pages[lru] = global_page_state(NR_LRU_BASE + lru);
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f142ea9..c25e160 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -52,6 +52,7 @@
 #include "internal.h"
 #include <net/sock.h>
 #include <net/tcp_memcontrol.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/uaccess.h>
 
@@ -4345,6 +4346,61 @@ mem_cgroup_get_total_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 		mem_cgroup_get_local_stat(iter, s);
 }
 
+void memcg_meminfo(struct sysinfo *val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_task(current);
+	__kernel_ulong_t totalram, totalswap;
+	if (current->nsproxy->pid_ns == &init_pid_ns ||
+	    memcg == NULL || mem_cgroup_is_root(memcg))
+		return;
+
+	totalram = res_counter_read_u64(&memcg->res,
+					RES_LIMIT) >> PAGE_SHIFT;
+	if (totalram < val->totalram) {
+		__kernel_ulong_t usageram;
+		usageram = res_counter_read_u64(&memcg->res,
+						RES_USAGE) >> PAGE_SHIFT;
+		val->totalram = totalram;
+		val->freeram = totalram - usageram;
+		val->bufferram = 0;
+		val->totalhigh = 0;
+		val->freehigh = 0;
+	} else
+		return;
+
+	totalswap = res_counter_read_u64(&memcg->memsw,
+					 RES_LIMIT) >> PAGE_SHIFT;
+	if (totalswap < val->totalswap) {
+		__kernel_ulong_t usageswap;
+		usageswap = res_counter_read_u64(&memcg->memsw,
+						 RES_USAGE) >> PAGE_SHIFT;
+		val->totalswap = totalswap - val->totalram;
+		val->freeswap = totalswap - usageswap - val->freeram;
+	}
+}
+
+void sys_page_state(unsigned long *pages, long *cached)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_task(current);
+
+	if (current->nsproxy->pid_ns == &init_pid_ns ||
+	    memcg == NULL || mem_cgroup_is_root(memcg)) {
+		int lru;
+		for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
+			pages[lru] = global_page_state(NR_LRU_BASE + lru);
+	} else {
+		struct mcs_total_stat s;
+		memset(&s, 0, sizeof(s));
+		mem_cgroup_get_total_stat(memcg, &s);
+		*cached = s.stat[MCS_CACHE] >> PAGE_SHIFT;
+		pages[LRU_ACTIVE_ANON] = s.stat[MCS_ACTIVE_ANON] >> PAGE_SHIFT;
+		pages[LRU_ACTIVE_FILE] = s.stat[MCS_ACTIVE_FILE] >> PAGE_SHIFT;
+		pages[LRU_INACTIVE_ANON] = s.stat[MCS_INACTIVE_ANON] >> PAGE_SHIFT;
+		pages[LRU_INACTIVE_FILE] = s.stat[MCS_INACTIVE_FILE] >> PAGE_SHIFT;
+		pages[LRU_UNEVICTABLE] = s.stat[MCS_UNEVICTABLE] >> PAGE_SHIFT;
+	}
+}
+
 #ifdef CONFIG_NUMA
 static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
