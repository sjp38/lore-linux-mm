Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CCCF48D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:45:35 -0500 (EST)
Message-Id: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:07:59 +0800
From: shaohui.zheng@intel.com
Subject: [0/8,v3] NUMA Hotplug Emulator - Introduction & Feedbacks 
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

* PATCHSET INTRODUCTION

patch 1: Add function to hide memory region via e820 table. Then emulator will
	     use these memory regions to fake offlined numa nodes.
patch 2: Infrastructure of NUMA hotplug emulation, introduce "hide node".
patch 3: Provide an userland interface to hotplug-add fake offlined nodes.
patch 4: Abstract cpu register functions, make these interface friend for cpu
		 hotplug emulation
patch 5: Support cpu probe/release in x86, it provide a software method to hot
		 add/remove cpu with sysfs interface.
patch 6: Fake CPU socket with logical CPU on x86, to prevent the scheduling
		 domain to build the incorrect hierarchy.
patch 7: extend memory probe interface to support NUMA, we can add the memory to
		 a specified node with the interface.
patch 8: Documentations

* FEEDBACKS & RESPONSES

1) Patch 0
Balbir & Greg: Suggest to use tool git/quilt to manage/send the patchset.
Response: Thanks for the recommendation, With help from Fengguang, I get quilt
		  working, it is a great tool.

2) Patch 2
Jaswinder Singh: if (hidden_num) is not required in patch 2
Response: good catching, it is removed in v2.


3) Patch 3
Dave Hansen: Suggest to create a dedicated sysfs file for each possible node.
Greg: 	  How big would this "list" be?  What will it look like exactly?
Haicheng: It should follow "one value per file". It intends to show acceptable
		  parameters.

		  For example, if we have 4 fake offlined nodes, like node 2-5, then:
			   $ cat /sys/devices/system/node/probe
				 2-5

		  Then user hotadds node3 to system:
			   $ echo 3 > /sys/devices/system/node/probe
			   $ cat /sys/devices/system/node/probe
				 2,4-5

Greg:   As you are trying to add a new sysfs file, please create the matching
		Documentation/ABI/ file as well.
Response: We miss it, and we already add it in v2.

Patch 4 & 5: 
Paul Mundt: This looks like an incredibly painful interface. How about scrapping all
of this _emu() mess and just reworking the register_cpu() interface?
Response: accept Paul's suggestion, and remove the cpu _emu functions.

Patch 7: 
Dave Hansen: If we're going to put multiple values into the file now and
		 add to the ABI, can we be more explicit about it?
		echo "physical_address=0x40000000 numa_node=3" > memory/probe
Response: Dave's new interface was accpeted, and more we still keep the old 
	      format for compatibility. We documented the these interfaces into
		  Documentation/ABI in v2.
Greg: 	suggest to use configfs replace for the memory probe interface
Andi: 	This is a debugging interface. It doesn't need to have the
	  	most pretty interface in the world, because it will be only used for
	  	QA by a few people. it's just a QA interface, not the next generation
		of POSIX.
Response: We still keep it as sysfs interface since node/cpu/memory probe interface
		  are all in sysfs, we can create another group of patches to support
		  configfs if we have this strong requirement in future.


* WHAT IS HOTPLUG EMULATOR 

NUMA hotplug emulator is collectively named for the hotplug emulation
it is able to emulate NUMA Node Hotplug thru a pure software way. It
intends to help people easily debug and test node/cpu/memory hotplug
related stuff on a none-numa-hotplug-support machine, even an UMA machine.

The emulator provides mechanism to emulate the process of physcial cpu/mem
hotadd, it provides possibility to debug CPU and memory hotplug on the machines
without NUMA support for kenrel developers. It offers an interface for cpu
and memory hotplug test purpose.

* WHY DO WE USE HOTPLUG EMULATOR

We are focusing on the hotplug emualation for a few months. The emualor helps
 team to reproduce all the major hotplug bugs. It plays an important role to
the hotplug code quality assuirance. Because of the hotplug emulator, we already
move most of the debug working to virtual evironment.

* Principles & Usages 

NUMA hotplug emulator include 3 different parts, We add a menu item to the
menuconfig to enable/disable them.

1) Node hotplug emulation:

The emulator firstly hides RAM via E820 table, and then it can
fake offlined nodes with the hidden RAM.

After system bootup, user is able to hotplug-add these offlined
nodes, which is just similar to a real hotplug hardware behavior.

Using boot option "numa=hide=N*size" to fake offlined nodes:
	- N is the number of hidden nodes
	- size is the memory size (in MB) per hidden node.

There is a sysfs entry "probe" under /sys/devices/system/node/ for user
to hotplug the fake offlined nodes:

 - to show all fake offlined nodes:
    $ cat /sys/devices/system/node/probe

 - to hotadd a fake offlined node, e.g. nodeid is N:
    $ echo N > /sys/devices/system/node/probe

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
Andi Kleen, Haicheng Li, Shaohui Zheng, Fengguang Wu and Yongkang You

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
