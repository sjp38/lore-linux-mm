Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4383E6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 05:04:56 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d77so11176002oig.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:04:56 -0700 (PDT)
Received: from sender-pp-092.zoho.com (sender-pp-092.zoho.com. [135.84.80.237])
        by mx.google.com with ESMTPS id o9si11834704oib.359.2017.07.17.02.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 02:04:55 -0700 (PDT)
Subject: Re: [PATCH v2] mm/vmalloc: terminate searching since one node found
References: <CAGWkznEyWgQe0HFiJ2MvfMB+Acbk_dTVTPH5VAA+Fep9uAFRZg@mail.gmail.com>
 <596C7924.1010207@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <596C7D99.5040208@zoho.com>
Date: Mon, 17 Jul 2017 17:04:25 +0800
MIME-Version: 1.0
In-Reply-To: <596C7924.1010207@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

On 07/17/2017 04:45 PM, zijun_hu wrote:
> On 07/17/2017 04:07 PM, Zhaoyang Huang wrote:
>> It is no need to find the very beginning of the area within
>> alloc_vmap_area, which can be done by judging each node during the process
>>
>> For current approach, the worst case is that the starting node which be found
>> for searching the 'vmap_area_list' is close to the 'vstart', while the final
>> available one is round to the tail(especially for the left branch).
>> This commit have the list searching start at the first available node, which
>> will save the time of walking the rb tree'(1)' and walking the list(2).
>>
>>       vmap_area_root
>>           /      \
>>      tmp_next     U
>>         /   (1)
>>       tmp
>>        /
>>      ...
>>       /
>>     first(current approach)
>>
>> vmap_area_list->...->first->...->tmp->tmp_next
> 
> the original code can ensure the following two points :
> A, the result vamp_area has the lowest available address in the range [vstart, vend)
> B, it can maintain the cached vamp_area node rightly which can speedup relative allocation
> i suspect this patch maybe destroy the above two points 
>>                             (2)
>>
>> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
>> ---
>>  mm/vmalloc.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 34a1c3e..f833e07 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -459,9 +459,16 @@ static struct vmap_area *alloc_vmap_area(unsigned
>> long size,
>>
>>                 while (n) {
>>                         struct vmap_area *tmp;
>> +                       struct vmap_area *tmp_next;
>>                         tmp = rb_entry(n, struct vmap_area, rb_node);
>> +                       tmp_next = list_next_entry(tmp, list);
>>                         if (tmp->va_end >= addr) {
>>                                 first = tmp;
>> +                               if (ALIGN(tmp->va_end, align) + size
>> +                                               < tmp_next->va_start) {
>> +                                       addr = ALIGN(tmp->va_end, align);
>> +                                       goto found;
>> +                               }
> is the aim vamp_area the lowest available one if the goto occurs ?
> it will bypass the latter cached vamp_area info  cached_hole_size update possibly if the goto occurs
  it think the aim area maybe don't locates the required range [vstart, vend) possibly.
>>                                 if (tmp->va_start <= addr)
>>                                         break;
>>                                 n = n->rb_left;
>> --
>> 1.9.1
>>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
