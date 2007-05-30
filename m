Date: Tue, 29 May 2007 21:14:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 7/7] Add /proc/sys/vm/compact_node for the explicit
 compaction of a node
In-Reply-To: <20070529173830.1570.91184.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705292109460.29854@schroedinger.engr.sgi.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
 <20070529173830.1570.91184.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 May 2007, Mel Gorman wrote:

> +	if (nodeid < 0)
> +		return -EINVAL;
> +
> +	pgdat = NODE_DATA(nodeid);
> +	if (!pgdat || pgdat->node_id != nodeid)
> +		return -EINVAL;

You cannot pass an arbitrary number to node data since NODE_DATA may do a 
simple array lookup.

Check for node < nr_node_ids first.

pgdat->node_id != nodeid? Sounds like something you should BUG() on.

IA64's NODE_DATA is

struct ia64_node_data {
        short                   active_cpu_count;
        short                   node;
        struct pglist_data      *pg_data_ptrs[MAX_NUMNODES];
};

/*
 * Given a node id, return a pointer to the pg_data_t for the node.
 *
 * NODE_DATA    - should be used in all code not related to system
 *                initialization. It uses pernode data structures to minimize
 *                offnode memory references. However, these structure are not
 *                present during boot. This macro can be used once cpu_init
 *                completes.
 */
#define NODE_DATA(nid)          (local_node_data->pg_data_ptrs[nid])

x86_64 also does

#define NODE_DATA(nid)          (node_data[nid])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
