Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFDC8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:07:59 -0500 (EST)
Date: Wed, 17 Nov 2010 15:06:59 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [8/8,v3] NUMA Hotplug Emulator: documentation
Message-Id: <20101117150659.0e0473c7.randy.dunlap@oracle.com>
In-Reply-To: <20101117021000.985643862@intel.com>
References: <20101117020759.016741414@intel.com>
	<20101117021000.985643862@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 10:08:07 +0800 shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
> 
> add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
> to explain the usage for the hotplug emulator.
> 
> Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> Index: linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt	2010-11-17 09:01:10.342836513 +0800
> @@ -0,0 +1,92 @@
> +NUMA Hotplug Emulator for x86

(I'm only looking at the documentation file.)

Is this only for x86_64?  if so, please change the line above (for x86).
If not, then don't put this file into the /x86_64/ sub-directory.


> +---------------------------------------------------
> +
> +NUMA hotplug emulator is able to emulate NUMA Node Hotplug
> +thru a pure software way. It intends to help people easily debug
> +and test node/cpu/memory hotplug related stuff on a

                 CPU

> +none-numa-hotplug-support machine, even a UMA machine and virtual

   non-NUMA-hotplug-support machine,

> +environment.
> +
> +1) Node hotplug emulation:
> +
> +The emulator firstly hides RAM via E820 table, and then it can
> +fake offlined nodes with the hidden RAM.
> +
> +After system bootup, user is able to hotplug-add these offlined
> +nodes, which is just similar to a real hotplug hardware behavior.
> +
> +Using boot option "numa=hide=N*size" to fake offlined nodes:
> +	- N is the number of hidden nodes
> +	- size is the memory size (in MB) per hidden node.
> +
> +There is a sysfs entry "probe" under /sys/devices/system/node/ for user
> +to hotplug the fake offlined nodes:
> +
> + - to show all fake offlined nodes:
> +    $ cat /sys/devices/system/node/probe
> +
> + - to hotadd a fake offlined node, e.g. nodeid is N:
> +    $ echo N > /sys/devices/system/node/probe
> +
> +2) CPU hotplug emulation:
> +
> +The emulator reserve CPUs throu grub parameter, the reserved CPUs can be

                             thru a kernel boot parameter;
(hopefully any boot loader will work, not just grub)

> +hot-add/hot-remove in software method, it emulates the process of physical
> +cpu hotplug.

   CPU

> +
> +When hotplug a CPU with emulator, we are using a logical CPU to emulate the CPU

        hotplugging

> +socket hotplug process. For the CPU supported SMT, some logical CPUs are in the
> +same socket, but it may located in different NUMA node after we have emulator.
> +We put the logical CPU into a fake CPU socket, and assign it an unique

                                                                a unique

> +phys_proc_id. For the fake socket, we put one logical CPU in only.
> +
> + - to hide CPUs
> +	- Using boot option "maxcpus=N" hide CPUs
> +	  N is the number of initialize CPUs

	  N is the number of CPUs to initialize; the rest will be hidden.

> +	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation

	                                           CPU
    
> +      when cpu_hpe is enabled, the rest CPUs will not be initialized

	                              rest of the CPUs

> +
> + - to hot-add CPU to node
> +	$ echo nid > cpu/probe
> +
> + - to hot-remove CPU
> +	$ echo nid > cpu/release
> +
> +3) Memory hotplug emulation:
> +
> +The emulator reserve memory before OS booting, the reserved memory region

                reserves memory before the OS boots; the reserved

> +is remove from e820 table, and they can be hot-added via the probe interface,

      removed                                                         interface.

> +this interface was extend to support add memory to the specified node, It

   This interface was extended to support adding memory to the specified node. It

> +maintains backwards compatibility.
> +
> +The difficulty of Memory Release is well-known, we have no plan for it until now.
> +
> + - reserve memory throu grub parameter

                     thru a kernel boot parameter

> + 	mem=1024m
> +
> + - add a memory section to node 3
> +    $ echo 0x40000000,3 > memory/probe
> +	OR
> +    $ echo 1024m,3 > memory/probe
> +	OR
> +    $ echo "physical_address=0x40000000 numa_node=3" > memory/probe
> +
> +4) Script for hotplug testing
> +
> +These scripts provides convenience when we hot-add memory/cpu in batch.
> +
> +- Online all memory sections:
> +for m in /sys/devices/system/memory/memory*;
> +do
> +	echo online > $m/state;
> +done
> +
> +- CPU Online:
> +for c in /sys/devices/system/cpu/cpu*;
> +do
> +	echo 1 > $c/online;
> +done
> +
> +- Haicheng Li <haicheng.li@intel.com>
> +- Shaohui Zheng <shaohui.zheng@intel.com>
> +  Nov 2010
> Index: linux-hpe4/Documentation/x86/x86_64/boot-options.txt
> ===================================================================
> --- linux-hpe4.orig/Documentation/x86/x86_64/boot-options.txt	2010-11-17 10:01:37.093461435 +0800
> +++ linux-hpe4/Documentation/x86/x86_64/boot-options.txt	2010-11-17 10:03:10.881043878 +0800
> @@ -173,6 +173,13 @@
>    numa=fake=<N>
>  		If given as an integer, fills all system RAM with N fake nodes
>  		interleaved over physical nodes.
> +  numa=hide=N*size1[,size2,...]
> +		Give an string seperated by comma, each sub string stands for a serie nodes.

		Give a string separated by commas; each substring stands for a node size.
??


> +		system will reserve an area to create hide numa nodes for them.

		System will reserve an area to create or hide NUMA nodes.

> +
> +		for example: numa=hide=2*512,256
> +			system will reserve (2*512 + 256) M for 3 hide nodes. 2 nodes with 512M memory,

			                                  MB for 3 hidden nodes: 2 nodes with
			512 MB memory and 1 node with 256 MB memory

> +			and 1 node with 256 memory 
>  
>  ACPI
>  
> @@ -316,3 +323,8 @@
>  		Do not use GB pages for kernel direct mappings.
>  	gbpages
>  		Use GB pages for kernel direct mappings.
> +	cpu_hpe=on/off
> +		Enable/disable cpu hotplug emulation with software method. when cpu_hpe=on,

		               CPU                                 method. When

> +		sysfs provides probe/release interface to hot add/remove cpu dynamically.

                                                                         CPUs

> +		this option is disabled in default.

		This                    by default.



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
