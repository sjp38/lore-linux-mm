Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A48636B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:42:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so14872367wrf.0
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:42:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x73si1203345wme.29.2017.09.27.01.42.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:42:53 -0700 (PDT)
Date: Wed, 27 Sep 2017 10:42:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
Message-ID: <20170927084251.kxves5ce76jz5skr@dhcp22.suse.cz>
References: <20170927082038.3782-1-jthumshirn@suse.de>
 <20170927082038.3782-2-jthumshirn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927082038.3782-2-jthumshirn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>

On Wed 27-09-17 10:20:33, Johannes Thumshirn wrote:
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

Yes, this is helpful. I am just wondering why we cannot have
kmalloc_array to call kmalloc_array_node with the local node as a
parameter. Maybe some sort of an optimization?

> Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.13.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
