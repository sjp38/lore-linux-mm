Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 05859900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 16:14:47 -0400 (EDT)
Received: by iesa3 with SMTP id a3so21845510ies.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:46 -0700 (PDT)
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com. [209.85.213.180])
        by mx.google.com with ESMTPS id b18si14534324igr.17.2015.06.03.13.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 13:14:46 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so23751574igb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:46 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v3 4/5] sunrpc: lock xprt before trying to set memalloc on the sockets
Date: Wed,  3 Jun 2015 16:14:28 -0400
Message-Id: <1433362469-2615-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
References: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
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
index cb928ae4e8f4..e3596fe184a0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1964,11 +1964,22 @@ static void xs_local_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 
 #if IS_ENABLED(CONFIG_SUNRPC_SWAP)
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
