Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D37416B025D
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:31:11 -0500 (EST)
Received: by wmvv187 with SMTP id v187so218759321wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:31:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x130si31121859wmx.46.2015.12.08.07.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:31:10 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 09/14] mm: memcontrol: generalize the socket accounting jump label
Date: Tue,  8 Dec 2015 10:30:19 -0500
Message-Id: <1449588624-9220-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The unified hierarchy memory controller is going to use this jump
label as well to control the networking callbacks. Move it to the
memory controller code and give it a more generic name.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/linux/memcontrol.h | 3 +++
 include/net/sock.h         | 7 -------
 mm/memcontrol.c            | 3 +++
 net/core/sock.c            | 5 -----
 net/ipv4/tcp_memcontrol.c  | 4 ++--
 5 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index daf6dbe..654c2fb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -685,11 +685,14 @@ void sock_release_memcg(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
+extern struct static_key memcg_sockets_enabled_key;
+#define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return memcg->tcp_mem.memory_pressure;
 }
 #else
+#define mem_cgroup_sockets_enabled 0
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return false;
diff --git a/include/net/sock.h b/include/net/sock.h
index 1a94b85..fcc9442 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1065,13 +1065,6 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 #define sk_refcnt_debug_release(sk) do { } while (0)
 #endif /* SOCK_REFCNT_DEBUG */
 
-#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
-extern struct static_key memcg_socket_limit_enabled;
-#define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
-#else
-#define mem_cgroup_sockets_enabled 0
-#endif
-
 static inline bool sk_stream_memory_free(const struct sock *sk)
 {
 	if (sk->sk_wmem_queued >= sk->sk_sndbuf)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 68d67fc..0602bee 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -291,6 +291,9 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 /* Writing them here to avoid exposing memcg's inner layout */
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 
+struct static_key memcg_sockets_enabled_key;
+EXPORT_SYMBOL(memcg_sockets_enabled_key);
+
 void sock_update_memcg(struct sock *sk)
 {
 	struct mem_cgroup *memcg;
diff --git a/net/core/sock.c b/net/core/sock.c
index 6486b0d..c5435b5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -201,11 +201,6 @@ EXPORT_SYMBOL(sk_net_capable);
 static struct lock_class_key af_family_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
 
-#if defined(CONFIG_MEMCG_KMEM)
-struct static_key memcg_socket_limit_enabled;
-EXPORT_SYMBOL(memcg_socket_limit_enabled);
-#endif
-
 /*
  * Make lock validator output more readable. (we pre-construct these
  * strings build-time, so that runtime initialization of socket
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index e507825..9a22e2d 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -34,7 +34,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 		return;
 
 	if (memcg->tcp_mem.active)
-		static_key_slow_dec(&memcg_socket_limit_enabled);
+		static_key_slow_dec(&memcg_sockets_enabled_key);
 }
 
 static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
@@ -65,7 +65,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 		 * because when this value change, the code to process it is not
 		 * patched in yet.
 		 */
-		static_key_slow_inc(&memcg_socket_limit_enabled);
+		static_key_slow_inc(&memcg_sockets_enabled_key);
 		memcg->tcp_mem.active = true;
 	}
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
