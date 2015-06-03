Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 01523900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:44:19 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so94073137wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:18 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id v3si31077866wix.97.2015.06.03.07.44.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 07:44:16 -0700 (PDT)
Received: by wiga1 with SMTP id a1so16992461wig.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:15 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2 4/5] sunrpc: lock xprt before trying to set memalloc on the sockets
Date: Wed,  3 Jun 2015 10:43:51 -0400
Message-Id: <1433342632-16173-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

It's possible that we could race with a call to xs_reset_transport, in
which case the xprt->inet pointer could be zeroed out while we're
accessing it. Lock the xprt before we try to set memalloc on it.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 359446442112..16aa5dad41b2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1964,11 +1964,22 @@ static void xs_local_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 
 #ifdef CONFIG_SUNRPC_SWAP
+/*
+ * Note that this should be called with XPRT_LOCKED held (or when we otherwise
+ * know that we have exclusive access to the socket), to guard against
+ * races with xs_reset_transport.
+ */
 static void xs_set_memalloc(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
 
+	/*
+	 * If there's no sock, then we have nothing to set. The
+	 * reconnecting process will get it for us.
+	 */
+	if (!transport->inet)
+		return;
 	if (atomic_read(&xprt->swapper))
 		sk_set_memalloc(transport->inet);
 }
@@ -1983,11 +1994,15 @@ static void xs_set_memalloc(struct rpc_xprt *xprt)
 int
 xs_swapper_enable(struct rpc_xprt *xprt)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
-			xprt);
+	struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
 
-	if (atomic_inc_return(&xprt->swapper) == 1)
-		sk_set_memalloc(transport->inet);
+	if (atomic_inc_return(&xprt->swapper) != 1)
+		return 0;
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE))
+		return -ERESTARTSYS;
+	if (xs->inet)
+		sk_set_memalloc(xs->inet);
+	xprt_release_xprt(xprt, NULL);
 	return 0;
 }
 
@@ -2001,11 +2016,15 @@ xs_swapper_enable(struct rpc_xprt *xprt)
 void
 xs_swapper_disable(struct rpc_xprt *xprt)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
-			xprt);
+	struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
 
-	if (atomic_dec_and_test(&xprt->swapper))
-		sk_clear_memalloc(transport->inet);
+	if (!atomic_dec_and_test(&xprt->swapper))
+		return;
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE))
+		return;
+	if (xs->inet)
+		sk_clear_memalloc(xs->inet);
+	xprt_release_xprt(xprt, NULL);
 }
 #else
 static void xs_set_memalloc(struct rpc_xprt *xprt)
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
