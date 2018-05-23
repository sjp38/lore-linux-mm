Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4C36B0266
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:51:49 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 5-v6so1793996qke.19
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:51:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w140-v6si9245311qka.381.2018.05.23.07.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 07:51:47 -0700 (PDT)
Subject: Re: [RFC] Checking for error code in __offline_pages
References: <20180523073547.GA29266@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <73c5f634-21d1-8dee-d259-8ea196857d9f@redhat.com>
Date: Wed, 23 May 2018 16:51:45 +0200
MIME-Version: 1.0
In-Reply-To: <20180523073547.GA29266@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On 23.05.2018 09:35, Oscar Salvador wrote:
> Hi,
> 
> This is something I spotted while testing offlining memory.
> 
> __offline_pages() calls do_migrate_range() to try to migrate a range,
> but we do not actually check for the error code.
> This, besides of ignoring underlying failures, can led to a situations
> where we never break up the loop because we are totally unaware of
> what is going on.
> 
> They way I spotted this was when trying to offline all memblocks belonging
> to a node.
> Due to an unfortunate setting with movablecore, memblocks containing bootmem
> memory (pages marked by get_page_bootmem()) ended up marked in zone_movable.
> So while trying to remove that memory, the system failed in:
> 
> do_migrate_range()
> {
> ...
> 	if (PageLRU(page))
> 		ret = isolate_lru_page(page);
> 	else
> 		ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
> 
> 	if (!ret)
> 		// success: do something
> 	else
> 		if (page_count(page))
> 			ret = -EBUSY;
> ...
> }
> 
> Since the pages from bootmem are not LRU, we call isolate_movable_page()
> but we fail when checking for __PageMovable().
> Since the page_count is more than 0 we return -EBUSY, but we do not check this
> in our caller, so we keep trying to migrate this memory over and over:
> 
> repeat:
> ...
>         pfn = scan_movable_pages(start_pfn, end_pfn);
>         if (pfn) { /* We have movable pages */
>                 ret = do_migrate_range(pfn, end_pfn);
>                 goto repeat;
>         }
> 
> But this is not only situation where we can get stuck.
> For example, if we fail with -ENOMEM in
> migrate_pages()->unmap_and_move()/unmap_and_move_huge_page(), we will keep trying as well.
> I think we should really detect these cases and fail with "goto failed_removal".
> Something like
> 
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1651,6 +1651,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
>         pfn = scan_movable_pages(start_pfn, end_pfn);
>         if (pfn) { /* We have movable pages */
>                 ret = do_migrate_range(pfn, end_pfn);
> +               if (ret) {
> +                       if (ret != -ENOMEM)
> +                               ret = -EBUSY;
> +                       goto failed_removal;
> +               }
>                 goto repeat;
>         }
> 
> Now, unless I overlooked something
> migrate_pages()->unmap_and_move()/unmap_and_move_huge_page() can return:
> -ENOMEM
> -EAGAIN
> -EBUSY
> -ENOSYS.
> 
> I am not sure if we should differentiate betweeen those errors.
> For example, it is possible that in migrate_pages() we just get -EAGAIN,
> and we return the number of "retry" we tried without having really failed.
> Although, since we do 10 passes it might be considered as failed.
> 
> And I am not sure either if we want to propagate the error codes, or in case we fail
> in migrate_pages(), whatever the error was (-ENOMEM, -EBUSY, etc.), we
> just return -EBUSY.
> 
> What do you think?

Hi,

While working on onlining/offlining of 4MB subsections I also stumbled
over the return value of offline_pages(). It would be nice if the
interface could actually indicate if an error is permanent or only
temporary.

For now I have to live with the assumption, that whenever this function
is not -EAGAIN or 0, that I simply have to retry later.

David

> 
> Thanks
> Oscar Salvador
> 


-- 

Thanks,

David / dhildenb
