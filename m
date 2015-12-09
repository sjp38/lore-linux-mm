Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 031BC6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 15:30:17 -0500 (EST)
Received: by lft93 with SMTP id 93so1828745lft.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 12:30:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p15si5698634lfe.235.2015.12.09.12.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 12:30:14 -0800 (PST)
Date: Wed, 9 Dec 2015 15:30:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC PATCH] mm: memcontrol: reign in CONFIG space madness
Message-ID: <20151209203004.GA5820@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hey guys,

there has been quite a bit of trouble that stems from dividing our
CONFIG space and having to provide real code and dummy functions
correctly in all possible combinations. This is amplified by having
the legacy mode and the cgroup2 mode in the same file sharing code.

The socket memory and kmem accounting series is a nightmare in that
respect, and I'm still in the process of sorting it out. But no matter
what the outcome there is going to be, what do you think about getting
rid of the CONFIG_MEMCG[_LEGACY]_KMEM and CONFIG_INET stuff?

Because they end up saving very little and it doesn't seem worth the
trouble. CONFIG_MEMCG_LEGACY_KMEM basically allows not compiling the
interface structures and the limit updating function. Everything else
is included anyway because of cgroup2. And CONFIG_INET also only saves
a page_counter and two words in struct mem_cgroup, as well as the tiny
socket-specific charge and uncharge wrappers that nobody would call.

Would you be opposed to getting rid of them to simplify things?

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c6a5ed2..bf895c0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -233,9 +233,10 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
 
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
+	unsigned long		socket_pressure;
+
+	/* Legacy tcp memory control */
 	struct cg_proto tcp_mem;
-#endif
 
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
@@ -253,10 +254,6 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
-#ifdef CONFIG_INET
-	unsigned long		socket_pressure;
-#endif
-
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -615,6 +612,26 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 		__memcg_kmem_put_cache(cachep);
 }
 
+extern struct static_key_false memcg_sockets_enabled_key;
+#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
+
+struct sock;
+void sock_update_memcg(struct sock *sk);
+void sock_release_memcg(struct sock *sk);
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+
+static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
+{
+	if (memcg->tcp_mem.memory_pressure)
+		return true;
+	do {
+		if (time_before(jiffies, memcg->socket_pressure))
+			return true;
+	} while ((memcg = parent_mem_cgroup(memcg)));
+	return false;
+}
+
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -836,6 +853,13 @@ static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
 
+#define mem_cgroup_sockets_enabled 0
+
+static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 #endif /* CONFIG_MEMCG */
 
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -863,32 +887,4 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-struct sock;
-void sock_update_memcg(struct sock *sk);
-void sock_release_memcg(struct sock *sk);
-bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
-void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
-#if defined(CONFIG_MEMCG) && defined(CONFIG_INET)
-extern struct static_key_false memcg_sockets_enabled_key;
-#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
-static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
-{
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
-	if (memcg->tcp_mem.memory_pressure)
-		return true;
-#endif
-	do {
-		if (time_before(jiffies, memcg->socket_pressure))
-			return true;
-	} while ((memcg = parent_mem_cgroup(memcg)));
-	return false;
-}
-#else
-#define mem_cgroup_sockets_enabled 0
-static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
-{
-	return false;
-}
-#endif
-
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/init/Kconfig b/init/Kconfig
index 05440ad..2a739b9 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1040,22 +1040,6 @@ config MEMCG_SWAP_ENABLED
 	  For those who want to have the feature enabled by default should
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
-config MEMCG_LEGACY_KMEM
-	bool "Legacy Memory Resource Controller Kernel Memory accounting"
-	depends on MEMCG
-	depends on SLUB || SLAB
-	help
-	  The Kernel Memory extension for Memory Resource Controller can limit
-	  the amount of memory used by kernel objects in the system. Those are
-	  fundamentally different from the entities handled by the standard
-	  Memory Controller, which are page-based, and can be swapped. Users of
-	  the kmem extension can use it to guarantee that no group of processes
-	  will ever exhaust kernel resources alone.
-
-	  This option affects the ORIGINAL cgroup interface. The cgroup2 memory
-	  controller includes important in-kernel memory consumers per default.
-
-	  If you're using cgroup2, say N.
 
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b4e27f7..5bce1e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2813,11 +2813,9 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	case _KMEM:
 		counter = &memcg->kmem;
 		break;
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	case _TCP:
 		counter = &memcg->tcp_mem.memory_allocated;
 		break;
