Message-Id: <20080724141530.724917290@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:02 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/30] netvm: filter emergency skbs.
Content-Disposition: inline; filename=netvm-sk_filter.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Toss all emergency packets not for a SOCK_MEMALLOC socket. This ensures our
precious memory reserve doesn't get stuck waiting for user-space.

The correctness of this approach relies on the fact that networks must be
assumed lossy.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/core/filter.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/net/core/filter.c
===================================================================
--- linux-2.6.orig/net/core/filter.c
+++ linux-2.6/net/core/filter.c
@@ -81,6 +81,9 @@ int sk_filter(struct sock *sk, struct sk
 	int err;
 	struct sk_filter *filter;
 
+	if (skb_emergency(skb) && !sk_has_memalloc(sk))
+		return -ENOMEM;
+
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
