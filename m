Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9E7636B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 07:31:23 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] mm/hotplug: Remove stop_machine() from try_offline_node()
Date: Tue, 13 Aug 2013 13:41:47 +0200
Message-ID: <3940091.8hz2Z6IIgz@vostro.rjw.lan>
In-Reply-To: <1376336071-9128-1-git-send-email-toshi.kani@hp.com>
References: <1376336071-9128-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, tangchen@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, liwanp@linux.vnet.ibm.com

On Monday, August 12, 2013 01:34:31 PM Toshi Kani wrote:
> lock_device_hotplug() serializes hotplug & online/offline operations.
> The lock is held in common sysfs online/offline interfaces and ACPI
> hotplug code paths.
> 
> try_offline_node() off-lines a node if all memory sections and cpus
> are removed on the node.  It is called from acpi_processor_remove()
> and acpi_memory_remove_memory()->remove_memory() paths, both of which
> are in the ACPI hotplug code.
> 
> try_offline_node() calls stop_machine() to stop all cpus while checking
> all cpu status with the assumption that the caller is not protected from
> CPU hotplug or CPU online/offline operations.  However, the caller is
> always serialized with lock_device_hotplug().  Also, the code needs to
> be properly serialized with a lock, not by stopping all cpus at a random
> place with stop_machine().
> 
> This patch removes the use of stop_machine() in try_offline_node() and
> adds comments to try_offline_node() and remove_memory() that
> lock_device_hotplug() is required.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  mm/memory_hotplug.c |   31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ca1dd3a..0b4b0f7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1674,9 +1674,8 @@ static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
>  	return ret;
>  }
>  
> -static int check_cpu_on_node(void *data)
> +static int check_cpu_on_node(pg_data_t *pgdat)
>  {
> -	struct pglist_data *pgdat = data;
>  	int cpu;
>  
>  	for_each_present_cpu(cpu) {
> @@ -1691,10 +1690,9 @@ static int check_cpu_on_node(void *data)
>  	return 0;
>  }
>  
> -static void unmap_cpu_on_node(void *data)
> +static void unmap_cpu_on_node(pg_data_t *pgdat)
>  {
>  #ifdef CONFIG_ACPI_NUMA
> -	struct pglist_data *pgdat = data;
>  	int cpu;
>  
>  	for_each_possible_cpu(cpu)
> @@ -1703,10 +1701,11 @@ static void unmap_cpu_on_node(void *data)
>  #endif
>  }
>  
> -static int check_and_unmap_cpu_on_node(void *data)
> +static int check_and_unmap_cpu_on_node(pg_data_t *pgdat)
>  {
> -	int ret = check_cpu_on_node(data);
> +	int ret;
>  
> +	ret = check_cpu_on_node(pgdat);
>  	if (ret)
>  		return ret;
>  
> @@ -1715,11 +1714,18 @@ static int check_and_unmap_cpu_on_node(void *data)
>  	 * the cpu_to_node() now.
>  	 */
>  
> -	unmap_cpu_on_node(data);
> +	unmap_cpu_on_node(pgdat);
>  	return 0;
>  }
>  
> -/* offline the node if all memory sections of this node are removed */
> +/**
> + * try_offline_node
> + *
> + * Offline a node if all memory sections and cpus of the node are removed.
> + *
> + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> + * and online/offline operations before this call.
> + */
>  void try_offline_node(int nid)
>  {
>  	pg_data_t *pgdat = NODE_DATA(nid);
> @@ -1745,7 +1751,7 @@ void try_offline_node(int nid)
>  		return;
>  	}
>  
> -	if (stop_machine(check_and_unmap_cpu_on_node, pgdat, NULL))
> +	if (check_and_unmap_cpu_on_node(pgdat))
>  		return;
>  
>  	/*
> @@ -1782,6 +1788,13 @@ void try_offline_node(int nid)
>  }
>  EXPORT_SYMBOL(try_offline_node);
>  
> +/**
> + * remove_memory
> + *
> + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> + * and online/offline operations before this call, as required by
> + * try_offline_node().
> + */
>  void __ref remove_memory(int nid, u64 start, u64 size)
>  {
>  	int ret;
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
