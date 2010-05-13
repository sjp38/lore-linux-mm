Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 24DC76B0222
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:26:51 -0400 (EDT)
Date: Thu, 13 May 2010 20:22:32 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC, 0/7] NUMA Hotplug emulator
Message-ID: <20100513122232.GA2560@shaohui>
References: <20100513113629.GA2169@shaohui>
 <20100513121149.GI2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513121149.GI2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

This email was lost after I check the LKML, resend it, sorry if duplicated.

Hi, All
	This patchset introduces NUMA hotplug emulator for x86. it refers too
many files and might introduce new bugs, so we send a RFC to comminity first
and expect comments and suggestions, thanks.

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

We send it to 

* EXPECT BUGS

This is the first version to send to the comminity, but it is already 3rd
version in internal. It expected to have bugs. 

OPEN: Kernel might use part of hidden memory region as RAM buffer,
      now emulator directly hide 128M extra space to workaround
      this issue.  Any better way to avoid this conflict? We expect a better
	  solution from the community(for patch 002).

* Principles & Usages 

NUMA hotplug emulator include 3 different parts, We add a menu item to the
menuconfig to enable/disable them

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
hot-add/hot-remove in software method, it emulates the procuess of physical
cpu hotplug.

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
