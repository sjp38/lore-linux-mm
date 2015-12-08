Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 522406B0261
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:35:07 -0500 (EST)
Received: by wmec201 with SMTP id c201so41429327wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:35:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fd18si5888487wjc.165.2015.12.08.10.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:35:06 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/8] mm: memcontrol: introduce CONFIG_MEMCG_LEGACY_KMEM
Date: Tue,  8 Dec 2015 13:34:25 -0500
Message-Id: <1449599665-18047-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Let the user know that CONFIG_MEMCG_KMEM does not apply to the cgroup2
interface. This also makes legacy-only code sections stand out better.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  4 ++--
 init/Kconfig               | 10 +++++++++-
 mm/memcontrol.c            | 16 ++++++++--------
 net/ipv4/Makefile          |  2 +-
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 80f38da..c6a5ed2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -233,7 +233,7 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
 
-#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
+#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	struct cg_proto tcp_mem;
 #endif
 
@@ -873,7 +873,7 @@ extern struct static_key_false memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (memcg->tcp_mem.memory_pressure)
 		return true;
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index f1af42d..e5e4971 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1040,10 +1040,13 @@ config MEMCG_SWAP_ENABLED
 	  For those who want to have the feature enabled by default should
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
+config MEMCG_LEGACY_KMEM
+       bool
 config MEMCG_KMEM
-	bool "Memory Resource Controller Kernel Memory accounting"
+	bool "Legacy Memory Resource Controller Kernel Memory accounting"
 	depends on MEMCG
 	depends on SLUB || SLAB
+	select MEMCG_LEGACY_KMEM
 	help
 	  The Kernel Memory extension for Memory Resource Controller can limit
 	  the amount of memory used by kernel objects in the system. Those are
@@ -1052,6 +1055,11 @@ config MEMCG_KMEM
 	  the kmem extension can use it to guarantee that no group of processes
 	  will ever exhaust kernel resources alone.
 
+	  This option affects the ORIGINAL cgroup interface. The cgroup2 memory
+	  controller includes important in-kernel memory consumers per default.
+
+	  If you're using cgroup2, say N.
+
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on HUGETLB_PAGE
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d048137..c527767 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2959,7 +2959,7 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	}
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
@@ -2983,7 +2983,7 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 {
 	return -EINVAL;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG_LEGACY_KMEM */
 
 /*
  * The user of this function is...
@@ -3995,7 +3995,7 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_numa_stat_show,
 	},
 #endif
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	{
 		.name = "kmem.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
@@ -4220,7 +4220,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	ret = tcp_init_cgroup(memcg);
 	if (ret)
 		return ret;
@@ -4276,7 +4276,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 
 	memcg_free_kmem(memcg);
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	tcp_destroy_cgroup(memcg);
 #endif
 
@@ -5495,7 +5495,7 @@ void sock_update_memcg(struct sock *sk)
 	memcg = mem_cgroup_from_task(current);
 	if (memcg == root_mem_cgroup)
 		goto out;
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcp_mem.active)
 		goto out;
 #endif
@@ -5524,7 +5524,7 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	gfp_t gfp_mask = GFP_KERNEL;
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		struct page_counter *counter;
 
@@ -5556,7 +5556,7 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
 				      nr_pages);
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index c29809f..bee5055 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -56,7 +56,7 @@ obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
-obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
+obj-$(CONFIG_MEMCG_LEGACY_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
