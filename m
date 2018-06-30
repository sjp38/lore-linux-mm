Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9E166B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 06:11:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l2-v6so5785537pff.3
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 03:11:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m21-v6sor1594093pfg.107.2018.06.30.03.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Jun 2018 03:10:59 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH net-next] net, mm: avoid unnecessary memcg charge skmem
Date: Sat, 30 Jun 2018 18:09:57 +0800
Message-Id: <1530353397-12948-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Yafang Shao <laoar.shao@gmail.com>

In __sk_mem_raise_allocated(), if mem_cgroup_charge_skmem() return
false, mem_cgroup_uncharge_skmem will be executed.

The logic is as bellow,
__sk_mem_raise_allocated
	ret = mem_cgroup_uncharge_skmem
		try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
		return false
	if (!ret)
		mem_cgroup_uncharge_skmem(sk->sk_memcg, amt);

So it is unnecessary to charge if it is not forced.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/linux/memcontrol.h |  3 ++-
 mm/memcontrol.c            | 12 +++++++++---
 net/core/sock.c            |  5 +++--
 net/ipv4/tcp_output.c      |  2 +-
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb11..56c07c9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1160,7 +1160,8 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
-bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages,
+			     bool force);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 #ifdef CONFIG_MEMCG
 extern struct static_key_false memcg_sockets_enabled_key;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5e..1122be2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5929,7 +5929,8 @@ void mem_cgroup_sk_free(struct sock *sk)
  * Charges @nr_pages to @memcg. Returns %true if the charge fit within
  * @memcg's configured limit, %false if the charge had to be forced.
  */
-bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages,
+			     bool force)
 {
 	gfp_t gfp_mask = GFP_KERNEL;
 
@@ -5940,7 +5941,10 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 			memcg->tcpmem_pressure = 0;
 			return true;
 		}
-		page_counter_charge(&memcg->tcpmem, nr_pages);
+
+		if (force)
+			page_counter_charge(&memcg->tcpmem, nr_pages);
+
 		memcg->tcpmem_pressure = 1;
 		return false;
 	}
@@ -5954,7 +5958,9 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
 		return true;
 
-	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
+	if (force)
+		try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
+
 	return false;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index bcc4182..148a840 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2401,9 +2401,10 @@ int __sk_mem_raise_allocated(struct sock *sk, int size, int amt, int kind)
 {
 	struct proto *prot = sk->sk_prot;
 	long allocated = sk_memory_allocated_add(sk, amt);
+	bool charged = false;
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
-	    !mem_cgroup_charge_skmem(sk->sk_memcg, amt))
+	    !(charged = mem_cgroup_charge_skmem(sk->sk_memcg, amt, false)))
 		goto suppress_allocation;
 
 	/* Under limit. */
@@ -2465,7 +2466,7 @@ int __sk_mem_raise_allocated(struct sock *sk, int size, int amt, int kind)
 
 	sk_memory_allocated_sub(sk, amt);
 
-	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg && charged)
 		mem_cgroup_uncharge_skmem(sk->sk_memcg, amt);
 
 	return 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f8f6129..9b741d4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3014,7 +3014,7 @@ void sk_forced_mem_schedule(struct sock *sk, int size)
 	sk_memory_allocated_add(sk, amt);
 
 	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
-		mem_cgroup_charge_skmem(sk->sk_memcg, amt);
+		mem_cgroup_charge_skmem(sk->sk_memcg, amt, true);
 }
 
 /* Send a FIN. The caller locks the socket for us.
-- 
1.8.3.1
