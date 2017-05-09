Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14FDA6B03E7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 04:42:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p62so17600668wrc.13
        for <linux-mm@kvack.org>; Tue, 09 May 2017 01:42:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f142si240801wmf.45.2017.05.09.01.42.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 01:42:34 -0700 (PDT)
Subject: Re: [PATCH] mm: fix the memory leak after collapsing the huge page
 fails
References: <1494317557-49680-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7d5fd103-f997-e445-2ce6-2e44deed33d8@suse.cz>
Date: Tue, 9 May 2017 10:42:32 +0200
MIME-Version: 1.0
In-Reply-To: <1494317557-49680-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On 05/09/2017 10:12 AM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> Current, when we prepare a huge page to collapse, due to some
> reasons, it can fail to collapse. At the moment, we should
> release the preallocate huge page.

Yeah, looks like the leak is there...

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/khugepaged.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 7cb9c88..3f5749e 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1080,6 +1080,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	result = SCAN_SUCCEED;
>  out_up_write:
>  	up_write(&mm->mmap_sem);
> +	put_page(new_page);

This doesn't seem correct.
- the put_page() will be called also on success, so a premature free?
- the out_nolock: case should be also handled
- collapse_shmem() seems to have the same problem

>  out_nolock:
>  	trace_mm_collapse_huge_page(mm, isolated, result);
>  	return;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
