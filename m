Date: Thu, 25 Oct 2007 17:07:04 +0100
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
Message-ID: <20071025160704.GA20345@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (25/10/07 08:55), Badari Pulavarty didst pronounce:
> Kame & Mel,
> 
> Here is the updated patch, which checks all the pages in the section
> to cover all archs. Are you okay with this ? 
> 
> Thanks,
> Badari
> 
> Here is the output:
> 
> ./memory0/mem_type: Multiple
> ./memory1/mem_type: Multiple
> ./memory2/mem_type: Movable
> ./memory3/mem_type: Movable
> ./memory4/mem_type: Movable
> ./memory5/mem_type: Movable
> ./memory6/mem_type: Movable
> ./memory7/mem_type: Movable
> ..
> 
> Each section of the memory has attributes in /sysfs. This patch adds 
> file "mem_type" to show that memory section's migrate type. This is useful
> to identify section of the memory for hotplug memory remove.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
>  drivers/base/memory.c |   33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 
> Index: linux-2.6.23/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.23.orig/drivers/base/memory.c	2007-10-23 15:19:14.000000000 -0700
> +++ linux-2.6.23/drivers/base/memory.c	2007-10-25 10:34:41.000000000 -0700
> @@ -105,6 +105,35 @@ static ssize_t show_mem_phys_index(struc
>  }
>  
>  /*
> + * show memory migrate type
> + */
> +static ssize_t show_mem_type(struct sys_device *dev, char *buf)
> +{
> +	struct page *page;
> +	int type;
> +	int i = pageblock_nr_pages;
> +	struct memory_block *mem =
> +		container_of(dev, struct memory_block, sysdev);
> +
> +	/*
> +	 * Get the type of first page in the block
> +	 */
> +	page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
> +	type = get_pageblock_migratetype(page);
> +
> +	/*
> +	 * Check the migrate type of other pages in this section.
> +	 * If the type doesn't match, report it.

The comment is a little misleading. We are not checking the type of pages,
but the pageblocks

/*
 * Check all pageblocks in this section to ensure they are all of
 * the same migrate type. If they are multiple types, report it.
 */

> +	 */
> +	while (i < PAGES_PER_SECTION) {
> +		if (type != get_pageblock_migratetype(page + i))
> +			return sprintf(buf, "Multiple\n");
> +		i += pageblock_nr_pages;
> +	}
> +	return sprintf(buf, "%s\n", migratetype_names[type]);
> +}
> +
> +/*
>   * online, offline, going offline, etc.
>   */
>  static ssize_t show_mem_state(struct sys_device *dev, char *buf)
> @@ -263,6 +292,7 @@ static ssize_t show_phys_device(struct s
>  static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
>  static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
>  static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
> +static SYSDEV_ATTR(mem_type, 0444, show_mem_type, NULL);
>  
>  #define mem_create_simple_file(mem, attr_name)	\
>  	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
> @@ -351,6 +381,8 @@ static int add_memory_block(unsigned lon
>  		ret = mem_create_simple_file(mem, state);
>  	if (!ret)
>  		ret = mem_create_simple_file(mem, phys_device);
> +	if (!ret)
> +		ret = mem_create_simple_file(mem, mem_type);
>  
>  	return ret;
>  }
> @@ -395,6 +427,7 @@ int remove_memory_block(unsigned long no
>  	mem_remove_simple_file(mem, phys_index);
>  	mem_remove_simple_file(mem, state);
>  	mem_remove_simple_file(mem, phys_device);
> +	mem_remove_simple_file(mem, mem_type);
>  	unregister_memory(mem, section, NULL);
>  
>  	return 0;
> 

Other than the misleading comment;

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
