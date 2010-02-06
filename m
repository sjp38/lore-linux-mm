Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A61886B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 10:56:32 -0500 (EST)
Date: Sat, 6 Feb 2010 16:56:24 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in fallback_alloc()
Message-ID: <20100206155624.GA2777@one.firstfloor.org>
References: <201002031039.710275915@firstfloor.org> <20100203213912.D3081B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com> <20100206072508.GN29555@one.firstfloor.org> <alpine.DEB.2.00.1002060148300.17897@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002060148300.17897@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If a hot-added node has not been initialized for the cache, your code is 
> picking an existing one in zonelist order which may be excluded by 
> current's cpuset.  Thus, your code has a very real chance of having 
> kmem_getpages() return NULL because get_page_from_freelist() will reject 
> non-atomic ALLOC_CPUSET allocations for prohibited nodes.  That isn't a 
> scenario that requires a "funny cpuset," it just has to not allow whatever 
> initialized node comes first in the zonelist.

The point was that you would need to run whoever triggers the memory
hotadd in a cpuset with limitations. That would be a clear
don't do that if hurts(tm)
 
> My suggested alternative does not pick a single initialized node, rather 
> it tries all nodes that actually have a chance of having kmem_getpages() 
> succeed which increases the probability that your patch actually has an 
> effect for cpuset users.

cpuset users are unlikely to trigger memory hotadds from inside limiting
cpusets. Typically that's done from udev etc.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
