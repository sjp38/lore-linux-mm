Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1EDD6B028F
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:18:47 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id j16so19956413pgn.14
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:18:47 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c6si13497963plo.446.2017.11.23.14.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 14:18:46 -0800 (PST)
Subject: Re: [PATCH v2 2/5] mm: memory_hotplug: Remove assumption on memory
 state before hotremove
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Message-ID: <cad46441-bbf6-4a3c-3487-db754919ba3b@intel.com>
Date: Thu, 23 Nov 2017 23:18:42 +0100
MIME-Version: 1.0
In-Reply-To: <4e21a27570f665793debf167c8567c6752116d0a.1511433386.git.ar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

On 11/23/2017 12:14 PM, Andrea Reale wrote:
> Commit 242831eb15a0 ("Memory hotplug / ACPI: Simplify memory removal")
> introduced an assumption whereas when control
> reaches remove_memory the corresponding memory has been already
> offlined. In that case, the acpi_memhotplug was making sure that
> the assumption held.
> This assumption, however, is not necessarily true if offlining
> and removal are not done by the same "controller" (for example,
> when first offlining via sysfs).
>
> Removing this assumption for the generic remove_memory code
> and moving it in the specific acpi_memhotplug code. This is
> a dependency for the software-aided arm64 offlining and removal
> process.
>
> Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> Signed-off-by: Maciej Bielski <m.bielski@linux.vnet.ibm.com>

Please resend this with a CC to linux-acpi.

Thanks!

> ---
>   drivers/acpi/acpi_memhotplug.c |  2 +-
>   include/linux/memory_hotplug.h |  9 ++++++---
>   mm/memory_hotplug.c            | 13 +++++++++----
>   3 files changed, 16 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 6b0d3ef..b0126a0 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>   			nid = memory_add_physaddr_to_nid(info->start_addr);
>   
>   		acpi_unbind_memory_blocks(info);
> -		remove_memory(nid, info->start_addr, info->length);
> +		BUG_ON(remove_memory(nid, info->start_addr, info->length));
>   		list_del(&info->list);
>   		kfree(info);
>   	}
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 58e110a..1a9c7b2 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -295,7 +295,7 @@ static inline bool movable_node_is_enabled(void)
>   extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
>   extern void try_offline_node(int nid);
>   extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> -extern void remove_memory(int nid, u64 start, u64 size);
> +extern int remove_memory(int nid, u64 start, u64 size);
>   
>   #else
>   static inline bool is_mem_section_removable(unsigned long pfn,
> @@ -311,7 +311,10 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>   	return -EINVAL;
>   }
>   
> -static inline void remove_memory(int nid, u64 start, u64 size) {}
> +static inline int remove_memory(int nid, u64 start, u64 size)
> +{
> +	return -EINVAL;
> +}
>   #endif /* CONFIG_MEMORY_HOTREMOVE */
>   
>   extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> @@ -323,7 +326,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>   		unsigned long nr_pages);
>   extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>   extern bool is_memblock_offlined(struct memory_block *mem);
> -extern void remove_memory(int nid, u64 start, u64 size);
> +extern int remove_memory(int nid, u64 start, u64 size);
>   extern int sparse_add_one_section(struct pglist_data *pgdat, unsigned long start_pfn);
>   extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>   		unsigned long map_offset);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d4b5f29..d5f15af 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1892,7 +1892,7 @@ EXPORT_SYMBOL(try_offline_node);
>    * and online/offline operations before this call, as required by
>    * try_offline_node().
>    */
> -void __ref remove_memory(int nid, u64 start, u64 size)
> +int __ref remove_memory(int nid, u64 start, u64 size)
>   {
>   	int ret;
>   
> @@ -1908,18 +1908,23 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>   	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
>   				check_memblock_offlined_cb);
>   	if (ret)
> -		BUG();
> +		goto end_remove;
> +
> +	ret = arch_remove_memory(start, size);
> +
> +	if (ret)
> +		goto end_remove;
>   
>   	/* remove memmap entry */
>   	firmware_map_remove(start, start + size, "System RAM");
>   	memblock_free(start, size);
>   	memblock_remove(start, size);
>   
> -	arch_remove_memory(start, size);
> -
>   	try_offline_node(nid);
>   
> +end_remove:
>   	mem_hotplug_done();
> +	return ret;
>   }
>   EXPORT_SYMBOL_GPL(remove_memory);
>   #endif /* CONFIG_MEMORY_HOTREMOVE */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
