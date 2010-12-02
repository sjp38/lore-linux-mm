Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 10BB86B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 18:34:09 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oB2NY6se013222
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 15:34:06 -0800
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz21.hot.corp.google.com with ESMTP id oB2NY4W4020440
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 15:34:05 -0800
Received: by pzk5 with SMTP id 5so1373081pzk.3
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 15:34:04 -0800 (PST)
Date: Thu, 2 Dec 2010 15:34:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF288D88D2B8@shsmsx502.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1012021528170.6878@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com> <20101202002716.GA13693@shaohui> <alpine.DEB.2.00.1012011807190.13942@chino.kir.corp.google.com> <A24AE1FFE7AEC5489F83450EE98351BF288D88D2B8@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <gregkh@suse.de>, "Li, Haicheng" <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, Zheng, Shaohui wrote:

> Why should we add so many interfaces for memory hotplug emulation?

Because they are functionally different from real memory hotplug and we 
want to support different configurations such as mapping memory to a 
different node id or onlining physical nodes that don't exist.

They are in debugfs because the emulation, unlike real memory hotplug, is 
used only for testing and debugging.

> If so, we should create both sysfs and debugfs 
> entries for an online node, we are trying to add redundant code logic.
> 

We do not need sysfs triggers for onlining a node, that already happens 
automatically if the memory that is being onlined has a hotpluggable node 
entry in the SRAT that has an offline node id.

> We need not make a simple thing such complicated, Simple is beautiful, I'd prefer to rename the mem_hotplug/probe 
> interface as mem_hotplug/add_memory.
> 
> 	/sys/kernel/debug/mem_hotplug/add_node (already exists)
> 	/sys/kernel/debug/mem_hotplug/add_memory (rename probe as add_memory)
> 

No, add_memory would then require these bizarre lines that you've been 
parsing like

	echo 'physical_addr=0x80000000 node_id=3' > /sys/kernel/debug/mem_hotplug/add_memory

which is unnecessary if you introduce my proposal for per-node debugfs 
directories similar to that under /sys/devices/system/node that is 
extendable later if we add additional per-node triggers under 
CONFIG_DEBUG_FS.

Adding /sys/kernel/debug/mem_hotplug/node2/add_memory that you write a 
physical address to is a much more robust, simple, and extendable 
interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
