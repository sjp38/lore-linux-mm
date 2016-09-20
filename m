Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCFB66B025E
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:35:37 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r126so68630710oib.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:35:37 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id c51si10624432ote.133.2016.09.20.13.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:35:33 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id w11so36563905oia.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:35:33 -0700 (PDT)
Date: Tue, 20 Sep 2016 13:35:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm,ksm: add __GFP_HIGH to the allocation in
 alloc_stable_node()
In-Reply-To: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com>
Message-ID: <alpine.LSU.2.11.1609201334480.3225@eggly.anvils>
References: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: hughd@google.com, akpm@linux-foundation.org, mhocko@suse.cz, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org

On Tue, 20 Sep 2016, zhongjiang wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> Accoding to HUgh's suggestion, alloc_stable_node() with GFP_KERNEL
> will cause the hungtask, despite less possiblity.
> 
> At present, if alloc_stable_node allocate fails, two break_cow may
> want to allocate a couple of pages, and the issue will come up when
> free memory is under pressure.
> 
> we fix it by adding the __GFP_HIGH to GFP. because it grant access to
> some of meory reserves. it will make progess to make it allocation
> successful at the utmost.
> 
> Suggested-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Thanks,
Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/ksm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 5048083..42bf16e 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -299,7 +299,7 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
>  
>  static inline struct stable_node *alloc_stable_node(void)
>  {
> -	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
> +	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL | __GFP_HIGH);
>  }
>  
>  static inline void free_stable_node(struct stable_node *stable_node)
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
