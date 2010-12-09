Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AB136B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 21:46:26 -0500 (EST)
Date: Thu, 9 Dec 2010 09:21:24 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
Message-ID: <20101209012124.GD5798@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, gregkh@suse.de, shaohui.zheng@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

> 
> > From:  Shaohui Zheng <shaohui.zheng@intel.com>
> > 
> > Add add_memory interface to support to memory hotplug emulation for each online
> > node under debugfs. The reserved memory can be added into desired node with
> > this interface.
> > 
> > The layout on debugfs:
> > 	mem_hotplug/node0/add_memory
> > 	mem_hotplug/node1/add_memory
> > 	mem_hotplug/node2/add_memory
> > 	...
> > 
> > Add a memory section(128M) to node 3(boots with mem=1024m)
> > 
> > 	echo 0x40000000 > mem_hotplug/node3/add_memory
> > 
> > And more we make it friendly, it is possible to add memory to do
> > 
> > 	echo 1024m > mem_hotplug/node3/add_memory
> > 
> 
> I don't think you should be using memparse() to support this type of 
> interface, the standard way of writing memory locations is by writing 
> address in hex as the first example does.  The idea is to not try to make 
> things simpler by introducing multiple ways of doing the same thing but 
> rather to standardize on a single interface.

Undoubtedly, A hex is the best way to represent a physical address. If we use
memparse function, we can use the much simpler way to represent an address,
it is not the offical way, but it takes many conveniences if we just want to 
to some simple test.

When we reserce memory, we use mempasre to parse the mem=XXX parameter, we can
avoid the complicated translation when we add memory thru the add_memory interface,
how about still use the memparse here? but remove it from the document since it is
just for some simple testing. 

