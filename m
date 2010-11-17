Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 48F816B0093
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 16:11:07 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id oAHLAw3d017624
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:10:58 -0800
Received: from gyd10 (gyd10.prod.google.com [10.243.49.202])
	by kpbe12.cbf.corp.google.com with ESMTP id oAHLAhvK030401
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:10:56 -0800
Received: by gyd10 with SMTP id 10so1610125gyd.18
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:10:56 -0800 (PST)
Date: Wed, 17 Nov 2010 13:10:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
In-Reply-To: <20101117075128.GA30254@shaohui>
Message-ID: <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com> <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Shaohui Zheng wrote:

> > Hmm, why can't you use numa=hide to hide a specified quantity of memory 
> > from the kernel and then use the add_memory() interface to hot-add the 
> > offlined memory in the desired quantity?  In other words, why do you need 
> > to track the offlined nodes with a state?
> > 
> > The userspace interface would take a desired size of hidden memory to 
> > hot-add and the node id would be the first_unset_node(node_online_map).
> Yes, it is a good idea, your solution is what we indeed do in our first 2
> versions.  We use mem=memsize to hide memory, and we call add_memory interface
> to hot-add offlined memory with desired quantity, and we can also add to
> desired nodes(even through the nodes does not exists). it is very flexible
> solution.
> 
> However, this solution was denied since we notice NUMA emulation, we should
> reuse it.
> 

I don't understand why that's a requirement, NUMA emulation is a seperate 
feature.  Although both are primarily used to test and instrument other VM 
and kernel code, NUMA emulation is restricted to only being used at boot 
to fake nodes on smaller machines and can be used to test things like the 
slab allocator.  The NUMA hotplug emulator that you're developing here is 
primarily used to test the hotplug callbacks; for that use-case, it seems 
particularly helpful if nodes can be hotplugged of various sizes and node 
ids rather than having static characteristics that cannot be changed with 
a reboot.

> Currently, our solution creates static nodes when OS boots, only the node with 
> state N_HIDDEN can be hot-added with node/probe interface, and we can query 
> 

The idea that I've proposed (and you've apparently thought about and even 
implemented at one point) is much more powerful than that.  We need not 
query the state of hidden nodes that we've setup at boot but can rather 
use the amount of hidden memory to setup the nodes in any way that we want 
at runtime (various sizes, interleaved node ids, etc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
