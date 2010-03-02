Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D45D6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 00:54:11 -0500 (EST)
Message-ID: <4B8CA7F5.1030802@cs.helsinki.fi>
Date: Tue, 02 Mar 2010 07:53:57 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] slab: add memory hotplug support
References: <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> Slab lacks any memory hotplug support for nodes that are hotplugged
> without cpus being hotplugged.  This is possible at least on x86
> CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
> ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
> node.  It can also be done manually by writing the start address to
> /sys/devices/system/memory/probe for kernels that have
> CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
> then onlining the new memory region.
> 
> When a node is hotadded, a nodelist for that node is allocated and 
> initialized for each slab cache.  If this isn't completed due to a lack
> of memory, the hotadd is aborted: we have a reasonable expectation that
> kmalloc_node(nid) will work for all caches if nid is online and memory is
> available.  
> 
> Since nodelists must be allocated and initialized prior to the new node's
> memory actually being online, the struct kmem_list3 is allocated off-node
> due to kmalloc_node()'s fallback.
> 
> When an entire node is offlined (or an online is aborted), these
> nodelists are subsequently drained and freed.  If objects still exist
> either on the partial or full lists for those nodes, the offline is
> aborted.  This scenario will not occur for an aborted online, however,
> since objects can never be allocated from those nodelists until the
> online has completed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Andi, does this fix the oops you were seeing?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
