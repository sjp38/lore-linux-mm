Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E832B6B002D
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 15:36:33 -0500 (EST)
Date: Mon, 7 Nov 2011 15:36:13 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [Revert] Re: [PATCH] mm: sync vmalloc address
 space page tables in alloc_vm_area()
Message-ID: <20111107203613.GA6546@phenom.dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
 <20110901161134.GA8979@dumpdata.com>
 <4E5FED1A.1000300@goop.org>
 <20110901141754.76cef93b.akpm@linux-foundation.org>
 <4E60C067.4010600@citrix.com>
 <20110902153204.59a928c1.akpm@linux-foundation.org>
 <20110906163553.GA28971@dumpdata.com>
 <20111105133846.GA4415@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Content-Disposition: inline
In-Reply-To: <20111105133846.GA4415@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Vrabel <david.vrabel@citrix.com>, Jeremy Fitzhardinge <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "namhyung@gmail.com" <namhyung@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rientjes@google.com" <rientjes@google.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> > > 
> > > oookay, I queued this for 3.1 and tagged it for a 3.0.x backport.  I
> > > *think* that's the outcome of this discussion, for the short-term?
> > 
> > <nods> Yup. Thanks!
> 
> Hey Andrew,
> 
> The long term outcome is the patchset that David worked on. I've sent
> a GIT PULL to Linus to pick up the Xen related patches that switch over
> the users of the right API:
> 
>  (xen) stable/vmalloc-3.2 for Linux 3.2-rc0
> 
> (https://lkml.org/lkml/2011/10/29/82)

And Linus picked it up.
.. snip..
> 
> Also, not sure what you thought of this patch below?

Patch included as attachment for easier review..
> 
> From b9acd3abc12972be0d938d7bc2466d899023e757 Mon Sep 17 00:00:00 2001
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Thu, 29 Sep 2011 16:53:32 +0100
> Subject: [PATCH] xen: map foreign pages for shared rings by updating the PTEs
>  directly
> 
> When mapping a foreign page with xenbus_map_ring_valloc() with the
> GNTTABOP_map_grant_ref hypercall, set the GNTMAP_contains_pte flag and
> pass a pointer to the PTE (in init_mm).
> 
> After the page is mapped, the usual fault mechanism can be used to
> update additional MMs.  This allows the vmalloc_sync_all() to be
> removed from alloc_vm_area().
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  arch/x86/xen/grant-table.c         |    2 +-
>  drivers/xen/xenbus/xenbus_client.c |   11 ++++++++---
>  include/linux/vmalloc.h            |    2 +-
>  mm/vmalloc.c                       |   27 +++++++++++++--------------
>  4 files changed, 23 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/x86/xen/grant-table.c b/arch/x86/xen/grant-table.c
> index 6bbfd7a..5a40d24 100644
> --- a/arch/x86/xen/grant-table.c
> +++ b/arch/x86/xen/grant-table.c
> @@ -71,7 +71,7 @@ int arch_gnttab_map_shared(unsigned long *frames, unsigned long nr_gframes,
>  
>  	if (shared == NULL) {
>  		struct vm_struct *area =
> -			alloc_vm_area(PAGE_SIZE * max_nr_gframes);
> +			alloc_vm_area(PAGE_SIZE * max_nr_gframes, NULL);
>  		BUG_ON(area == NULL);
>  		shared = area->addr;
>  		*__shared = shared;
> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
> index 229d3ad..52bc57f 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -34,6 +34,7 @@
>  #include <linux/types.h>
>  #include <linux/vmalloc.h>
>  #include <asm/xen/hypervisor.h>
> +#include <asm/xen/page.h>
>  #include <xen/interface/xen.h>
>  #include <xen/interface/event_channel.h>
>  #include <xen/events.h>
> @@ -435,19 +436,20 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
>  int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
>  {
>  	struct gnttab_map_grant_ref op = {
> -		.flags = GNTMAP_host_map,
> +		.flags = GNTMAP_host_map | GNTMAP_contains_pte,
>  		.ref   = gnt_ref,
>  		.dom   = dev->otherend_id,
>  	};
>  	struct vm_struct *area;
> +	pte_t *pte;
>  
>  	*vaddr = NULL;
>  
> -	area = alloc_vm_area(PAGE_SIZE);
> +	area = alloc_vm_area(PAGE_SIZE, &pte);
>  	if (!area)
>  		return -ENOMEM;
>  
> -	op.host_addr = (unsigned long)area->addr;
> +	op.host_addr = arbitrary_virt_to_machine(pte).maddr;
>  
>  	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
>  		BUG();
> @@ -526,6 +528,7 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr)
>  	struct gnttab_unmap_grant_ref op = {
>  		.host_addr = (unsigned long)vaddr,
>  	};
> +	unsigned int level;
>  
>  	/* It'd be nice if linux/vmalloc.h provided a find_vm_area(void *addr)
>  	 * method so that we don't have to muck with vmalloc internals here.
> @@ -547,6 +550,8 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr)
>  	}
>  
>  	op.handle = (grant_handle_t)area->phys_addr;
> +	op.host_addr = arbitrary_virt_to_machine(
> +		lookup_address((unsigned long)vaddr, &level)).maddr;
>  
>  	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
>  		BUG();
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 9332e52..1a77252 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -118,7 +118,7 @@ unmap_kernel_range(unsigned long addr, unsigned long size)
>  #endif
>  
>  /* Allocate/destroy a 'vmalloc' VM area. */
> -extern struct vm_struct *alloc_vm_area(size_t size);
> +extern struct vm_struct *alloc_vm_area(size_t size, pte_t **ptes);
>  extern void free_vm_area(struct vm_struct *area);
>  
>  /* for /dev/kmem */
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 5016f19..b5deec6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2105,23 +2105,30 @@ void  __attribute__((weak)) vmalloc_sync_all(void)
>  
>  static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
>  {
> -	/* apply_to_page_range() does all the hard work. */
> +	pte_t ***p = data;
> +
> +	if (p) {
> +		*(*p) = pte;
> +		(*p)++;
> +	}
>  	return 0;
>  }
>  
>  /**
>   *	alloc_vm_area - allocate a range of kernel address space
>   *	@size:		size of the area
> + *	@ptes:		returns the PTEs for the address space
>   *
>   *	Returns:	NULL on failure, vm_struct on success
>   *
>   *	This function reserves a range of kernel address space, and
>   *	allocates pagetables to map that range.  No actual mappings
> - *	are created.  If the kernel address space is not shared
> - *	between processes, it syncs the pagetable across all
> - *	processes.
> + *	are created.
> + *
> + *	If @ptes is non-NULL, pointers to the PTEs (in init_mm)
> + *	allocated for the VM area are returned.
>   */
> -struct vm_struct *alloc_vm_area(size_t size)
> +struct vm_struct *alloc_vm_area(size_t size, pte_t **ptes)
>  {
>  	struct vm_struct *area;
>  
> @@ -2135,19 +2142,11 @@ struct vm_struct *alloc_vm_area(size_t size)
>  	 * of kernel virtual address space and mapped into init_mm.
>  	 */
>  	if (apply_to_page_range(&init_mm, (unsigned long)area->addr,
> -				area->size, f, NULL)) {
> +				size, f, ptes ? &ptes : NULL)) {
>  		free_vm_area(area);
>  		return NULL;
>  	}
>  
> -	/*
> -	 * If the allocated address space is passed to a hypercall
> -	 * before being used then we cannot rely on a page fault to
> -	 * trigger an update of the page tables.  So sync all the page
> -	 * tables here.
> -	 */
> -	vmalloc_sync_all();
> -
>  	return area;
>  }
>  EXPORT_SYMBOL_GPL(alloc_vm_area);
> -- 
> 1.7.7.1
> 

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-xen-map-foreign-pages-for-shared-rings-by-updating-t.patch"


--45Z9DzgjV8m4Oswq--
