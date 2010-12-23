Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C9CA6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 21:58:40 -0500 (EST)
Date: Thu, 23 Dec 2010 09:34:10 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <20101223013410.GA11356@shaohui>
References: <20101210073119.156388875@intel.com>
 <20101210073242.670777298@intel.com>
 <20101222162727.56b830b0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101222162727.56b830b0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaohui.zheng@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 22, 2010 at 04:27:27PM -0800, Andrew Morton wrote:
> On Fri, 10 Dec 2010 15:31:24 +0800
> > +
> > +ssize_t arch_cpu_probe(const char *buf, size_t count)
> > +{
> > +	int nid = 0;
> > +	int num = 0, selected = 0;
> 
> One definition per line make for more maintainable code.
> 
> Two of these initialisations are unnecessary.
> 
Agree, I will put them into 2 lines, and remove the initialisations.
I always try to initialize them when we define it, it seems that it is a bad habit.

> > +	/* check parameters */
> > +	if (!buf || count < 2)
> > +		return -EPERM;
> > +
> > +	nid = simple_strtoul(buf, NULL, 0);
> 
> checkpatch?

it is a warning, so I ignore it.
I will solve it.

> 
> > +	printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);
> 
> "Add a CPU to node %d" would make more sense.
> 

Get it.

> > +	if (nid < 0 || nid > nr_node_ids - 1) {
> > +		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
> > +			nid, nr_node_ids);
> > +		return -EPERM;
> > +	}
> > +
> > +	if (!node_online(nid)) {
> > +		printk(KERN_ERR "NUMA node %d is not online, give up.\n", nid);
> 
> "giving"
> 

Get it.

> > +		return -EPERM;
> > +	}
> > +
> > +	/* find first uninitialized cpu */
> > +	for_each_present_cpu(num) {
> 
> s/num/cpu/ would be conventional.  "num" is a pretty poor identifier in
> general - it fails to identify what it is counting.
> 

I will replace the identifier 'num' with 'cpu'.

> > +		if (per_cpu(cpu_sys_devices, num) == NULL) {
> > +			selected = num;
> 
> Similarly, I'd have used "selected_cpu".
> 

Get it.

> > +			break;
> > +		}
> > +	}
> > +
> > +	if (selected >= num_possible_cpus()) {
> > +		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
> > +		return -EPERM;
> > +	}
> > +
> > +	/* register cpu */
> > +	arch_register_cpu_node(selected, nid);
> > +	acpi_map_lsapic_emu(selected, nid);
> > +
> > +	return count;
> > +}
> > +EXPORT_SYMBOL(arch_cpu_probe);
> 
> arch_cpu_probe() is global and exported to modules, but is undocumented.
> 
> If it had been documented, I might have been able to work out why arg
> `count' is checked, but never used.
> 

Sorry, Andrew, I did not catch it. Do you mean to add the document before
 the definition of the function arch_cpu_probe?

> > +ssize_t arch_cpu_release(const char *buf, size_t count)
> > +{
> > +	int cpu = 0;
> > +
> > +	cpu =  simple_strtoul(buf, NULL, 0);
> 
> unneeded initialisation, spurious whitespace, checkpatch.
> 

Agree.

> > +	/* cpu 0 is not hotplugable */
> > +	if (cpu == 0) {
> > +		printk(KERN_ERR "can not release cpu 0.\n");
> 
> It's generally better to make kernel messages self-identifying. 
> Especially error messages.  If someone comes along and sees "can not
> release cpu 0" in their logs, they don't have a clue what caused it
> unless they download the kernel sources and go grepping.
> 

How about "arch_cpu_release: can not release cpu 0.\n"?

> > +		return -EPERM;
> > +	}
> > +
> > +	if (cpu_online(cpu)) {
> > +		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
> > +		if (!cpu_down(cpu)) {
> > +			printk(KERN_ERR "fail to offline cpu %d, give up.\n", cpu);
> 
> "failed", "giving".
> 

Get it.

> > +			return -EPERM;
> > +		}
> > +
> > +	}
> > +
> > +	arch_unregister_cpu(cpu);
> > +	acpi_unmap_lsapic(cpu);
> > +
> > +	return count;
> > +}
> > +EXPORT_SYMBOL(arch_cpu_release);
> 
> No documentation.
> 

Sorry, It is the same with function arch_cpu_probe, I did not catch the
problem, should I add documentation before the definition or declaration? Or
add the documentation into directory Documentation/.

> >  #else /* CONFIG_HOTPLUG_CPU */
> >  
> >  static int __init arch_register_cpu(int num)
> > @@ -83,8 +158,14 @@
> >  		register_one_node(i);
> >  #endif
> >  
> > -	for_each_present_cpu(i)
> > -		arch_register_cpu(i);
> > +	/*
> > +	 * when cpu hotplug emulation enabled, register the online cpu only,
> > +	 * the rests are reserved for cpu probe.
> > +	 */
> 
> Something like "When cpu hotplug emulation is enabled, register only
> the online cpu.  The remainder are reserved for cpu probing.".
> 
> 

Get it.

> > +	for_each_present_cpu(i) {
> > +		if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
> > +			arch_register_cpu(i);
> > +	}
> >  
> >  	return 0;
> >  }
> >
> > ...
> >
> > --- linux-hpe4.orig/drivers/acpi/processor_driver.c	2010-12-10 13:42:34.593331000 +0800
> > +++ linux-hpe4/drivers/acpi/processor_driver.c	2010-12-10 14:48:32.143331001 +0800
> > @@ -542,6 +542,14 @@
> >  		goto err_free_cpumask;
> >  
> >  	sysdev = get_cpu_sysdev(pr->id);
> > +	/*
> > +	 * Reserve cpu for hotplug emulation, the reserved cpu can be hot-added
> > +	 * throu the cpu probe interface. Return directly.
> 
> s/emulation, the/emulation.  The/
> s/throu/through/
> 
> > +	 */
> > +	if (sysdev == NULL) {
> > +		goto out;
> > +	}
> 
> Unneeded braces.
> 
> >  	if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) {
> >  		result = -EFAULT;
> >  		goto err_remove_fs;
> > @@ -582,6 +590,7 @@
> >  		goto err_remove_sysfs;
> >  	}
> >  
> > +out:
> >  	return 0;
> >  
> >
> > ...
> >
> > --- linux-hpe4.orig/drivers/base/cpu.c	2010-12-10 14:39:43.333331000 +0800
> > +++ linux-hpe4/drivers/base/cpu.c	2010-12-10 14:48:32.143331001 +0800
> > @@ -22,9 +22,15 @@
> >  };
> >  EXPORT_SYMBOL(cpu_sysdev_class);
> >  
> > -static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
> > +DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
> >  
> >  #ifdef CONFIG_HOTPLUG_CPU
> > +/*
> > + * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is
> 
> s/it/It/.
> 
> > + * disabled in default, we can enable it throu grub parameter cpu_hpe=on
> 
> "through".
> 
> > + */
> > +int cpu_hpe_on;
> 
> __read_mostly, perhaps.
> 

CPU Hotplug emulation is for debug purpose, so cpu_hpe_on is not used very frequently.

> >  static ssize_t show_online(struct sys_device *dev, struct sysdev_attribute *attr,
> >  			   char *buf)
> >  {
> >
> > ...
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
