Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 47B256B0095
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 21:33:46 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6P1Xg9k022827
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 25 Jul 2009 10:33:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8503345DE4F
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 10:33:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 63F3945DE4E
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 10:33:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DA111DB803C
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 10:33:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E888D1DB803E
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 10:33:41 +0900 (JST)
Message-ID: <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090724160936.a3b8ad29.akpm@linux-foundation.org>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
    <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
    <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
    <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
    <20090724160936.a3b8ad29.akpm@linux-foundation.org>
Date: Sat, 25 Jul 2009 10:33:41 +0900 (JST)
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 24 Jul 2009 15:51:51 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:

> afaik we don't have a final patch for this.  I asked Motohiro-san about
> this and he's proposing that we revert the offending change (which one
> was it?) if nothing gets fixed soon - the original author is on a
> lengthy vacation.
>
>
> If we _do_ have a patch then can we start again?  Someone send out the
> patch
> and let's take a look at it.
Hmm, like this ? (cleaned up David's one because we shouldn't have
extra nodemask_t on stack.)

Problems are
  - rebind() is maybe broken but no good idea.
   (but it seems to be broken in old kernels
  - Who can test this is only a user who has possible node on SRAT.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At setting mempolicy's nodemask (or node id), we need to guarantee
node-id is online. But cpuset's nodemask may contain not-online(possible)
nodes and it can cause an access to NODE_DATA(nid) of not-online nodes.

This patch fiexs mempolicy's nodemask to be subset of valid nodes.
(N_HIGH_MEMORY).

But, there are 2 caes for setting policy's mask
 - new
 - rebind
A difficult case is rebind. In this patch, if relationship of
new cpuset's nodemask & policy's mask is invalid, just use cpuset's
mask.

Based on David Rientjes's patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/mempolicy.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

Index: mmotm-2.6.31-Jul16/mm/mempolicy.c
===================================================================
--- mmotm-2.6.31-Jul16.orig/mm/mempolicy.c
+++ mmotm-2.6.31-Jul16/mm/mempolicy.c
@@ -204,12 +204,22 @@ static int mpol_set_nodemask(struct memp
 	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
 		nodes = NULL;	/* explicit local allocation */
 	else {
+		/*
+		 * Here, we mask this new nodemask with N_HIGH_MEMORY.
+		 * An issue is memory hotplug. Now, at hot-add, we don't
+		 * update, this. This should be fixed. At hot-remove, we don't
+		 * remove pgdat  itself, then, we should update this but
+		 * we'll never see terrible bugs. Leaving it as it is, now.
+		 */
+		nodes_and(cpuset_context_mask, &cpuset_current_mems_allowed,
+			  node_states[N_HIGH_MEMORY]);
+		/* should we call is_valid_nodemask() here ?*/
 		if (pol->flags & MPOL_F_RELATIVE_NODES)
 			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
-					       &cpuset_current_mems_allowed);
+					       &cpuset_context_nmask);
 		else
 			nodes_and(cpuset_context_nmask, *nodes,
-				  cpuset_current_mems_allowed);
+				  cpuset_context_nmask);
 		if (mpol_store_user_nodemask(pol))
 			pol->w.user_nodemask = *nodes;
 		else
@@ -290,7 +300,16 @@ static void mpol_rebind_nodemask(struct
 			    *nodes);
 		pol->w.cpuset_mems_allowed = *nodes;
 	}
-
+	/*
+	 * At rebind, passed *nodes is guaranteed to online, but..calculated
+	 * nodemask can be empty or invalid. print WARNING and use cpuset's
+	 * mask
+	 */
+	if (nodes_empty(tmp) ||
+	    (pol->mode == MPOL_BIND && !is_valid_nodemask(tmp))) {
+		tmp = *nodes;
+	    printk("relation amoung cpuset/mempolicy goes bad.\n");
+	}
 	pol->v.nodes = tmp;
 	if (!node_isset(current->il_next, tmp)) {
 		current->il_next = next_node(current->il_next, tmp);







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
