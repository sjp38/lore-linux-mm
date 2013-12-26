Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 59FBE6B0031
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 18:45:08 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so8655762qeb.27
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 15:45:07 -0800 (PST)
Received: from mail-gg0-x229.google.com (mail-gg0-x229.google.com [2607:f8b0:4002:c02::229])
        by mx.google.com with ESMTPS id r5si25504428qat.16.2013.12.26.15.45.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Dec 2013 15:45:07 -0800 (PST)
Received: by mail-gg0-f169.google.com with SMTP id f4so1827740ggn.28
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 15:45:06 -0800 (PST)
Date: Thu, 26 Dec 2013 15:45:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/memblock: use WARN_ONCE when MAX_NUMNODES passed as
 input parameter
In-Reply-To: <1387578536-18280-1-git-send-email-santosh.shilimkar@ti.com>
Message-ID: <alpine.DEB.2.02.1312261542260.9342@chino.kir.corp.google.com>
References: <1387578536-18280-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>

On Fri, 20 Dec 2013, Santosh Shilimkar wrote:

> diff --git a/mm/memblock.c b/mm/memblock.c
> index 71b11d9..6af873a 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -707,11 +707,9 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
>  	struct memblock_type *rsv = &memblock.reserved;
>  	int mi = *idx & 0xffffffff;
>  	int ri = *idx >> 32;
> -	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
>  
> -	if (nid == MAX_NUMNODES)
> -		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
> -			     __func__);
> +	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
> +		nid = NUMA_NO_NODE;
>  
>  	for ( ; mi < mem->cnt; mi++) {
>  		struct memblock_region *m = &mem->regions[mi];

Um, why do this at runtime?  This is only used for 
for_each_free_mem_range(), which is used rarely in x86 and memblock-only 
code.  I'm struggling to understand why we can't deterministically fix the 
callers if this condition is possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
