Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B8CB96B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 00:57:46 -0500 (EST)
Date: Thu, 18 Nov 2010 12:36:41 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
Message-ID: <20101118043641.GB2408@shaohui>
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

First, the emulator is just for test purpose, and I believe that only very
few people will use it, so we did not want to take so many modification.
the more you changed, the more bugs you may get. the memory/probe interface
is already enough to test memory hot-add.

Second, if we want to use configfs and debugfs for cpu/memory probe interface,
it should implemented in another series patch since it is not part of the emulator.
 We have 8 patches in this patchset now, it is should be very long patch if 
want to add all in.

> 
> > +       depends on NUMA_HOTPLUG_EMU
> > +       ---help---
> > +         Enable memory hotplug emulation. Reserve memory with grub parameter
> > +         "mem=N"(such as mem=1024M), where N is the initial memory size, the
> > +         rest physical memory will be removed from e820 table; the memory probe
> > +         interface is for memory hot-add to specified node in software method.
> > +         This is for debuging and testing purpose
> 
> mem= actually sets the largest physical address that we're trying to
> use.  If you have a 256MB hole at 768MB, then mem=1G will only get you
> 768MB of memory.  We probably get this wrong in a number of other places
> in the documentation, but we might as well get it right here.
> 
> Maybe something like:
>         
>         Enable emulation of hotplug of NUMA nodes.  To use this, you
>         must also boot with the kernel command-line parameter
>         "mem=N"(such as mem=1024M), where N is the highest physical
>         address you would like to use at boot.  The rest of physical
>         memory will be removed from firmware tables and may be then be
>         hotplugged with this feature. This is for debuging and testing
>         purposes.
>         
>         Note that you can still examine the original, non-modified
>         firmware tables in: /sys/firmware/memmap
>         
> -- Dave
I did not aware the memory hole here, good catching.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
