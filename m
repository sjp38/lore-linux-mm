Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9099D82907
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 12:38:33 -0500 (EST)
Received: by pabkq14 with SMTP id kq14so1297580pab.3
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 09:38:33 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id xv5si9500603pbb.23.2015.02.19.09.38.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Feb 2015 09:38:32 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NK100L6R56QT610@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Feb 2015 17:42:26 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54E61F91.9080506@partner.samsung.com>
Date: Thu, 19 Feb 2015 20:38:25 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: Re: [PATCH v5 2/3] mm: cma: allocation trigger
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
 <1423780008-16727-3-git-send-email-sasha.levin@oracle.com>
In-reply-to: <1423780008-16727-3-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org

Hi,

On 13/02/15 01:26, Sasha Levin wrote:
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
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 3a25413..5bd6863 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
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

If CONFIG_DMA_CMA (and therefore CONFIG_CMA_ALIGNMENT) isn't configured
then building fails.
> mm/cma_debug.c: In function a??cma_alloc_mema??:
> mm/cma_debug.c:223:28: error: a??CONFIG_CMA_ALIGNMENTa?? undeclared (first use in this function)
>   p = cma_alloc(cma, count, CONFIG_CMA_ALIGNMENT);
>                             ^

Also, could you please fix the whitespace errors in your patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
