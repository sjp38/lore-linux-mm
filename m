Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACB946B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 17:21:26 -0400 (EDT)
Date: Wed, 1 Jul 2009 14:21:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
Message-Id: <20090701142152.7f41fe70.akpm@linux-foundation.org>
In-Reply-To: <20090630154818.1583.26154.sendpatchset@lts-notebook>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
	<20090630154818.1583.26154.sendpatchset@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.org, mel@csn.ul.ie, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009 11:48:18 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task mempolicy
> 
>
> ...
>
> +/**
> + * huge_mpol_nodes_allowed()
> + *
> + * Return a [pointer to a] nodelist for persistent huge page allocation
> + * based on the current task's mempolicy:
> + *
> + * If the task's mempolicy is "default" [NULL], just return NULL for
> + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> + * or 'interleave' policy or construct a nodemask for 'preferred' or
> + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> + * It is the caller's responsibility to free this nodemask.
> + */

Comment purports to be kereldoc but doesn't look very kerneldoccy?

> +nodemask_t *huge_mpol_nodes_allowed(void)
> +{
> +	nodemask_t *nodes_allowed = NULL;
> +	struct mempolicy *mempolicy;
> +	int nid;
> +
> +	if (!current || !current->mempolicy)
> +		return NULL;
> +
> +	mpol_get(current->mempolicy);
> +	nodes_allowed = kzalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> +	if (!nodes_allowed) {
> +		printk(KERN_WARNING "Unable to allocate nodes allowed mask "
> +			"for huge page allocation\nFalling back to default\n");

hm.  If we're going to emit a diagnostic on behalf of userspace, it
would be best if that diagnostic were to contain sufficient information
for the identification of the failing application (pid and comm, for
example).  Otherwise this mesasge would be a real head-scratcher on a
large and busy system.

> +		goto out;
> +	}
> +
> +	mempolicy = current->mempolicy;
> +	switch(mempolicy->mode) {
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
> +			*nodes_allowed =  mempolicy->v.nodes;

whitespace broke.

> +		break;
> +
> +	default:
> +		BUG();
> +	}
> +
> +out:
> +	mpol_put(current->mempolicy);
> +	return nodes_allowed;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
