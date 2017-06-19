Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC2786B033C
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 13so45128204pgg.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:54 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id f14si9343199pgr.380.2017.06.19.16.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:54 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id f185so54757167pgc.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:54 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 15/23] net: define usercopy region in struct proto slab cache
Date: Mon, 19 Jun 2017 16:36:29 -0700
Message-Id: <1497915397-93805-16-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

The following objects need to be copied to/from userspace:

  * sctp socket event notification subscription information
  * ICMP filters for IPv4 and IPv6 raw sockets
  * CAIF channel connection request parameters

These objects are stored in per-protocol slabs.

In support of usercopy hardening, this patch defines a region in
the struct proto slab cache in which userspace copy operations
are allowed.

This region is known as the slab cache's usercopy region.  Slab
caches can now check that each copy operation involving cache-managed
memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/sock.h     | 2 ++
 net/caif/caif_socket.c | 2 ++
 net/core/sock.c        | 5 +++--
 net/ipv4/raw.c         | 2 ++
 net/ipv6/raw.c         | 2 ++
 net/sctp/socket.c      | 4 ++++
 6 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f33e3d134e0b..9cc6052d3dac 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1091,6 +1091,8 @@ struct proto {
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
 	int			slab_flags;
+	size_t			useroffset;	/* Usercopy region offset */
+	size_t			usersize;	/* Usercopy region size */
 
 	struct percpu_counter	*orphan_count;
 
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index adcad344c843..73fa59d87c3b 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1028,6 +1028,8 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	static struct proto prot = {.name = "PF_CAIF",
 		.owner = THIS_MODULE,
 		.obj_size = sizeof(struct caifsock),
+		.useroffset = offsetof(struct caifsock, conn_req.param),
+		.usersize = sizeof_field(struct caifsock, conn_req.param)
 	};
 
 	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
diff --git a/net/core/sock.c b/net/core/sock.c
index 727f924b7f91..9e229874c785 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3049,9 +3049,10 @@ static int req_prot_init(const struct proto *prot)
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	if (alloc_slab) {
-		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
+		prot->slab = kmem_cache_create_usercopy(prot->name,
+					prot->obj_size, 0,
 					SLAB_HWCACHE_ALIGN | prot->slab_flags,
-					NULL);
+					prot->useroffset, prot->usersize, NULL);
 
 		if (prot->slab == NULL) {
 			pr_crit("%s: Can't create sock SLAB cache!\n",
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bdffad875691..336d555ad237 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -964,6 +964,8 @@ struct proto raw_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
+	.useroffset	   = offsetof(struct raw_sock, filter),
+	.usersize	   = sizeof_field(struct raw_sock, filter),
 	.h.raw_hash	   = &raw_v4_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 60be012fe708..27dd9a5f71c6 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1265,6 +1265,8 @@ struct proto rawv6_prot = {
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
+	.useroffset	   = offsetof(struct raw6_sock, filter),
+	.usersize	   = sizeof_field(struct raw6_sock, filter),
 	.h.raw_hash	   = &raw_v6_hashinfo,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_rawv6_setsockopt,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f16c8d97b7f3..0defc0c76552 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -8178,6 +8178,10 @@ struct proto sctp_prot = {
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
 	.obj_size    =  sizeof(struct sctp_sock),
+	.useroffset  =  offsetof(struct sctp_sock, subscribe),
+	.usersize    =  sizeof_field(struct sctp_sock, initmsg) -
+				offsetof(struct sctp_sock, subscribe) +
+				sizeof_field(struct sctp_sock, initmsg),
 	.sysctl_mem  =  sysctl_sctp_mem,
 	.sysctl_rmem =  sysctl_sctp_rmem,
 	.sysctl_wmem =  sysctl_sctp_wmem,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
