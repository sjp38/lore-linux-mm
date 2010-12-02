Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3767D8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:26:21 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oB21LrSX017077
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 17:21:53 -0800
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by hpaq12.eem.corp.google.com with ESMTP id oB21Lp98021976
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 17:21:51 -0800
Received: by pxi17 with SMTP id 17so1473021pxi.20
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 17:21:50 -0800 (PST)
Date: Wed, 1 Dec 2010 17:21:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
In-Reply-To: <20101201234514.GA13509@shaohui>
Message-ID: <alpine.DEB.2.00.1012011716550.22420@chino.kir.corp.google.com>
References: <20101130071324.908098411@intel.com> <20101130071437.461969179@intel.com> <alpine.DEB.2.00.1012011656590.1896@chino.kir.corp.google.com> <20101201234514.GA13509@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg KH <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, Shaohui Zheng wrote:

> > > From: Shaohui Zheng <shaohui.zheng@intel.com>
> > > 
> > > Implement a debugfs inteface /sys/kernel/debug/mem_hotplug/probe for meomory hotplug
> > > emulation.  it accepts the same parameters like
> > > /sys/devices/system/memory/probe.
> > > 
> > 
> > NACK, we don't need two interfaces to do the same thing.  
> 
> You may not know the background, the sysfs memory/probe interface is a general
> interface.  Even through we have a debugfs interface, we should still keep it.
> 
> For test purpose, the sysfs is enough, according to the comments from Greg & Dave,
> we create the debugfs interface.
> 

I doubt either Greg or Dave suggested adding duplicate interfaces for the 
same functionality.

The difference is that we needed to add the add_node interface in a new 
mem_hotplug debugfs directory because it's only useful for debugging 
kernel code and, thus, doesn't really have an appropriate place in sysfs.  
Nobody is going to use add_node unless they lack hotpluggable memory 
sections in their SRAT and want to debug the memory hotplug callers.  For 
example, I already wrote all of this node hotplug emulation stuff when I 
wrote the node hotplug support for SLAB.

Memory hotplug, however, does serve a non-debugging function and is 
appropriate in sysfs since this is how people hotplug memory.  It's an ABI 
that we can't simply remove without deprecation over a substantial period 
of time and in this case it doesn't seem to have a clear advantage.  We 
need not add special emulation support for something that is already 
possible for real systems, so adding a duplicate interface in debugfs is 
inappropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
