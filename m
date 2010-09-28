Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 559A96B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 05:29:32 -0400 (EDT)
Date: Tue, 28 Sep 2010 04:29:19 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 6/8] v2 Update node sysfs code
Message-ID: <20100928092919.GF14068@sgi.com>
References: <4CA0EBEB.1030204@austin.ibm.com>
 <4CA0F00D.9000702@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA0F00D.9000702@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch may work, but it appears it is lacking in, at least the
link_mem_sections() function.  Assuming you have a memory block covering
2GB and a section size of 128MB (some values we are toying with for
large SGI machines), you end up calling register_mem_sect_under_node()
16 times which then takes the same steps.

I think you also need:

Index: linux-2.6.32/drivers/base/node.c
===================================================================
--- linux-2.6.32.orig/drivers/base/node.c	2010-09-28 04:18:53.848448349 -0500
+++ linux-2.6.32/drivers/base/node.c	2010-09-28 04:21:35.169446261 -0500
@@ -342,6 +342,7 @@
 		if (!err)
 			err = ret;
 
+		pfn = section_nr_to_pfn(mem_blk->end_phys_index);
 		/* discard ref obtained in find_memory_block() */
 		kobject_put(&mem_blk->sysdev.kobj);
 	}

Also, I don't think I much care for the weirdness that occurs if a
memory block spans two nodes.  I have not thought through how possible
(or likely) this is, but the code certainly permits it.  If that were
the case, how would we know which sections need to be taken offline, etc?
I wonder how much this will muddy up the information available in sysfs.

Thanks,
Robin

On Mon, Sep 27, 2010 at 02:27:09PM -0500, Nathan Fontenot wrote:
> Update the node sysfs code to be aware of the new capability for a memory
> block to contain multiple memory sections.  This requires an additional
> parameter to unregister_mem_sect_under_nodes so that we know which memory
> section of the memory block to unregister.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> ---
>  drivers/base/memory.c |    2 +-
>  drivers/base/node.c   |   12 ++++++++----
>  include/linux/node.h  |    6 ++++--
>  3 files changed, 13 insertions(+), 7 deletions(-)
> 
> Index: linux-next/drivers/base/node.c
> ===================================================================
> --- linux-next.orig/drivers/base/node.c	2010-09-27 13:49:36.000000000 -0500
> +++ linux-next/drivers/base/node.c	2010-09-27 13:50:43.000000000 -0500
> @@ -346,8 +346,10 @@
>  		return -EFAULT;
>  	if (!node_online(nid))
>  		return 0;
> -	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +
> +	sect_start_pfn = section_nr_to_pfn(mem_blk->start_phys_index);
> +	sect_end_pfn = section_nr_to_pfn(mem_blk->end_phys_index);
> +	sect_end_pfn += PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>  		int page_nid;
>  
> @@ -371,7 +373,8 @@
>  }
>  
>  /* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> +int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +				    unsigned long phys_index)
>  {
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -383,7 +386,8 @@
>  	if (!unlinked_nodes)
>  		return -ENOMEM;
>  	nodes_clear(*unlinked_nodes);
> -	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> +
> +	sect_start_pfn = section_nr_to_pfn(phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>  		int nid;
> Index: linux-next/drivers/base/memory.c
> ===================================================================
> --- linux-next.orig/drivers/base/memory.c	2010-09-27 13:50:38.000000000 -0500
> +++ linux-next/drivers/base/memory.c	2010-09-27 13:50:43.000000000 -0500
> @@ -587,9 +587,9 @@
>  
>  	mutex_lock(&mem_sysfs_mutex);
>  	mem = find_memory_block(section);
> +	unregister_mem_sect_under_nodes(mem, __section_nr(section));
>  
>  	if (atomic_dec_and_test(&mem->section_count)) {
> -		unregister_mem_sect_under_nodes(mem);
>  		mem_remove_simple_file(mem, phys_index);
>  		mem_remove_simple_file(mem, end_phys_index);
>  		mem_remove_simple_file(mem, state);
> Index: linux-next/include/linux/node.h
> ===================================================================
> --- linux-next.orig/include/linux/node.h	2010-09-27 13:49:36.000000000 -0500
> +++ linux-next/include/linux/node.h	2010-09-27 13:50:43.000000000 -0500
> @@ -44,7 +44,8 @@
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						int nid);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
> +extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +					   unsigned long phys_index);
>  
>  #ifdef CONFIG_HUGETLBFS
>  extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
> @@ -72,7 +73,8 @@
>  {
>  	return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> +static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> +						  unsigned long phys_index)
>  {
>  	return 0;
>  }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
