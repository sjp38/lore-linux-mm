Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4F32A6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 19:15:54 -0400 (EDT)
Date: Thu, 10 Sep 2009 16:15:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
Message-Id: <20090910161525.dce065b0.akpm@linux-foundation.org>
In-Reply-To: <20090909163152.12963.80784.sendpatchset@localhost.localdomain>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	<20090909163152.12963.80784.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 09 Sep 2009 12:31:52 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> This patch derives a "nodes_allowed" node mask from the numa
> mempolicy of the task modifying the number of persistent huge
> pages to control the allocation, freeing and adjusting of surplus
> huge pages.
>
> ...
>

> Index: linux-2.6.31-rc7-mmotm-090827-1651/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-1651.orig/mm/mempolicy.c	2009-09-09 11:57:26.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-1651/mm/mempolicy.c	2009-09-09 11:57:36.000000000 -0400
> @@ -1564,6 +1564,57 @@ struct zonelist *huge_zonelist(struct vm
>  	}
>  	return zl;
>  }
> +
> +/*
> + * alloc_nodemask_of_mempolicy
> + *
> + * Returns a [pointer to a] nodelist based on the current task's mempolicy.
> + *
> + * If the task's mempolicy is "default" [NULL], return NULL for default
> + * behavior.  Otherwise, extract the policy nodemask for 'bind'
> + * or 'interleave' policy or construct a nodemask for 'preferred' or
> + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> + *
> + * N.B., it is the caller's responsibility to free a returned nodemask.
> + */
> +nodemask_t *alloc_nodemask_of_mempolicy(void)
> +{
> +	nodemask_t *nodes_allowed = NULL;
> +	struct mempolicy *mempolicy;
> +	int nid;
> +
> +	if (!current->mempolicy)
> +		return NULL;
> +
> +	mpol_get(current->mempolicy);
> +	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);

Ho hum.  I guess a caller which didn't permit GFP_KERNEL would be
pretty lame.

> +	if (!nodes_allowed)
> +		return NULL;		/* silently default */

Missed an mpol_put().

> +	nodes_clear(*nodes_allowed);
> +	mempolicy = current->mempolicy;
> +	switch (mempolicy->mode) {
> +	case MPOL_PREFERRED:
> +		if (mempolicy->flags & MPOL_F_LOCAL)
> +			nid = numa_node_id();
> +		else
> +			nid = mempolicy->v.preferred_node;
> +		node_set(nid, *nodes_allowed);
> +		break;
> +
> +	case MPOL_BIND:
> +		/* Fall through */
> +	case MPOL_INTERLEAVE:
> +		*nodes_allowed =  mempolicy->v.nodes;
> +		break;
> +
> +	default:
> +		BUG();
> +	}
> +
> +	mpol_put(current->mempolicy);
> +	return nodes_allowed;
> +}

Do we actually need the mpol_get()/put here?  Can some other process
really some in and trash a process's current->mempolicy when that
process isn't looking?

If so, why the heck isn't the code racy?

static inline void mpol_get(struct mempolicy *pol)
{
	if (pol)
		atomic_inc(&pol->refcnt);
}

If it's possible for some other task to trash current->mempolicy then
that trashing can happen between the `if' and the `atomic_inc', so
we're screwed.  

So either we need some locking here or the mpol_get() isn't needed on
current's mempolicy or the mpol_get() has some secret side-effect?


Fixlets:

--- a/mm/hugetlb.c~hugetlb-derive-huge-pages-nodes-allowed-from-task-mempolicy-fix
+++ a/mm/hugetlb.c
@@ -1253,7 +1253,7 @@ static unsigned long set_max_huge_pages(
 
 	nodes_allowed = alloc_nodemask_of_mempolicy();
 	if (!nodes_allowed) {
-		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
+		printk(KERN_WARNING "%s: unable to allocate nodes allowed mask "
 			"for huge page allocation.  Falling back to default.\n",
 			current->comm);
 		nodes_allowed = &node_online_map;
--- a/mm/mempolicy.c~hugetlb-derive-huge-pages-nodes-allowed-from-task-mempolicy-fix
+++ a/mm/mempolicy.c
@@ -1589,7 +1589,7 @@ nodemask_t *alloc_nodemask_of_mempolicy(
 	mpol_get(current->mempolicy);
 	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
 	if (!nodes_allowed)
-		return NULL;		/* silently default */
+		goto out;		/* silently default */
 
 	nodes_clear(*nodes_allowed);
 	mempolicy = current->mempolicy;
@@ -1611,7 +1611,7 @@ nodemask_t *alloc_nodemask_of_mempolicy(
 	default:
 		BUG();
 	}
-
+out:
 	mpol_put(current->mempolicy);
 	return nodes_allowed;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
