From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:16 -0400
Message-Id: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 00/14] NUMA: Memoryless node support V4
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Changes V3->V4:
- Refresh against 23-rc1-mm1
- teach cpusets about memoryless nodes.

Changes V2->V3:
- Refresh patches (sigh)
- Add comments suggested by Kamezawa Hiroyuki
- Add signoff by Jes Sorensen

Changes V1->V2:
- Add a generic layer that allows the definition of additional node bitmaps

This patchset is implementing additional node bitmaps that allow the system
to track nodes that are online without memory and nodes that have processors.

In various subsystems we can use that information to customize VM behavior.


We define a number of node states that we track in enum node_states

/*
 * Bitmasks that are kept for all the nodes.
 */
enum node_states {
	N_POSSIBLE,     /* The node could become online at some point */
	N_ONLINE,       /* The node is online */
	N_MEMORY,       /* The node has memory */
	N_CPU,          /* The node has cpus */
	NR_NODE_STATES
};

and define operations using the node states:

static inline int node_state(int node, enum node_states state)
{
        return node_isset(node, node_states[state]);
}

static inline void node_set_state(int node, enum node_states state)
{
        __node_set(node, &node_states[state]);
}

static inline void node_clear_state(int node, enum node_states state)
{
        __node_clear(node, &node_states[state]);
}

static inline int num_node_state(enum node_states state)
{
        return nodes_weight(node_states[state]);
}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
