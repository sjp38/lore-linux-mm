Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 958B66B00B2
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:47 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 69/80] c/r: introduce checkpoint/restore methods to struct proto_ops
Date: Wed, 23 Sep 2009 19:51:49 -0400
Message-Id: <1253749920-18673-70-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This adds new 'proto_ops' function for checkpointing and restoring
sockets. This allows the checkpoint/restart code to compile nicely
when, e.g., AF_UNIX sockets are selected as a module.

It also adds a function 'collecting' a socket for leak-detection
during full-container checkpoint. This is useful for those sockets
that hold references to other "collectable" objects. Two examples are
AF_UNIX buffers which reference the socket of origin, and sockets that
have file descriptors in-transit.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/net.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4fc2ffd..b99f350 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -147,6 +147,9 @@ struct sockaddr;
 struct msghdr;
 struct module;
 
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+
 struct proto_ops {
 	int		family;
 	struct module	*owner;
@@ -191,6 +194,12 @@ struct proto_ops {
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+	int		(*checkpoint)(struct ckpt_ctx *ctx,
+				      struct socket *sock);
+	int		(*collect)(struct ckpt_ctx *ctx,
+				   struct socket *sock);
+	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
+				   struct ckpt_hdr_socket *h);
 };
 
 struct net_proto_family {
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
