Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A3576B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 03:45:07 -0500 (EST)
Message-Id: <20101130071324.908098411@intel.com>
Date: Tue, 30 Nov 2010 15:13:24 +0800
From: shaohui.zheng@intel.com
Subject: [0/8, v6] NUMA Hotplug Emulator(v6) - Introduction & Feedbacks 
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

* PATCHSET INTRODUCTION

patch 1: Documentation.
patch 2: Adds a numa=possible=<N> command line option to set an additional N nodes
		 as being possible for memory hotplug. 
	    
patch 3: Add node hotplug emulation, introduce debugfs node/add_node interface

patch 4: Abstract cpu register functions, make these interfaces friendly for cpu
		 hotplug emulation
patch 5: Support cpu probe/release in x86, it provides a software method to hot
		 add/remove cpu with sysfs interface.
patch 6: Fake CPU socket with logical CPU on x86, to prevent the scheduling
		 domain to build the incorrect hierarchy.
patch 7: Extend memory probe interface to support NUMA, we can add the memory to
		 a specified node with the interface.
patch 8: Implement memory probe interface with debugfs

* FEEDBACKDS & RESPONSES

v5:

David: Suggests to use a flexible method to to do node hotplug emulation. After
       review our 2 versions emulator implemetations, David provides a better solution
	   to solve both the flexibility and memory wasting issue. 
	   
	   Add numa=possible=<N> command line option, provide sysfs inteface
	   /sys/devices/system/node/add_node interface, and move the inteface to debugfs
	   /sys/kernel/debug/hotplug/add_node after hearing the voice from community.

Greg KH: move the interface from hotplug/add_node to node/add_node

Response: Accept David's node=possible=<n> command line options. After talking
       with David, he agreed to add his patch to our patchset, thanks David's solution(patch 1).

	   David's original interface /sys/kernel/debug/hotplug/add_node is not so clear for
	   node hotplug emulation, we accept Greg's suggestion, move the interface to ndoe/add_node  
	   (patch 2)
		 
Dave Hansen: For memory hotplug, Dave reminds Greg KH's advice, suggest us to use configfs replace
       sysfs. After Dave knows that it is just for test purpose, Dave thinks debugfs should
	   be the best.

Response: memory probe sysfs interface already exists, I'd like to still keep it, and extend it
       to support memory add on a specified node(patch 6).

	   We accepts Dave's suggestion, implement memory probe interface with debugfs(patch 7).

Randy Dunlap: Correct many grammatical errors in our documentation(patch 8).

Response: Thanks for Randy's careful review, we already correct them. 

v6:

Greg KH:  Suggest to use interface mem_hotplug/add_node
David:    Agree with Greg's suggestion
Response: We move the interface from node/add_node to mem_hotplug/add_node, and we also move 
          memory/probe interface to mem_hotplug/probe since both are related to memory hotplug.

Kletnieks Valdis: suggest to renumber the patch serie, and move patch 8/8 to patch 1/8.
Response: Move patch 8/8 to patch 1/8, and we will include the full description in 0/8 when
          we send patches in future.	    
       
* WHAT IS HOTPLUG EMULATOR 

NUMA hotplug emulator is collectively named for the hotplug emulation
it is able to emulate NUMA Node Hotplug thru a pure software way. It
intends to help people easily debug and test node/cpu/memory hotplug
related stuff on a none-NUMA-hotplug-support machine, even an UMA machine.

The emulator provides mechanism to emulate the process of physcial cpu/mem
hotadd, it provides possibility to debug CPU and memory hotplug on the machines
without NUMA support for kenrel developers. It offers an interface for cpu and
memory hotplug test purpose.

* WHY DO WE USE HOTPLUG EMULATOR

We are focusing on the hotplug emualation for a few months. The emualor helps
team to reproduce all the major hotplug bugs. It plays an important role to the
hotplug code quality assuirance. Because of the hotplug emulator, we already
move most of the debug working to virtual evironment.

* Principles & Usages 

NUMA hotplug emulator include 3 different parts: node/CPU/memory hotplug
emulation.

1) Node hotplug emulation:

Adds a numa=possible=<N> command line option to set an additional N nodes as
being possible for memory hotplug. This set of possible nodes control
nr_node_ids and the sizes of several dynamically allocated node arrays.

This allows memory hotplug to create new nodes for newly added memory
rather than binding it to existing nodes.

For emulation on x86, it would be possible to set aside memory for hotplugged
nodes (say, anything above 2G) and to add an additional four nodes as being
possible on boot with

	mem=2G numa=possible=4

and then creating a new 128M node at runtime:

	# echo 128M@0x80000000 > /sys/kernel/debug/node/add_node
	On node 1 totalpages: 0
	init_memory_mapping: 0000000080000000-0000000088000000
	 0080000000 - 0088000000 page 2M

Once the new node has been added, its memory can be onlined.  If this
memory represents memory section 16, for example:

	# echo online > /sys/devices/system/memory/memory16/state
	Built 2 zonelists in Node order, mobility grouping on.  Total pages: 514846
	Policy zone: Normal
 [ The memory section(s) mapped to a particular node are visible via
   /sys/devices/system/node/node1, in this example. ]

2) CPU hotplug emulation:

The emulator reserve CPUs throu grub parameter, the reserved CPUs can be
hot-add/hot-remove in software method.

When hotplug a CPU with emulator, we are using a logical CPU to emulate the CPU
hotplug process. For the CPU supported SMT, some logical CPUs are in the same
socket, but it may located in different NUMA node after we have emulator.  We
put the logical CPU into a fake CPU socket, and assign it an unique
phys_proc_id. For the fake socket, we put one logical CPU in only.

 - to hide CPUs
	- Using boot option "maxcpus=N" hide CPUs
	  N is the number of initialize CPUs
	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation
      when cpu_hpe is enabled, the rest CPUs will not be initialized 

 - to hot-add CPU to node
	$ echo nid > cpu/probe

 - to hot-remove CPU
	$ echo nid > cpu/release

3) Memory hotplug emulation:

The emulator reserve memory before OS booting, the reserved memory region
is remove from e820 table, and they can be hot-added via the probe interface,
this interface was extend to support add memory to the specified node, It
maintains backwards compatibility.

The difficulty of Memory Release is well-known, we have no plan for it until now.

 - reserve memory throu grub parameter
 	mem=1024m

 - add a memory section to node 3
    $ echo 0x40000000,3 > memory/probe
	OR
    $ echo 1024m,3 > memory/probe

* ACKNOWLEDGMENT 

hotplug emulator includes a team's efforts, thanks all of them.
They are:
Andi Kleen, Haicheng Li, Shaohui Zheng, Fengguang Wu, David Rientjes and
Yongkang You


-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
