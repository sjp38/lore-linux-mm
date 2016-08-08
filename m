Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80A676B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 13:15:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g67so161558784qkf.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 10:15:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v3si17949671qkh.77.2016.08.08.10.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 10:15:11 -0700 (PDT)
Subject: Re: [PATCH] mm: fix the incorrect hugepages count
References: <1470624546-902-1-git-send-email-zhongjiang@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d00a2c1d-5f02-056c-4eef-dd7514293418@oracle.com>
Date: Mon, 8 Aug 2016 10:14:48 -0700
MIME-Version: 1.0
In-Reply-To: <1470624546-902-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/07/2016 07:49 PM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when memory hotplug enable, free hugepages will be freed if movable node offline.
> therefore, /proc/sys/vm/nr_hugepages will be incorrect.
> 
> The patch fix it by reduce the max_huge_pages when the node offline.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f904246..3356e3a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1448,6 +1448,7 @@ static void dissolve_free_huge_page(struct page *page)
>  		list_del(&page->lru);
>  		h->free_huge_pages--;
>  		h->free_huge_pages_node[nid]--;
> +		h->max_huge_pages--;
>  		update_and_free_page(h, page);
>  	}
>  	spin_unlock(&hugetlb_lock);
> 

Adding Naoya as he was the original author of this code.

>From quick look it appears that the huge page will be migrated (allocated
on another node).  If my understanding is correct, then max_huge_pages
should not be adjusted here.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
