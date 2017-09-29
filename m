Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C02CD6B025E
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 08:00:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n64so1265274wma.0
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 05:00:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z134si2838313wmd.154.2017.09.29.05.00.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Sep 2017 05:00:39 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
References: <20170927082038.3782-1-jthumshirn@suse.de>
 <20170927082038.3782-2-jthumshirn@suse.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a8a93630-8b7a-9e4e-0277-8db13d4563e8@suse.cz>
Date: Fri, 29 Sep 2017 14:00:37 +0200
MIME-Version: 1.0
In-Reply-To: <20170927082038.3782-2-jthumshirn@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>

On 09/27/2017 10:20 AM, Johannes Thumshirn wrote:
> We have kmalloc_array() and kcalloc() wrappers on top of kmalloc() which
> ensure us overflow free multiplication for the size of a memory
> allocation but these implementations are not NUMA-aware.
> 
> Likewise we have kmalloc_node() which is a NUMA-aware version of
> kmalloc() but the implementation is not aware of any possible overflows in
> eventual size calculations.
> 
> Introduce a combination of the two above cases to have a NUMA-node aware
> version of kmalloc_array() and kcalloc().
> 
> Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>

Sounds better than custom open-coded stuff indeed.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/slab.h | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 41473df6dfb0..aaf4723e41b3 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -635,6 +635,22 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
>  #define kmalloc_track_caller(size, flags) \
>  	__kmalloc_track_caller(size, flags, _RET_IP_)
>  
> +static inline void *kmalloc_array_node(size_t n, size_t size, gfp_t flags,
> +				       int node)
> +{
> +	if (size != 0 && n > SIZE_MAX / size)
> +		return NULL;
> +	if (__builtin_constant_p(n) && __builtin_constant_p(size))
> +		return kmalloc_node(n * size, flags, node);
> +	return __kmalloc_node(n * size, flags, node);
> +}
> +
> +static inline void *kcalloc_node(size_t n, size_t size, gfp_t flags, int node)
> +{
> +	return kmalloc_array_node(n, size, flags | __GFP_ZERO, node);
> +}
> +
> +
>  #ifdef CONFIG_NUMA
>  extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
>  #define kmalloc_node_track_caller(size, flags, node) \
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
