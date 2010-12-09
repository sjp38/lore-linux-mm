Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 259166B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:22:09 -0500 (EST)
Date: Fri, 10 Dec 2010 07:57:05 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
Message-ID: <20101209235705.GA10674@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com>
 <20101209012124.GD5798@shaohui>
 <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 01:29:28PM -0800, David Rientjes wrote:
> On Thu, 9 Dec 2010, Shaohui Zheng wrote:
> 
> > > I don't think you should be using memparse() to support this type of 
> > > interface, the standard way of writing memory locations is by writing 
> > > address in hex as the first example does.  The idea is to not try to make 
> > > things simpler by introducing multiple ways of doing the same thing but 
> > > rather to standardize on a single interface.
> > 
> > Undoubtedly, A hex is the best way to represent a physical address. If we use
> > memparse function, we can use the much simpler way to represent an address,
> > it is not the offical way, but it takes many conveniences if we just want to 
> > to some simple test.
> > 
> 
> Testing code should be removed from the patch prior to proposal.
> 
> > When we reserce memory, we use mempasre to parse the mem=XXX parameter, we can
> > avoid the complicated translation when we add memory thru the add_memory interface,
> > how about still use the memparse here? but remove it from the document since it is
> > just for some simple testing. 
> > 
> 
> We really don't want a public interface to have undocumented behavior, so 
> it would be much better to retain the documentation if you choose to keep 
> the memparse().  I disagree that converting the mem= parameter to hex is 
> "complicated," however, so I'd prefer that the interface is similar to 
> that of add_node.
> 

Okay, I will keep interface to accept hex address which is simliar wiht add_node.

> > > > +	printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
> > > > +	phys_addr = memparse(buf, NULL);
> > > > +	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
> > > 
> > > Does the add_memory() call handle memoryless nodes such that they 
> > > appropriately transition to N_HIGH_MEMORY when memory is added?
> > 
> > For memoryless nodes, it will cause OOM issue on old kernel version, but now
> > memoryless node is already supported, and the test result matches it well. The
> > emulator is a tool to reproduce the OOM issue in eraly kernel.
> > 
> 
> That doesn't address the question.  My question is whether or not adding 
> memory to a memoryless node in this way transitions its state to 
> N_HIGH_MEMORY in the VM?
I guess that you are talking about memory hotplug on x86_32, memory hotplug is
NOT supported well for x86_32, and the function add_memory does not consider
this situlation.

For 64bit, N_HIGH_MEMORY == N_NORMAL_MEMORY, so we need not to do the transition.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
