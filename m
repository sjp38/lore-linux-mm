Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 864056B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 20:26:00 -0400 (EDT)
Message-ID: <4A3ADB33.8060102@kernel.org>
Date: Thu, 18 Jun 2009 17:26:27 -0700
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] bootmem.c: Avoid c90 declaration warning
References: <1245355633.29927.16.camel@Joe-Laptop.home> <20090618132410.0b55cd90.akpm@linux-foundation.org> <20090618215744.GA10816@cmpxchg.org>
In-Reply-To: <20090618215744.GA10816@cmpxchg.org>
Content-Type: multipart/mixed;
 boundary="------------060305060601080404060503"
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060305060601080404060503
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Johannes Weiner wrote:
> On Thu, Jun 18, 2009 at 01:24:10PM -0700, Andrew Morton wrote:
>> On Thu, 18 Jun 2009 13:07:13 -0700
>> Joe Perches <joe@perches.com> wrote:
>>
>>> Signed-off-by: Joe Perches <joe@perches.com>
>>>
>>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>>> index 282df0a..09d9c98 100644
>>> --- a/mm/bootmem.c
>>> +++ b/mm/bootmem.c
>>> @@ -536,11 +536,13 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
>>>  		return kzalloc(size, GFP_NOWAIT);
>>>  
>>>  #ifdef CONFIG_HAVE_ARCH_BOOTMEM
>>> +	{
>>>  	bootmem_data_t *p_bdata;
>>>  
>>>  	p_bdata = bootmem_arch_preferred_node(bdata, size, align, goal, limit);
>>>  	if (p_bdata)
>>>  		return alloc_bootmem_core(p_bdata, size, align, goal, limit);
>>> +	}
>>>  #endif
>>>  	return NULL;
>>>  }
>> Well yes.
>>
>> We'll be needing some tabs there.
>>
>> Unrelatedly, I'm struggling a bit with bootmem_arch_preferred_node(). 
>> It's only defined if CONFIG_X86_32=y && CONFIG_NEED_MULTIPLE_NODES=y,
>> but it gets called if CONFIG_HAVE_ARCH_BOOTMEM=y.
>>
>> Is this correct, logical and as simple as we can make it??
> 
> x86_32 numa is the only setter of HAVE_ARCH_BOOTMEM.  I don't know why
> this arch has a strict preference/requirement(?) for bootmem on node
> 0.
> 
> I found this mail from Yinghai
> 
>   http://marc.info/?l=linux-kernel&m=123614990906256&w=2
> 
> where he says that it expects all bootmem on node zero but with the
> current code and alloc_arch_preferred_bootmem() failing, we could fall
> back to another node.  Won't this break?  Yinghai?

not sure it is the same problem. the fix was in mainline already.


