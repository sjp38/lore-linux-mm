Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A95E6B008A
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 19:28:51 -0500 (EST)
Date: Wed, 22 Dec 2010 16:27:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-Id: <20101222162727.56b830b0.akpm@linux-foundation.org>
In-Reply-To: <20101210073242.670777298@intel.com>
References: <20101210073119.156388875@intel.com>
	<20101210073242.670777298@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:31:24 +0800
shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
> 
> CPU physical hot-add/hot-remove are supported on some hardwares, and it 
> was already supported in current linux kernel. NUMA Hotplug Emulator provides
> a mechanism to emulate the process with software method. It can be used for
> testing or debuging purpose.
> 
> CPU physical hotplug is different with logical CPU online/offline. Logical
> online/offline is controled by interface /sys/device/cpu/cpuX/online. CPU
> hotplug emulator uses probe/release interface. It becomes possible to do cpu
> hotplug automation and stress
> 
> Add cpu interface probe/release under sysfs for x86_64. User can use this
> interface to emulate the cpu hot-add and hot-remove process.
> 
> Directive:
> *) Reserve CPU thru grub parameter like:
> 	maxcpus=4
> 
> the rest CPUs will not be initiliazed. 
> 
> *) Probe CPU
> we can use the probe interface to hot-add new CPUs:
> 	echo nid > /sys/devices/system/cpu/probe
> 
> *) Release a CPU
> 	echo cpu > /sys/devices/system/cpu/release
> 
> A reserved CPU will be hot-added to the specified node.
> 1) nid == 0, the CPU will be added to the real node which the CPU
> should be in
> 2) nid != 0, add the CPU to node nid even through it is a fake node.
> 
>
> ...
>
> --- linux-hpe4.orig/arch/x86/kernel/topology.c	2010-12-10 14:39:43.333331000 +0800
> +++ linux-hpe4/arch/x86/kernel/topology.c	2010-12-10 14:49:56.043331000 +0800
> @@ -30,6 +30,9 @@
>  #include <linux/init.h>
>  #include <linux/smp.h>
>  #include <asm/cpu.h>
> +#include <linux/cpu.h>
> +#include <linux/topology.h>
> +#include <linux/acpi.h>
>  
>  static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
>  
> @@ -66,6 +69,78 @@
>  	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
>  }
>  EXPORT_SYMBOL(arch_unregister_cpu);
> +
> +ssize_t arch_cpu_probe(const char *buf, size_t count)
> +{
> +	int nid = 0;
> +	int num = 0, selected = 0;

One definition per line make for more maintainable code.

Two of these initialisations are unnecessary.

> +	/* check parameters */
> +	if (!buf || count < 2)
> +		return -EPERM;
> +
> +	nid = simple_strtoul(buf, NULL, 0);

checkpatch?

> +	printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);

"Add a CPU to node %d" would make more sense.

> +	if (nid < 0 || nid > nr_node_ids - 1) {
> +		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
> +			nid, nr_node_ids);
> +		return -EPERM;
> +	}
> +
> +	if (!node_online(nid)) {
> +		printk(KERN_ERR "NUMA node %d is not online, give up.\n", nid);

"giving"

> +		return -EPERM;
> +	}
> +
> +	/* find first uninitialized cpu */
> +	for_each_present_cpu(num) {

s/num/cpu/ would be conventional.  "num" is a pretty poor identifier in
general - it fails to identify what it is counting.

> +		if (per_cpu(cpu_sys_devices, num) == NULL) {
> +			selected = num;

Similarly, I'd have used "selected_cpu".

> +			break;
> +		}
> +	}
> +
> +	if (selected >= num_possible_cpus()) {
> +		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
> +		return -EPERM;
> +	}
> +
> +	/* register cpu */
> +	arch_register_cpu_node(selected, nid);
> +	acpi_map_lsapic_emu(selected, nid);
> +
> +	return count;
> +}
> +EXPORT_SYMBOL(arch_cpu_probe);

