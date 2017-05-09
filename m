Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6A92803C7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 07:34:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u96so18972324wrc.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 04:34:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x65si18471888wrb.290.2017.05.09.04.34.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 04:34:12 -0700 (PDT)
Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge page
 fails
References: <1494327305-835-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <442638e9-d6db-2f1c-e260-9290d7524f1d@suse.cz>
Date: Tue, 9 May 2017 13:34:10 +0200
MIME-Version: 1.0
In-Reply-To: <1494327305-835-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org

On 05/09/2017 12:55 PM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> Current, when we prepare a huge page to collapse, due to some
> reasons, it can fail to collapse. At the moment, we should
> release the preallocate huge page.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Hmm, scratch that, there's no memory leak. The pointer to new_page is
stored in *hpage, and put_page() is called all the way up in
khugepaged_do_scan().

> ---
>  mm/khugepaged.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 7cb9c88..586b1f1 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1082,6 +1082,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	up_write(&mm->mmap_sem);
>  out_nolock:
>  	trace_mm_collapse_huge_page(mm, isolated, result);
> +	if (page != NULL && result != SCAN_SUCCEED)
> +		put_page(new_page);
>  	return;
>  out:
>  	mem_cgroup_cancel_charge(new_page, memcg, true);
> @@ -1555,6 +1557,8 @@ static void collapse_shmem(struct mm_struct *mm,
>  	}
>  out:
>  	VM_BUG_ON(!list_empty(&pagelist));
> +	if (page != NULL && result != SCAN_SUCCEED)
> +		put_page(new_page);
>  	/* TODO: tracepoints */
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
