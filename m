Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 366816B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 20:52:16 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so10920388pdb.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 17:52:15 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id yb4si2195290pbb.25.2015.08.04.17.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Aug 2015 17:52:15 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSL00A3D3R0AL90@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 05 Aug 2015 09:52:12 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <55C15E37.80504@samsung.com>
Date: Wed, 05 Aug 2015 09:52:07 +0900
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: Re: [PATCH v2] vmscan: fix increasing nr_isolated incurred by putback
 unevictable pages
References: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
 <20150804150937.ee3b62257e77911a2f41a48e@linux-foundation.org>
 <20150804233108.GA662@bgram>
In-reply-to: <20150804233108.GA662@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2015e?? 08i?? 05i? 1/4  08:31, Minchan Kim wrote:
> Hello,
> 
> On Tue, Aug 04, 2015 at 03:09:37PM -0700, Andrew Morton wrote:
>> On Tue, 04 Aug 2015 19:40:08 +0900 Jaewon Kim <jaewon31.kim@samsung.com> wrote:
>>
>>> reclaim_clean_pages_from_list() assumes that shrink_page_list() returns
>>> number of pages removed from the candidate list. But shrink_page_list()
>>> puts back mlocked pages without passing it to caller and without
>>> counting as nr_reclaimed. This incurrs increasing nr_isolated.
>>> To fix this, this patch changes shrink_page_list() to pass unevictable
>>> pages back to caller. Caller will take care those pages.
>>>
>>> ..
>>>
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1157,7 +1157,7 @@ cull_mlocked:
>>>  		if (PageSwapCache(page))
>>>  			try_to_free_swap(page);
>>>  		unlock_page(page);
>>> -		putback_lru_page(page);
>>> +		list_add(&page->lru, &ret_pages);
>>>  		continue;
>>>  
>>>  activate_locked:
>>
>> Is this going to cause a whole bunch of mlocked pages to be migrated
>> whereas in current kernels they stay where they are?
>>
> 
> It fixes two issues.
> 
> 1. With unevictable page, cma_alloc will be successful.
> 
> Exactly speaking, cma_alloc of current kernel will fail due to unevictable pages.
> 
> 2. fix leaking of NR_ISOLATED counter of vmstat
> 
> With it, too_many_isolated works. Otherwise, it could make hang until
> the process get SIGKILL.
> 
> So, I think it's stable material.
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> 
> 
Hello

Traditional shrink_inactive_list will put back the unevictable pages as it does through putback_inactive_pages.
However as Minchan Kim said, cma_alloc will be more successful by migrating unevictable pages.
In current kernel, I think, cma_alloc is already trying to migrate unevictable pages except clean page cache.
This patch will allow clean page cache also to be migrated in cma_alloc.

Thank you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
