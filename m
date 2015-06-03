Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD06900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:44:13 -0400 (EDT)
Received: by wgv5 with SMTP id 5so11227530wgv.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:12 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id ck10si23149547wib.65.2015.06.03.07.44.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 07:44:11 -0700 (PDT)
Received: by wibdt2 with SMTP id dt2so15795798wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:10 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2 2/5] sunrpc: make xprt->swapper an atomic_t
Date: Wed,  3 Jun 2015 10:43:49 -0400
Message-Id: <1433342632-16173-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

Split xs_swapper into enable/disable functions and eliminate the
"enable" flag.

Currently, it's racy if you have multiple swapon/swapoff operations
running in parallel over the same xprt. Also fix it so that we only
set it to a memalloc socket on a 0->1 transition and only clear it
on a 1->0 transition.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/xprt.h |  5 +++--
 net/sunrpc/clnt.c           |  4 ++--
 net/sunrpc/xprtsock.c       | 38 +++++++++++++++++++++++++-------------
 3 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8b93ef53df3c..26b1624128ec 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -180,7 +180,7 @@ struct rpc_xprt {
 	atomic_t		num_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		resvport   : 1; /* use a reserved port */
-	unsigned int		swapper;	/* we're swapping over this
+	atomic_t		swapper;	/* we're swapping over this
 						   transport */
 	unsigned int		bind_index;	/* bind function index */
 
@@ -345,7 +345,8 @@ void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
-int			xs_swapper(struct rpc_xprt *xprt, int enable);
+int			xs_swapper_enable(struct rpc_xprt *xprt);
+void			xs_swapper_disable(struct rpc_xprt *xprt);
 
 bool			xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
 void			xprt_unlock_connect(struct rpc_xprt *, void *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 383cb778179f..804a75e71e84 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2492,7 +2492,7 @@ retry:
 			goto retry;
 		}
 
-		ret = xs_swapper(xprt, 1);
+		ret = xs_swapper_enable(xprt);
 		xprt_put(xprt);
 	}
 	return ret;
@@ -2519,7 +2519,7 @@ retry:
 			goto retry;
 		}
 
-		xs_swapper(xprt, 0);
+		xs_swapper_disable(xprt);
 		xprt_put(xprt);
 	}
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b29703996028..a2861bbfd319 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1966,31 +1966,43 @@ static void xs_set_memalloc(struct rpc_xprt *xprt)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
 
-	if (xprt->swapper)
+	if (atomic_read(&xprt->swapper))
 		sk_set_memalloc(transport->inet);
 }
 
 /**
- * xs_swapper - Tag this transport as being used for swap.
+ * xs_swapper_enable - Tag this transport as being used for swap.
  * @xprt: transport to tag
- * @enable: enable/disable
  *
+ * Take a reference to this transport on behalf of the rpc_clnt, and
+ * optionally mark it for swapping if it wasn't already.
  */
-int xs_swapper(struct rpc_xprt *xprt, int enable)
+int
+xs_swapper_enable(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
-	int err = 0;
 
-	if (enable) {
-		xprt->swapper++;
-		xs_set_memalloc(xprt);
-	} else if (xprt->swapper) {
-		xprt->swapper--;
-		sk_clear_memalloc(transport->inet);
-	}
+	if (atomic_inc_return(&xprt->swapper) == 1)
+		sk_set_memalloc(transport->inet);
+	return 0;
+}
 
-	return err;
+/**
+ * xs_swapper_disable - Untag this transport as being used for swap.
+ * @xprt: transport to tag
+ *
+ * Drop a "swapper" reference to this xprt on behalf of the rpc_clnt. If the
+ * swapper refcount goes to 0, untag the socket as a memalloc socket.
+ */
+void
+xs_swapper_disable(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
+			xprt);
+
+	if (atomic_dec_and_test(&xprt->swapper))
+		sk_clear_memalloc(transport->inet);
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
