Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 26AF06B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:30:48 -0500 (EST)
Received: by wmec201 with SMTP id c201so217589598wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:30:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q72si31118396wmd.52.2015.12.08.07.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:30:47 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 00/14] mm: memcontrol: account socket memory in unified hierarchy v4-RESEND
Date: Tue,  8 Dec 2015 10:30:10 -0500
Message-Id: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

there was some build breakage in CONFIG_ combinations I hadn't tested
in the last revision, so here is a fixed-up resend with minimal CC
list. The only difference to the previous version is a section in
memcontrol.h, but it accumulates throughout the series and would have
been a pain to resolve on your end. So here goes. This also includes
the review tags that Dave and Vlad had sent out in the meantime.

Difference to the original v4:

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9a19590..189f04d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -702,14 +702,14 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-#ifdef CONFIG_INET
 struct sock;
-extern struct static_key_false memcg_sockets_enabled_key;
-#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+#if defined(CONFIG_MEMCG) && defined(CONFIG_INET)
+extern struct static_key_false memcg_sockets_enabled_key;
+#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 #ifdef CONFIG_MEMCG_KMEM
@@ -724,7 +724,11 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #else
 #define mem_cgroup_sockets_enabled 0
-#endif /* CONFIG_INET */
+static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
+{
+	return false;
+}
+#endif
 
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key_false memcg_kmem_enabled_key;
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index a77b142..3347cc3 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -43,7 +43,7 @@ extern int vmpressure_register_event(struct mem_cgroup *memcg,
 extern void vmpressure_unregister_event(struct mem_cgroup *memcg,
 					struct eventfd_ctx *eventfd);
 #else
-static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 			      unsigned long scanned, unsigned long reclaimed) {}
 static inline void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg,
 				   int prio) {}


 Documentation/kernel-parameters.txt |   4 +
 include/linux/memcontrol.h          |  75 ++++++---
 include/linux/vmpressure.h          |   7 +-
 include/net/sock.h                  | 149 ++---------------
 include/net/tcp.h                   |   5 +-
 include/net/tcp_memcontrol.h        |   1 -
 mm/backing-dev.c                    |   2 +-
 mm/memcontrol.c                     | 302 ++++++++++++++++++++++------------
 mm/vmpressure.c                     |  78 ++++++---
 mm/vmscan.c                         |  10 +-
 net/core/sock.c                     |  78 ++-------
 net/ipv4/tcp.c                      |   3 +-
 net/ipv4/tcp_ipv4.c                 |   9 +-
 net/ipv4/tcp_memcontrol.c           |  82 ++++-----
 net/ipv4/tcp_output.c               |   7 +-
 net/ipv6/tcp_ipv6.c                 |   3 -
 16 files changed, 391 insertions(+), 424 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
