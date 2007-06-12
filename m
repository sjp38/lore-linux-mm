Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C59FTp013661
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:09:15 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C59FsI550948
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:09:15 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C59FdD027046
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:09:15 -0400
Date: Mon, 11 Jun 2007 22:09:10 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612050910.GU3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612034407.GB11773@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [20:44:07 -0700], William Lee Irwin III wrote:
> On 11.06.2007 [16:17:47 -0700], Christoph Lameter wrote:
> >> nid == 1 means local node? Or why do we check for nid < 0?
> >> 	if (nid == 1)
> >> 		 nid = numa_node_id();
> >> ?
> 
> On Mon, Jun 11, 2007 at 05:15:42PM -0700, Nishanth Aravamudan wrote:
> > No, nid is a static variable. So we initialize it to -1 to catch the
> > first time we go through the loop.
> > IIRC, we can't just set it to first_node(node_populated_map), because
> > it's a non-constant or something?
> 
> I wrote that, so I figure I should chime in. The static variable can
> be killed off outright.
> 
> Initially filling the pool doesn't need the static affair. Refilling
> the pool from the page allocator can refill the node with the least
> memory first, and choose randomly otherwise. Using default mpolicies
> or defaulting to node-local memory instead of round-robin allocation
> will likely do for callers into the allocator.
> 
> It depends a bit on what SGI's app that originally wanted striping of
> hugetlb does.
> 
> Also, if one has such a large number of nodes that exhaustive search
> for the node with the least memory would be prohibitive, esp. when in
> a loop, it's always possible to keep node ID's in an array
> heap-ordered by the number of pages in the node's segment of the pool.
> In such a manner the inner loop's search is limited to
> O(lg(nr_online_nodes())).

Well, (presuming I understood everything you wrote :), don't we need the
static 'affair' to guarantee the initial allocations are approximately
round-robin? Or, if we aren't going to make that guarantee, than we
should only change that once my sysfs allocator (or its equivalent) is
available?

Just trying to get a handle on what you're suggesting without any
historical context.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
