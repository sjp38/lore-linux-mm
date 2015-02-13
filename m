Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 54A026B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 21:48:14 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ey11so15622298pad.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 18:48:14 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ce2si1078020pdb.21.2015.02.12.18.48.12
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 18:48:13 -0800 (PST)
Date: Fri, 13 Feb 2015 11:50:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 2/3] mm: cma: allocation trigger
Message-ID: <20150213025029.GE6592@js1304-P5Q-DELUXE>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
 <1423780008-16727-3-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423780008-16727-3-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com

On Thu, Feb 12, 2015 at 05:26:47PM -0500, Sasha Levin wrote:
> Provides a userspace interface to trigger a CMA allocation.
> 
> Usage:
> 
> 	echo [pages] > alloc
> 
> This would provide testing/fuzzing access to the CMA allocation paths.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/cma.c       |    6 ++++++
>  mm/cma.h       |    4 ++++
>  mm/cma_debug.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 64 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index e093b53..9e3d44a 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -121,6 +121,12 @@ static int __init cma_activate_area(struct cma *cma)
>  	} while (--i);
>  
>  	mutex_init(&cma->lock);
> +
> +#ifdef CONFIG_CMA_DEBUGFS
> +	INIT_HLIST_HEAD(&cma->mem_head);
> +	spin_lock_init(&cma->mem_head_lock);
> +#endif
> +
>  	return 0;
>  
>  err:
> diff --git a/mm/cma.h b/mm/cma.h
> index 4141887..1132d73 100644
> --- a/mm/cma.h
> +++ b/mm/cma.h
> @@ -7,6 +7,10 @@ struct cma {
>  	unsigned long   *bitmap;
>  	unsigned int order_per_bit; /* Order of pages represented by one bit */
>  	struct mutex    lock;
> +#ifdef CONFIG_CMA_DEBUGFS
> +	struct hlist_head mem_head;
> +	spinlock_t mem_head_lock;
> +#endif
>  };
>  
>  extern struct cma cma_areas[MAX_CMA_AREAS];
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 3a25413..5bd6863 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -7,9 +7,18 @@
>  
>  #include <linux/debugfs.h>
>  #include <linux/cma.h>
> +#include <linux/list.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
>  
>  #include "cma.h"
>  
> +struct cma_mem {
> +	struct hlist_node node;
> +	struct page *p;
> +	unsigned long n;
> +};
> +
>  static struct dentry *cma_debugfs_root;
>  
>  static int cma_debugfs_get(void *data, u64 *val)
> @@ -23,8 +32,48 @@ static int cma_debugfs_get(void *data, u64 *val)
>  
>  DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
>  
> -static void cma_debugfs_add_one(struct cma *cma, int idx)
> +static void cma_add_to_cma_mem_list(struct cma *cma, struct cma_mem *mem)
> +{
> +	spin_lock(&cma->mem_head_lock);
> +	hlist_add_head(&mem->node, &cma->mem_head);
> +	spin_unlock(&cma->mem_head_lock);
> +}
> +
> +static int cma_alloc_mem(struct cma *cma, int count)
> +{
> +	struct cma_mem *mem;
> +	struct page *p;
> +
> +	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> +	if (!mem) 
> +		return -ENOMEM;
> +
> +	p = cma_alloc(cma, count, CONFIG_CMA_ALIGNMENT);

Alignment is resurrected. Please change it to 0.

Other than that,
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
