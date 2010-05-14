Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 002BA6B01EE
	for <linux-mm@kvack.org>; Thu, 13 May 2010 22:20:33 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4E2KSSJ008716
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 May 2010 11:20:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DA2245DE56
	for <linux-mm@kvack.org>; Fri, 14 May 2010 11:20:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 70E0D45DE54
	for <linux-mm@kvack.org>; Fri, 14 May 2010 11:20:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B0BAE08005
	for <linux-mm@kvack.org>; Fri, 14 May 2010 11:20:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DD86D1DB805B
	for <linux-mm@kvack.org>; Fri, 14 May 2010 11:20:26 +0900 (JST)
Date: Fri, 14 May 2010 11:16:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
Message-Id: <20100514111615.c7ca63a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100513114544.GC2169@shaohui>
References: <20100513114544.GC2169@shaohui>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 19:45:44 +0800
Shaohui Zheng <shaohui.zheng@intel.com> wrote:

> x86: infrastructure of NUMA hotplug emulation
> 

Hmm. do we have to create this for x86 only ?
Can't we live with lmb ? as

	lmb_hide_node() or some.

IIUC, x86-version lmb is now under development.

THanks,
-Kame

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
> 
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
> -- 
> Thanks & Regards,
> Shaohui
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
