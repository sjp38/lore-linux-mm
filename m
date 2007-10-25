Date: Thu, 25 Oct 2007 11:17:32 +0100
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
Message-ID: <20071025101731.GC30732@skynet.ie>
References: <1193243866.30836.25.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1193243866.30836.25.camel@dyn9047017100.beaverton.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/10/07 09:37), Badari Pulavarty didst pronounce:
> Each memory block of the memory has attributes exported to /sysfs. 
> This patch adds file "mem_type" to show that memory block's migrate type. 
> This is useful to identify memory blocks for hotplug memory remove.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com> 
> ---
>  drivers/base/memory.c |   24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> Index: linux-2.6.23/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.23.orig/drivers/base/memory.c	2007-10-24 09:09:05.000000000 -0700
> +++ linux-2.6.23/drivers/base/memory.c	2007-10-24 09:10:05.000000000 -0700
> @@ -105,6 +105,26 @@ static ssize_t show_mem_phys_index(struc
>  }
>  
>  /*
> + * show memory migrate type
> + */
> +static ssize_t show_mem_type(struct sys_device *dev, char *buf)
> +{
> +	struct page *first_page;
> +	int type;
> +	struct memory_block *mem =
> +		container_of(dev, struct memory_block, sysdev);
> +
> +	/*
> +	 * Get the type of the firstpage in the memory block.
> +	 * For now, assume that entire memory block is of same
> +	 * type.
> +	 */
> +	first_page = pfn_to_page(section_nr_to_pfn(mem->phys_index));
> +	type =  get_pageblock_migratetype(first_page);

Silly pick-issue but there is a "  " there.

> +	return sprintf(buf, "%s\n", migratetype_names[type]);
> +}

Ok, it is safe to assume get_pageblock_migratetype() will never return a
stupid value outside the bounds of that array.

> +
> +/*
>   * online, offline, going offline, etc.
>   */
>  static ssize_t show_mem_state(struct sys_device *dev, char *buf)
> @@ -270,6 +290,7 @@ static ssize_t show_phys_device(struct s
>  static SYSDEV_ATTR(phys_index, 0444, show_mem_phys_index, NULL);
>  static SYSDEV_ATTR(state, 0644, show_mem_state, store_mem_state);
>  static SYSDEV_ATTR(phys_device, 0444, show_phys_device, NULL);
> +static SYSDEV_ATTR(mem_type, 0444, show_mem_type, NULL);
>  

Sensible permissions.

>  #define mem_create_simple_file(mem, attr_name)	\
>  	sysdev_create_file(&mem->sysdev, &attr_##attr_name)
> @@ -358,6 +379,8 @@ static int add_memory_block(unsigned lon
>  		ret = mem_create_simple_file(mem, state);
>  	if (!ret)
>  		ret = mem_create_simple_file(mem, phys_device);
> +	if (!ret)
> +		ret = mem_create_simple_file(mem, mem_type);
>  
>  	return ret;
>  }
> @@ -402,6 +425,7 @@ int remove_memory_block(unsigned long no
>  	mem_remove_simple_file(mem, phys_index);
>  	mem_remove_simple_file(mem, state);
>  	mem_remove_simple_file(mem, phys_device);
> +	mem_remove_simple_file(mem, mem_type);
>  	unregister_memory(mem, section, NULL);
>  
>  	return 0;
> 

Other than the possibility of sections having more than one block on x86_64,
this all looks fine. On x86_64 the multiple blocks might be annoying but I
also feel the mem_type information is not much use to that arch so;

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
