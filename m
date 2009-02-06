Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 338AF6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:15:23 -0500 (EST)
Received: by rn-out-0910.google.com with SMTP id 56so659936rnw.4
        for <linux-mm@kvack.org>; Fri, 06 Feb 2009 09:15:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com>
References: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206044907.GA18467@cmpxchg.org>
	 <20090206135302.628E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206122417.GB1580@cmpxchg.org>
	 <28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com>
Date: Sat, 7 Feb 2009 02:15:21 +0900
Message-ID: <28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>> Grr, you are right.
>>> I agree, currently may_swap doesn't control swap out or not.
>>> so I think we should change it correct name ;)
>>
>> Agreed.  What do you think about the following patch?
>
> As for me, I can't agree with you.
> There are two kinds of file-mapped pages.
>
> 1. file-mapped and dirty page.
> 2. file-mapped and no-dirty page
>
> Both pages are not swapped.
> File-mapped and dirty page is synced with original file
> File-mapped and no-dirty page is just discarded with viewpoint of reclaim.
>
> So, may_swap is just related to anon-pages
> Thus, I think may_swap is reasonable.
> How about you ?

Sorry for misunderstood your point.
It would be better to remain more detaily for git log ?

'may_swap' applies not only to anon pages but to mapped file pages as
well. 'may_swap' term is sometime used for 'swap', sometime used for
'sync|discard'.
In case of anon pages, 'may_swap' determines whether pages were swapout or not.
but In case of mapped file pages, it determines whether pages are
synced or discarded. so, 'may_swap' is rather awkward. Rename it to
'may_unmap' which is the actual meaning.

If you find wrong word and sentence, Please, fix it. :)

>
>>
>> ---
>> Subject: vmscan: rename may_swap scan control knob
>>
>> may_swap applies not only to anon pages but to mapped file pages as
>> well.  Rename it to may_unmap which is the actual meaning.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> ---
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 9a27c44..2523600 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -60,8 +60,8 @@ struct scan_control {
>>
>>        int may_writepage;
>>
>> -       /* Can pages be swapped as part of reclaim? */
>> -       int may_swap;
>> +       /* Reclaim mapped pages */
>> +       int may_unmap;
>>
>>        /* This context's SWAP_CLUSTER_MAX. If freeing memory for
>>         * suspend, we effectively ignore SWAP_CLUSTER_MAX.
>> @@ -606,7 +606,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>                if (unlikely(!page_evictable(page, NULL)))
>>                        goto cull_mlocked;
>>
>> -               if (!sc->may_swap && page_mapped(page))
>> +               if (!sc->may_unmap && page_mapped(page))
>>                        goto keep_locked;
>>
>>                /* Double the slab pressure for mapped and swapcache pages */
>> @@ -1694,7 +1694,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>>                .gfp_mask = gfp_mask,
>>                .may_writepage = !laptop_mode,
>>                .swap_cluster_max = SWAP_CLUSTER_MAX,
>> -               .may_swap = 1,
>> +               .may_unmap = 1,
>>                .swappiness = vm_swappiness,
>>                .order = order,
>>                .mem_cgroup = NULL,
>> @@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>>  {
>>        struct scan_control sc = {
>>                .may_writepage = !laptop_mode,
>> -               .may_swap = 1,
>> +               .may_unmap = 1,
>>                .swap_cluster_max = SWAP_CLUSTER_MAX,
>>                .swappiness = swappiness,
>>                .order = 0,
>> @@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>>        struct zonelist *zonelist;
>>
>>        if (noswap)
>> -               sc.may_swap = 0;
>> +               sc.may_unmap = 0;
>>
>>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>>                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>> @@ -1762,7 +1762,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>>        struct reclaim_state *reclaim_state = current->reclaim_state;
>>        struct scan_control sc = {
>>                .gfp_mask = GFP_KERNEL,
>> -               .may_swap = 1,
>> +               .may_unmap = 1,
>>                .swap_cluster_max = SWAP_CLUSTER_MAX,
>>                .swappiness = vm_swappiness,
>>                .order = order,
>> @@ -2109,7 +2109,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>>        struct reclaim_state reclaim_state;
>>        struct scan_control sc = {
>>                .gfp_mask = GFP_KERNEL,
>> -               .may_swap = 0,
>> +               .may_unmap = 0,
>>                .swap_cluster_max = nr_pages,
>>                .may_writepage = 1,
>>                .swappiness = vm_swappiness,
>> @@ -2147,7 +2147,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>>
>>                /* Force reclaiming mapped pages in the passes #3 and #4 */
>>                if (pass > 2) {
>> -                       sc.may_swap = 1;
>> +                       sc.may_unmap = 1;
>>                        sc.swappiness = 100;
>>                }
>>
>> @@ -2292,7 +2292,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>>        int priority;
>>        struct scan_control sc = {
>>                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>> -               .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>> +               .may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>>                .swap_cluster_max = max_t(unsigned long, nr_pages,
>>                                        SWAP_CLUSTER_MAX),
>>                .gfp_mask = gfp_mask,
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>
>
> --
> Kinds regards,
> MinChan Kim
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
