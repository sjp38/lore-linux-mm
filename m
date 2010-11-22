Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 41ACD6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 22:08:48 -0500 (EST)
Date: Mon, 22 Nov 2010 09:47:06 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [patch 2/2] mm: add node hotplug emulation
Message-ID: <20101122014706.GB9081@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF28723FC4A7@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF28723FC4A7@shsmsx502.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, gregkh@suse.de, rientjes@google.com
Cc: mingo@redhat.com, hpa@zytor.com, tglx@linutronix.de, lethal@linux-sh.org, ak@linux.intel.com, yinghai@kernel.org, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, haicheng.li@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com, shaohui.zheng@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 09:47:02AM +0800, Zheng, Shaohui wrote:
> Add an interface to allow new nodes to be added when performing memory
> hot-add.  This provides a convenient interface to test memory hotplug
> notifier callbacks and surrounding hotplug code when new nodes are
> onlined without actually having a machine with such hotpluggable SRAT
> entries.
> 
> This adds a new interface at /sys/devices/system/memory/add_node that
> behaves in a similar way to the memory hot-add "probe" interface.  Its
> format is size@start, where "size" is the size of the new node to be
> added and "start" is the physical address of the new memory.
> 
> The new node id is a currently offline, but possible, node.  The bit must
> be set in node_possible_map so that nr_node_ids is sized appropriately.
> 
> For emulation on x86, for example, it would be possible to set aside
> memory for hotplugged nodes (say, anything above 2G) and to add an
> additional three nodes as being possible on boot with
> 
> 	mem=2G numa=possible=3
> 
> and then creating a new 128M node at runtime:
> 
> 	# echo 128M@0x80000000 > /sys/devices/system/memory/add_node
> 	On node 1 totalpages: 0
> 	init_memory_mapping: 0000000080000000-0000000088000000
> 	 0080000000 - 0088000000 page 2M

For cpu/memory physical hotplug, we have the unique interface probe/release,
it is the _standard_ interface, it is not only for x86, ppc use the the interface
as well. For node hotplug, it should follow the rule.

You are creating a new interface /sys/devices/system/memory/add_node to add both
memory and node, you are just trying to create DUPLICATED feature with the
memory probe interface, it breaks the rule. 

I did NOT see the feature difference with our emulator patch http://lkml.org/lkml/2010/11/16/740,
you pick up a piece of feature from emulator, and create an other thread. You
are trying to replace the interface with a new one, which is not recommended.
the memory probe interface is already powerful and flexible enough after apply
our patch. What's more important, it keeps the old directives, and it maintains
backwards compatibility.

Add a memory section(128M) to node 3(boots with mem=1024m)

	echo 0x40000000,3 > memory/probe

And more we make it friendly, it is possible to add memory to do

	echo 3g > memory/probe
	echo 1024m,3 > memory/probe

It maintains backwards compatibility.

Another format suggested by Dave Hansen:

	echo physical_address=0x40000000 numa_node=3 > memory/probe

we should not need duplicated interface /sys/devices/system/memory/add_node here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
