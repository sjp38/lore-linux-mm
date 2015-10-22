Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB7F82F65
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:20 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so102285759wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:20 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j6si15986147wjb.63.2015.10.21.21.22.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:22:19 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/8] mm: memcontrol: hook up vmpressure to socket pressure
Date: Thu, 22 Oct 2015 00:21:36 -0400
Message-Id: <1445487696-21545-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Let the networking stack know when a memcg is under reclaim pressure,
so it can shrink its transmit windows accordingly.

Whenever the reclaim efficiency of a memcg's LRU lists drops low
enough for a MEDIUM or HIGH vmpressure event to occur, assert a
pressure state in the socket and tcp memory code that tells it to
reduce memory usage in sockets associated with said memory cgroup.

vmpressure events are edge triggered, so for hysteresis assert socket
pressure for a second to allow for subsequent vmpressure events to
occur before letting the socket code return to normal.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  9 +++++++++
 include/net/sock.h         |  4 ++++
 include/net/tcp.h          |  4 ++++
 mm/memcontrol.c            |  1 +
 mm/vmpressure.c            | 29 ++++++++++++++++++++++++-----
 5 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d66ae18..b9990f7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -246,6 +246,7 @@ struct mem_cgroup {
 
 #ifdef CONFIG_INET
 	struct work_struct socket_work;
+	unsigned long socket_pressure;
 #endif
 
 	/* List of events which userspace want to receive */
@@ -696,6 +697,10 @@ void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+static inline bool mem_cgroup_socket_pressure(struct mem_cgroup *memcg)
+{
+	return time_before(jiffies, memcg->socket_pressure);
+}
 #else
 static inline bool mem_cgroup_do_sockets(void)
 {
@@ -716,6 +721,10 @@ static inline void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg,
 					     unsigned int nr_pages)
 {
 }
+static inline bool mem_cgroup_socket_pressure(struct mem_cgroup *memcg)
+{
+	return false;
+}
 #endif /* CONFIG_INET */
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/include/net/sock.h b/include/net/sock.h
index 67795fc..22bfb9c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1087,6 +1087,10 @@ static inline bool sk_has_memory_pressure(const struct sock *sk)
 
 static inline bool sk_under_memory_pressure(const struct sock *sk)
 {
+	if (mem_cgroup_do_sockets() && sk->sk_memcg &&
+	    mem_cgroup_socket_pressure(sk->sk_memcg))
+		return true;
+
 	if (!sk->sk_prot->memory_pressure)
 		return false;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 77b6c7e..c7d342c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -291,6 +291,10 @@ extern int tcp_memory_pressure;
 /* optimized version of sk_under_memory_pressure() for TCP sockets */
 static inline bool tcp_under_memory_pressure(const struct sock *sk)
 {
+	if (mem_cgroup_do_sockets() && sk->sk_memcg &&
+	    mem_cgroup_socket_pressure(sk->sk_memcg))
+		return true;
+
 	return tcp_memory_pressure;
 }
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb1d6aa..2e09def 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4178,6 +4178,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #endif
 #ifdef CONFIG_INET
 	INIT_WORK(&memcg->socket_work, socket_work_func);
+	memcg->socket_pressure = jiffies;
 #endif
 	return &memcg->css;
 
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 4c25e62..f64c0e1 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -137,14 +137,11 @@ struct vmpressure_event {
 };
 
 static bool vmpressure_event(struct vmpressure *vmpr,
-			     unsigned long scanned, unsigned long reclaimed)
+			     enum vmpressure_levels level)
 {
 	struct vmpressure_event *ev;
-	enum vmpressure_levels level;
 	bool signalled = false;
 
-	level = vmpressure_calc_level(scanned, reclaimed);
-
 	mutex_lock(&vmpr->events_lock);
 
 	list_for_each_entry(ev, &vmpr->events, node) {
@@ -162,6 +159,7 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 static void vmpressure_work_fn(struct work_struct *work)
 {
 	struct vmpressure *vmpr = work_to_vmpressure(work);
+	enum vmpressure_levels level;
 	unsigned long scanned;
 	unsigned long reclaimed;
 
@@ -185,8 +183,29 @@ static void vmpressure_work_fn(struct work_struct *work)
 	vmpr->reclaimed = 0;
 	spin_unlock(&vmpr->sr_lock);
 
+	level = vmpressure_calc_level(scanned, reclaimed);
+
+	if (level > VMPRESSURE_LOW) {
+		struct mem_cgroup *memcg;
+		/*
+		 * Let the socket buffer allocator know that we are
+		 * having trouble reclaiming LRU pages.
+		 *
+		 * For hysteresis, keep the pressure state asserted
+		 * for a second in which subsequent pressure events
+		 * can occur.
+		 *
+		 * XXX: is vmpressure a global feature or part of
+		 * memcg? There shouldn't be anything memcg-specific
+		 * about exporting reclaim success ratios from the VM.
+		 */
+		memcg = container_of(vmpr, struct mem_cgroup, vmpressure);
+		if (memcg != root_mem_cgroup)
+			memcg->socket_pressure = jiffies + HZ;
+	}
+
 	do {
-		if (vmpressure_event(vmpr, scanned, reclaimed))
+		if (vmpressure_event(vmpr, level))
 			break;
 		/*
 		 * If not handled, propagate the event upward into the
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
