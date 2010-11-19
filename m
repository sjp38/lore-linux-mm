Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CC476B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 04:12:29 -0500 (EST)
Date: Fri, 19 Nov 2010 15:51:19 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
Message-ID: <20101119075119.GD3327@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.916235444@intel.com>
 <1290019807.9173.3789.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290019807.9173.3789.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 10:50:07AM -0800, Dave Hansen wrote:
> On Wed, 2010-11-17 at 10:08 +0800, shaohui.zheng@intel.com wrote:
> > And more we make it friendly, it is possible to add memory to do
> > 
> >         echo 3g > memory/probe
> >         echo 1024m,3 > memory/probe
> > 
> > It maintains backwards compatibility.
> > 
> > Another format suggested by Dave Hansen:
> > 
> >         echo physical_address=0x40000000 numa_node=3 > memory/probe
> > 
> > it is more explicit to show meaning of the parameters.
> 
> The other thing that Greg suggested was to use configfs.  Looking back
> on it, that makes a lot of sense.  We can do better than these "probe"
> files.
> 
> In your case, it might be useful to tell the kernel to be able to add
> memory in a node and add the node all in one go.  That'll probably be
> closer to what the hardware will do, and will exercise different code
> paths that the separate "add node", "then add memory" steps that you're
> using here.
> 
> For the emulator, I also have to wonder if using debugfs is the right
> was since its ABI is a bit more, well, _flexible_ over time. :)

There will be a lot of problems which need to solve if we decide to use configfs or
debugfs. I have no good method to solve these problems, so I want to listen some
advices.

1) How to design the probe interace 
I can not find a good method with configfs to replace current memory/probe 
interface.

As we know, A configfs config_item is created via an explicit userspace
operation mkdir. when we add a memory section, we need to convert it to an mkdir
action. the following implementation is the possible solution.

node/memory hotplug:
/configfs/node
when we hotadd node, we can create dir with command:
	mkdir /configfs/node/nodeX

And export a probe interface
/configfs/node/nodeX/probe, we can use this interface to hot-add memory section
to this node.

after memory hot-add with the probe interface, there should be some memory
entries for each memory section under this directories.

cpu hotplug:
/configfs/cpu/
to hot-add a cpu
	mkdir /configfs/cpu/cpuX
to hot-remove a CPU
	rmdir /configfs/cpu/cpuX

I did not whether it is the expected interface on configfs.

2) co-existence for sysfs and configfs

If we keep both interfaces, thing becomes complicated. when we hot-add
memory/cpu thru sysfs, we should create the sysfs entrie for it, and we should
also create the configfs entries for it. Vice versa, when we hot-add/remove
cpu/memory thru configfs, we should maintain the changes on sysfs, too.

it becomes very complicated after we have both configfs & sysfs interface, and
we should not get them together, we need to get it simple.

the purpose of hotplug emulator is providing a possible solution for cpu/memory
hotplug testing, the interface upgrading is not part of emulator. Let's forget
configfs here.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
