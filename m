Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 639F76B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:17:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x184so38894029wmf.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:17:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si25138806edi.1.2017.05.24.08.17.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 08:17:49 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-3-mhocko@kernel.org>
 <3a85146e-2f31-8a9e-26da-6051119586fe@suse.cz>
 <20170524134237.GH14733@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6a0bd7c7-8beb-d599-ed31-caca68cd8b30@suse.cz>
Date: Wed, 24 May 2017 17:17:08 +0200
MIME-Version: 1.0
In-Reply-To: <20170524134237.GH14733@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 05/24/2017 03:42 PM, Michal Hocko wrote:
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index ec7d6ae01c96..64aed7386fe4 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2246,11 +2246,11 @@
>  			that the amount of memory usable for all allocations
>  			is not too small.
>  
> -	movable_node	[KNL] Boot-time switch to make hotplugable to be
> -			movable. This means that the memory of such nodes
> -			will be usable only for movable allocations which
> -			rules out almost all kernel allocations. Use with
> -			caution!
> +	movable_node	[KNL] Boot-time switch to make hotplugable memory
> +			NUMA nodes to be movable. This means that the memory
> +			of such nodes will be usable only for movable
> +			allocations which rules out almost all kernel
> +			allocations. Use with caution!
>  
>  	MTD_Partition=	[MTD]
>  			Format: <name>,<region-number>,<size>,<offset>
> 
> Better?

Yes, thanks.

> [...]
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -149,32 +149,6 @@ config NO_BOOTMEM
>>>  config MEMORY_ISOLATION
>>>  	bool
>>>  
>>> -config MOVABLE_NODE
>>> -	bool "Enable to assign a node which has only movable memory"
>>> -	depends on HAVE_MEMBLOCK
>>> -	depends on NO_BOOTMEM
>>> -	depends on X86_64 || OF_EARLY_FLATTREE || MEMORY_HOTPLUG
>>> -	depends on NUMA
>>
>> That's a lot of depends. What happens if some of them are not met and
>> the movable_node bootparam is used?
> 
> Good question. I haven't explored that, to be honest. Now that I am looking closer
> I am not even sure why all those dependencies are thre. MEMORY_HOTPLUG
> is clear and OF_EARLY_FLATTREE is explained by 41a9ada3e6b4 ("of/fdt:
> mark hotpluggable memory"). NUMA is less clear to me because
> MEMORY_HOTPLUG doesn't really depend on NUMA systems. Dependency on
> NO_BOOTMEM is also not clear to me because zones layout
> doesn't really depend on the specific boot time allocator.
> 
> So we are left with HAVE_MEMBLOCK which seems to be there because
> movable_node_enabled is defined there while the parameter handling is in
> the hotplug proper. But there is no real reason to have it like that.
> This compiles but I will have to put throw my full compile battery on it
> to be sure. I will make it a separate patch.

I'd expect stuff might compile and work (run without crash), just in
some cases the boot option could be effectively ignored? In that case
it's just a matter of documenting the option, possibly also some warning
when used, e.g. "node_movable was ignored because CONFIG_FOO is not
enabled"?

Vlastimil

> Thanks!
> --- 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 9622fb8c101b..071692894254 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -57,8 +57,6 @@ struct memblock {
>  
>  extern struct memblock memblock;
>  extern int memblock_debug;
> -/* If movable_node boot option specified */
> -extern bool movable_node_enabled;
>  
>  #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
>  #define __init_memblock __meminit
> @@ -171,11 +169,6 @@ static inline bool memblock_is_hotpluggable(struct memblock_region *m)
>  	return m->flags & MEMBLOCK_HOTPLUG;
>  }
>  
> -static inline bool __init_memblock movable_node_is_enabled(void)
> -{
> -	return movable_node_enabled;
> -}
> -
>  static inline bool memblock_is_mirror(struct memblock_region *m)
>  {
>  	return m->flags & MEMBLOCK_MIRROR;
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 9e0249d0f5e4..9c1ac94f857b 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -115,6 +115,12 @@ extern void __online_page_free(struct page *page);
>  extern int try_online_node(int nid);
>  
>  extern bool memhp_auto_online;
> +/* If movable_node boot option specified */
> +extern bool movable_node_enabled;
> +static inline bool movable_node_is_enabled(void)
> +{
> +	return movable_node_enabled;
> +}
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern bool is_pageblock_removable_nolock(struct page *page);
> @@ -266,6 +272,10 @@ static inline void put_online_mems(void) {}
>  static inline void mem_hotplug_begin(void) {}
>  static inline void mem_hotplug_done(void) {}
>  
> +static inline bool __init_memblock movable_node_is_enabled(void)
> +{
> +	return false;
> +}
>  #endif /* ! CONFIG_MEMORY_HOTPLUG */
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 4895f5a6cf7e..8c52fb11510c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -54,7 +54,6 @@ struct memblock memblock __initdata_memblock = {
>  };
>  
>  int memblock_debug __initdata_memblock;
> -bool movable_node_enabled __initdata_memblock = false;
>  static bool system_has_some_mirror __initdata_memblock = false;
>  static int memblock_can_resize __initdata_memblock;
>  static int memblock_memory_in_slab __initdata_memblock = 0;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2a14f8c18a22..b0d2bf3256d0 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -79,6 +79,8 @@ static struct {
>  #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
>  #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
>  
> +bool movable_node_enabled = false;
> +
>  #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
>  bool memhp_auto_online;
>  #else
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
