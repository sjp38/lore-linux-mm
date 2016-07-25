Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 837196B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 13:56:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f6so342192312ith.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:56:11 -0700 (PDT)
Received: from dfwrgout.huawei.com (dfwrgout.huawei.com. [206.16.17.72])
        by mx.google.com with ESMTPS id y6si11945730otd.129.2016.07.25.10.56.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 10:56:10 -0700 (PDT)
Message-ID: <5795D3BC.5010004@huawei.com>
Date: Mon, 25 Jul 2016 16:54:20 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mem-hotplug: alloc new page from the next node if
 zone is MOVABLE_ZONE
References: <57918BAC.8000008@huawei.com> <cd3707d7-fb97-ab90-24d6-6bee3113f515@suse.cz> <5795C2CA.7030707@huawei.com> <1aa8186c-5672-013f-9e04-d950ed651a0b@suse.cz>
In-Reply-To: <1aa8186c-5672-013f-9e04-d950ed651a0b@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/25 15:52, Vlastimil Babka wrote:

> On 07/25/2016 09:42 AM, Xishi Qiu wrote:
>> On 2016/7/25 14:59, Vlastimil Babka wrote:
>>
>>> On 07/22/2016 04:57 AM, Xishi Qiu wrote:
>>>> Memory offline could happen on both movable zone and non-movable zone.
>>>> We can offline the whole node if the zone is movable zone, and if the
>>>> zone is non-movable zone, we cannot offline the whole node, because
>>>> some kernel memory can't be migrated.
>>>>
>>>> So if we offline a node with movable zone, use prefer mempolicy to alloc
>>>> new page from the next node instead of the current node or other remote
>>>> nodes, because re-migrate is a waste of time and the distance of the
>>>> remote nodes is often very large.
>>>>
>>>> Also use GFP_HIGHUSER_MOVABLE to alloc new page if the zone is movable
>>>> zone.
>>>>
>>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>>
>>> I think this could be simpler, if you preferred the next node regardless of whether it's movable zone or not. What are use cases for trying to offline part of non-MOVABLE zone in a node? It's not guaranteed to succeed anyway. Also if the reasoning is that the non-MOVABLE offlining preference for migration target should be instead on the *same* node, then alloc_migrate_target() would anyway prefer the node of the current CPU that happens to execute the offlining, which is random wrt the node in question. So consistently choosing remote node is IMHO better than random even for non-MOVABLE zone.
>>>
>>
>> Hi Vlastimil,
>>
>> use next node for movable zone, use current node for non-movable zone, right?
> 
> I was asking why not just next node for any zone, to make things simpler. What's the use case for offlining in non-movable zone?
> 

OK, both use the next node is much simpler.

>>
>>>> ---
>>>>  mm/memory_hotplug.c | 35 +++++++++++++++++++++++++++++------
>>>>  1 file changed, 29 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>> index e3cbdca..930a5c6 100644
>>>> --- a/mm/memory_hotplug.c
>>>> +++ b/mm/memory_hotplug.c
>>>> @@ -1501,6 +1501,16 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>>>>      return 0;
>>>>  }
>>>>
>>>> +static struct page *new_node_page(struct page *page, unsigned long node,
>>>> +        int **result)
>>>> +{
>>>> +    if (PageHuge(page))
>>>> +        return alloc_huge_page_node(page_hstate(compound_head(page)),
>>>> +                    node);
>>>> +    else
>>>> +        return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
>>>
>>> You could just test for page in movable (or highmem?) zone here in the callback.
>>>
>>
>> is_highmem_idx() always return 0 if CONFIG_HIGHMEM closed.
> 
> Yeah, but then it doesn't matter if __GFP_HIGHMEM is given.
> 
>> And GFP_HIGHUSER_MOVABLE will choose movable_zone first, then normal_zone.
>> So how about this check? if (PageHighMem() or zone == ZONE_MOVABLE) then use GFP_HIGHUSER_MOVABLE
> 
> zone == ZONE_MOVABLE -> GFP_HIGHUSER_MOVABLE
> PageHighMem() -> GFP_HIGHUSER

How about use GFP_HIGHUSER_MOVABLE in the above two cases? As Joonsoo said:

"all migratable pages are not from user space. For example,
blockdev file cache has __GFP_MOVABLE and migratable but it has no
__GFP_HIGHMEM and __GFP_USER.
And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE."

And you said this before "GFP_USER just specifies some reclaim flags"

> else GFP_USER ?

else use GFP_USER | __GFP_MOVABLE ?

Thanks,
Xishi Qiu

> 
>>>> +}
>>>> +
>>>>  #define NR_OFFLINE_AT_ONCE_PAGES    (256)
>>>>  static int
>>>>  do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>>>> @@ -1510,6 +1520,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>>>>      int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
>>>>      int not_managed = 0;
>>>>      int ret = 0;
>>>> +    int nid = NUMA_NO_NODE;
>>>>      LIST_HEAD(source);
>>>>
>>>>      for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
>>>> @@ -1564,12 +1575,24 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>>>>              goto out;
>>>>          }
>>>>
>>>> -        /*
>>>> -         * alloc_migrate_target should be improooooved!!
>>>> -         * migrate_pages returns # of failed pages.
>>>> -         */
>>>> -        ret = migrate_pages(&source, alloc_migrate_target, NULL, 0,
>>>> -                    MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>>>> +        for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>>>> +            if (!pfn_valid(pfn))
>>>> +                continue;
>>>> +            page = pfn_to_page(pfn);
>>>> +            if (zone_idx(page_zone(page)) == ZONE_MOVABLE)
>>>> +                nid = next_node_in(page_to_nid(page),
>>>> +                        node_online_map);
>>>> +            break;
>>>> +        }
>>>
>>> Then you could remove the ZONE_MOVABLE check here. I'm not sure how much worth the precalculation of nid is, if it has to be a rather complicated code like this, hm.
>>>
>>> Also, since we know that "next node in node_online_map" is in fact not optimal, what about using the opportunity to really try the best possible way? Maybe it's as simple as allocating via __alloc_pages_nodemask() with current node's zonelist (where remote nodes should be already sorted according to NUMA distance), but with current node (which would be first in the zonelist) removed from the nodemask so that it's skipped over? But check if memory offlining process didn't kill the zonelist already at this point, or something.
>>>
>>
>> Do you mean that call __alloc_pages_nodemask(), the zonelist is from current page's node,
>> but it(the current page's node) is not include in the nodemask?
> 
> Exactly.
> The question is if there should be a fallback to current page's node if that fails. Only make sense if somebody wants to offline only part of the node?
> 
>>
>> Thanks,
>> Xishi Qiu
>>
>>>> +
>>>> +        /* Alloc new page from the next node if possible */
>>>> +        if (nid != NUMA_NO_NODE)
>>>> +            ret = migrate_pages(&source, new_node_page, NULL,
>>>> +                    nid, MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>>>> +        else
>>>> +            ret = migrate_pages(&source, alloc_migrate_target, NULL,
>>>> +                    0, MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>>>
>>> Please just use one new callback fully tailored for memory offline, instead of choosing between the two like this.
>>>
>>>>          if (ret)
>>>>              putback_movable_pages(&source);
>>>>      }
>>>>
>>>
>>>
>>> .
>>>
>>
>>
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
