Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0BA6B00DD
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 16:18:58 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAHLItxb028651
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:18:55 -0800
Received: from gxk22 (gxk22.prod.google.com [10.202.11.22])
	by wpaz24.hot.corp.google.com with ESMTP id oAHLIspI008776
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:18:54 -0800
Received: by gxk22 with SMTP id 22so1019663gxk.15
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:18:54 -0800 (PST)
Date: Wed, 17 Nov 2010 13:18:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <1290019807.9173.3789.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: shaohui.zheng@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Dave Hansen wrote:

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

That seems like a seperate issue of moving the memory hotplug interface 
over to configfs and that seems like it will cause a lot of userspace 
breakage.  The memory hotplug interface can already add memory to a node 
without using the ACPI notifier, so what does it have to do with this 
patchset?

I think what this patchset really wants to do is map offline hot-added 
memory to a different node id before it is onlined.  It needs no 
additional command-line interface or kconfig options, users just need to 
physically hot-add memory at runtime or use mem= when booting to reserve 
present memory from being used.

Then, export the amount of memory that is actually physically present in 
the e820 but was truncated by mem= and allow users to hot-add the memory 
via the probe interface.  Add a writeable 'node' file to offlined memory 
section directories and allow it to be changed prior to online.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
