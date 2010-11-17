Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2388D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 17:45:07 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oAHMj2ml024060
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:45:02 -0800
Received: from yxi11 (yxi11.prod.google.com [10.190.3.11])
	by hpaq1.eem.corp.google.com with ESMTP id oAHMiCW5017072
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:45:01 -0800
Received: by yxi11 with SMTP id 11so1126352yxi.1
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 14:45:01 -0800 (PST)
Date: Wed, 17 Nov 2010 14:44:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <1290030945.9173.4211.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz> <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com> <1290030945.9173.4211.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: shaohui.zheng@intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>, Aaron Durbin <adurbin@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Dave Hansen wrote:

> > Then, export the amount of memory that is actually physically present in 
> > the e820 but was truncated by mem=
> 
> I _think_ that's already effectively done in /sys/firmware/memmap.   
> 

Ok.

It's a little complicated because we don't export each online node's 
physical address range so you have to parse the dmesg to find what nodes 
were allocated at boot and determine how much physically present memory 
you have that's hidden but can be hotplugged using the probe files.

Adding Aaron Durbin <adurbin@google.com> to the cc because he has a patch 
that exports the physical address range of each node in their sysfs 
directories.

> > and allow users to hot-add the memory 
> > via the probe interface.  Add a writeable 'node' file to offlined memory 
> > section directories and allow it to be changed prior to online.
> 
> That would work, in theory.  But, in practice, we allocate the mem_map[]
> at probe time.  So, we've already effectively picked a node at probe.
> That was done because the probe is equivalent to the hardware "add"
> event.  Once the hardware where in the address space the memory is, it
> always also knows the node.
> 
> But, I guess it also wouldn't be horrible if we just hot-removed and
> hot-added an offline section if someone did write to a node file like
> you're suggesting.  It might actually exercise some interesting code
> paths.
> 

Since the pages are offline you should be able to modify the memmap when 
the 'node' file is written and use populate_memnodemap() since that file 
is only writeable in an offline state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
