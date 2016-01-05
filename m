Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 973166B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:22:46 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id f206so17237332wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:22:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si4297380wmf.111.2016.01.05.02.22.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 02:22:45 -0800 (PST)
Subject: Re: [PATCH 4/4] thp: increase split_huge_page() success rate
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151228153026.628d44126a848e14bcbbce68@linux-foundation.org>
 <20151229205709.GB6260@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568B9974.8030704@suse.cz>
Date: Tue, 5 Jan 2016 11:22:44 +0100
MIME-Version: 1.0
In-Reply-To: <20151229205709.GB6260@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On 12/29/2015 09:57 PM, Kirill A. Shutemov wrote:
> On Mon, Dec 28, 2015 at 03:30:26PM -0800, Andrew Morton wrote:
>> Fair enough.
>>
>> mlocked pages are rare and lru_add_drain() isn't free.  We could easily
>> and cheaply make page_remove_rmap() return "bool was_mlocked" (or,
>> better, "bool might_be_in_lru_cache") to skip this overhead.
>
> Propagating it back is painful. What about this instead:

Looks good.

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ecb4ed1a821a..edfa53eda9ca 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3385,6 +3385,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>   	struct page *head = compound_head(page);
>   	struct anon_vma *anon_vma;
>   	int count, mapcount, ret;
> +	bool mlocked;
>
>   	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
>   	VM_BUG_ON_PAGE(!PageAnon(page), page);
> @@ -3415,11 +3416,13 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>   		goto out_unlock;
>   	}
>
> +	mlocked = PageMlocked(page);
>   	freeze_page(anon_vma, head);
>   	VM_BUG_ON_PAGE(compound_mapcount(head), head);
>
>   	/* Make sure the page is not on per-CPU pagevec as it takes pin */
> -	lru_add_drain();
> +	if (mlocked)
> +		lru_add_drain();
>
>   	/* Prevent deferred_split_scan() touching ->_count */
>   	spin_lock(&split_queue_lock);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
