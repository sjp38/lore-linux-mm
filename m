Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 12B5F6B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 06:40:00 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id 20so19836937wmh.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 03:40:00 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id k185si15873493wmf.6.2016.03.29.03.39.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 03:39:59 -0700 (PDT)
Message-ID: <56FA5AF5.30006@huawei.com>
Date: Tue, 29 Mar 2016 18:37:41 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com> <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org> <56F61EC8.7080508@huawei.com> <56FA5062.2020103@suse.cz>
In-Reply-To: <56FA5062.2020103@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 2016/3/29 17:52, Vlastimil Babka wrote:

> On 03/26/2016 06:31 AM, Xishi Qiu wrote:
>> On 2016/3/26 3:22, Andrew Morton wrote:
>>
>>> On Fri, 25 Mar 2016 14:56:04 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
>>>
>>>> It is incorrect to use next_node to find a target node, it will
>>>> return MAX_NUMNODES or invalid node. This will lead to crash in
>>>> buddy system allocation.
>>>>
>>>> ...
>>>>
>>>> --- a/mm/page_isolation.c
>>>> +++ b/mm/page_isolation.c
>>>> @@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>>>>        * now as a simple work-around, we use the next node for destination.
>>>>        */
>>>>       if (PageHuge(page)) {
>>>> -        nodemask_t src = nodemask_of_node(page_to_nid(page));
>>>> -        nodemask_t dst;
>>>> -        nodes_complement(dst, src);
>>>> +        int node = next_online_node(page_to_nid(page));
>>>> +        if (node == MAX_NUMNODES)
>>>> +            node = first_online_node;
>>>>           return alloc_huge_page_node(page_hstate(compound_head(page)),
>>>> -                        next_node(page_to_nid(page), dst));
>>>> +                        node);
>>>>       }
>>>>
>>>>       if (PageHighMem(page))
>>>
>>> Indeed.  Can you tell us more about this circumstances under which the
>>> kernel will crash?  I need to decide which kernel version(s) need the
>>> patch, but the changelog doesn't contain the info needed to make this
>>> decision (it should).
>>>
>>
>> Hi Andrew,
>>
>> I read the code v4.4, and find the following path maybe trigger the bug.
>>
>> alloc_migrate_target()
>>     alloc_huge_page_node()  // the node may be offline or MAX_NUMNODES
>>         __alloc_buddy_huge_page_no_mpol()
>>             __alloc_buddy_huge_page()
>>                 __hugetlb_alloc_buddy_huge_page()
> 
> The code in this functions seems to come from 099730d67417d ("mm, hugetlb: use memory policy when available") by Dave Hansen (adding to CC), which was indeed merged in 4.4-rc1.
> 
> However, alloc_pages_node() is only called in the block guarded by:
> 
> if (!IS_ENABLED(CONFIG_NUMA) || !vma) {
> 
> The rather weird "!IS_ENABLED(CONFIG_NUMA)" part comes from immediate followup commit e0ec90ee7e6f ("mm, hugetlbfs: optimize when NUMA=n")
> 
> So I doubt the code path here can actually happen. But it's fragile and confusing nevertheless.
> 

Hi Vlastimil

__alloc_buddy_huge_page(h, NULL, addr, nid); // so the vma is NULL

Thanks,
Xishi Qiu

>>                     alloc_pages_node()
>>                         __alloc_pages_node()
>>                             VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>>                             VM_WARN_ON(!node_online(nid));
>>
>> Thanks,
>> Xishi Qiu
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
