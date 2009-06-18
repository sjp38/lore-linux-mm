Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6146C6B005A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 15:08:15 -0400 (EDT)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id n5IJ8OGU029072
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 20:08:25 +0100
Received: from wf-out-1314.google.com (wfg24.prod.google.com [10.142.7.24])
	by zps76.corp.google.com with ESMTP id n5IJ8LQB004615
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:08:22 -0700
Received: by wf-out-1314.google.com with SMTP id 24so455749wfg.20
        for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:08:21 -0700 (PDT)
Date: Thu, 18 Jun 2009 12:08:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
In-Reply-To: <1245258954.6235.58.camel@lts-notebook>
Message-ID: <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jun 2009, Lee Schermerhorn wrote:

> > > Specifically, there is no easy
> > > way to reduce the persistent huge page count for a specific node.
> > > I think the degree of control provided by these patches is the
> > > minimal necessary and sufficient for managing the persistent the
> > > huge page pool.  However, with a bit more reorganization,  we
> > > could implement per node controls if others would find that
> > > useful.
> > > 

Thanks for looking at this, it's going to be very useful.

>From a cpusets perspective, control over the hugepage allocations on 
various nodes is essential when the number of nodes on the system is not 
trivially small.  While cpusets are generally used to assign applications 
to a set of nodes to which they have affinity, they are also hierarchial 
so that within a cpuset, nodes can be further divided as a means of 
resource management.  With your extensions, this could potentially include 
hugepage management in addition to strict memory isolation.

Manipulating hugepages via a nodemask seems less ideal than, as you 
mentioned, per-node hugepage controls, probably via 
/sys/kernel/system/node/node*/nr_hugepages.  This type of interface 
provides all the functionality that this patchset does, including hugepage 
allocation and freeing, but with more power to explicitly allocate and 
free on targeted nodes.  /proc/sys/vm/nr_hugepages would remain to 
round-robin the allocation (and freeing, with your patch 1/5 which I 
ack'd).

Such an interface would also automatically deal with all memory 
hotplug/remove issues without storing or keeping a nodemask updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
