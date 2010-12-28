Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 52C266B0088
	for <linux-mm@kvack.org>; Tue, 28 Dec 2010 02:35:10 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oBS7Yu0Z015939
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 23:34:56 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by kpbe13.cbf.corp.google.com with ESMTP id oBS7YoYt002093
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 23:34:54 -0800
Received: by pzk27 with SMTP id 27so2248642pzk.0
        for <linux-mm@kvack.org>; Mon, 27 Dec 2010 23:34:50 -0800 (PST)
Date: Mon, 27 Dec 2010 23:34:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
In-Reply-To: <20101222162723.72075372.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1012272241200.23315@chino.kir.corp.google.com>
References: <20101210073119.156388875@intel.com> <20101210073242.462037866@intel.com> <20101222162723.72075372.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
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
> > +	u64 start, size;
> > +	char buffer[64];
> > +	char *p;
> > +	int nid;
> > +	int ret;
> > +
> > +	memset(buffer, 0, sizeof(buffer));
> > +	if (count > sizeof(buffer) - 1)
> > +		count = sizeof(buffer) - 1;
> 
> This will cause the write to return a smaller number than `count': a
> short write.  Some userspace code may then decide to write the
> remainder of the data (whcih is the correct way to use the write()
> syscall).
> 
> Could be a bit dangerous, and perhaps simply declaring an error if too
> much data was written would be a better approach.
> 
> > +	if (copy_from_user(buffer, buf, count))
> > +		return -EFAULT;
> > +
> > +	size = memparse(buffer, &p);
> > +	if (size < (PAGES_PER_SECTION << PAGE_SHIFT))
> 
> PAGES_PER_SECTION has type unsigned long, so the rhs of this comparison
> might overflow on 32-bit, should anyone ever try to use this code on
> 32-bit.
> 
> otoh the compiler might do it as 64-bit because the lhs is 64-bit.  Not
> sure.
> 
> > +		return -EINVAL;
> > +	if (*p != '@')
> > +		return -EINVAL;
> > +
> > +	start = simple_strtoull(p + 1, NULL, 0);
> 
> You disagreed with checkpatch?
> 
> > +	nodes_andnot(mask, node_possible_map, node_online_map);
> > +	nid = first_node(mask);
> > +	if (nid == MAX_NUMNODES)
> > +		return -ENOMEM;
> > +
> > +	ret = add_memory(nid, start, size);
> > +	return ret ? ret : count;
> > +}
> > +
> > +static const struct file_operations add_node_file_ops = {
> > +	.write		= add_node_store,
> > +	.llseek		= generic_file_llseek,
> > +};
> > +
> > +static int __init node_debug_init(void)
> > +{
> > +	if (!memhp_debug_root)
> > +		memhp_debug_root = debugfs_create_dir("mem_hotplug", NULL);
> > +	if (!memhp_debug_root)
> > +		return -ENOMEM;
> > +
> > +	if (!debugfs_create_file("add_node", S_IWUSR, memhp_debug_root,
> > +			NULL, &add_node_file_ops))
> > +		return -ENOMEM;
> > +
> > +	return 0;
> > +}
> > +
> > +module_init(node_debug_init);
> > +#endif /* CONFIG_DEBUG_FS */

Shaohui, I'll reply to this message with an updated version of this patch 
to address Andrew's comments.  You can merge it into your series or Andrew 
can take it seperately (although it doesn't do much good without "x86: add 
numa=possible command line option" unless you have hotpluggable SRAT 
entries and CONFIG_ACPI_NUMA).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
