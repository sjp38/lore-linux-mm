Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1EC1B6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 21:54:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o232sgfD014614
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 11:54:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C9EB45DE57
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 11:54:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8E3845DE4E
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 11:54:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC7DFE38004
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 11:54:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F8041DB8038
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 11:54:41 +0900 (JST)
Date: Wed, 3 Mar 2010 11:51:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] slab: add memory hotplug support
Message-Id: <20100303115110.97361d5d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021836040.2205@chino.kir.corp.google.com>
References: <20100215105253.GE21783@one.firstfloor.org>
	<20100215110135.GN5723@laptop>
	<alpine.DEB.2.00.1002191222320.26567@router.home>
	<20100220090154.GB11287@basil.fritz.box>
	<alpine.DEB.2.00.1002240949140.26771@router.home>
	<4B862623.5090608@cs.helsinki.fi>
	<alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002251228140.18861@router.home>
	<20100226114136.GA16335@basil.fritz.box>
	<alpine.DEB.2.00.1002260904311.6641@router.home>
	<20100226155755.GE16335@basil.fritz.box>
	<alpine.DEB.2.00.1002261123520.7719@router.home>
	<alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
	<4B8CA7F5.1030802@cs.helsinki.fi>
	<alpine.DEB.2.00.1003021419020.30059@router.home>
	<20100303102844.fe740203.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021836040.2205@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 18:39:20 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > At node hot-add
> > 
> >  * pgdat is allocated from other node (because we have no memory for "nid")
> >  * memmap for the first section (and possiby others) will be allocated from
> >    other nodes.
> >  * Once a section for the node is onlined, any memory can be allocated localy.
> > 
> 
> Correct, and the struct kmem_list3 is also alloacted from other nodes with 
> my patch.
> 
> >    (Allocating memory from local node requires some new implementation as
> >     bootmem allocater, we didn't that.)
> > 
> >  Before this patch, slab's control layer is allocated by cpuhotplug.
> >  So, at least keeping this order,
> >     memory online -> cpu online
> >  slab's control layer is allocated from local node.
> > 
> >  When node-hotadd is done in this order
> >     cpu online -> memory online
> >  kmalloc_node() will allocate memory from other node via fallback.
> > 
> >  After this patch, slab's control layer is allocated by memory hotplug.
> >  Then, in any order, slab's control will be allocated via fallback routine.
> > 
> 
> Again, this addresses memory hotplug that requires a new node to be 
> onlined that do not have corresponding cpus that are being onlined.  On 
> x86, these represent ACPI_SRAT_MEM_HOT_PLUGGABLE regions that are onlined 
> either by the acpi hotplug or done manually with CONFIG_ARCH_MEMORY_PROBE.  
> On other architectures such as powerpc, this is done in different ways.
> 
> All of this is spelled out in the changelog for the patch.
> 
Ah, ok. for cpu-less node and kmallco_node() against that node.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
