Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 37AE96B0078
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 04:53:08 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o169r4xU025134
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 09:53:04 GMT
Received: from pxi40 (pxi40.prod.google.com [10.243.27.40])
	by spaceape9.eur.corp.google.com with ESMTP id o169r2LF008373
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 01:53:02 -0800
Received: by pxi40 with SMTP id 40so5013005pxi.21
        for <linux-mm@kvack.org>; Sat, 06 Feb 2010 01:53:02 -0800 (PST)
Date: Sat, 6 Feb 2010 01:53:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in
 fallback_alloc()
In-Reply-To: <20100206072508.GN29555@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002060148300.17897@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213912.D3081B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com> <20100206072508.GN29555@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 2010, Andi Kleen wrote:

> > That other node must be allowed by current's cpuset, otherwise 
> > kmem_getpages() will fail when get_page_from_freelist() iterates only over 
> > unallowed nodes.
> 
> All theses cases are really only interesting in the memory hotplug path
> itself (afterwards the slab is working anyways and memory is there)
> and if someone sets funny cpusets for those he gets what he deserves ...
> 

If a hot-added node has not been initialized for the cache, your code is 
picking an existing one in zonelist order which may be excluded by 
current's cpuset.  Thus, your code has a very real chance of having 
kmem_getpages() return NULL because get_page_from_freelist() will reject 
non-atomic ALLOC_CPUSET allocations for prohibited nodes.  That isn't a 
scenario that requires a "funny cpuset," it just has to not allow whatever 
initialized node comes first in the zonelist.

My suggested alternative does not pick a single initialized node, rather 
it tries all nodes that actually have a chance of having kmem_getpages() 
succeed which increases the probability that your patch actually has an 
effect for cpuset users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
