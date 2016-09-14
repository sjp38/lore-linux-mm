Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6CD6B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 05:35:28 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 186so38883284itf.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 02:35:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id x78si7457470oia.164.2016.09.14.02.35.15
        for <linux-mm@kvack.org>;
        Wed, 14 Sep 2016 02:35:16 -0700 (PDT)
Message-ID: <57D91771.9050108@huawei.com>
Date: Wed, 14 Sep 2016 17:25:05 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz> <57D7FB71.9090102@huawei.com> <20160913132854.GB6592@dhcp22.suse.cz> <57D8F8AE.1090404@huawei.com> <20160914084219.GA1612@dhcp22.suse.cz> <20160914085227.GB1612@dhcp22.suse.cz>
In-Reply-To: <20160914085227.GB1612@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Hugh Dickins <hughd@google.com>

On 2016/9/14 16:52, Michal Hocko wrote:
> On Wed 14-09-16 10:42:19, Michal Hocko wrote:
>> [Let's CC Hugh]
> now for real...
>
>> On Wed 14-09-16 15:13:50, zhong jiang wrote:
>> [...]
>>>   hi, Michal
>>>
>>>   Recently, I hit the same issue when run a OOM case of the LTP and ksm enable.
>>>  
>>> [  601.937145] Call trace:
>>> [  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
>>> [  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
>>> [  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
>>> [  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
>>> [  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
>>> [  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
>>> [  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
>>> [  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
>>> [  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
>>> [  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
>>> [  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
>>> [  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
>> So this is a hung task triggering because the exiting task cannot get
>> the mmap sem for write because the ksmd holds it for read while
>> allocating memory which just takes ages to complete, right?
>>
>>> The root case is that ksmd hold the read lock. and the lock is not released.
>>>  scan_get_next_rmap_item
>>>          down_read
>>>                    get_next_rmap_item
>>>                              alloc_rmap_item     #ksmd will loop permanently.
>>>
>>> How do you see this kind of situation ? or  let the issue alone.
>> I am not familiar with the ksmd code so it is hard for me to judge but
>> one thing to do would be __GFP_NORETRY which would force a bail out from
>> the allocation rather than looping for ever. A quick look tells me that
>> the allocation failure here is quite easy to handle. There might be
>> others...
>>
>> -- 
>> Michal Hocko
>> SUSE Labs
Adding the __GFP_NORETRY,  the issue also can fixed.
Therefore, we can assure that the case of LTP will leads to the endless looping.

index d45a0a1..03fb67b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -283,7 +283,7 @@ static inline struct rmap_item *alloc_rmap_item(void)
 {
        struct rmap_item *rmap_item;

-       rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
+       rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL | __GFP_NORETRY);
        if (rmap_item)
                ksm_rmap_items++;
        return rmap_item;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
