Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA2C6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 16:05:44 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n6GK5c0T010401
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:05:38 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz33.hot.corp.google.com with ESMTP id n6GK4Z5K026141
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:05:35 -0700
Received: by pzk2 with SMTP id 2so234210pzk.31
        for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:05:34 -0700 (PDT)
Date: Thu, 16 Jul 2009 13:05:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Lee Schermerhorn wrote:

> Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> with memory].  Maybe this is a to support hot-plug?
> 

numactl --interleave=all simply passes a nodemask with all bits set, so if 
cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
then mpol_set_nodemask() doesn't mask them off.

Seems like we could handle this strictly in mempolicies without worrying 
about top_cpuset like in the following?
---
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -194,6 +194,7 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
 static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
 {
 	nodemask_t cpuset_context_nmask;
+	nodemask_t mems_allowed;
 	int ret;
 
 	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
@@ -201,20 +202,21 @@ static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
 		return 0;
 
 	VM_BUG_ON(!nodes);
+	nodes_and(mems_allowed, cpuset_current_mems_allowed,
+				node_states[N_HIGH_MEMORY]);
 	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
 		nodes = NULL;	/* explicit local allocation */
 	else {
 		if (pol->flags & MPOL_F_RELATIVE_NODES)
 			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
-					       &cpuset_current_mems_allowed);
+					       &mems_allowed);
 		else
 			nodes_and(cpuset_context_nmask, *nodes,
-				  cpuset_current_mems_allowed);
+				  mems_allowed);
 		if (mpol_store_user_nodemask(pol))
 			pol->w.user_nodemask = *nodes;
 		else
-			pol->w.cpuset_mems_allowed =
-						cpuset_current_mems_allowed;
+			pol->w.cpuset_mems_allowed = mems_allowed;
 	}
 
 	ret = mpol_ops[pol->mode].create(pol,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
