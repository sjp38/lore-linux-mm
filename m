Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C10E06B01E3
	for <linux-mm@kvack.org>; Fri, 14 May 2010 00:49:44 -0400 (EDT)
Message-ID: <4BECD65A.7080004@linux.intel.com>
Date: Fri, 14 May 2010 12:49:30 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
References: <20100513114544.GC2169@shaohui>
In-Reply-To: <20100513114544.GC2169@shaohui>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Shaohui Zheng wrote:
> x86: infrastructure of NUMA hotplug emulation
> 
> NUMA hotplug emulator introduces a new node state N_HIDDEN to
> identify the fake offlined node. It firstly hides RAM via E820
> table and then emulates fake offlined nodes with the hidden RAM.
> 
> After system bootup, user is able to hotplug-add these offlined
> nodes, which is just similar to a real hardware hotplug behavior.
> 
> Using boot option "numa=hide=N*size" to fake offlined nodes:
> 	- N is the number of hidden nodes
> 	- size is the memory size (in MB) per hidden node.
> 
> OPEN: Kernel might use part of hidden memory region as RAM buffer,
>       now emulator directly hide 128M extra space to workaround
>       this issue.  Any better way to avoid this conflict?

I'd like to hear some advices on this OPEN. I'm not sure if it's an undebugged bug, but it might be. 
Now, removing extra 128M is just a workaround.

I used to find kernel might map the hidden address space to RAM buffer.
For example:
1) I have removed the mem range "0x2c0000000 ~ 0x33fffffff" from e820 table.
2) however, after kernel bootup, I might find:
# cat /proc/iomem
2c0000000-2c5ffffffff : RAM buffer

This is just an example, the space range (2c5ffffffff) is not the exact number which I saw in my 
testing.

This issue might come from

