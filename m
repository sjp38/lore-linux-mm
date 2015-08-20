Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CD1C46B0253
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 20:02:56 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so6970075pdb.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:02:56 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id j2si4209114pdh.123.2015.08.19.17.02.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 17:02:56 -0700 (PDT)
Received: by pawq9 with SMTP id q9so13767868paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:02:55 -0700 (PDT)
Date: Wed, 19 Aug 2015 17:02:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem()
 to support memoryless node
In-Reply-To: <55D43C63.7060802@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1508191701010.30666@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com> <alpine.DEB.2.10.1508171723290.5527@chino.kir.corp.google.com> <55D43C63.7060802@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Wed, 19 Aug 2015, Jiang Liu wrote:

> > Why not simply fix build_zonelists_node() so that the __GFP_THISNODE 
> > zonelists are set up to reference the zones of cpu_to_mem() for memoryless 
> > nodes?
> > 
> > It seems much better than checking and maintaining every __GFP_THISNODE 
> > user to determine if they are using a memoryless node or not.  I don't 
> > feel that this solution is maintainable in the longterm.
> Hi David,
> 	There are some usage cases, such as memory migration,
> expect the page allocator rejecting memory allocation requests
> if there is no memory on local node. So we have:
> 1) alloc_pages_node(cpu_to_node(), __GFP_THISNODE) to only allocate
> memory from local node.
> 2) alloc_pages_node(cpu_to_mem(), __GFP_THISNODE) to allocate memory
> from local node or from nearest node if local node is memoryless.
> 

Right, so do you think it would be better to make the default zonelists be 
setup so that cpu_to_node()->zonelists == cpu_to_mem()->zonelists and then 
individual callers that want to fail for memoryless nodes check 
populated_zone() themselves?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
