Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DFB06B0208
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 16:46:05 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o34Kk0xR026725
	for <linux-mm@kvack.org>; Sun, 4 Apr 2010 22:46:01 +0200
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by hpaq3.eem.corp.google.com with ESMTP id o34Kjvp6016755
	for <linux-mm@kvack.org>; Sun, 4 Apr 2010 22:45:59 +0200
Received: by pwi6 with SMTP id 6so2432701pwi.4
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 13:45:57 -0700 (PDT)
Date: Sun, 4 Apr 2010 13:45:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] slab: add memory hotplug support
In-Reply-To: <alpine.DEB.2.00.1003301141190.24717@router.home>
Message-ID: <alpine.DEB.2.00.1004041336450.4184@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>  <20100226155755.GE16335@basil.fritz.box>  <alpine.DEB.2.00.1002261123520.7719@router.home>  <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>  <20100305062002.GV8653@laptop>  <alpine.DEB.2.00.1003081502400.30456@chino.kir.corp.google.com>  <20100309134633.GM8653@laptop>  <alpine.DEB.2.00.1003271849260.7249@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003271940190.8399@chino.kir.corp.google.com> <84144f021003300201x563c72vb41cc9de359cc7d0@mail.gmail.com> <alpine.DEB.2.00.1003301141190.24717@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Christoph Lameter wrote:

> > Nick, Christoph, lets make a a deal: you ACK, I merge. How does that
> > sound to you?
> 
> I looked through the patch before and slabwise this seems to beok but I am
> still not very sure how this interacts with the node and cpu bootstrap.
> You can have the ack with this caveat.
> 
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> 

Thanks.

I tested this for node hotplug by setting ACPI_SRAT_MEM_HOT_PLUGGABLE 
regions and then setting up a new memory section with 
/sys/devices/system/memory/probe.  I onlined the new memory section, which 
mapped to an offline node, and verified that the nwe nodelists were 
initialized correctly.  This is done before the MEM_ONLINE notifier and 
the bit being set in node_states[N_HIGH_MEMORY].  So, for node hot-add, it 
works.

MEM_GOING_OFFLINE is more interesting, but there's nothing harmful about 
draining the freelist and reporting whether there are existing full or 
partial slabs back to the memory hotplug layer to preempt a hot-remove 
since those slabs cannot be freed.  I don't consider that to be a risky 
change.

As far as the interactions between memory and cpu hotplug, they are really 
different things with many of the same implications for the slab layer.  
Both have the possibility of bringing new nodes online or offline and they 
must be dealt with accordingly.  We lack support for offlining an entire 
node at a time since we must hotplug first by adding a new memory section, 
so these notifiers won't be called simultaneously.  Even if they were, 
draining the freelist and checking if a nodelist needs to be initialized 
is not going to be harmful since both notifiers have the same checks for 
existing nodelists (which is not only necessary if we _did_ have 
simultaneous cpu and memory hot-add, but also if a node transitioned from 
online to offline and back to online).

I hope this patch is merged because it obviously fixed a problem on my box 
where a memory section could be added, a node onlined, and then no slab 
metadata being initialized for that memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
