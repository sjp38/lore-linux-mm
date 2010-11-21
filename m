Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 336486B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:42:58 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oALLgtFJ013409
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:42:55 -0800
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by kpbe14.cbf.corp.google.com with ESMTP id oALLgsw3005116
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:42:54 -0800
Received: by gxk10 with SMTP id 10so1289341gxk.26
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:42:54 -0800 (PST)
Date: Sun, 21 Nov 2010 13:42:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
In-Reply-To: <789F9655DD1B8F43B48D77C5D30659732FE95E6E@shsmsx501.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1011211334150.26304@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com> <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
 <789F9655DD1B8F43B48D77C5D30659732FE95E6E@shsmsx501.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Li, Haicheng" <haicheng.li@intel.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010, Li, Haicheng wrote:

> > I think what we'll end up wanting to do is something like this, which
> > adds 
> > a numa=possible=<N> parameter for x86; this will add an additional N
> > possible nodes to node_possible_map that we can use to online later. 
> > It 
> > also adds a new /sys/devices/system/memory/add_node file which takes a
> > typical "size@start" value to hot-add an emulated node.  For example,
> > using "mem=2G numa=possible=1" on the command line and doing
> > echo 128M@0x80000000" > /sys/devices/system/memory/add_node would
> > hot-add 
> > a node of 128M.
> > 
> > Comments?
> 
> Sorry for the late response as I'm in a biz trip recently.
> 
> David, your original concern is just about powerful/flexibility. I'm 
> sure our implementation can better meets such requirments.
> 

Not with hacky hidden nodes or being unnecessarily tied to e820, it can't.

> IMHO, I don't see any powerful/flexibility from your patch, compared to 
> our original implementation. you just make things more complex and mess.
> Why not use "numa=hide=N*size" as originally implemented?

Hidden nodes are a hack and completely unnecessary for node hotplug 
emulation, there's no need to have additional nodemasks or node states 
throughout the kernel.  They also require that you define the node sizes 
at boot, mine allows you to hotplug multiple node sizes of your choice at 
runtime.

> - later you just need to online the node once you want. And it 
> naturally/exactly emulates the behavior that current HW provides.

My proposal allows you to hotplug various node sizes, they can be 
offlined, their sizes can be subsequently changed, and re-hotplugged.  
It's a very dynamic and flexible model that allows you to emulate all 
possible combinations of node hotplug without constantly rebooting.

> - N is the possible node number. And we can use 128M as the default 
> size for each hidden node if user doesn't specify a size.

My model allows you to define the node size you'd like to add at runtime.

> - If user wants more mem for hidden node, he just needs specify the 
> "size".
> - besides, user can also use "mem=" to hide more mem and later use 
> mem-add i/f to freely attach more mem to the hidden node during runtime.
> 

Each of these requires a reboot, you cannot emulate hotplugging a node, 
offlining it, removing the memory, and re-hotplugging the same node with a 
larger amount of added memory with your model.

> Your patch introduces additional dependency on "mem=", but ours is 
> simple and flexibly compatible with "mem=" and "numa=emu". 
> 

This is the natural use case of mem=, to truncate the memory map to only 
allow the kernel to have a portion of usable memory.  The remainder can be 
used by this new interface, if desired, with complete power and control 
over the size of nodes you're adding without having to conform to hidden 
node sizes that you've specified at boot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
