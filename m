Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC1456B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 20:19:17 -0400 (EDT)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id n8M0JJBF019969
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 17:19:19 -0700
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by zps19.corp.google.com with ESMTP id n8M0FuO4031246
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 17:19:16 -0700
Received: by pzk38 with SMTP id 38so411066pzk.11
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 17:19:16 -0700 (PDT)
Date: Mon, 21 Sep 2009 17:19:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <1253577603.7103.174.camel@pasglop>
Message-ID: <alpine.DEB.1.00.0909211704180.4798@chino.kir.corp.google.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253577603.7103.174.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, Benjamin Herrenschmidt wrote:

> So if I understand correctly, we have a problem with both cpu-less and
> memory-less nodes. Interesting setups :-)
> 

I agree with Christoph that we need to resolve the larger kernel issue of 
memoryless nodes in the kernel and the result of that work will most 
likely become the basis from which the slqb fixes originate.

I disagree that we need kernel support for memoryless nodes on x86 and 
probably on all architectures period.  "NUMA nodes" will always contain 
memory by definition and I think hijacking the node abstraction away from 
representing anything but memory affinity is wrong in the interest of a 
long-term maintainable kernel and will continue to cause issues such as 
this in other subsystems.

I do understand the asymmetries of these machines, including the ppc that 
is triggering this particular hang with slqb.  But I believe the support 
can be implemented in a different way: I would offer an alternative 
representation based entirely on node distances.  This would isolate each 
region of memory that has varying affinity to cpus, pci busses, etc., into 
nodes and then report a distance, whether local or remote, to other nodes 
much in the way the ACPI specification does with proximity domains.

Using node distances instead of memoryless nodes would still be able to 
represent all asymmetric machines that currently benefit from the support 
by binding devices to memory regions to which they have the closest 
affinity and then reporting relative distances to other nodes via 
node_distance().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
