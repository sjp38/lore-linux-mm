Message-Id: <20070504103159.868846185@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:10 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/40] netfilter: notify about NF_QUEUE vs emergency skbs
Content-Disposition: inline; filename=emergency-nf_queue.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Patrick McHardy <kaber@trash.net>
List-ID: <linux-mm.kvack.org>

Avoid memory getting stuck waiting for userspace, drop all emergency packets.
This of course requires the regular storage route to not include an NF_QUEUE
target ;-)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/core.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6-git/net/netfilter/core.c
===================================================================
--- linux-2.6-git.orig/net/netfilter/core.c	2007-02-22 15:48:28.000000000 +0100
+++ linux-2.6-git/net/netfilter/core.c	2007-02-26 14:23:25.000000000 +0100
@@ -184,9 +184,12 @@ next_hook:
 		ret = 1;
 		goto unlock;
 	} else if (verdict == NF_DROP) {
+drop:
 		kfree_skb(*pskb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
+		if (skb_emergency(*pskb))
+			goto drop;
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
 		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
