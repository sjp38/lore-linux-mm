Date: Fri, 28 Mar 2008 09:47:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: vmalloc: Return page array on vunmap
Message-Id: <20080328094702.b6dfa83d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Mar 2008 21:18:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com>, Christoph Lameter <clameter@sgi.com> wrote:

> Make vunmap return the page array that was used at vmap. This is useful
> if one has no structures to track the page array but simply stores the
> virtual address somewhere. The disposition of the page array can then
> be decided upon by the caller after vunmap has torn down the mapping.
> 
> vfree() may now also be used instead of vunmap. vfree() will release the
> page array after vunmap'ping it. If vfree() is called to free the page
> array then the page array must either be
> 
> 1. Allocated via the slab allocator
> 
> 2. Allocated via vmalloc but then VM_VPAGES must have been passed at
>    vunmap to specify that a vfree is needed.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/vmalloc.h |    2 +-
>  mm/vmalloc.c            |   29 +++++++++++++++++++----------
>  2 files changed, 20 insertions(+), 11 deletions(-)
> 
> Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-26 21:17:29.536667641 -0700
> +++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-26 21:17:30.746669304 -0700
> @@ -50,7 +50,7 @@ extern void vfree(const void *addr);
>  
>  extern void *vmap(struct page **pages, unsigned int count,
>  			unsigned long flags, pgprot_t prot);
> -extern void vunmap(const void *addr);
> +extern struct page **vunmap(const void *addr);
>  
>  extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
>  							unsigned long pgoff);
> Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-26 21:17:29.546668091 -0700
> +++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-26 21:18:17.903682868 -0700
> @@ -153,6 +153,7 @@ int map_vm_area(struct vm_struct *area, 
>  	unsigned long addr = (unsigned long) area->addr;
>  	unsigned long end = addr + area->size - PAGE_SIZE;
>  	int err;
> +	area->pages = *pages;
>  
>  	BUG_ON(addr >= end);
>  	pgd = pgd_offset_k(addr);
> @@ -163,6 +164,8 @@ int map_vm_area(struct vm_struct *area, 
>  			break;
>  	} while (pgd++, addr = next, addr != end);
>  	flush_cache_vmap((unsigned long) area->addr, end);
> +
> +	area->nr_pages = *pages - area->pages;
>  	return err;
>  }

Why this change ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
