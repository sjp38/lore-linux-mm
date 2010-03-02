Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 452C16B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 16:03:13 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id o22L38IT005940
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 13:03:11 -0800
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by spaceape24.eur.corp.google.com with ESMTP id o22L36kS029938
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 13:03:07 -0800
Received: by pvc7 with SMTP id 7so190956pvc.21
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 13:03:06 -0800 (PST)
Date: Tue, 2 Mar 2010 13:03:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slab: add memory hotplug support
In-Reply-To: <alpine.DEB.2.00.1003021419020.30059@router.home>
Message-ID: <alpine.DEB.2.00.1003021253520.18137@chino.kir.corp.google.com>
References: <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi>
 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <4B8CA7F5.1030802@cs.helsinki.fi>
 <alpine.DEB.2.00.1003021419020.30059@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010, Christoph Lameter wrote:

> 
> Not sure how this would sync with slab use during node bootstrap and
> shutdown. Kame-san?
> 

All the nodelist allocation and initialization is done during 
MEM_GOING_ONLINE, so there should be no use of them until that 
notification cycle is done and it has graduated to MEM_ONLINE: if there 
are, there're even bigger problems because zonelist haven't even been 
built for that pgdat yet.  I can only speculate, but since Andi's 
patchset did all this during MEM_ONLINE, where the bit is already set in 
node_states[N_HIGH_MEMORY] and is passable to kmalloc_node(), this is 
probably why additional hacks had to be added elsewhere.

Other than that, concurrent kmem_cache_create() is protected by 
cache_chain_mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
