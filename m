Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 326BC6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:53:28 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7JIUL0r015991
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:30:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7JIrQZX2932878
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:53:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7JIrNi9017172
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:53:24 -0400
Date: Fri, 19 Aug 2011 11:53:22 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] avoid null pointer access in vm_struct
Message-ID: <20110819185322.GI2401@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110819105133.7504.62129.stgit@ltc219.sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110819105133.7504.62129.stgit@ltc219.sdl.hitachi.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yrl.pp-manager.tt@hitachi.com, Andrew Morton <akpm@linux-foundation.org>, Namhyung Kim <namhyung@gmail.com>, David Rientjes <rientjes@google.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

On Fri, Aug 19, 2011 at 07:51:33PM +0900, Mitsuo Hayasaka wrote:
> The /proc/vmallocinfo shows information about vmalloc allocations in vmlist
> that is a linklist of vm_struct. It, however, may access pages field of
> vm_struct where a page was not allocated, which results in a null pointer
> access and leads to a kernel panic.
> 
> Why this happen:
> In __vmalloc_area_node(), the nr_pages field of vm_struct are set to the
> expected number of pages to be allocated, before the actual pages
> allocations. At the same time, when the /proc/vmallocinfo is read, it
> accesses the pages field of vm_struct according to the nr_pages field at
> show_numa_info(). Thus, a null pointer access happens.
> 
> Patch:
> This patch sets nr_pages field of vm_struct AFTER the pages allocations
> finished in __vmalloc_area_node(). So, it can avoid accessing the pages
> field with unallocated page when show_numa_info() is called.

One question below...

> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Namhyung Kim <namhyung@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> ---
> 
>  mm/vmalloc.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 7ef0903..49d8aed 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1529,7 +1529,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));
> 
> -	area->nr_pages = nr_pages;
>  	/* Please note that the recursion is strictly bounded. */
>  	if (array_size > PAGE_SIZE) {
>  		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
> @@ -1538,15 +1537,15 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	} else {
>  		pages = kmalloc_node(array_size, nested_gfp, node);
>  	}
> -	area->pages = pages;
> -	area->caller = caller;
> -	if (!area->pages) {
> +	if (!pages) {
>  		remove_vm_area(area->addr);
>  		kfree(area);
>  		return NULL;
>  	}
> +	area->pages = pages;
> +	area->caller = caller;
> 
> -	for (i = 0; i < area->nr_pages; i++) {
> +	for (i = 0; i < nr_pages; i++) {
>  		struct page *page;
>  		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
> 
> @@ -1562,6 +1561,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  		}
>  		area->pages[i] = page;
>  	}

Don't we need something here to prevent the compiler and/or the CPU
from reordering the assignment?  Or am I missing how this is otherwise
prevented?

> +	area->nr_pages = nr_pages;
> 
>  	if (map_vm_area(area, prot, &pages))
>  		goto fail;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
