Date: Mon, 11 Jun 2007 20:44:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612034407.GB11773@holomorphy.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612001542.GJ14458@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [16:17:47 -0700], Christoph Lameter wrote:
>> nid == 1 means local node? Or why do we check for nid < 0?
>> 	if (nid == 1)
>> 		 nid = numa_node_id();
>> ?

On Mon, Jun 11, 2007 at 05:15:42PM -0700, Nishanth Aravamudan wrote:
> No, nid is a static variable. So we initialize it to -1 to catch the
> first time we go through the loop.
> IIRC, we can't just set it to first_node(node_populated_map), because
> it's a non-constant or something?

I wrote that, so I figure I should chime in. The static variable can
be killed off outright.

Initially filling the pool doesn't need the static affair. Refilling
the pool from the page allocator can refill the node with the least
memory first, and choose randomly otherwise. Using default mpolicies
or defaulting to node-local memory instead of round-robin allocation
will likely do for callers into the allocator.

It depends a bit on what SGI's app that originally wanted striping of
hugetlb does.

Also, if one has such a large number of nodes that exhaustive search
for the node with the least memory would be prohibitive, esp. when in
a loop, it's always possible to keep node ID's in an array heap-ordered
by the number of pages in the node's segment of the pool. In such a
manner the inner loop's search is limited to O(lg(nr_online_nodes())).


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
