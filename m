Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id AB6166B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:19:24 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] finish fixing cgroup config option conversion
Date: Wed, 27 Jun 2012 16:16:47 +0400
Message-Id: <1340799407-4688-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>

Andrew, please fold it in your patch so we don't break the build.  Some
of them are needed not to break the build (in net and swap).  And I am
taking the change to patch the Documentation file to reflect reality.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 Documentation/cgroups/memory.txt |    8 ++++----
 include/linux/swap.h             |    6 +++---
 include/net/sock.h               |    4 ++--
 mm/Makefile                      |    2 +-
 net/core/sock.c                  |    2 +-
 net/ipv4/Makefile                |    2 +-
 net/ipv4/sysctl_net_ipv4.c       |    4 ++--
 net/ipv4/tcp_ipv4.c              |    2 +-
 net/ipv6/tcp_ipv6.c              |    2 +-
 9 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index dd88540..22d97b9 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -192,7 +192,7 @@ When you do swapoff and make swapped-out pages of shmem(tmpfs) to
 be backed into memory in force, charges for pages are accounted against the
 caller of swapoff rather than the users of shmem.
 
-2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
+2.4 Swap Extension (CONFIG_MEMCG_SWAP)
 
 Swap Extension allows you to record charge for swap. A swapped-in page is
 charged back to original page allocator if possible.
@@ -259,7 +259,7 @@ When oom event notifier is registered, event will be delivered.
   per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
   zone->lru_lock, it has no lock of its own.
 
-2.7 Kernel Memory Extension (CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
+2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
 
 With the Kernel memory extension, the Memory Controller is able to limit
 the amount of kernel memory used by the system. Kernel memory is fundamentally
@@ -286,8 +286,8 @@ per cgroup, instead of globally.
 
 a. Enable CONFIG_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
-c. Enable CONFIG_CGROUP_MEM_RES_CTLR
-d. Enable CONFIG_CGROUP_MEM_RES_CTLR_SWAP (to use swap extension)
+c. Enable CONFIG_MEMCG
+d. Enable CONFIG_MEMCG_SWAP (to use swap extension)
 
 1. Prepare the cgroups (see cgroups.txt, Why are cgroups needed?)
 # mount -t tmpfs none /sys/fs/cgroup
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c84ec68..9a16bb1 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -301,7 +301,7 @@ static inline void scan_unevictable_unregister_node(struct node *node)
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_MEMCG
 extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
 #else
 static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
@@ -309,7 +309,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 	return vm_swappiness;
 }
 #endif
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+#ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
 #else
 static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
@@ -360,7 +360,7 @@ extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+#ifdef CONFIG_MEMCG
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
 #else
diff --git a/include/net/sock.h b/include/net/sock.h
index 4a45216..a78ea6f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -908,7 +908,7 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 	/*
 	 * cgroup specific init/deinit functions. Called once for all
 	 * protocols that implement it, from cgroups populate function.
@@ -989,7 +989,7 @@ inline void sk_refcnt_debug_release(const struct sock *sk)
 #define sk_refcnt_debug_release(sk) do { } while (0)
 #endif /* SOCK_REFCNT_DEBUG */
 
-#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) && defined(CONFIG_NET)
+#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
 extern struct static_key memcg_socket_limit_enabled;
 static inline struct cg_proto *parent_cg_proto(struct proto *proto,
 					       struct cg_proto *cg_proto)
diff --git a/mm/Makefile b/mm/Makefile
index 2e2fbbe..a211198 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
diff --git a/net/core/sock.c b/net/core/sock.c
index 9e5b71f..55db752 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -142,7 +142,7 @@
 static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	struct proto *proto;
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index ff75d3b..864f618 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) += tcp_memcontrol.o
+obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index ef32956..d80335f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -184,7 +184,7 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 	int ret;
 	unsigned long vec[3];
 	struct net *net = current->nsproxy->net_ns;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 	struct mem_cgroup *memcg;
 #endif
 
@@ -203,7 +203,7 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 	if (ret)
 		return ret;
 
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c8d28c4..9b2c64b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2614,7 +2614,7 @@ struct proto tcp_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 	.init_cgroup		= tcp_init_cgroup,
 	.destroy_cgroup		= tcp_destroy_cgroup,
 	.proto_cgroup		= tcp_proto_cgroup,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3a9aec2..a4c2168 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2069,7 +2069,7 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_MEMCG_KMEM
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
 };
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
