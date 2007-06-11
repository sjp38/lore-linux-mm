Received: from e6.ny.us.ibm.com ([192.168.1.106])
	by pokfb.esmtp.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l5BHC8ul007356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:12:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BHDAFs031008
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:13:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BHC5md556478
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:12:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BHC4wW031466
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:12:05 -0400
Date: Mon, 11 Jun 2007 10:12:01 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some are unpopulated
Message-ID: <20070611171201.GB3798@us.ibm.com>
References: <20070607150425.GA15776@us.ibm.com> <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com> <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org> <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [09:42:14 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Christoph Lameter wrote:
> 
> > Well maybe we better fix this? I put an effort into using only cachelines 
> > already used for GFP_THISNODE since this is in a very performance 
> > critical path but at that point I was not thinking that we 
> > would have memoryless nodes.
> 
> Duh. Too bad. The node information is not available in __alloc_pages at 
> all. The only thing we have to go on is a zonelist. And the first element 
> of that zonelist must no longer be the node from which we picked up 
> the zonelist after memoryless nodes come into play.
> 
> We could check this for alloc_pages_node() and alloc_pages_current by 
> putting in some code into the place where we retrive the zonelist based on 
> the current policy.
> 
> And looking at that code I can see some more bad consequences of 
> memoryless nodes:
> 
> 1. Interleave to the memoryless node will be redirected to the nearest
>    node to the memoryless node. This will typically result in the nearest
>    node getting double the allocations if interleave is set.
> 
>    So interleave is basically broken. It will no longer spread out the
>    allocations properly.
> 
> 2. MPOL_BIND may allow allocations outside of the nodes specified.
>    It assumes that the first item of the zonelist of each node
>    is that zone.
> 
> 
> So we have a universal assumption in the VM that the first zone of a
> zonelist contains the local node. The current way of generating
> zonelists for memoryless zones is broken (unsurprisingly since the NUMA 
> handling was never designed to handle memoryless nodes).
> 
> I think we can to fix all these troubles by adding a empty zone as
> a first zone in the zonelist if the node has no memory of its own.
> Then we need to make sure that we do the right thing of falling back 
> anytime these empty zones will be encountered.
> 
> This will have the effect of
> 
> 1. GFP_THISNODE will fail since there is no memory in the empty zone.
> 
> 2. MPOL_BIND will not allocate on nodes outside of the specified set
>    since there will be an empty zone in the generated zonelist.
> 
> 3. Interleave will still hit an empty zones and fall back to the next.
>    We should add detection of memoryless nodes to mempoliy.c to skip
>    those nodes.

These are the exact semantics, I expected. so I'll be happy to test/work
on these fixes.

This would also make it unnecessary to add the populated checks in
various places, I think, as THISNODE will mean ONLYTHISNODE (and perhaps
should be renamed in the series).

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
