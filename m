Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 684A96B0088
	for <linux-mm@kvack.org>; Sun, 12 Dec 2010 22:34:56 -0500 (EST)
Date: Mon, 13 Dec 2010 10:09:25 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
Message-ID: <20101213020924.GB19637@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com>
 <20101209012124.GD5798@shaohui>
 <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com>
 <20101209235705.GA10674@shaohui>
 <alpine.DEB.2.00.1012101529190.30039@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012101529190.30039@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 03:30:38PM -0800, David Rientjes wrote:
> On Fri, 10 Dec 2010, Shaohui Zheng wrote:
> 
> > > That doesn't address the question.  My question is whether or not adding 
> > > memory to a memoryless node in this way transitions its state to 
> > > N_HIGH_MEMORY in the VM?
> > I guess that you are talking about memory hotplug on x86_32, memory hotplug is
> > NOT supported well for x86_32, and the function add_memory does not consider
> > this situlation.
> > 
> > For 64bit, N_HIGH_MEMORY == N_NORMAL_MEMORY, so we need not to do the transition.
> > 
> 
> One more time :)  Memoryless nodes do not have their bit set in 
> N_HIGH_MEMORY.  When memory is added to a memoryless node with this new 
> interface, does the bit get set?

When we use debugfs add_node interface to add a fake node, the node was created, 
and memory sections were created, but the state of the memory section is still 
__offline__, so the new added node is still memoryless node. the result of debugfs
add_memory interface doing the similar thing with add_node, it just add memory
to an exists node.

For the state transition to N_HIGH_MEMORY, it does not happen on the above too
interfaces. It happens when the memory was onlined with sysfs /sys/device/system/memory/memoryXX/online
interface.

That is the code path:
store_mem_state
	->memory_block_change_state
	 	->memory_block_action
			->online_pages

			if (onlined_pages) {
				kswapd_run(zone_to_nid(zone));
				node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
			}

does it address your question? thanks.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
