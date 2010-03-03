Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF14D6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 21:39:31 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o232dRXH010595
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 02:39:27 GMT
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by spaceape23.eur.corp.google.com with ESMTP id o232dOg9009175
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 18:39:26 -0800
Received: by pvg12 with SMTP id 12so267845pvg.18
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 18:39:24 -0800 (PST)
Date: Tue, 2 Mar 2010 18:39:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slab: add memory hotplug support
In-Reply-To: <20100303102844.fe740203.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021836040.2205@chino.kir.corp.google.com>
References: <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi>
 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <4B8CA7F5.1030802@cs.helsinki.fi> <alpine.DEB.2.00.1003021419020.30059@router.home>
 <20100303102844.fe740203.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:

> At node hot-add
> 
>  * pgdat is allocated from other node (because we have no memory for "nid")
>  * memmap for the first section (and possiby others) will be allocated from
>    other nodes.
>  * Once a section for the node is onlined, any memory can be allocated localy.
> 

Correct, and the struct kmem_list3 is also alloacted from other nodes with 
my patch.

>    (Allocating memory from local node requires some new implementation as
>     bootmem allocater, we didn't that.)
> 
>  Before this patch, slab's control layer is allocated by cpuhotplug.
>  So, at least keeping this order,
>     memory online -> cpu online
>  slab's control layer is allocated from local node.
> 
>  When node-hotadd is done in this order
>     cpu online -> memory online
>  kmalloc_node() will allocate memory from other node via fallback.
> 
>  After this patch, slab's control layer is allocated by memory hotplug.
>  Then, in any order, slab's control will be allocated via fallback routine.
> 

Again, this addresses memory hotplug that requires a new node to be 
onlined that do not have corresponding cpus that are being onlined.  On 
x86, these represent ACPI_SRAT_MEM_HOT_PLUGGABLE regions that are onlined 
either by the acpi hotplug or done manually with CONFIG_ARCH_MEMORY_PROBE.  
On other architectures such as powerpc, this is done in different ways.

All of this is spelled out in the changelog for the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
