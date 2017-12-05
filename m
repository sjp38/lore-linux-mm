Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B00C6B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:51:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j26so77456pff.8
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:51:10 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j8si48095pli.353.2017.12.05.04.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:51:08 -0800 (PST)
Message-ID: <5A269613.5090405@huawei.com>
Date: Tue, 5 Dec 2017 20:50:27 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [patch 13/15] mm/page_owner: align with pageblock_nr pages
References: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org> <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz> <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz> <5A2536B0.5060804@huawei.com> <20171204120114.iezicg6pmyj2z6lq@dhcp22.suse.cz> <5A253E55.7040706@huawei.com> <20171204123546.lhhcbpulihz3upm6@dhcp22.suse.cz> <5A25460F.9050206@huawei.com> <687fc876-c610-2ceb-6b91-5e400816bb32@suse.cz>
In-Reply-To: <687fc876-c610-2ceb-6b91-5e400816bb32@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2017/12/5 19:22, Vlastimil Babka wrote:
> On 12/04/2017 01:56 PM, zhong jiang wrote:
>> On 2017/12/4 20:35, Michal Hocko wrote:
>>> On Mon 04-12-17 20:23:49, zhong jiang wrote:
>>>> On 2017/12/4 20:01, Michal Hocko wrote:
>>>>> On Mon 04-12-17 19:51:12, zhong jiang wrote:
>>>>>> On 2017/12/2 1:15, Michal Hocko wrote:
>>>>>>> On Fri 01-12-17 17:58:28, Vlastimil Babka wrote:
>>>>>>>> On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
>>>>>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>>>>> Subject: mm/page_owner: align with pageblock_nr pages
>>>>>>>>>
>>>>>>>>> When pfn_valid(pfn) returns false, pfn should be aligned with
>>>>>>>>> pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
>>>>>>>>> because the skipped 2M may be valid pfn, as a result, early allocated
>>>>>>>>> count will not be accurate.
>>>>>>>>>
>>>>>>>>> Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
>>>>>>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>>>>>>> Cc: Michal Hocko <mhocko@kernel.org>
>>>>>>>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>>>>>>> The author never responded and Michal Hocko basically NAKed it in
>>>>>>>> https://lkml.kernel.org/r/<20160812130727.GI3639@dhcp22.suse.cz>
>>>>>>>> I think we should drop it.
>>>>>>> Or extend the changelog to actually describe what kind of problem it
>>>>>>> fixes and do an additional step to unigy
>>>>>>> MAX_ORDER_NR_PAGES/pageblock_nr_pages
>>>>>>>  
>>>>>>   Hi, Michal
>>>>>>    
>>>>>>         IIRC,  I had explained the reason for patch.  if it not. I am so sorry for that.
>>>>>>     
>>>>>>         when we select MAX_ORDER_NR_PAGES,   the second 2M will be skiped.
>>>>>>        it maybe result in normal pages leak.
>>>>>>
>>>>>>         meanwhile.  as you had said.  it make the code consistent.  why do not we do it.
>>>>>>    
>>>>>>         I think it is reasonable to upstream the patch.  maybe I should rewrite the changelog
>>>>>>        and repost it.
>>>>>>
>>>>>>     Michal,  Do you think ?
>>>>> Yes, rewrite the patch changelog and make it _clear_ what it fixes and
>>>>> under _what_ conditions. There are also other places using
>>>>> MAX_ORDER_NR_PAGES rathern than pageblock_nr_pages. Do they need to be
>>>>> updated as well?
>>>>  in the lastest kernel.  according to correspond context,   I  can not find the candidate. :-)
>>> git grep says some in page_ext.c, memory_hotplug.c and few in the arch
>>> code. I belive we really want to describe and document the distinction
>>> between the two constants and explain when to use which one.
>>>
>>  yes,   limited by my knowledge and english.  Maybe Vlastimil  can  address it  in detail.  
> Hi, on a fresh look, I believe this patch doesn't improve anything in
> practice. It potentially makes init_pages_in_zone() catch more early
> allocations, if a hole happens to be placed in the beginning of
> MAX_ORDER block, and the following pageblock within the block was early
> allocated.
 Hi, Vlastimil

  I have a stupid question about holes

  because a hole is possible to have within a MAX_ORDER_NR_PAGES, it indeed
  exist in first pfn. it that is true, why we must skip the whole MAX_ORDER block?
  Any limit ?  I can not find the answer.

  Thanks
  zhongjiang
> However, read_page_owner() skips whole MAX_ORDER block as well in this
> situation, so we won't be able to read the info anyway...
>
> Also the problem is not as simple as documenting MAX_ORDER_NR_PAGES vs
> pabeblock_nr_pages. We discussed it year ago when this patch was first
> posted, how skipping over holes would have to be made more robust, and
> how architectures should define hole granularity to avoid checking each
> individual pfn in what appears to be a hole, to see if the hole has ended.
>
>> Thanks
>> zhongjiang
>>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
