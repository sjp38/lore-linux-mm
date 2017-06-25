Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A78E6B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 23:31:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d62so77076296pfb.13
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 20:31:23 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id n10si4043999pgf.399.2017.06.24.20.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 20:31:22 -0700 (PDT)
Subject: Re: [RFC PATCH 1/4] mm/hotplug: aligne the hotplugable range with
 memory_block
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-2-richard.weiyang@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <be965d3a-002b-9a9f-873b-b7237238ac21@nvidia.com>
Date: Sat, 24 Jun 2017 20:31:20 -0700
MIME-Version: 1.0
In-Reply-To: <20170625025227.45665-2-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

On 06/24/2017 07:52 PM, Wei Yang wrote:
> memory hotplug is memory block aligned instead of section aligned.
> 
> This patch fix the range check during hotplug.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  drivers/base/memory.c  | 3 ++-
>  include/linux/memory.h | 2 ++
>  mm/memory_hotplug.c    | 9 +++++----
>  3 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index c7c4e0325cdb..b54cfe9cd98b 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -31,7 +31,8 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>  
>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>  
> -static int sections_per_block;
> +int sections_per_block;
> +EXPORT_SYMBOL(sections_per_block);

Hi Wei,

Is sections_per_block ever assigned a value? I am not seeing that happen,
either in this patch, or in the larger patchset.


>  
>  static inline int base_memory_block_id(int section_nr)
>  {
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index b723a686fc10..51a6355aa56d 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -142,4 +142,6 @@ extern struct memory_block *find_memory_block(struct mem_section *);
>   */
>  extern struct mutex text_mutex;
>  
> +extern int sections_per_block;
> +
>  #endif /* _LINUX_MEMORY_H_ */
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 387ca386142c..f5d06afc8645 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1183,11 +1183,12 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>  {
>  	u64 start_pfn = PFN_DOWN(start);
>  	u64 nr_pages = size >> PAGE_SHIFT;
> +	u64 page_per_block = sections_per_block * PAGES_PER_SECTION;

"pages_per_block" would be a little better.

Also, in the first line of the commit, s/aligne/align/.

thanks,
john h

>  
> -	/* Memory range must be aligned with section */
> -	if ((start_pfn & ~PAGE_SECTION_MASK) ||
> -	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
> -		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
> +	/* Memory range must be aligned with memory_block */
> +	if ((start_pfn & (page_per_block - 1)) ||
> +	    (nr_pages % page_per_block) || (!nr_pages)) {
> +		pr_err("Memory_block-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
>  				(unsigned long long)start,
>  				(unsigned long long)size);
>  		return -EINVAL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
