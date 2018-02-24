Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61D066B0009
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 14:05:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c5so5959561pfn.17
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 11:05:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3sor1430534pfh.110.2018.02.24.11.05.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Feb 2018 11:05:05 -0800 (PST)
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/2] net: mark slab's used by ss as UAPI
Date: Sat, 24 Feb 2018 11:04:54 -0800
Message-Id: <20180224190454.23716-3-sthemmin@microsoft.com>
In-Reply-To: <20180224190454.23716-1-sthemmin@microsoft.com>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, willy@infradead.org
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Hemminger <stephen@networkplumber.org>

The iproute2 ss command reads /proc/slabinfo as way to get estimates
for number of open sockets etc. This has been broken since slab
merging went in 3.17.

Mark those kmem caches's as non mergeable with new flag.
The TCP caches's are already not mergeable because of the RCU
flags, but someone might change that and cause surprise later.

Reported-by: Igor Komyagin <ikomyagin@gmail.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv4/tcp.c      | 3 ++-
 net/ipv4/tcp_ipv4.c | 2 +-
 net/ipv6/tcp_ipv6.c | 2 +-
 net/socket.c        | 6 +++---
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 48636aee23c3..8c0d4cdc601d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3617,7 +3617,8 @@ void __init tcp_init(void)
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
-				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+				  SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_VISIBLE_UAPI,
+				  NULL);
 
 	/* Size and allocate the main established and bind bucket
 	 * hash tables.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f8ad397e285e..4442f91fab93 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2434,7 +2434,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem_offset	= offsetof(struct net, ipv4.sysctl_tcp_rmem),
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
-	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU | SLAB_VISIBLE_UAPI,
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 412139f4eccd..d6df3b3f401c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1944,7 +1944,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem_offset	= offsetof(struct net, ipv4.sysctl_tcp_rmem),
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
-	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU | SLAB_VISIBLE_UAPI,
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/socket.c b/net/socket.c
index a93c99b518ca..f76ae11af8c7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -286,9 +286,9 @@ static void init_inodecache(void)
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
 					      sizeof(struct socket_alloc),
 					      0,
-					      (SLAB_HWCACHE_ALIGN |
-					       SLAB_RECLAIM_ACCOUNT |
-					       SLAB_MEM_SPREAD | SLAB_ACCOUNT),
+					      SLAB_HWCACHE_ALIGN | SLAB_VISIBLE_UAPI |
+					      SLAB_RECLAIM_ACCOUNT |
+					      SLAB_MEM_SPREAD | SLAB_ACCOUNT,
 					      init_once);
 	BUG_ON(sock_inode_cachep == NULL);
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
