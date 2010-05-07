Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3CA966200B2
	for <linux-mm@kvack.org>; Fri,  7 May 2010 03:19:22 -0400 (EDT)
Message-ID: <4BE3BEE6.9080106@linux.intel.com>
Date: Fri, 07 May 2010 15:19:02 +0800
From: minskey guo <chaohong_guo@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] permit to online CPUs before local memory comes online
References: <1272344264.28378.3.camel@minskey-desktop>
In-Reply-To: <1272344264.28378.3.camel@minskey-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, "Kleen, Andi" <andi.kleen@intel.com>, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Could you please help me review this patch and give me
some inputs ? such as,  is it  acceptable to do that,
I mean, online CPUs  of  a NUMA node without local
memory

The patch is against upstream vanilla kernel.

I mis-spelled the mail address of linux-mm when I sent
the email for the first time,  please forgive me
if you receive two copies.


thanks,
-minskey


On 04/27/2010 12:57 PM, minskey wrote:
>
>
> This patch enables users to online CPUs even if the CPUs belongs to
> a numa node which doesn't have onlined local memory.
>
> The zonlists(pg_data_t.node_zonelists[]) of a numa node are created
> either in system boot/init period, or at the time of local memory
> online.  For a numa node without onlined local memory, its zonelists
> are not initialized at present. As a result, any memory allocation
> operations executed by CPUs within this node will fail. In fact, an
> out-of-memory error is triggered when attempt to online CPUs before
> memory comes to online.
>
> This patch tries to create zonelists for such numa nodes, so that
> the memory allocation for this node can be fallback'ed to other
> nodes.
>
> Signed-off-by: minskey guo<chaohong.guo@intel.com>
> ---
>   include/linux/memory_hotplug.h |    1 +
>   kernel/cpu.c                   |   26 ++++++++++++++++++++++++++
>   mm/memory_hotplug.c            |   25 +++++++++++++++++++++++++
>   3 files changed, 52 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 35b07b7..864035f 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -202,6 +202,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
>   }
>   #endif /* CONFIG_MEMORY_HOTREMOVE */
>
> +extern int mem_online_node(int nid);
>   extern int add_memory(int nid, u64 start, u64 size);
>   extern int arch_add_memory(int nid, u64 start, u64 size);
>   extern int remove_memory(u64 start, u64 size);
> diff --git a/kernel/cpu.c b/kernel/cpu.c
> index f8cced2..c31b9cb 100644
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -335,6 +335,12 @@ out_notify:
>   int __cpuinit cpu_up(unsigned int cpu)
>   {
>   	int err = 0;
> +
> +#ifdef	CONFIG_MEMORY_HOTPLUG
> +	int nid;
> +	pg_data_t	*pgdat;
> +#endif
> +
>   	if (!cpu_possible(cpu)) {
>   		printk(KERN_ERR "can't online cpu %d because it is not "
>   			"configured as may-hotadd at boot time\n", cpu);
> @@ -345,6 +351,26 @@ int __cpuinit cpu_up(unsigned int cpu)
>   		return -EINVAL;
>   	}
>
> +#ifdef	CONFIG_MEMORY_HOTPLUG
> +	nid = cpu_to_node(cpu);
> +	if (!node_online(nid)) {
> +		err = mem_online_node(nid);
> +		if (err)
> +			return err;
> +	}
> +
> +	pgdat = NODE_DATA(nid);
> +	if (!pgdat) {
> +		printk(KERN_ERR
> +			"Can't online cpu %d due to NULL pgdat\n", cpu);
> +		return -ENOMEM;
> +	}
> +
> +	if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
> +		build_all_zonelists();
> +	}
> +#endif
> +
>   	cpu_maps_update_begin();
>
>   	if (cpu_hotplug_disabled) {
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index be211a5..2d24bef 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -482,6 +482,31 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
>   }
>
>
> +/*
> + * called by cpu_up() to online a node without onlined memory.
> + */
> +int mem_online_node(int nid)
> +{
> +	pg_data_t	*pgdat;
> +	int	ret;
> +
> +	lock_system_sleep();
> +	pgdat = hotadd_new_pgdat(nid, 0);
> +	if (pgdat) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +	node_set_online(nid);
> +	ret = register_one_node(nid);
> +	BUG_ON(ret);
> +
> +out:
> +	unlock_system_sleep();
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(mem_online_node);
> +
> +
>   /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
>   int __ref add_memory(int nid, u64 start, u64 size)
>   {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
