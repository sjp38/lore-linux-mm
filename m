Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 573ED6B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 04:55:35 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u19-v6so12615885qkl.13
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 01:55:35 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10097.outbound.protection.outlook.com. [40.107.1.97])
        by mx.google.com with ESMTPS id o2-v6si45753qki.134.2018.08.06.01.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Aug 2018 01:55:34 -0700 (PDT)
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
 <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
 <20180805000305.GC3183@bombadil.infradead.org>
 <e5d67774-a006-e533-d928-64a4407cbb16@virtuozzo.com>
 <20180805125004.GD3183@bombadil.infradead.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0e7f6e2b-621c-dda0-ebd8-c9b4e7e7f04b@virtuozzo.com>
Date: Mon, 6 Aug 2018 11:55:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180805125004.GD3183@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05.08.2018 15:50, Matthew Wilcox wrote:
> On Sun, Aug 05, 2018 at 08:30:43AM +0300, Kirill Tkhai wrote:
>> On 05.08.2018 03:03, Matthew Wilcox wrote:
>>> On Sat, Aug 04, 2018 at 09:42:05PM +0300, Kirill Tkhai wrote:
>>>> This is exactly the thing the patch makes. Instead of inserting a shrinker pointer
>>>> to idr, it inserts a fake value SHRINKER_REGISTERING there. The patch makes impossible
>>>> to dereference a shrinker unless it's completely registered. 
>>>
>>> -       id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
>>> +       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
>>>
>>> Instead:
>>>
>>> +       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);
>>>
>>> ... and the rest of your patch becomes even simpler.
>>
>> The patch, we are discussing at the moment, does *exactly* this:
>>
>> https://lkml.org/lkml/2018/8/3/588
>>
>> It looks like you missed this hunk in the patch.
> 
> No, it does this:
> 
> +       id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
> 
> I'm saying do this:
> 
> +       id = idr_alloc(&shrinker_idr, NULL, 0, 0, GFP_KERNEL);

No, this won't work at all. The patch introduces special value SHRINKER_REGISTERING,
because shrink_slab_memcg() needs to differ the cases, when 1)shrinker is registering
and 2)shrinker is unregistered. In case of shrinker is registering we do not clear
the bit in shrink_slab_memcg(), while in the other case we must do that. This introduce
a generic solution for all type of shrinkers, and this allows to not impose restrictions
on specific shrinker registering code. A user of shrinker may add a first element to its
LRU list before register_shrinker_prepared() is called, and the corresponding bit won't
be cleared. This gives flexibility for users, it's just the same flexibility they have now.

Before the patch, list_empty() was used like such the indicator, and this is the difference
the patch makes.
