Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id D3ED86B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 01:47:35 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so6768348pbb.40
        for <linux-mm@kvack.org>; Sun, 09 Mar 2014 22:47:35 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id vo7si15621384pab.103.2014.03.09.22.47.33
        for <linux-mm@kvack.org>;
        Sun, 09 Mar 2014 22:47:34 -0700 (PDT)
Date: Mon, 10 Mar 2014 14:47:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH][RFC] mm: warning message for vm_map_ram about vm size
Message-ID: <20140310054743.GH14370@bbox>
References: <001a01cf3c1d$310716a0$931543e0$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <001a01cf3c1d$310716a0$931543e0$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Zhang Yanfei' <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>

Hi Giho,

On Mon, Mar 10, 2014 at 01:57:07PM +0900, Gioh Kim wrote:
> Hi,
> 
> I have a failure of allocation of virtual memory on ARMv7 based platform.
> 
> I called alloc_page()/vm_map_ram() for allocation/mapping pages.
> Virtual memory space exhausting problem occurred.
> I checked virtual memory space and found that there are too many 4MB chunks.
> 
> I thought that if just one page in the 4MB chunk lives long, 
> the entire chunk cannot be freed. Therefore new chunk is created again and again.
> 
> In my opinion, the vm_map_ram() function should be used for temporary mapping
> and/or short term memory mapping. Otherwise virtual memory is wasted.
> 
> I am not sure if my opinion is correct. If it is, please add some warning message
> about the vm_map_ram().
> 
> 
> 
> ---8<---
> 
> Subject: [PATCH] mm: warning comment for vm_map_ram
> 
> vm_map_ram can occur locking of virtual memory space
> because if only one page lives long in one vmap_block,
> it takes 4MB (1024-times more than one page) space.

For clarification, vm_map_ram has fragment problem because it
couldn't purge a chunk(ie, 4M address space) if there is a pinning
object in that addresss space so it could consume all VMALLOC
address space easily.

We can fix the fragementaion problem with using vmap instead of
vm_map_ram but it wouldn't a good solution because vmap is much
slower than vm_map_ram for VMAP_MAX_ALLOC below. In my x86 machine,
vm_map_ram is 5 times faster than vmap.

AFAICR, some proprietary GPU driver uses that function heavily so
performance would be really important so I want to stick to use
vm_map_ram.

Another option is that caller should separate long-life and short-life
object and use vmap for long-life but vm_map_ram for short-life.
But it's not a good solution because it's hard for allocator layer
to detect it that how customer lives with the object.

So I thought to fix that problem with revert [1] and adding more
logic to solve fragmentation problem and make bitmap search
operation more efficient by caching the hole. It might handle
fragmentation at the moment but it would make more IPI storm for
TLB flushing as time goes by so that it would mitigate API itself
so using for only temporal object is too limited but it's best at the
moment. I am supporting your opinion.

Let's add some notice message to user.

[1] [3fcd76e8028, mm/vmalloc.c: remove dead code in vb_alloc]

> 
> Change-Id: I6f5919848cf03788b5846b7d850d66e4d93ac39a
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> ---
>  mm/vmalloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0fdf968..2de1d1b 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1083,6 +1083,10 @@ EXPORT_SYMBOL(vm_unmap_ram);
>   * @node: prefer to allocate data structures on this node
>   * @prot: memory protection to use. PAGE_KERNEL for regular RAM
>   *
> + * This function should be used for TEMPORARY mapping. If just one page lives i
> + * long, it would occupy 4MB vm size permamently. 100 pages (just 400KB) could
> + * takes 400MB with bad luck.
> + *

    If you use this function for below VMAP_MAX_ALLOC pages, it could be faster
    than vmap so it's good but if you mix long-life and short-life object
    with vm_map_ram, it could consume lots of address space by fragmentation(
    expecially, 32bit machine) so you could see failure in the end.
    So, please use this function for short-life object.

>   * Returns: a pointer to the address that has been mapped, or %NULL on failure
>   */
>  void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
> --
> 1.7.9.5
> 
> Gioh Kim / e1? e,? i??
> Research Engineer
> Advanced OS Technology Team
> Software Platform R&D Lab.
> Mobile: 82-10-7322-5548  
> E-mail: gioh.kim@lge.com 
> 19, Yangjae-daero 11gil
> Seocho-gu, Seoul 137-130, Korea
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
