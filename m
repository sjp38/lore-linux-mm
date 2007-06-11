Date: Mon, 11 Jun 2007 16:15:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH][RFC] Fix INTERLEAVE with memoryless nodes
In-Reply-To: <20070611230829.GC14458@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Christoph was also worried about the performance impact on these paths,
> so, as he suggested, uninline alloc_pages_node() and move it to
> mempolicy.c.

uninlining does not address performance issues.

> @@ -184,6 +185,16 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
>  	atomic_set(&policy->refcnt, 1);
>  	switch (mode) {
>  	case MPOL_INTERLEAVE:
> +		/*
> +		 * Clear any memoryless nodes here so that v.nodes can be used
> +		 * without extra checks
> +		 */
> +		nid = first_node(*nodes);
> +		while (nid < MAX_NUMNODES) {
> +			if (!node_populated(nid))
> +				node_clear(nid, *nodes);
> +			nid = next_node(nid, *nodes);
> +		}

There is a "nodes_and" function for this.

> @@ -1126,9 +1153,11 @@ static unsigned interleave_nodes(struct mempolicy *policy)
>  	struct task_struct *me = current;
>  
>  	nid = me->il_next;
> -	next = next_node(nid, policy->v.nodes);
> -	if (next >= MAX_NUMNODES)
> -		next = first_node(policy->v.nodes);
> +	do {
> +		next = next_node(nid, policy->v.nodes);
> +		if (next >= MAX_NUMNODES)
> +			next = first_node(policy->v.nodes);
> +	} while (!node_populated(next));

Is there a case where nodes has no node set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