arch_cpu_probe() is global and exported to modules, but is undocumented.

If it had been documented, I might have been able to work out why arg
`count' is checked, but never used.

> +ssize_t arch_cpu_release(const char *buf, size_t count)
> +{
> +	int cpu = 0;
> +
> +	cpu =  simple_strtoul(buf, NULL, 0);

unneeded initialisation, spurious whitespace, checkpatch.

> +	/* cpu 0 is not hotplugable */
> +	if (cpu == 0) {
> +		printk(KERN_ERR "can not release cpu 0.\n");

It's generally better to make kernel messages self-identifying. 
Especially error messages.  If someone comes along and sees "can not
release cpu 0" in their logs, they don't have a clue what caused it
unless they download the kernel sources and go grepping.

> +		return -EPERM;
> +	}
> +
> +	if (cpu_online(cpu)) {
> +		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
> +		if (!cpu_down(cpu)) {
> +			printk(KERN_ERR "fail to offline cpu %d, give up.\n", cpu);

"failed", "giving".

> +			return -EPERM;
> +		}
> +
> +	}
> +
> +	arch_unregister_cpu(cpu);
> +	acpi_unmap_lsapic(cpu);
> +
> +	return count;
> +}
> +EXPORT_SYMBOL(arch_cpu_release);

No documentation.

>  #else /* CONFIG_HOTPLUG_CPU */
>  
>  static int __init arch_register_cpu(int num)
> @@ -83,8 +158,14 @@
>  		register_one_node(i);
>  #endif
>  
> -	for_each_present_cpu(i)
> -		arch_register_cpu(i);
> +	/*
> +	 * when cpu hotplug emulation enabled, register the online cpu only,
> +	 * the rests are reserved for cpu probe.
> +	 */

Something like "When cpu hotplug emulation is enabled, register only
the online cpu.  The remainder are reserved for cpu probing.".


> +	for_each_present_cpu(i) {
> +		if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
> +			arch_register_cpu(i);
> +	}
>  
>  	return 0;
>  }
>
> ...
>
> --- linux-hpe4.orig/drivers/acpi/processor_driver.c	2010-12-10 13:42:34.593331000 +0800
> +++ linux-hpe4/drivers/acpi/processor_driver.c	2010-12-10 14:48:32.143331001 +0800
> @@ -542,6 +542,14 @@
>  		goto err_free_cpumask;
>  
>  	sysdev = get_cpu_sysdev(pr->id);
> +	/*
> +	 * Reserve cpu for hotplug emulation, the reserved cpu can be hot-added
> +	 * throu the cpu probe interface. Return directly.

s/emulation, the/emulation.  The/
s/throu/through/

> +	 */
> +	if (sysdev == NULL) {
> +		goto out;
> +	}

Unneeded braces.

>  	if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) {
>  		result = -EFAULT;
>  		goto err_remove_fs;
> @@ -582,6 +590,7 @@
>  		goto err_remove_sysfs;
>  	}
>  
> +out:
>  	return 0;
>  
>
> ...
>
> --- linux-hpe4.orig/drivers/base/cpu.c	2010-12-10 14:39:43.333331000 +0800
> +++ linux-hpe4/drivers/base/cpu.c	2010-12-10 14:48:32.143331001 +0800
> @@ -22,9 +22,15 @@
>  };
>  EXPORT_SYMBOL(cpu_sysdev_class);
>  
> -static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
> +DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
>  
>  #ifdef CONFIG_HOTPLUG_CPU
> +/*
> + * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is

s/it/It/.

> + * disabled in default, we can enable it throu grub parameter cpu_hpe=on

"through".

> + */
> +int cpu_hpe_on;

__read_mostly, perhaps.

>  static ssize_t show_online(struct sys_device *dev, struct sysdev_attribute *attr,
>  			   char *buf)
>  {
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
