Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 73E2F6B016C
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 12:11:53 -0400 (EDT)
Date: Thu, 1 Sep 2011 12:11:34 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [Revert] Re: [PATCH] mm: sync vmalloc address space page tables in
 alloc_vm_area()
Message-ID: <20110901161134.GA8979@dumpdata.com>
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, namhyung@gmail.com, rientjes@google.com, linux-mm@kvack.org
Cc: xen-devel@lists.xensource.com, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, paulmck@linux.vnet.ibm.com

On Thu, Sep 01, 2011 at 12:51:03PM +0100, David Vrabel wrote:
> From: David Vrabel <david.vrabel@citrix.com>

Andrew,

I was wondering if you would be Ok with this patch for 3.1.

It is a revert (I can prepare a proper revert if you would like
that instead of this patch).

The users of this particular function (alloc_vm_area) are just
Xen. There are no others.

> 
> Xen backend drivers (e.g., blkback and netback) would sometimes fail
> to map grant pages into the vmalloc address space allocated with
> alloc_vm_area().  The GNTTABOP_map_grant_ref would fail because Xen
> could not find the page (in the L2 table) containing the PTEs it
> needed to update.
> 
> (XEN) mm.c:3846:d0 Could not find L1 PTE for address fbb42000
> 
> netback and blkback were making the hypercall from a kernel thread
> where task->active_mm != &init_mm and alloc_vm_area() was only
> updating the page tables for init_mm.  The usual method of deferring
> the update to the page tables of other processes (i.e., after taking a
> fault) doesn't work as a fault cannot occur during the hypercall.
> 
> This would work on some systems depending on what else was using
> vmalloc.
> 
> Fix this by reverting ef691947d8a3d479e67652312783aedcf629320a
> (vmalloc: remove vmalloc_sync_all() from alloc_vm_area()) and add a
> comment to explain why it's needed.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> ---
>  mm/vmalloc.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 7ef0903..5016f19 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2140,6 +2140,14 @@ struct vm_struct *alloc_vm_area(size_t size)
>  		return NULL;
>  	}
>  
> +	/*
> +	 * If the allocated address space is passed to a hypercall
> +	 * before being used then we cannot rely on a page fault to
> +	 * trigger an update of the page tables.  So sync all the page
> +	 * tables here.
> +	 */
> +	vmalloc_sync_all();
> +
>  	return area;
>  }
>  EXPORT_SYMBOL_GPL(alloc_vm_area);
> -- 
> 1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
