Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6296B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 23:12:18 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so24006317pdi.10
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 20:12:17 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20131204222943.GC21724@cmpxchg.org>
	<20131204.175028.1602944177771517327.davem@davemloft.net>
Date: Wed, 04 Dec 2013 20:12:04 -0800
In-Reply-To: <20131204.175028.1602944177771517327.davem@davemloft.net> (David
	Miller's message of "Wed, 04 Dec 2013 17:50:28 -0500 (EST)")
Message-ID: <87mwkg542z.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [PATCH] tcp_memcontrol: Cleanup/fix cg_proto->memory_pressure handling.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hannes@cmpxchg.org, glommer@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@kvack.org


kill memcg_tcp_enter_memory_pressure.  The only function of
memcg_tcp_enter_memory_pressure was to reduce deal with the
unnecessary abstraction that was tcp_memcontrol.  Now that struct
tcp_memcontrol is gone remove this unnecessary function, the
unnecessary function pointer, and modify sk_enter_memory_pressure to
set this field directly, just as sk_leave_memory_pressure cleas this
field directly.

This fixes a small bug I intruduced when killing struct tcp_memcontrol
that caused memcg_tcp_enter_memory_pressure to never be called and
thus failed to ever set cg_proto->memory_pressure.

Remove the cg_proto enter_memory_pressure function as it now serves
no useful purpose.

Don't test cg_proto->memory_presser in sk_leave_memory_pressure before
clearing it.  The test was originally there to ensure that the pointer
was non-NULL.  Now that cg_proto is not a pointer the pointer does not
matter.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sock.h        |    6 ++----
 net/ipv4/tcp_memcontrol.c |    7 -------
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e3a18ff0c38b..2ef3c3eca47a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1035,7 +1035,6 @@ enum cg_proto_flags {
 };
 
 struct cg_proto {
-	void			(*enter_memory_pressure)(struct sock *sk);
 	struct res_counter	memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
 	int			memory_pressure;
@@ -1155,8 +1154,7 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
 		struct proto *prot = sk->sk_prot;
 
 		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			if (cg_proto->memory_pressure)
-				cg_proto->memory_pressure = 0;
+			cg_proto->memory_pressure = 0;
 	}
 
 }
@@ -1171,7 +1169,7 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 		struct proto *prot = sk->sk_prot;
 
 		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->enter_memory_pressure(sk);
+			cg_proto->memory_pressure = 1;
 	}
 
 	sk->sk_prot->enter_memory_pressure(sk);
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 03e9154f7e68..2c39f8f0dddf 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -6,13 +6,6 @@
 #include <linux/memcontrol.h>
 #include <linux/module.h>
 
-static void memcg_tcp_enter_memory_pressure(struct sock *sk)
-{
-	if (sk->sk_cgrp->memory_pressure)
-		sk->sk_cgrp->memory_pressure = 1;
-}
-EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
-
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	/*
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
