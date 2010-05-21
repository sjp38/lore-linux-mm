Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F1D276B01B4
	for <linux-mm@kvack.org>; Fri, 21 May 2010 05:36:42 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id o4L9Xvx2025212
	for <linux-mm@kvack.org>; Fri, 21 May 2010 15:03:57 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4L9XvCH344262
	for <linux-mm@kvack.org>; Fri, 21 May 2010 15:03:57 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4L9Xv9F017886
	for <linux-mm@kvack.org>; Fri, 21 May 2010 19:33:57 +1000
Date: Fri, 21 May 2010 15:03:40 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [RFC, 0/7] NUMA Hotplug emulator
Message-ID: <20100521093340.GA7024@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20100513113629.GA2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513113629.GA2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
Cc: Balbir Singh <balbir@in.ibm.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 13, 2010 at 07:36:30PM +0800, Shaohui Zheng wrote:
> Hi, All
> 	This patchset introduces NUMA hotplug emulator for x86. it refers too
> many files and might introduce new bugs, so we send a RFC to comminity first
> and expect comments and suggestions, thanks.
> 

<snip>

> * Principles & Usages 
> 
> NUMA hotplug emulator include 3 different parts, We add a menu item to the
> menuconfig to enable/disable them
> (Refer to http://shaohui.org/images/hpe-krnl-cfg.jpg)
> 
> 
> 1) Node hotplug emulation:
> 
> The emulator firstly hides RAM via E820 table, and then it can
> fake offlined nodes with the hidden RAM.
> 
> After system bootup, user is able to hotplug-add these offlined
> nodes, which is just similar to a real hotplug hardware behavior.
> 
> Using boot option "numa=hide=N*size" to fake offlined nodes:
> 	- N is the number of hidden nodes
> 	- size is the memory size (in MB) per hidden node.
> 
> There is a sysfs entry "probe" under /sys/devices/system/node/ for user
> to hotplug the fake offlined nodes:
> 
>  - to show all fake offlined nodes:
>     $ cat /sys/devices/system/node/probe
> 
>  - to hotadd a fake offlined node, e.g. nodeid is N:
>     $ echo N > /sys/devices/system/node/probe
> 

I tried the patchset on a non-NUMA machine. So, inorder to create fake
NUMA nodes and be able to emulate the hotplug behavior, I used the
following commandline:

	"numa=fake=4  numa=hide=2*2048"

on a machine with 8G memory. I expected to see 4 nodes, out of which 2
would be hidden. However, the system comes up the 4 online nodes and 2
offline nodes (thus a total of 6 nodes). While we could decide this to
be the semantics, however, I feel that numa=fake should define the total
number of nodes. So in the above case, the system should have come up
with 2 online nodes and 2 offline nodes.

Also, "numa=hide=N" could also be supported, with the size
of the hidden nodes being equal to the entire size of the node, with or
without numa=fake parameter.

On onlining one of the offline nodes, I see another issue that the
memory under it is not automatically brought online. For example:

#ls /sys/devices/system/node
.... node0 node1 node2..

#cat /sys/devices/system/node/probe
3

#echo 3 > /sys/devices/system/node/probe
#ls /sys/devices/system/node
.... node0 node1 node2 node3

#cat /sys/devices/system/node/node3/meminfo
Node 3 MemTotal:              0 kB
Node 3 MemFree:               0 kB
Node 3 MemUsed:               0 kB
Node 3 Active:                0 kB
......

i.e, as memory-less nodes. However, these nodes were designated to have
memory. So, on onlining the nodes, maybe we could have all their memory
brought into online state as well ?

-- 
Regards,                                                                        
Ankita Garg (ankita@in.ibm.com)                                                 
Linux Technology Center                                                         
IBM India Systems & Technology Labs,                                            
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
