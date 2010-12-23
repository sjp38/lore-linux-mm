Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3B56B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 20:38:52 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oBN1cn9T021181
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:38:50 -0800
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq12.eem.corp.google.com with ESMTP id oBN1clBb004230
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:38:48 -0800
Received: by pwj8 with SMTP id 8so447617pwj.14
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 17:38:47 -0800 (PST)
Date: Wed, 22 Dec 2010 17:38:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
In-Reply-To: <20101222162723.72075372.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1012221736110.13932@chino.kir.corp.google.com>
References: <20101210073119.156388875@intel.com> <20101210073242.462037866@intel.com> <20101222162723.72075372.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Haicheng Li <haicheng.li@linux.intel.com>, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Shaohui Zheng <shaohui.zheng@linux.intel.com>, dave@linux.vnet.ibm.com, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010, Andrew Morton wrote:

> > Index: linux-hpe4/mm/memory_hotplug.c
> > ===================================================================
> > --- linux-hpe4.orig/mm/memory_hotplug.c	2010-11-30 12:40:43.757622001 +0800
> > +++ linux-hpe4/mm/memory_hotplug.c	2010-11-30 14:02:33.877622002 +0800
> > @@ -924,3 +924,63 @@
> >  }
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >  EXPORT_SYMBOL_GPL(remove_memory);
> > +
> > +#ifdef CONFIG_DEBUG_FS
> > +#include <linux/debugfs.h>
> > +
> > +static struct dentry *memhp_debug_root;
> > +
> > +static ssize_t add_node_store(struct file *file, const char __user *buf,
> > +				size_t count, loff_t *ppos)
> > +{
> > +	nodemask_t mask;
> 
> NODEMASK_ALLOC()?
> 

We traditionally haven't been using NODEMASK_ALLOC() in sysfs (or, in this 
case, debugfs) functions because they're never deep in a call chain.  Even 
for 4K node support, which isn't a supported config on any arch that 
allows CONFIG_MEMORY_HOTPLUG, this would only be 512 bytes on the short 
stack.

I agree with the remainder of the points in your review and will be 
sending fixes against -mm, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
