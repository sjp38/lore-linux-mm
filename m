Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAE26B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 09:08:03 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so117748687pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 06:08:02 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id mi6si19249693pab.85.2015.11.20.06.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 06:08:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] memcg: do not allow to disable tcp accounting after limit is set
Date: Fri, 20 Nov 2015 17:07:49 +0300
Message-ID: <1448028469-22151-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are two bits defined for cg_proto->flags - MEMCG_SOCK_ACTIVATED
and MEMCG_SOCK_ACTIVE - both are set in tcp_update_limit, but the former
is never cleared while the latter can be cleared by unsetting the limit.
This allows to disable tcp socket accounting for new sockets after it
was enabled by writing -1 to memory.kmem.tcp.limit_in_bytes while still
guaranteeing that memcg_socket_limit_enabled static key will be
decremented on memcg destruction.

This functionality looks dubious, because it is not clear what a use
case would be. By enabling tcp accounting a user accepts the price. If
they then find the performance degradation unacceptable, they can always
restart their workload with tcp accounting disabled. It does not seem
there is any need to flip it while the workload is running.

Besides, it contradicts to how kmem accounting API works: writing
whatever to memory.kmem.limit_in_bytes enables kmem accounting for the
cgroup in question, after which it cannot be disabled. Therefore one
might expect that writing -1 to memory.kmem.tcp.limit_in_bytes just
enables socket accounting w/o limiting it, which might be useful by
itself, but it isn't true.

Since this API peculiarity is not documented anywhere, I propose to drop
it. This will allow to simplify the code by dropping cg_proto->flags.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 12 +-----------
 mm/memcontrol.c            |  2 +-
 net/ipv4/tcp_memcontrol.c  | 17 +++++------------
 3 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a096b6440fca..9d5472be551b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -85,22 +85,12 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_NTARGETS,
 };
 
-/*
- * Bits in struct cg_proto.flags
- */
-enum cg_proto_flags {
-	/* Currently active and new sockets should be assigned to cgroups */
-	MEMCG_SOCK_ACTIVE,
-	/* It was ever activated; we must disarm static keys on destruction */
-	MEMCG_SOCK_ACTIVATED,
-};
-
 struct cg_proto {
 	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
 	int			memory_pressure;
+	bool			active;
 	long			sysctl_mem[3];
-	unsigned long		flags;
 	/*
 	 * memcg field is used to find which memcg we belong directly
 	 * Each memcg struct can hold more than one cg_proto, so container_of
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3d5df68f8e09..273a5dfedace 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -316,7 +316,7 @@ void sock_update_memcg(struct sock *sk)
 		rcu_read_lock();
 		memcg = mem_cgroup_from_task(current);
 		cg_proto = sk->sk_prot->proto_cgroup(memcg);
-		if (cg_proto && test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags) &&
+		if (cg_proto && cg_proto->active &&
 		    css_tryget_online(&memcg->css)) {
 			sk->sk_cgrp = cg_proto;
 		}
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 2379c1b4efb2..d07579ada001 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -48,7 +48,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 
 	percpu_counter_destroy(&cg_proto->sockets_allocated);
 
-	if (test_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
+	if (cg_proto->active)
 		static_key_slow_dec(&memcg_socket_limit_enabled);
 
 }
@@ -72,11 +72,9 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
 						sysctl_tcp_mem[i]);
 
-	if (nr_pages == PAGE_COUNTER_MAX)
-		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	else {
+	if (!cg_proto->active) {
 		/*
-		 * The active bit needs to be written after the static_key
+		 * The active flag needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
 		 * function is the last one to run. See sock_update_memcg() for
 		 * details, and note that we don't mark any socket as belonging
@@ -90,14 +88,9 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 		 * We never race with the readers in sock_update_memcg(),
 		 * because when this value change, the code to process it is not
 		 * patched in yet.
-		 *
-		 * The activated bit is used to guarantee that no two writers
-		 * will do the update in the same memcg. Without that, we can't
-		 * properly shutdown the static key.
 		 */
-		if (!test_and_set_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
-			static_key_slow_inc(&memcg_socket_limit_enabled);
-		set_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
+		static_key_slow_inc(&memcg_socket_limit_enabled);
+		cg_proto->active = true;
 	}
 
 	return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
