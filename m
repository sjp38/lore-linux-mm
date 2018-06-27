Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 777136B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 16:41:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b9-v6so1379898pgq.17
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 13:41:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5-v6sor1633562plx.112.2018.06.27.13.41.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 13:41:56 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [RFC PATCH] net, mm: account sock objects to kmemcg
Date: Wed, 27 Jun 2018 13:41:39 -0700
Message-Id: <20180627204139.225988-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

Currently the kernel accounts the memory for network traffic through
mem_cgroup_[un]charge_skmem() interface. However the memory accounted
only includes the truesize of sk_buff which does not include the size of
sock objects. In our production environment, with opt-out kmem
accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
among the top most charged kmem caches and consume a significant amount
of memory which can not be left as system overhead. So, this patch
converts the kmem caches of more important sock objects to SLAB_ACCOUNT.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 net/ipv4/raw.c      | 1 +
 net/ipv4/tcp_ipv4.c | 2 +-
 net/ipv4/udp.c      | 1 +
 net/ipv6/raw.c      | 1 +
 net/ipv6/tcp_ipv6.c | 2 +-
 net/ipv6/udp.c      | 1 +
 net/unix/af_unix.c  | 1 +
 7 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index abb3c9490c55..2c4b04c6461a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -988,6 +988,7 @@ struct proto raw_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
+	.slab_flags	   = SLAB_ACCOUNT,
 	.useroffset	   = offsetof(struct raw_sock, filter),
 	.usersize	   = sizeof_field(struct raw_sock, filter),
 	.h.raw_hash	   = &raw_v4_hashinfo,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fed3f1c66167..9ae31979aefa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2459,7 +2459,7 @@ struct proto tcp_prot = {
 	.sysctl_rmem_offset	= offsetof(struct net, ipv4.sysctl_tcp_rmem),
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp_sock),
-	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU | SLAB_ACCOUNT,
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9bb27df4dac5..26e07b8a83cc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2657,6 +2657,7 @@ struct proto udp_prot = {
 	.sysctl_wmem_offset	= offsetof(struct net, ipv4.sysctl_udp_wmem_min),
 	.sysctl_rmem_offset	= offsetof(struct net, ipv4.sysctl_udp_rmem_min),
 	.obj_size		= sizeof(struct udp_sock),
+	.slab_flags		= SLAB_ACCOUNT,
 	.h.udp_table		= &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_udp_setsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ce6f0d15b5dd..044ed44e7c16 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1272,6 +1272,7 @@ struct proto rawv6_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
+	.slab_flags	   = SLAB_ACCOUNT,
 	.useroffset	   = offsetof(struct raw6_sock, filter),
 	.usersize	   = sizeof_field(struct raw6_sock, filter),
 	.h.raw_hash	   = &raw_v6_hashinfo,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b620d9b72e59..7187609ca25f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1973,7 +1973,7 @@ struct proto tcpv6_prot = {
 	.sysctl_rmem_offset	= offsetof(struct net, ipv4.sysctl_tcp_rmem),
 	.max_header		= MAX_TCP_HEADER,
 	.obj_size		= sizeof(struct tcp6_sock),
-	.slab_flags		= SLAB_TYPESAFE_BY_RCU,
+	.slab_flags		= SLAB_TYPESAFE_BY_RCU | SLAB_ACCOUNT,
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e6645cae403e..47c9a3c74981 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1582,6 +1582,7 @@ struct proto udpv6_prot = {
 	.sysctl_wmem_offset     = offsetof(struct net, ipv4.sysctl_udp_wmem_min),
 	.sysctl_rmem_offset     = offsetof(struct net, ipv4.sysctl_udp_rmem_min),
 	.obj_size		= sizeof(struct udp6_sock),
+	.slab_flags		= SLAB_ACCOUNT,
 	.h.udp_table		= &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_udpv6_setsockopt,
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 95b02a71fd47..5e3e377a7269 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -742,6 +742,7 @@ static struct proto unix_proto = {
 	.name			= "UNIX",
 	.owner			= THIS_MODULE,
 	.obj_size		= sizeof(struct unix_sock),
+	.slab_flags		= SLAB_ACCOUNT,
 };
 
 static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
-- 
2.18.0.rc2.346.g013aa6912e-goog
