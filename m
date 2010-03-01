Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4C16B0078
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 05:27:41 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o21ARakA001129
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 10:27:36 GMT
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by spaceape14.eur.corp.google.com with ESMTP id o21ARYPL007920
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 02:27:34 -0800
Received: by pwi10 with SMTP id 10so1367635pwi.25
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 02:27:34 -0800 (PST)
Date: Mon, 1 Mar 2010 02:27:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <20100301105932.5db60c93.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003010224530.26824@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <20100226173115.GG16335@basil.fritz.box>
 <20100301105932.5db60c93.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > > Well Kamesan indicated that this worked if a cpu became online.
> > 
> > I mean in the general case. There were tons of problems all over.
> > 
> Then, it's cpu hotplug matter, not memory hotplug.
> cpu hotplug callback should prepaare 
> 
> 
> 	l3 = searchp->nodelists[node];
> 	BUG_ON(!l3);
> 
> before onlined. Rather than taking care of races.
> 

I can only speak for x86 and not the abundance of memory hotplug support 
that exists for powerpc, but cpu hotplug doesn't do _anything_ when a 
memory region that has a corresponding ACPI_SRAT_MEM_HOT_PLUGGABLE entry 
in the SRAT is hotadded and requires a new nodeid.  That can be triggered 
via the acpi layer with plug and play or explicitly from the command line 
via CONFIG_ARCH_MEMORY_PROBE.

Relying on cpu hotplug to set up nodelists in such a circumstance simply 
won't work.  You need memory hotplug support such as in my patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
