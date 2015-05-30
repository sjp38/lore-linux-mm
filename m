Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 23F056B0071
	for <linux-mm@kvack.org>; Sat, 30 May 2015 08:03:44 -0400 (EDT)
Received: by wizo1 with SMTP id o1so52667512wiz.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:43 -0700 (PDT)
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id es2si8761400wib.45.2015.05.30.05.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 05:03:40 -0700 (PDT)
Received: by wgme6 with SMTP id e6so81197456wgm.2
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:39 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH 4/4] sunrpc: lock xprt before trying to set memalloc on the sockets
Date: Sat, 30 May 2015 08:03:13 -0400
Message-Id: <1432987393-15604-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

It's possible that we could race with a call to xs_reset_transport, in
which case the xprt->inet pointer could be zeroed out while we're
accessing it. Lock the xprt before we try to set memalloc on it.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 359446442112..91770ccab608 100644
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
@@ -1986,8 +1997,11 @@ xs_swapper_enable(struct rpc_xprt *xprt)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
 
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE))
+		return -ERESTARTSYS;
 	if (atomic_inc_return(&xprt->swapper) == 1)
 		sk_set_memalloc(transport->inet);
+	xprt_release_xprt(xprt, NULL);
 	return 0;
 }
 
@@ -2004,8 +2018,11 @@ xs_swapper_disable(struct rpc_xprt *xprt)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
 
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_UNINTERRUPTIBLE))
+		return;
 	if (atomic_dec_and_test(&xprt->swapper))
 		sk_clear_memalloc(transport->inet);
+	xprt_release_xprt(xprt, NULL);
 }
 #else
 static void xs_set_memalloc(struct rpc_xprt *xprt)
-- 
2.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
