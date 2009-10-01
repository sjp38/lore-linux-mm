Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E62A3600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:28:34 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 21/31] netfilter: NF_QUEUE vs emergency skbs
Date: Thu,  1 Oct 2009 19:38:49 +0530
Message-Id: <1254406129-16409-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Avoid memory getting stuck waiting for userspace, drop all emergency packets.
This of course requires the regular storage route to not include an NF_QUEUE
target ;-)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 net/netfilter/core.c |    3 +++
 1 file changed, 3 insertions(+)

Index: mmotm/net/netfilter/core.c
===================================================================
--- mmotm.orig/net/netfilter/core.c
+++ mmotm/net/netfilter/core.c
@@ -175,9 +175,12 @@ next_hook:
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
 	} else if (verdict == NF_DROP) {
+drop:
 		kfree_skb(skb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+		if (skb_emergency(skb))
+			goto drop;
 		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
