Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E6096B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 05:31:34 -0400 (EDT)
Date: Tue, 28 Sep 2010 04:31:32 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 2/8] v2 Add section count to memory_block struct
Message-ID: <20100928093132.GG14068@sgi.com>
References: <4CA0EBEB.1030204@austin.ibm.com>
 <4CA0EEF0.70402@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA0EEF0.70402@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

In the next patch, you introduce a mutex for adding/removing memory blocks.
Is there really a need for this to be atomic?  If you reorder the patches
so the mutex comes first, would the atomic be needed any longer?

Robin

On Mon, Sep 27, 2010 at 02:22:24PM -0500, Nathan Fontenot wrote:
> Add a section count property to the memory_block struct to track the number
> of memory sections that have been added/removed from a memory block. This
> allows us to know when the last memory section of a memory block has been
> removed so we can remove the memory block.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> ---
>  drivers/base/memory.c  |   16 ++++++++++------
>  include/linux/memory.h |    3 +++
>  2 files changed, 13 insertions(+), 6 deletions(-)
> 
> Index: linux-next/drivers/base/memory.c
> ===================================================================
> --- linux-next.orig/drivers/base/memory.c	2010-09-27 09:17:20.000000000 -0500
> +++ linux-next/drivers/base/memory.c	2010-09-27 09:31:35.000000000 -0500
> @@ -478,6 +478,7 @@
>  
>  	mem->phys_index = __section_nr(section);
>  	mem->state = state;
> +	atomic_inc(&mem->section_count);
>  	mutex_init(&mem->state_mutex);
>  	start_pfn = section_nr_to_pfn(mem->phys_index);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> @@ -505,12 +506,15 @@
>  	struct memory_block *mem;
>  
>  	mem = find_memory_block(section);
> -	unregister_mem_sect_under_nodes(mem);
> -	mem_remove_simple_file(mem, phys_index);
> -	mem_remove_simple_file(mem, state);
> -	mem_remove_simple_file(mem, phys_device);
> -	mem_remove_simple_file(mem, removable);
> -	unregister_memory(mem, section);
> +
> +	if (atomic_dec_and_test(&mem->section_count)) {
> +		unregister_mem_sect_under_nodes(mem);
> +		mem_remove_simple_file(mem, phys_index);
> +		mem_remove_simple_file(mem, state);
> +		mem_remove_simple_file(mem, phys_device);
> +		mem_remove_simple_file(mem, removable);
> +		unregister_memory(mem, section);
> +	}
>  
>  	return 0;
>  }
> Index: linux-next/include/linux/memory.h
> ===================================================================
> --- linux-next.orig/include/linux/memory.h	2010-09-27 09:17:20.000000000 -0500
> +++ linux-next/include/linux/memory.h	2010-09-27 09:22:56.000000000 -0500
> @@ -19,10 +19,13 @@
>  #include <linux/node.h>
>  #include <linux/compiler.h>
>  #include <linux/mutex.h>
> +#include <asm/atomic.h>
>  
>  struct memory_block {
>  	unsigned long phys_index;
>  	unsigned long state;
> +	atomic_t section_count;
> +
>  	/*
>  	 * This serializes all state change requests.  It isn't
>  	 * held during creation because the control files are
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
