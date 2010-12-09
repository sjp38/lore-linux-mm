Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DB85E6B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 16:29:37 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oB9LTX8W003282
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 13:29:34 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by kpbe20.cbf.corp.google.com with ESMTP id oB9LTWQE001841
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 13:29:32 -0800
Received: by pzk2 with SMTP id 2so11622pzk.4
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 13:29:32 -0800 (PST)
Date: Thu, 9 Dec 2010 13:29:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
In-Reply-To: <20101209012124.GD5798@shaohui>
Message-ID: <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com> <20101209012124.GD5798@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, gregkh@suse.de, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 2010, Shaohui Zheng wrote:

> > I don't think you should be using memparse() to support this type of 
> > interface, the standard way of writing memory locations is by writing 
> > address in hex as the first example does.  The idea is to not try to make 
> > things simpler by introducing multiple ways of doing the same thing but 
> > rather to standardize on a single interface.
> 
> Undoubtedly, A hex is the best way to represent a physical address. If we use
> memparse function, we can use the much simpler way to represent an address,
> it is not the offical way, but it takes many conveniences if we just want to 
> to some simple test.
> 

Testing code should be removed from the patch prior to proposal.

> When we reserce memory, we use mempasre to parse the mem=XXX parameter, we can
> avoid the complicated translation when we add memory thru the add_memory interface,
> how about still use the memparse here? but remove it from the document since it is
> just for some simple testing. 
> 

We really don't want a public interface to have undocumented behavior, so 
it would be much better to retain the documentation if you choose to keep 
the memparse().  I disagree that converting the mem= parameter to hex is 
"complicated," however, so I'd prefer that the interface is similar to 
that of add_node.

> > > +	printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
> > > +	phys_addr = memparse(buf, NULL);
> > > +	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
> > 
> > Does the add_memory() call handle memoryless nodes such that they 
> > appropriately transition to N_HIGH_MEMORY when memory is added?
> 
> For memoryless nodes, it will cause OOM issue on old kernel version, but now
> memoryless node is already supported, and the test result matches it well. The
> emulator is a tool to reproduce the OOM issue in eraly kernel.
> 

That doesn't address the question.  My question is whether or not adding 
memory to a memoryless node in this way transitions its state to 
N_HIGH_MEMORY in the VM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
