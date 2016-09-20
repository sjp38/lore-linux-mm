Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73C046B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 17:06:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so59914224pfv.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 14:06:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bf3si9000944pad.100.2016.09.20.14.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 14:06:40 -0700 (PDT)
Date: Tue, 20 Sep 2016 14:06:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,ksm: add __GFP_HIGH to the allocation in
 alloc_stable_node()
Message-Id: <20160920140639.2f1ea83784d994699e713c2e@linux-foundation.org>
In-Reply-To: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com>
References: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: hughd@google.com, mhocko@suse.cz, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org

On Tue, 20 Sep 2016 14:54:44 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

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

It is very hard for a reader to understand why this __GFP_HIGH is being
used here, so we should have a code comment explaining the reasoning,
please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
