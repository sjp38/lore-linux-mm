Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CD7416B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:03:20 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 4so182206yxp.26
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 04:03:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210204210.6FEF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090209222416.GA9758@cmpxchg.org>
	 <28c262360902100247x1d537dc2kfef3c4c0f769a259@mail.gmail.com>
	 <20090210204210.6FEF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 10 Feb 2009 21:03:19 +0900
Message-ID: <28c262360902100403m772576afp3c9212157dc9fcd@mail.gmail.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 8:43 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> ---
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 9a27c44..18406ee 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1699,6 +1699,7 @@ unsigned long try_to_free_pages(struct zonelist
>> *zonelist, int order,
>>                 .order = order,
>>                 .mem_cgroup = NULL,
>>                 .isolate_pages = isolate_pages_global,
>> +               .nr_reclaimed = 0,
>>         };
>>
>>         return do_try_to_free_pages(zonelist, &sc);
>> @@ -1719,6 +1720,7 @@ unsigned long
>> try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>>                 .order = 0,
>>                 .mem_cgroup = mem_cont,
>>                 .isolate_pages = mem_cgroup_isolate_pages,
>> +               .nr_reclaimed = 0;
>>         };
>>         struct zonelist *zonelist;
>
> I think this code is better.
>
> and, I think we also need to
>
>
> static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> {
>        /* Minimum pages needed in order to stay on node */
>        const unsigned long nr_pages = 1 << order;
>        struct task_struct *p = current;
>        struct reclaim_state reclaim_state;
>        int priority;
>        struct scan_control sc = {
>                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>                .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>                .swap_cluster_max = max_t(unsigned long, nr_pages,
>                                        SWAP_CLUSTER_MAX),
>                .gfp_mask = gfp_mask,
>                .swappiness = vm_swappiness,
>                .isolate_pages = isolate_pages_global,
> +               .nr_reclaimed = 0;
>        };
>
>
>
>
>

Hmm.. I missed that.  Thanks.
There is one in shrink_all_memory.


-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
