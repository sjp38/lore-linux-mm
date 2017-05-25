Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03C3C6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 04:41:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r203so41335363wmb.2
        for <linux-mm@kvack.org>; Thu, 25 May 2017 01:41:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l18si31597590edd.19.2017.05.25.01.41.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 01:41:08 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-3-mhocko@kernel.org>
 <3a85146e-2f31-8a9e-26da-6051119586fe@suse.cz>
 <20170524134237.GH14733@dhcp22.suse.cz>
 <6a0bd7c7-8beb-d599-ed31-caca68cd8b30@suse.cz>
 <20170525062722.GD12721@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7e628491-bbe5-4587-5863-b048742464e8@suse.cz>
Date: Thu, 25 May 2017 10:41:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170525062722.GD12721@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 05/25/2017 08:27 AM, Michal Hocko wrote:
> On Wed 24-05-17 17:17:08, Vlastimil Babka wrote:
>> On 05/24/2017 03:42 PM, Michal Hocko wrote:
> [...]
>>
>> I'd expect stuff might compile and work (run without crash), just in
>> some cases the boot option could be effectively ignored? In that case
>> it's just a matter of documenting the option, possibly also some warning
>> when used, e.g. "node_movable was ignored because CONFIG_FOO is not
>> enabled"?
> 
> Hmm, I can make the cmd parameter available only when
> CONFIG_HAVE_MEMBLOCK_NODE_MAP but I am not sure how helpful it would be.
> AFAIR unrecognized options are just ignored. On the other hand debugging
> why the parameter doesn't do anything might be really frustrating. Here
> is the patch I will put on top of the two posted. Strictly speaking it
> breaks the bisection but swithing the order would be kind of pointless
> ifdefery game and I do not see it would matter all that much. I can
> rework if you guys think otherwise though.

Sounds good, thanks!

> ---
> From 4ed5cca9399f9b1e616478160ed5320d3951ec29 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 24 May 2017 15:43:49 +0200
> Subject: [PATCH] mm, memory_hotplug: move movable_node to the hotplug proper
> 
> movable_node_is_enabled is defined in memblock proper while it
> is initialized from the memory hotplug proper. This is quite messy
> and it makes a dependency between the two so move movable_node along
> with the helper functions to memory_hotplug.
> 
> To make it more entertaining the kernel parameter is ignored unless
> CONFIG_HAVE_MEMBLOCK_NODE_MAP=y because we do not have the node
> information for each memblock otherwise. So let's warn when the option
> is disabled.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/memblock.h       |  7 -------
>  include/linux/memory_hotplug.h | 10 ++++++++++
>  mm/memblock.c                  |  1 -
>  mm/memory_hotplug.c            |  6 ++++++
>  4 files changed, 16 insertions(+), 8 deletions(-)
> 
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
> index 9e0249d0f5e4..d6e5e63b31d5 100644
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
> +static inline bool movable_node_is_enabled(void)
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
> index 2a14f8c18a22..1a148b35e8a3 100644
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
> @@ -1561,7 +1563,11 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>  
>  static int __init cmdline_parse_movable_node(char *p)
>  {
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  	movable_node_enabled = true;
> +#else
> +	pr_warn("movable_node parameter depends on CONFIG_HAVE_MEMBLOCK_NODE_MAP to work properly\n");
> +#endif
>  	return 0;
>  }
>  early_param("movable_node", cmdline_parse_movable_node);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
