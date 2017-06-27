Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D20FE6B02FA
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:11:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so20654930pgr.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:11:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id q2si1439078pgd.227.2017.06.27.00.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 00:11:53 -0700 (PDT)
Subject: Re: [RFC PATCH 4/4] base/memory: pass start_section_nr to
 init_memory_block()
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-5-richard.weiyang@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ac2b2750-d673-ce91-cd48-fc95e41ae6f7@nvidia.com>
Date: Tue, 27 Jun 2017 00:11:52 -0700
MIME-Version: 1.0
In-Reply-To: <20170625025227.45665-5-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

On 06/24/2017 07:52 PM, Wei Yang wrote:
> The second parameter of init_memory_block() is to calculate the
> start_section_nr for the memory_block. While current implementation dose
> some unnecessary transform between mem_sectioni and section_nr.

Hi Wei,

I am unable to find anything wrong with this patch (except of course
that your top-level description in the "[PATCH 0/4" thread will need
to be added somewhere).

Here's a slight typo/grammar improvement for the patch
description above, if you like:

"The current implementation does some unnecessary conversions
between mem_section and section_nr."

thanks,
john h

> 
> This patch simplifies the function by just passing the start_section_nr to
> it. By doing so, we can also simplify add_memory_block() too.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  drivers/base/memory.c  | 16 ++++++----------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    |  2 +-
>  3 files changed, 8 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 468e5ad1bc87..43783dbb1d5e 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -645,7 +645,7 @@ int register_memory(struct memory_block *memory)
>  }
>  
>  static int init_memory_block(struct memory_block **memory,
> -			     struct mem_section *section, unsigned long state)
> +			     int start_section_nr, unsigned long state)
>  {
>  	struct memory_block *mem;
>  	unsigned long start_pfn;
> @@ -656,9 +656,7 @@ static int init_memory_block(struct memory_block **memory,
>  	if (!mem)
>  		return -ENOMEM;
>  
> -	scn_nr = __section_nr(section);
> -	mem->start_section_nr =
> -			base_memory_block_id(scn_nr) * sections_per_block;
> +	mem->start_section_nr = start_section_nr;
>  	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
> @@ -673,21 +671,19 @@ static int init_memory_block(struct memory_block **memory,
>  static int add_memory_block(int base_section_nr)
>  {
>  	struct memory_block *mem;
> -	int i, ret, section_count = 0, section_nr;
> +	int i, ret, section_count = 0;
>  
>  	for (i = base_section_nr;
>  	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
>  	     i++) {
>  		if (!present_section_nr(i))
>  			continue;
> -		if (section_count == 0)
> -			section_nr = i;
>  		section_count++;
>  	}
>  
>  	if (section_count == 0)
>  		return 0;
> -	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
> +	ret = init_memory_block(&mem, base_section_nr, MEM_ONLINE);
>  	if (ret)
>  		return ret;
>  	mem->section_count = section_count;
> @@ -698,14 +694,14 @@ static int add_memory_block(int base_section_nr)
>   * need an interface for the VM to add new memory regions,
>   * but without onlining it.
>   */
> -int register_new_memory(int nid, struct mem_section *section)
> +int register_new_memory(int nid, int start_section_nr)
>  {
>  	int ret = 0;
>  	struct memory_block *mem;
>  
>  	mutex_lock(&mem_sysfs_mutex);
>  
> -	ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +	ret = init_memory_block(&mem, start_section_nr, MEM_OFFLINE);
>  	if (ret)
>  		goto out;
>  	mem->section_count = sections_per_block;
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 51a6355aa56d..0cbde14f7cea 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -108,7 +108,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -extern int register_new_memory(int, struct mem_section *);
> +extern int register_new_memory(int, int);
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern int unregister_memory_section(struct mem_section *);
>  #endif
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 14a08b980b59..fc198847dd5b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -346,7 +346,7 @@ static int __meminit __add_memory_block(int nid, unsigned long phys_start_pfn,
>  	if (!want_memblock)
>  		return 0;
>  
> -	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> +	return register_new_memory(nid, pfn_to_section_nr(phys_start_pfn));
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