> 
> Otherwise, could we perhaps use something as simple as this?
> 
> diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
> index ede6998..b68a672 100644
> --- a/arch/x86/include/asm/mmzone_32.h
> +++ b/arch/x86/include/asm/mmzone_32.h
> @@ -92,8 +92,7 @@ static inline int pfn_valid(int pfn)
>  
>  #ifdef CONFIG_NEED_MULTIPLE_NODES
>  /* always use node 0 for bootmem on this numa platform */
> -#define bootmem_arch_preferred_node(__bdata, size, align, goal, limit)	\
> -	(NODE_DATA(0)->bdata)
> +#define bootmem_arch_preferred_node (NODE(0)->bdata)
>  #endif /* CONFIG_NEED_MULTIPLE_NODES */
>  
>  #endif /* _ASM_X86_MMZONE_32_H */
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 282df0a..0097fa2 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -528,23 +528,6 @@ find_block:
>  	return NULL;
>  }
>  
> -static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
> -					unsigned long size, unsigned long align,
> -					unsigned long goal, unsigned long limit)
> -{
> -	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc(size, GFP_NOWAIT);
> -
> -#ifdef CONFIG_HAVE_ARCH_BOOTMEM
> -	bootmem_data_t *p_bdata;
> -
> -	p_bdata = bootmem_arch_preferred_node(bdata, size, align, goal, limit);
> -	if (p_bdata)
> -		return alloc_bootmem_core(p_bdata, size, align, goal, limit);
> -#endif
> -	return NULL;
> -}
> -
>  static void * __init ___alloc_bootmem_nopanic(unsigned long size,
>  					unsigned long align,
>  					unsigned long goal,
> @@ -553,11 +536,15 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
>  	bootmem_data_t *bdata;
>  	void *region;
>  
> +	if (WARN_ON_ONCE(slab_is_available()))
> +		return kzalloc(size, GFP_NOWAIT);
>  restart:
> -	region = alloc_arch_preferred_bootmem(NULL, size, align, goal, limit);
> +#ifdef bootmem_arch_preferred_node
> +	region = alloc_bootmem_core(bootmem_arch_preferred_node,
> +				size, align, goal, limit);
>  	if (region)
>  		return region;
> -
> +#endif
>  	list_for_each_entry(bdata, &bdata_list, list) {
>  		if (goal && bdata->node_low_pfn <= PFN_DOWN(goal))
>  			continue;
> @@ -636,13 +623,11 @@ static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
>  {
>  	void *ptr;
>  
> -	ptr = alloc_arch_preferred_bootmem(bdata, size, align, goal, limit);
> -	if (ptr)
> -		return ptr;
> -
> +#ifndef bootmem_arch_preferred_node
>  	ptr = alloc_bootmem_core(bdata, size, align, goal, limit);
>  	if (ptr)
>  		return ptr;
> +#endif
>  
>  	return ___alloc_bootmem(size, align, goal, limit);
>  }


any reason to kill alloc_arch_preferred_bootmem?

YH

--------------060305060601080404060503
Content-Type: text/x-patch;
 name="11.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.patch"

commit a71edd1f46c8a599509bda478fb4eea27fb0da63
Author: Yinghai Lu <yinghai@kernel.org>
Date:   Wed Mar 4 01:22:35 2009 -0800

    x86: fix bootmem cross node for 32bit numa
    
    Impact: fix panic on system 2g x4 sockets
    
    Found one system with 4 sockets and every sockets has 2g can not boot
    with numa32 because boot mem is crossing nodes.
    
    So try to have numa version of setup_bootmem_allocator().
    
    Signed-off-by: Yinghai Lu <yinghai@kernel.org>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    LKML-Reference: <49AE485B.8000902@kernel.org>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 917c4e6..67bdb59 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -776,9 +776,37 @@ static void __init zone_sizes_init(void)
 	free_area_init_nodes(max_zone_pfns);
 }
 
+#ifdef CONFIG_NEED_MULTIPLE_NODES
+static unsigned long __init setup_node_bootmem(int nodeid,
+				 unsigned long start_pfn,
+				 unsigned long end_pfn,
+				 unsigned long bootmap)
+{
+	unsigned long bootmap_size;
+
+	if (start_pfn > max_low_pfn)
+		return bootmap;
+	if (end_pfn > max_low_pfn)
+		end_pfn = max_low_pfn;
+
+	/* don't touch min_low_pfn */
+	bootmap_size = init_bootmem_node(NODE_DATA(nodeid),
+					 bootmap >> PAGE_SHIFT,
+					 start_pfn, end_pfn);
+	printk(KERN_INFO "  node %d low ram: %08lx - %08lx\n",
+		nodeid, start_pfn<<PAGE_SHIFT, end_pfn<<PAGE_SHIFT);
+	printk(KERN_INFO "  node %d bootmap %08lx - %08lx\n",
+		 nodeid, bootmap, bootmap + bootmap_size);
+	free_bootmem_with_active_regions(nodeid, end_pfn);
+	early_res_to_bootmem(start_pfn<<PAGE_SHIFT, end_pfn<<PAGE_SHIFT);
+
+	return bootmap + bootmap_size;
+}
+#endif
+
 void __init setup_bootmem_allocator(void)
 {
-	int i;
+	int nodeid;
 	unsigned long bootmap_size, bootmap;
 	/*
 	 * Initialize the boot-time allocator (with low memory only):
@@ -791,18 +819,24 @@ void __init setup_bootmem_allocator(void)
 		panic("Cannot find bootmem map of size %ld\n", bootmap_size);
 	reserve_early(bootmap, bootmap + bootmap_size, "BOOTMAP");
 
-	/* don't touch min_low_pfn */
-	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap >> PAGE_SHIFT,
-					 min_low_pfn, max_low_pfn);
 	printk(KERN_INFO "  mapped low ram: 0 - %08lx\n",
 		 max_pfn_mapped<<PAGE_SHIFT);
 	printk(KERN_INFO "  low ram: %08lx - %08lx\n",
 		 min_low_pfn<<PAGE_SHIFT, max_low_pfn<<PAGE_SHIFT);
+
+#ifdef CONFIG_NEED_MULTIPLE_NODES
+	for_each_online_node(nodeid)
+		bootmap = setup_node_bootmem(nodeid, node_start_pfn[nodeid],
+					node_end_pfn[nodeid], bootmap);
+#else
+	/* don't touch min_low_pfn */
+	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap >> PAGE_SHIFT,
+					 min_low_pfn, max_low_pfn);
 	printk(KERN_INFO "  bootmap %08lx - %08lx\n",
 		 bootmap, bootmap + bootmap_size);
