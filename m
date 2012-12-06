Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E44636B0068
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 21:52:02 -0500 (EST)
Message-ID: <50C0081A.308@huawei.com>
Date: Thu, 6 Dec 2012 10:51:06 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] page_alloc: Make movablecore_map has higher priority
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-5-git-send-email-tangchen@cn.fujitsu.com> <50BF6BA0.8060505@gmail.com> <50BFF443.3090504@cn.fujitsu.com> <50C00259.50901@huawei.com>
In-Reply-To: <50C00259.50901@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Jiang Liu <liuj97@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Tang,

There is a bug in Gerry's patch, please apply this patch to fix it.

---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 41c3b51..d981810 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4383,7 +4383,7 @@ static int __init find_zone_movable_from_movablecore_map(void)
 			 */
 			start_pfn = max(start_pfn,
 					movablecore_map.map[map_pos].start);
-			zone_movable_pfn[nid] = roundup(zone_movable_pfn[nid],
+			zone_movable_pfn[nid] = roundup(start_pfn,
 							MAX_ORDER_NR_PAGES);
 			break;
 		}
-- 
1.7.6.1

On 2012/12/6 10:26, Jiang Liu wrote:

> On 2012-12-6 9:26, Tang Chen wrote:
>> On 12/05/2012 11:43 PM, Jiang Liu wrote:
>>> If we make "movablecore_map" take precedence over "movablecore/kernelcore",
>>> the logic could be simplified. I think it's not so attractive to support
>>> both "movablecore_map" and "movablecore/kernelcore" at the same time.
>>
>> Hi Liu,
>>
>> Thanks for you advice. :)
>>
>> Memory hotplug needs different support on different hardware. We are
>> trying to figure out a way to satisfy as many users as we can.
>> Since it is a little difficult, it may take sometime. :)
>>
>> But I still think we need a boot option to support it. Just a metter of
>> how to make it easier to use. :)
>>
>> Thanks. :)
>>
>>>
>>> On 11/23/2012 06:44 PM, Tang Chen wrote:
>>>> If kernelcore or movablecore is specified at the same time
>>>> with movablecore_map, movablecore_map will have higher
>>>> priority to be satisfied.
>>>> This patch will make find_zone_movable_pfns_for_nodes()
>>>> calculate zone_movable_pfn[] with the limit from
>>>> zone_movable_limit[].
>>>>
>>>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>>>> Reviewed-by: Wen Congyang<wency@cn.fujitsu.com>
>>>> Reviewed-by: Lai Jiangshan<laijs@cn.fujitsu.com>
>>>> Tested-by: Lin Feng<linfeng@cn.fujitsu.com>
>>>> ---
>>>>   mm/page_alloc.c |   35 +++++++++++++++++++++++++++++++----
>>>>   1 files changed, 31 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index f23d76a..05bafbb 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -4800,12 +4800,25 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>>>           required_kernelcore = max(required_kernelcore, corepages);
>>>>       }
>>>>
>>>> -    /* If kernelcore was not specified, there is no ZONE_MOVABLE */
>>>> -    if (!required_kernelcore)
>>>> +    /*
>>>> +     * No matter kernelcore/movablecore was limited or not, movable_zone
>>>> +     * should always be set to a usable zone index.
>>>> +     */
>>>> +    find_usable_zone_for_movable();
>>>> +
>>>> +    /*
>>>> +     * If neither kernelcore/movablecore nor movablecore_map is specified,
>>>> +     * there is no ZONE_MOVABLE. But if movablecore_map is specified, the
>>>> +     * start pfn of ZONE_MOVABLE has been stored in zone_movable_limit[].
>>>> +     */
>>>> +    if (!required_kernelcore) {
>>>> +        if (movablecore_map.nr_map)
>>>> +            memcpy(zone_movable_pfn, zone_movable_limit,
>>>> +                sizeof(zone_movable_pfn));
>>>>           goto out;
>>>> +    }
>>>>
>>>>       /* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
>>>> -    find_usable_zone_for_movable();
>>>>       usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
>>>>
>>>>   restart:
>>>> @@ -4833,10 +4846,24 @@ restart:
>>>>           for_each_mem_pfn_range(i, nid,&start_pfn,&end_pfn, NULL) {
>>>>               unsigned long size_pages;
>>>>
>>>> +            /*
>>>> +             * Find more memory for kernelcore in
>>>> +             * [zone_movable_pfn[nid], zone_movable_limit[nid]).
>>>> +             */
>>>>               start_pfn = max(start_pfn, zone_movable_pfn[nid]);
>>>>               if (start_pfn>= end_pfn)
>>>>                   continue;
>>>>
>>>> +            if (zone_movable_limit[nid]) {
>>>> +                end_pfn = min(end_pfn, zone_movable_limit[nid]);
>>>> +                /* No range left for kernelcore in this node */
>>>> +                if (start_pfn>= end_pfn) {
>>>> +                    zone_movable_pfn[nid] =
>>>> +                            zone_movable_limit[nid];
>>>> +                    break;
>>>> +                }
>>>> +            }
> Hi Tang,
> 	I just to remove the above logic, so the implementation will be greatly
> simplified. Please refer to the attachment.
> Regards!
> Gerry
> 
>>>> +
>>>>               /* Account for what is only usable for kernelcore */
>>>>               if (start_pfn<  usable_startpfn) {
>>>>                   unsigned long kernel_pages;
>>>> @@ -4896,12 +4923,12 @@ restart:
>>>>       if (usable_nodes&&  required_kernelcore>  usable_nodes)
>>>>           goto restart;
>>>>
>>>> +out:
>>>>       /* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
>>>>       for (nid = 0; nid<  MAX_NUMNODES; nid++)
>>>>           zone_movable_pfn[nid] =
>>>>               roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
>>>>
>>>> -out:
>>>>       /* restore the node_state */
>>>>       node_states[N_HIGH_MEMORY] = saved_node_state;
>>>>   }
>>>>
>>>
>>>
>>
>>
>> .
>>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
