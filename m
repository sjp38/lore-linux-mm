Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C55E16B000A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:35:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b9so871287pgu.13
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:35:45 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00125.outbound.protection.outlook.com. [40.107.0.125])
        by mx.google.com with ESMTPS id d8si1978450pfb.349.2018.03.20.15.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 15:35:44 -0700 (PDT)
Subject: =?UTF-8?B?UmU6IOetlOWkjTog562U5aSNOiBbUEFUQ0hdIG1tL21lbWNvbnRyb2wu?=
 =?UTF-8?Q?c:_speed_up_to_force_empty_a_memory_cgroup?=
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com>
 <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com>
 <20180320083950.GD23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803201327060.167205@chino.kir.corp.google.com>
 <56508bd0-e8d7-55fd-5109-c8dacf26b13e@virtuozzo.com>
 <alpine.DEB.2.20.1803201514340.14003@chino.kir.corp.google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e265c518-968b-8669-ad22-671c781ad96e@virtuozzo.com>
Date: Wed, 21 Mar 2018 01:35:05 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803201514340.14003@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 03/21/2018 01:15 AM, David Rientjes wrote:
> On Wed, 21 Mar 2018, Andrey Ryabinin wrote:
> 
>>>>> It would probably be best to limit the 
>>>>> nr_pages to the amount that needs to be reclaimed, though, rather than 
>>>>> over reclaiming.
>>>>
>>>> How do you achieve that? The charging path is not synchornized with the
>>>> shrinking one at all.
>>>>
>>>
>>> The point is to get a better guess at how many pages, up to 
>>> SWAP_CLUSTER_MAX, that need to be reclaimed instead of 1.
>>>
>>>>> If you wanted to be invasive, you could change page_counter_limit() to 
>>>>> return the count - limit, fix up the callers that look for -EBUSY, and 
>>>>> then use max(val, SWAP_CLUSTER_MAX) as your nr_pages.
>>>>
>>>> I am not sure I understand
>>>>
>>>
>>> Have page_counter_limit() return the number of pages over limit, i.e. 
>>> count - limit, since it compares the two anyway.  Fix up existing callers 
>>> and then clamp that value to SWAP_CLUSTER_MAX in 
>>> mem_cgroup_resize_limit().  It's a more accurate guess than either 1 or 
>>> 1024.
>>>
>>
>> JFYI, it's never 1, it's always SWAP_CLUSTER_MAX.
>> See try_to_free_mem_cgroup_pages():
>> ....	
>> 	struct scan_control sc = {
>> 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>>
> 
> Is SWAP_CLUSTER_MAX the best answer if I'm lowering the limit by 1GB?
> 

Absolutely not. I completely on your side here. 
I've tried to fix this recently - http://lkml.kernel.org/r/20180119132544.19569-2-aryabinin@virtuozzo.com
I guess that Andrew decided to not take my patch, because Michal wasn't
happy about it (see mail archives if you want more details).