commit 45fbe3ee01b8e463b28c2751b5dcc0cbdc142d90
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed May 6 08:06:44 2009 -0700

     x86, e820, pci: reserve extra free space near end of RAM

     The point is to take all RAM resources we have, and
     _after_ we've added all the resources we've seen in
     the E820 tree, we then _also_ try to add fake reserved
     entries for any "round up to X" at the end of the RAM
     resources.

     [ Impact: improve PCI mem-resource allocation robustness, protect "stolen RA
M" ]

How could I make a better fix for this OPEN?

-haicheng

> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
> diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
> index 8948f47..3e0d94d 100644
> --- a/arch/x86/mm/numa_64.c
> +++ b/arch/x86/mm/numa_64.c
> @@ -307,6 +307,87 @@ void __init numa_init_array(void)
>  	}
>  }
>  
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +static char *hp_cmdline __initdata;
> +static struct bootnode *hidden_nodes;
> +static u64 hp_start, hp_end;
> +static long hidden_num, hp_size;
> +
> +int hotadd_hidden_nodes(int nid)
> +{
> +	int ret;
> +
> +	if (!node_hidden(nid))
> +		return -EINVAL;
> +
> +	ret = add_memory(nid, hidden_nodes[nid].start,
> +			 hidden_nodes[nid].end - hidden_nodes[nid].start);
> +	if (!ret) {
> +		node_clear_hidden(nid);
> +		return 0;
> +	} else {
> +		return -EEXIST;
> +	}
> +}
> +
> +static void __init numa_hide_nodes(void)
> +{
> +	char *c;
> +	int ret;
> +
> +	c = strchr(hp_cmdline, '*');
> +	if (!c)
> +		return;
> +	else
> +		*c = '\0';
> +	ret = strict_strtol(hp_cmdline, 0, &hidden_num);
> +	if (ret == -EINVAL)
> +		return;
> +	ret = strict_strtol(c + 1, 0, &hp_size);
> +	if (ret == -EINVAL)
> +		return;
> +	hp_size <<= 20;
> +
> +	hp_start = e820_hide_mem(hidden_num * hp_size);
> +	if (hp_start <= 0) {
> +		printk(KERN_ERR "Hide too much memory, disable node hotplug emualtion.");
> +		hidden_num = 0;
> +		return;
> +	}
> +
> +	hp_end = hp_start + hidden_num * hp_size;
> +
> +	/* leave 128M space for possible RAM buffer usage later
> +	 * any other better way to avoid this conflict?
> +	 */
> +	e820_hide_mem(128*1024*1024);
> +}
> +
> +static void __init numa_hotplug_emulation(void)
> +{
> +	int i, num_nodes = 0;
> +
> +	for_each_online_node(i)
> +		if (i > num_nodes)
> +			num_nodes = i;
> +
> +	i = num_nodes + hidden_num;
> +	if (!hidden_nodes) {
> +		hidden_nodes = alloc_bootmem(sizeof(struct bootnode) * i);
> +		memset(hidden_nodes, 0, sizeof(struct bootnode) * i);
> +	}
> +
> +	if (hidden_num)
> +		for (i = 0; i < hidden_num; i++) {
> +			int nid = num_nodes + i + 1;
> +			node_set(nid, node_possible_map);
> +			hidden_nodes[nid].start = hp_start + hp_size * i;
> +			hidden_nodes[nid].end = hp_start + hp_size * (i+1);
> +			node_set_hidden(nid);
> +		}
> +}
> +#endif /* CONFIG_NODE_HOTPLUG_EMU */
> +
>  #ifdef CONFIG_NUMA_EMU
>  /* Numa emulation */
>  static struct bootnode nodes[MAX_NUMNODES] __initdata;
> @@ -661,7 +742,7 @@ void __init initmem_init(unsigned long start_pfn, unsigned long last_pfn,
>  
>  #ifdef CONFIG_NUMA_EMU
>  	if (cmdline && !numa_emulation(start_pfn, last_pfn, acpi, k8))
> -		return;
> +		goto done;
>  	nodes_clear(node_possible_map);
>  	nodes_clear(node_online_map);
>  #endif
> @@ -669,14 +750,14 @@ void __init initmem_init(unsigned long start_pfn, unsigned long last_pfn,
>  #ifdef CONFIG_ACPI_NUMA
>  	if (!numa_off && acpi && !acpi_scan_nodes(start_pfn << PAGE_SHIFT,
>  						  last_pfn << PAGE_SHIFT))
> -		return;
> +		goto done;
>  	nodes_clear(node_possible_map);
>  	nodes_clear(node_online_map);
>  #endif
>  
>  #ifdef CONFIG_K8_NUMA
>  	if (!numa_off && k8 && !k8_scan_nodes())
> -		return;
> +		goto done;
>  	nodes_clear(node_possible_map);
>  	nodes_clear(node_online_map);
>  #endif
> @@ -696,6 +777,12 @@ void __init initmem_init(unsigned long start_pfn, unsigned long last_pfn,
>  		numa_set_node(i, 0);
>  	e820_register_active_regions(0, start_pfn, last_pfn);
>  	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn << PAGE_SHIFT);
> +done:
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +	if (hidden_num)
> +		numa_hotplug_emulation();
> +#endif
> +	return;
>  }
>  
>  unsigned long __init numa_free_all_bootmem(void)
> @@ -723,6 +810,12 @@ static __init int numa_setup(char *opt)
>  	if (!strncmp(opt, "fake=", 5))
>  		cmdline = opt + 5;
>  #endif
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +	if (!strncmp(opt, "hide=", 5)) {
> +		hp_cmdline = opt + 5;
> +		numa_hide_nodes();
> +	}
> +#endif
>  #ifdef CONFIG_ACPI_NUMA
>  	if (!strncmp(opt, "noacpi", 6))
>  		acpi_numa = -1;
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index dba35e4..ba0f82d 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -371,6 +371,10 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
>   */
>  enum node_states {
>  	N_POSSIBLE,		/* The node could become online at some point */
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +	N_HIDDEN,		/* The node is hidden at booting time, could be
> +				 * onlined in run time */
> +#endif
>  	N_ONLINE,		/* The node is online */
>  	N_NORMAL_MEMORY,	/* The node has regular memory */
>  #ifdef CONFIG_HIGHMEM
> @@ -470,6 +474,13 @@ static inline int num_node_state(enum node_states state)
>  #define node_online(node)	node_state((node), N_ONLINE)
>  #define node_possible(node)	node_state((node), N_POSSIBLE)
>  
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +#define node_set_hidden(node)	   node_set_state((node), N_HIDDEN)
> +#define node_clear_hidden(node)	   node_clear_state((node), N_HIDDEN)
> +#define node_hidden(node)	node_state((node), N_HIDDEN)
> +extern int hotadd_hidden_nodes(int nid);
> +#endif
> +
>  #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
>  #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
