Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 051086B0003
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:08:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h9so4238052pfn.22
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:08:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z23si5111763pgc.484.2018.04.20.06.08.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 06:08:54 -0700 (PDT)
Date: Fri, 20 Apr 2018 15:08:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180420130852.GC16083@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Thu 19-04-18 12:12:38, Mikulas Patocka wrote:
[...]
> From: Mikulas Patocka <mpatocka@redhat.com>
> Subject: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
> 
> The kvmalloc function tries to use kmalloc and falls back to vmalloc if
> kmalloc fails.
> 
> Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> code.
> 
> These bugs are hard to reproduce because vmalloc falls back to kmalloc
> only if memory is fragmented.
> 
> In order to detect these bugs reliably I submit this patch that changes
> kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.

No way. This is just wrong! First of all, you will explode most likely
on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
enabled quite often.

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Nacked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/util.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6/mm/util.c
> ===================================================================
> --- linux-2.6.orig/mm/util.c	2018-04-18 15:46:23.000000000 +0200
> +++ linux-2.6/mm/util.c	2018-04-18 16:00:43.000000000 +0200
> @@ -395,6 +395,7 @@ EXPORT_SYMBOL(vm_mmap);
>   */
>  void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  {
> +#ifndef CONFIG_DEBUG_VM
>  	gfp_t kmalloc_flags = flags;
>  	void *ret;
>  
> @@ -426,6 +427,7 @@ void *kvmalloc_node(size_t size, gfp_t f
>  	 */
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
> +#endif
>  
>  	return __vmalloc_node_flags_caller(size, node, flags,
>  			__builtin_return_address(0));

-- 
Michal Hocko
SUSE Labs
