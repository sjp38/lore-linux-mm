Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25F706B0253
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 20:43:54 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so1188969wjy.6
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 17:43:54 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id s26si424174wma.12.2017.02.02.17.43.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 17:43:53 -0800 (PST)
Subject: Re: [PATCH v5 1/4] mm/migration: make isolate_movable_page() return
 int type
References: <1485867981-16037-1-git-send-email-ysxie@foxmail.com>
 <1485867981-16037-2-git-send-email-ysxie@foxmail.com>
 <20170201064821.GA10342@bbox> <20170201075924.GB5977@dhcp22.suse.cz>
 <20170201094636.GC10342@bbox> <20170201100022.GI5977@dhcp22.suse.cz>
 <20170202072826.GC11694@bbox>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <55ba8d7e-df15-5a27-cf53-84d3f5ed2a59@huawei.com>
Date: Fri, 3 Feb 2017 09:42:36 +0800
MIME-Version: 1.0
In-Reply-To: <20170202072826.GC11694@bbox>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: ysxie@foxmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com

Hi Minchan
Thanks for reviewing.
On 2017/2/2 15:28, Minchan Kim wrote:
> On Wed, Feb 01, 2017 at 11:00:23AM +0100, Michal Hocko wrote:
>> On Wed 01-02-17 18:46:36, Minchan Kim wrote:
>>> On Wed, Feb 01, 2017 at 08:59:24AM +0100, Michal Hocko wrote:
>>>> On Wed 01-02-17 15:48:21, Minchan Kim wrote:
>>>>> Hi Yisheng,
>>>>>
>>>>> On Tue, Jan 31, 2017 at 09:06:18PM +0800, ysxie@foxmail.com wrote:
>>>>>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>>>>>
>>>>>> This patch changes the return type of isolate_movable_page()
>>>>>> from bool to int. It will return 0 when isolate movable page
>>>>>> successfully, return -EINVAL when the page is not a non-lru movable
>>>>>> page, and for other cases it will return -EBUSY.
>>>>>>
>>>>>> There is no functional change within this patch but prepare
>>>>>> for later patch.
>>>>>>
>>>>>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>>>>>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>>>>>
>>>>> Sorry for missing this one you guys were discussing.
>>>>> I don't understand the patch's goal although I read later patches.
>>>>
>>>> The point is that the failed isolation has to propagate error up the
>>>> call chain to the userspace which has initiated the migration.
>>>>
>>>>> isolate_movable_pages returns success/fail so that's why I selected
>>>>> bool rather than int but it seems you guys want to propagate more
>>>>> detailed error to the user so added -EBUSY and -EINVAL.
>>>>>
>>>>> But the question is why isolate_lru_pages doesn't have -EINVAL?
>>>>
>>>> It doesn't have to same as isolate_movable_pages. We should just return
>>>> EBUSY when the page is no longer movable.
>>>
>>> Why isolate_lru_page is okay to return -EBUSY in case of race while
>>> isolate_movable_page should return -EINVAL?
>>> What's the logic in your mind? I totally cannot understand.
>>
>> Let me rephrase. Both should return EBUSY.
> 
> It means it's binary return value(success: 0 fail : -EBUSY) so IMO,
> bool is better and caller should return -EBUSY if that functions
> returns *false*. No need to make deeper propagation level.
> Anyway, it's trivial so I'm not against it if you want to make
> isolate_movable_page returns int. Insetad, please remove -EINVAL
> in this patch and just return -EBUSY for isolate_movable_page to
> be consistent with isolate_lru_page.
> Then, we don't need to fix any driver side, either. Even, no need to
> update any document because you don't add any new error value.
> 
Ok, I will remove the -EINVAL.

Thanks.
Yisheng Xie.

> That's enough.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
