Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DKrKXw018329
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 16:53:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DKrKhC281124
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 16:53:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DKrKY8015098
	for <linux-mm@kvack.org>; Wed, 13 Sep 2006 16:53:20 -0400
Subject: Re: [PATCH] Get rid of zone_table
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 13:53:15 -0700
Message-Id: <1158180795.9141.158.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-13 at 13:44 -0700, Christoph Lameter wrote:
> The zone table is mostly not needed. If we have a node in the page flags 
> then we can get to the zone via NODE_DATA(). In case of SMP and UP 
> NODE_DATA() is a constant pointer which allows us to access an exact 
> replica of zonetable in the node_zones field. In all of the above cases 
> there will be no need at all for the zone table.
> 
> The only remaining case is if in a NUMA system the node numbers do not fit 
> into the page flags. In that case we make sparse generate a table that 
> maps sections to nodes and use that table to to figure out the node 
> number.
> 
> For sparsemem the zone table seems to be have been fairly large based on 
> the maximum possible number of sections and the number of zones per node.
> 
> The section_to_node table (if we still need it) is still the size of the 
> number of sections but the individual elements are integers (which already 
> saves 50% on 64 bit platforms) and we do not need to duplicate the entries 
> per zone type. So even if we have to keep the table then we shrink it to 
> 1/4th (32bit) or 1/8th )(64bit).

It doesn't feel like this is the best fit to go with sparsemem, but the
impact is pretty tiny, and it does seem somewhat sensible to put it
there.

A few concerns: is there a cache or readability impact from keeping this
structure separate from the mem_section, when it is logically and
functionally pretty paired with it?  It doesn't work with
SPARSEMEM_EXTREME (it would just blow up horribly), and this part at
least deserves a comment.  Is there any impact from making this a
non-inlined call, unlike the old zonetable lookup?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
