Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id EC1886B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 23:29:27 -0500 (EST)
Received: by iajr24 with SMTP id r24so10478288iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 20:29:27 -0800 (PST)
Date: Tue, 6 Mar 2012 20:29:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: make mempolicies robust against errors
In-Reply-To: <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

It's unnecessary to BUG() in situations when a mempolicy has an
unsupported mode, it just means that a mode doesn't have complete coverage
in all mempolicy functions -- which is an error, but not a fatal error --
or that a bit has flipped.  Regardless, it's sufficient to warn the user
in the kernel log of the situation once and then proceed without crashing
the system.

This patch converts nearly all the BUG()'s in mm/mempolicy.c to
WARN_ON_ONCE(1) and provides the necessary code to return successfully.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c |   34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -303,7 +303,7 @@ static void mpol_rebind_default(struct mempolicy *pol, const nodemask_t *nodes,
 static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 				 enum mpol_rebind_step step)
 {
-	nodemask_t tmp;
+	nodemask_t tmp = NODE_MASK_NONE;
 
 	if (pol->flags & MPOL_F_STATIC_NODES)
 		nodes_and(tmp, pol->w.user_nodemask, *nodes);
@@ -322,7 +322,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 			tmp = pol->w.cpuset_mems_allowed;
 			pol->w.cpuset_mems_allowed = *nodes;
 		} else
-			BUG();
+			WARN_ON_ONCE(1);
 	}
 
 	if (nodes_empty(tmp))
@@ -333,7 +333,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 	else if (step == MPOL_REBIND_ONCE || step == MPOL_REBIND_STEP2)
 		pol->v.nodes = tmp;
 	else
-		BUG();
+		WARN_ON_ONCE(1);
 
 	if (!node_isset(current->il_next, tmp)) {
 		current->il_next = next_node(current->il_next, tmp);
@@ -397,15 +397,19 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
 	if (step == MPOL_REBIND_STEP1 && (pol->flags & MPOL_F_REBINDING))
 		return;
 
-	if (step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING))
-		BUG();
+	if (step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING)) {
+		WARN_ON_ONCE(1);
+		return;
+	}
 
 	if (step == MPOL_REBIND_STEP1)
 		pol->flags |= MPOL_F_REBINDING;
 	else if (step == MPOL_REBIND_STEP2)
 		pol->flags &= ~MPOL_F_REBINDING;
-	else if (step >= MPOL_REBIND_NSTEP)
-		BUG();
+	else if (step >= MPOL_REBIND_NSTEP) {
+		WARN_ON_ONCE(1);
+		return;
+	}
 
 	mpol_ops[pol->mode].rebind(pol, newmask, step);
 }
@@ -789,7 +793,7 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 		/* else return empty node mask for local allocation */
 		break;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 	}
 }
 
@@ -1552,7 +1556,7 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 			nd = first_node(policy->v.nodes);
 		break;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 	}
 	return node_zonelist(nd, gfp);
 }
@@ -1611,7 +1615,7 @@ unsigned slab_node(struct mempolicy *policy)
 	}
 
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 		return numa_node_id();
 	}
 }
@@ -1751,7 +1755,7 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 		break;
 
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 	}
 	task_unlock(current);
 
@@ -1796,7 +1800,7 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 		ret = nodes_intersects(mempolicy->v.nodes, *mask);
 		break;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 	}
 out:
 	task_unlock(tsk);
@@ -2005,7 +2009,7 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 		return false;
 	}
 }
@@ -2521,7 +2525,9 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 		break;
 
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
+		mode = MPOL_DEFAULT;
+		nodes_clear(nodes);
 	}
 
 	l = strlen(policy_modes[mode]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
