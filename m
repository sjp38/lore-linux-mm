Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDF156B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:42:06 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o1BLfvHj002238
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 21:41:58 GMT
Received: from pxi38 (pxi38.prod.google.com [10.243.27.38])
	by kpbe16.cbf.corp.google.com with ESMTP id o1BLfZnn012082
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:41:56 -0800
Received: by pxi38 with SMTP id 38so176283pxi.21
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:41:56 -0800 (PST)
Date: Thu, 11 Feb 2010 13:41:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc()
 v2
In-Reply-To: <20100211205401.002CFB1978@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002111338090.8809@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205401.002CFB1978@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Andi Kleen wrote:

> When fallback_alloc() runs the node of the CPU might not be initialized yet.
> Handle this case by allocating in another node.
> 
> v2: Try to allocate from all nodes (David Rientjes)
> 

You don't need to specifically address the cpuset restriction in 
fallback_alloc() since kmem_getpages() will return NULL whenever a zone is 
tried from an unallowed node, I just thought it was a faster optimization 
considering you (i) would operate over a nodemask and not the entire 
zonelist, (ii) it would avoid the zone_to_nid() for all zones since you 
already did a zonelist iteration in this function, and (iii) it wouldn't 
needlessly call kmem_getpages() for unallowed nodes.

> Signed-off-by: Andi Kleen <ak@linux.intel.com>

That said, I don't want to see this fix go unmerged since you already 
declined to make that optimization once:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
