Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1C66B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:30:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y10-v6so6166109wrg.9
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:30:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si4066278edd.380.2018.04.19.11.30.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 11:30:31 -0700 (PDT)
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f0be0592-2839-c87e-0f44-bd10956f7704@suse.cz>
Date: Thu, 19 Apr 2018 20:28:30 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Laura Abbott <labbott@redhat.com>

On 04/19/2018 06:12 PM, Mikulas Patocka wrote:
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
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Hmm AFAIK Fedora uses CONFIG_DEBUG_VM in their kernels. Sure you want to
impose this on all users? Seems too much for DEBUG_VM to me. Maybe it
should be hidden under some error injection config?

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

Did you verify that vmalloc does the right thing for sub-page sizes?
Shouldn't those be exempted?

>  	return __vmalloc_node_flags_caller(size, node, flags,
>  			__builtin_return_address(0));
> 
