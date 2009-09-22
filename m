Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D77696B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 03:59:30 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n8M7xPXM012994
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:59:25 +0100
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by spaceape9.eur.corp.google.com with ESMTP id n8M7wr0m018605
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 00:59:22 -0700
Received: by pzk31 with SMTP id 31so2994120pzk.23
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 00:59:22 -0700 (PDT)
Date: Tue, 22 Sep 2009 00:59:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <alpine.DEB.1.10.0909220227050.3719@V090114053VZO-1>
Message-ID: <alpine.DEB.1.00.0909220023070.9061@chino.kir.corp.google.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253577603.7103.174.camel@pasglop> <alpine.DEB.1.00.0909211704180.4798@chino.kir.corp.google.com> <alpine.DEB.1.10.0909220227050.3719@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, Christoph Lameter wrote:

> How would you deal with a memoryless node that has lets say 4 processors
> and some I/O devices? Now the memory policy is round robin and there are 4
> nodes at the same distance with 4G memory each. Does one of the nodes now
> become priviledged under your plan? How do you equally use memory from all
> these nodes?
> 

If the distance between the memoryless node with the cpus/devices and all 
4G nodes is the same, then this is UMA and no abstraction is necessary: 
there's no reason to support interleaving of memory allocations amongst 
four different regions of memory if there's no difference in latencies to 
those regions.

It is possible, however, to have a system configured in such a way that 
representing all devices, including memory, at a single level of 
abstraction isn't possible.  An example is a four cpu system where cpus 
0-1 have local distance to all memory and cpus 2-3 have remote distance.

A solution would be to abstract everything into "system localities" like 
the ACPI specification does.  These localities in my plan are slightly 
different, though: they are limited to only a single class of device.

A locality is simply an aggregate of a particular type of device; a device 
is bound to a locality if it shares the same proximity as all other 
devices in that locality to all other localities.  In other words, the  
previous example would have two cpu localities: one with cpus 0-1 and one 
with cpus 2-3.  If cpu 0 had a different proximity than cpu 1 to a pci 
bus, however, there would be three cpu localities.

The equivalent of proximity domains then describes the distance between 
all localities; these distances need not be one-way, it is possible for 
distance in one direction to be different from the opposite direction, 
just as ACPI pxm's allow.

A "node" in this plan is simply a system locality consisting of memory.

For subsystems such as slab allocators, all we require is cpu_to_node() 
tables which would map cpu localities to nodes and describe them in terms 
of local or remote distance (or whatever the SLIT says, if provided).  All 
present day information can still be represented in this model, we've just 
added additional layers of abstraction internally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
