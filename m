Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8259E6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 03:01:47 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o1P81hvl016880
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 08:01:44 GMT
Received: from pzk15 (pzk15.prod.google.com [10.243.19.143])
	by wpaz13.hot.corp.google.com with ESMTP id o1P81gfk006452
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 00:01:42 -0800
Received: by pzk15 with SMTP id 15so716709pzk.20
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 00:01:42 -0800 (PST)
Date: Thu, 25 Feb 2010 00:01:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <4B862623.5090608@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org>
 <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010, Pekka Enberg wrote:

> > > > > I'm just worried there is still an underlying problem here.
> > > > So am I. What caused the breakage that requires this patchset?
> > > Memory hotadd with a new node being onlined.
> > 
> > That used to work fine.
> 
> OK, can we get this issue resolved? The merge window is open and Christoph
> seems to be unhappy with the whole patch queue. I'd hate this bug fix to miss
> .34...
> 

I don't see how memory hotadd with a new node being onlined could have 
worked fine before since slab lacked any memory hotplug notifier until 
Andi just added it.

That said, I think the first and fourth patch in this series may be 
unnecessary if slab's notifier were to call slab_node_prepare() on 
MEM_GOING_ONLINE instead of MEM_ONLINE.  Otherwise, kswapd is already 
running, the zonelists for the new pgdat have been initialized, and the 
bit has been set in node_states[N_HIGH_MEMORY] without allocated 
cachep->nodelists[node] memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