-#endif
 	default:
 		BUG();
 	}
@@ -2964,7 +2962,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	}
 }
 
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
@@ -2982,15 +2979,7 @@ out:
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
-#else
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
-{
-	return -EINVAL;
-}
-#endif /* CONFIG_MEMCG_LEGACY_KMEM */
 
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
 	int ret;
@@ -3025,12 +3014,6 @@ out:
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
-#else
-static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
-{
-	return -EINVAL;
-}
-#endif /* CONFIG_MEMCG_LEGACY_KMEM && CONFIG_INET */
 
 /*
  * The user of this function is...
@@ -3093,11 +3076,9 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 	case _KMEM:
 		counter = &memcg->kmem;
 		break;
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	case _TCP:
 		counter = &memcg->tcp_mem.memory_allocated;
 		break;
-#endif
 	default:
 		BUG();
 	}
@@ -4050,7 +4031,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_numa_stat_show,
 	},
 #endif
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	{
 		.name = "kmem.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
@@ -4083,7 +4063,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_slab_show,
 	},
 #endif
-#ifdef CONFIG_INET
 	{
 		.name = "kmem.tcp.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_TCP, RES_LIMIT),
@@ -4107,8 +4086,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.write = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read_u64,
 	},
-#endif
-#endif
 	{ },	/* terminate */
 };
 
@@ -4236,13 +4213,11 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
+	memcg->socket_pressure = jiffies;
 	memcg->kmemcg_id = -1;
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
-#ifdef CONFIG_INET
-	memcg->socket_pressure = jiffies;
-#endif
 	return &memcg->css;
 
 free_out:
@@ -4275,10 +4250,8 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 		page_counter_init(&memcg->tcp_mem.memory_allocated,
 				  &parent->tcp_mem.memory_allocated);
-#endif
 
 		/*
 		 * No need to take a reference to the parent because cgroup
@@ -4290,9 +4263,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 		page_counter_init(&memcg->tcp_mem.memory_allocated, NULL);
-#endif
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -4307,10 +4278,8 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
-#ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
-#endif
 
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
@@ -4350,15 +4319,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-#ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
-#endif
 
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	if (memcg->tcp_mem.active)
 		static_branch_dec(&memcg_sockets_enabled_key);
-#endif
 
 	memcg_free_kmem(memcg);
 
@@ -5550,8 +5515,6 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-#ifdef CONFIG_INET
-
 DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
 EXPORT_SYMBOL(memcg_sockets_enabled_key);
 
@@ -5577,10 +5540,8 @@ void sock_update_memcg(struct sock *sk)
 	memcg = mem_cgroup_from_task(current);
 	if (memcg == root_mem_cgroup)
 		goto out;
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcp_mem.active)
 		goto out;
-#endif
 	if (css_tryget_online(&memcg->css))
 		sk->sk_memcg = memcg;
 out:
@@ -5606,7 +5567,6 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	gfp_t gfp_mask = GFP_KERNEL;
 
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		struct page_counter *counter;
 
@@ -5619,7 +5579,7 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 		memcg->tcp_mem.memory_pressure = 1;
 		return false;
 	}
-#endif
+
 	/* Don't block in the packet receive path */
 	if (in_softirq())
 		gfp_mask = GFP_NOWAIT;
@@ -5638,19 +5598,16 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
 				      nr_pages);
 		return;
 	}
-#endif
+
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	css_put_many(&memcg->css, nr_pages);
 }
 
-#endif /* CONFIG_INET */
-
 static int __init cgroup_memory(char *s)
 {
 	char *token;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
