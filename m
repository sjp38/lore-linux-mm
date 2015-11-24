Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CF4E56B025C
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:52:53 -0500 (EST)
Received: by wmec201 with SMTP id c201so229831889wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:52:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 191si1027760wmn.7.2015.11.24.13.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:52:52 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 06/13] net: tcp_memcontrol: simplify the per-memcg limit access
Date: Tue, 24 Nov 2015 16:51:58 -0500
Message-Id: <1448401925-22501-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

tcp_memcontrol replicates the global sysctl_mem limit array per
cgroup, but it only ever sets these entries to the value of the
memory_allocated page_counter limit. Use the latter directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 1 -
 include/net/sock.h         | 8 +++++---
 net/ipv4/tcp_memcontrol.c  | 8 --------
 3 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cc45407..1a658be 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -89,7 +89,6 @@ struct cg_proto {
 	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	int			memory_pressure;
 	bool			active;
-	long			sysctl_mem[3];
 	/*
 	 * memcg field is used to find which memcg we belong directly
 	 * Each memcg struct can hold more than one cg_proto, so container_of
diff --git a/include/net/sock.h b/include/net/sock.h
index 7afbdab..0b333c2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1159,10 +1159,12 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 
 static inline long sk_prot_mem_limits(const struct sock *sk, int index)
 {
-	long *prot = sk->sk_prot->sysctl_mem;
+	long limit = sk->sk_prot->sysctl_mem[index];
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		prot = sk->sk_cgrp->sysctl_mem;
-	return prot[index];
+		limit = min_t(long, limit, sk->sk_cgrp->memory_allocated.limit);
+
+	return limit;
 }
 
 static inline void memcg_memory_allocated_add(struct cg_proto *prot,
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 6759e0d..ef4268d 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -21,9 +21,6 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	if (!cg_proto)
 		return 0;
 
-	cg_proto->sysctl_mem[0] = sysctl_tcp_mem[0];
-	cg_proto->sysctl_mem[1] = sysctl_tcp_mem[1];
-	cg_proto->sysctl_mem[2] = sysctl_tcp_mem[2];
 	cg_proto->memory_pressure = 0;
 	cg_proto->memcg = memcg;
 
@@ -54,7 +51,6 @@ EXPORT_SYMBOL(tcp_destroy_cgroup);
 static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
 	struct cg_proto *cg_proto;
-	int i;
 	int ret;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
@@ -65,10 +61,6 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 	if (ret)
 		return ret;
 
-	for (i = 0; i < 3; i++)
-		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
-						sysctl_tcp_mem[i]);
-
 	if (!cg_proto->active) {
 		/*
 		 * The active flag needs to be written after the static_key
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