-	for_each_online_node(i)
-		free_bootmem_with_active_regions(i, max_low_pfn);
+	free_bootmem_with_active_regions(0, max_low_pfn);
 	early_res_to_bootmem(0, max_low_pfn<<PAGE_SHIFT);
+#endif
 
 	after_init_bootmem = 1;
 }
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
index 451fe95..3daefa0 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -416,10 +416,11 @@ void __init initmem_init(unsigned long start_pfn,
 	for_each_online_node(nid)
 		propagate_e820_map_node(nid);
 
-	for_each_online_node(nid)
+	for_each_online_node(nid) {
 		memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
+		NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
+	}
 
-	NODE_DATA(0)->bdata = &bootmem_node_data[0];
 	setup_bootmem_allocator();
 }
 

--------------060305060601080404060503
Content-Type: text/x-patch;
 name="12.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="12.patch"

commit fc5efe3941c47c0278fe1bbcf8cc02a03a74fcda
Author: Yinghai Lu <yinghai@kernel.org>
Date:   Wed Mar 4 12:21:24 2009 -0800

    x86: fix bootmem cross node for 32bit numa, cleanup
    
    Impact: clean up
    
    Simplify the code, reuse some lines.
    Remove min_low_pfn reference, it is always 0
    
    Signed-off-by: Yinghai Lu <yinghai@kernel.org>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    LKML-Reference: <49AEE2C4.2030602@kernel.org>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index c69c6b1..c351456 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -776,7 +776,6 @@ static void __init zone_sizes_init(void)
 	free_area_init_nodes(max_zone_pfns);
 }
 
-#ifdef CONFIG_NEED_MULTIPLE_NODES
 static unsigned long __init setup_node_bootmem(int nodeid,
 				 unsigned long start_pfn,
 				 unsigned long end_pfn,
@@ -802,7 +801,6 @@ static unsigned long __init setup_node_bootmem(int nodeid,
 
 	return bootmap + bootmap_size;
 }
-#endif
 
 void __init setup_bootmem_allocator(void)
 {
@@ -812,8 +810,7 @@ void __init setup_bootmem_allocator(void)
 	 * Initialize the boot-time allocator (with low memory only):
 	 */
 	bootmap_size = bootmem_bootmap_pages(max_low_pfn)<<PAGE_SHIFT;
-	bootmap = find_e820_area(min_low_pfn<<PAGE_SHIFT,
-				 max_pfn_mapped<<PAGE_SHIFT, bootmap_size,
+	bootmap = find_e820_area(0, max_pfn_mapped<<PAGE_SHIFT, bootmap_size,
 				 PAGE_SIZE);
 	if (bootmap == -1L)
 		panic("Cannot find bootmem map of size %ld\n", bootmap_size);
@@ -821,21 +818,14 @@ void __init setup_bootmem_allocator(void)
 
 	printk(KERN_INFO "  mapped low ram: 0 - %08lx\n",
 		 max_pfn_mapped<<PAGE_SHIFT);
-	printk(KERN_INFO "  low ram: %08lx - %08lx\n",
-		 min_low_pfn<<PAGE_SHIFT, max_low_pfn<<PAGE_SHIFT);
+	printk(KERN_INFO "  low ram: 0 - %08lx\n", max_low_pfn<<PAGE_SHIFT);
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
 	for_each_online_node(nodeid)
 		bootmap = setup_node_bootmem(nodeid, node_start_pfn[nodeid],
 					node_end_pfn[nodeid], bootmap);
 #else
-	/* don't touch min_low_pfn */
-	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap >> PAGE_SHIFT,
-					 min_low_pfn, max_low_pfn);
-	printk(KERN_INFO "  bootmap %08lx - %08lx\n",
-		 bootmap, bootmap + bootmap_size);
-	free_bootmem_with_active_regions(0, max_low_pfn);
-	early_res_to_bootmem(0, max_low_pfn<<PAGE_SHIFT);
+	bootmap = setup_node_bootmem(0, 0, max_low_pfn, bootmap);
 #endif
 
 	after_init_bootmem = 1;

--------------060305060601080404060503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