> 
> > CC: David Rientjes <rientjes@google.com>
> > CC: Dave Hansen <dave@linux.vnet.ibm.com>
> > Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> > Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> > ---
> > Index: linux-hpe4/mm/memory_hotplug.c
> > ===================================================================
> > --- linux-hpe4.orig/mm/memory_hotplug.c	2010-12-02 12:35:31.557622002 +0800
> > +++ linux-hpe4/mm/memory_hotplug.c	2010-12-06 07:30:36.067622001 +0800
> > @@ -930,6 +930,80 @@
> >  
> >  static struct dentry *memhp_debug_root;
> >  
> > +#ifdef CONFIG_ARCH_MEMORY_PROBE
> > +
> > +static ssize_t add_memory_store(struct file *file, const char __user *buf,
> > +				size_t count, loff_t *ppos)
> > +{
> > +	u64 phys_addr = 0;
> > +	int nid = file->private_data - NULL;
> > +	int ret;
> > +
> > +	phys_addr = simple_strtoull(buf, NULL, 0);
> 
> This isn't doing anything.
> 
Should be removed

> > +	printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
> > +	phys_addr = memparse(buf, NULL);
> > +	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
> 
> Does the add_memory() call handle memoryless nodes such that they 
> appropriately transition to N_HIGH_MEMORY when memory is added?

For memoryless nodes, it will cause OOM issue on old kernel version, but now
memoryless node is already supported, and the test result matches it well. The
emulator is a tool to reproduce the OOM issue in eraly kernel.

> 
> > +
> > +	if (ret)
> > +		count = ret;
> > +
> > +	return count;
> > +}
> > +
> > +static int add_memory_open(struct inode *inode, struct file *file)
> > +{
> > +	file->private_data = inode->i_private;
> > +	return 0;
> > +}
> > +
> > +static const struct file_operations add_memory_file_ops = {
> > +	.open		= add_memory_open,
> > +	.write		= add_memory_store,
> > +	.llseek		= generic_file_llseek,
> > +};
> > +
> > +/*
> > + * Create add_memory debugfs entry under specified node
> > + */
> > +static int debugfs_create_add_memory_entry(int nid)
> > +{
> > +	char buf[32];
> > +	static struct dentry *node_debug_root;
> > +
> > +	snprintf(buf, sizeof(buf), "node%d", nid);
> > +	node_debug_root = debugfs_create_dir(buf, memhp_debug_root);
> 
> This can fail, and if it does then the subsequent debugfs_create_file() 
> will be added to root while we don't want, so this needs error handling.
> 
I will add error handling code for it.

> > +
> > +	/* the nid information was represented by the offset of pointer(NULL+nid) */
> > +	if (!debugfs_create_file("add_memory", S_IWUSR, node_debug_root,
> > +			NULL + nid, &add_memory_file_ops))
> > +		return -ENOMEM;
> > +
> > +	return 0;
> > +}
> > +
> > +static int __init memory_debug_init(void)
> > +{
> > +	int nid;
> > +
> > +	if (!memhp_debug_root)
> > +		memhp_debug_root = debugfs_create_dir("mem_hotplug", NULL);
> > +	if (!memhp_debug_root)
> > +		return -ENOMEM;
> > +
> > +	for_each_online_node(nid)
> > +		 debugfs_create_add_memory_entry(nid);
> > +
> > +	return 0;
> > +}
> > +
> > +module_init(memory_debug_init);
> > +#else
> > +static debugfs_create_add_memory_entry(int nid)
> > +{
> > +	return 0;
> > +}
> > +#endif /* CONFIG_ARCH_MEMORY_PROBE */
> > +
> >  static ssize_t add_node_store(struct file *file, const char __user *buf,
> >  				size_t count, loff_t *ppos)
> >  {
> > @@ -960,6 +1034,8 @@
> >  		return -ENOMEM;
> >  
> >  	ret = add_memory(nid, start, size);
> > +
> > +	debugfs_create_add_memory_entry(nid);
> >  	return ret ? ret : count;
> >  }
> >  
> > Index: linux-hpe4/Documentation/memory-hotplug.txt
> > ===================================================================
> > --- linux-hpe4.orig/Documentation/memory-hotplug.txt	2010-12-02 12:35:31.557622002 +0800
> > +++ linux-hpe4/Documentation/memory-hotplug.txt	2010-12-06 07:39:36.007622000 +0800
> > @@ -19,6 +19,7 @@
> >    4.1 Hardware(Firmware) Support
> >    4.2 Notify memory hot-add event by hand
> >    4.3 Node hotplug emulation
> > +  4.4 Memory hotplug emulation
> >  5. Logical Memory hot-add phase
> >    5.1. State of memory
> >    5.2. How to online memory
> > @@ -239,6 +240,29 @@
> >  Once the new node has been added, it is possible to online the memory by
> >  toggling the "state" of its memory section(s) as described in section 5.1.
> >  
> > +4.4 Memory hotplug emulation
> > +------------
> > +With debugfs, it is possible to test memory hotplug with software method, we
> > +can add memory section to desired node with add_memory interface. It is a much
> > +more powerful interface than "probe" described in section 4.2.
> > +
> > +There is an add_memory interface for each online node at the debugfs mount
> > +point.
> > +	mem_hotplug/node0/add_memory
> > +	mem_hotplug/node1/add_memory
> > +	mem_hotplug/node2/add_memory
> > +	...
> > +
> > +Add a memory section(128M) to node 3(boots with mem=1024m)
> > +
> > +	echo 0x40000000 > mem_hotplug/node3/add_memory
> > +
> > +And more we make it friendly, it is possible to add memory to do
> > +
> > +	echo 1024m > mem_hotplug/node3/add_memory
> > +
> > +Once the new memory section has been added, it is possible to online the memory
> > +by toggling the "state" described in section 5.1.
> >  
> >  ------------------------------
> >  5. Logical Memory hot-add phase
> > 
> > -- 
> > Thanks & Regards,
> > Shaohui
> > 
> > 
> > 

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
