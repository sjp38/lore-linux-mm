Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 542BC6B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:31:57 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n8MHVqnN017754
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 18:31:52 +0100
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz1.hot.corp.google.com with ESMTP id n8MHVnxv030681
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:31:49 -0700
Received: by pxi12 with SMTP id 12so46914pxi.9
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:31:49 -0700 (PDT)
Date: Tue, 22 Sep 2009 10:31:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <20090922152649.GG25965@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909221018380.7114@chino.kir.corp.google.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253577603.7103.174.camel@pasglop> <20090922152649.GG25965@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, Mel Gorman wrote:

> Lumping the per-cpu allocator to cover per-cpu and per-node feels a bit
> confusing. Maybe it would have been easier if there simply were never
> memoryless nodes and cpus were always mapped to their closest, instead of
> their local, node. There likely would be a few corner cases though and memory
> hotplug would add to the mess. I haven't been able to decide on a sensible
> way forward that doesn't involve a number of invasive changes.
> 

I strongly agree with removing memoryless node support from the kernel, 
but I don't think we should substitute it with a multiple cpu binding 
approach because it doesn't export the true physical topology of the 
system.

If we treat all cpus equally with respect to a region of memory when one 
happens to be more remote, userspace can no longer use sched_setaffinity() 
for latency-sensitive apps nor can it correctly interleave with other 
nodes.  Reduced to its simplest form, a machine now with a single node 
because memoryless nodes have been obsoleted would incorrectly report that 
all cpus are true siblings.

While memoryless nodes are inconvenient for the implementation, they do 
have the benefit of being able to represent the actual physical topology 
when binding cpus to their nearest node, even though it may not be local, 
would not.

It's important to accurately represent the physical topology, and that can 
be done with the device class abstraction model as I described in 
http://lkml.org/lkml/2009/9/22/97 of which a node is only a locality of a 
particular type.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
