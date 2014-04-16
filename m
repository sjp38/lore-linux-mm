Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 400A36B0039
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:18:26 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so8278669eek.15
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:18:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si28117273eel.212.2014.04.15.21.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:18:25 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 05/19] SUNRPC: track whether a request is coming from a
 loop-back interface.
Message-ID: <20140416040336.10604.14822.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, netdev@vger.kernel.org

If an incoming NFS request is coming from the local host, then
nfsd will need to perform some special handling.  So detect that
possibility and make the source visible in rq_local.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/svc.h      |    1 +
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svcsock.c            |   10 ++++++++++
 3 files changed, 12 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 04e763221246..a0dbbd1e00e9 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -254,6 +254,7 @@ struct svc_rqst {
 	u32			rq_prot;	/* IP protocol */
 	unsigned short
 				rq_secure  : 1;	/* secure port */
+	unsigned short		rq_local   : 1;	/* local request */
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b05963f09ebf..b99bdfb0fcf9 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,6 +63,7 @@ struct svc_xprt {
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
 #define XPT_CACHE_AUTH	12		/* cache auth info */
+#define XPT_LOCAL	13		/* connection from loopback interface */
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b6e59f0a9475..193115fe968c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -811,6 +811,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
+	struct dst_entry *dst;
 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
@@ -867,6 +868,14 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
 
+	clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
+	rcu_read_lock();
+	dst = rcu_dereference(newsock->sk->sk_dst_cache);
+	if (dst && dst->dev &&
+	    (dst->dev->features & NETIF_F_LOOPBACK))
+		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
+	rcu_read_unlock();
+
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1112,6 +1121,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
+	rqstp->rq_local	      = !!test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags);
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
