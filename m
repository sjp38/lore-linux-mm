Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB066B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 12:42:51 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id r21-v6so2759826lfi.22
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 09:42:51 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [2a02:6b8:0:1465::fd])
        by mx.google.com with ESMTPS id v1-v6si3001176ljb.198.2018.11.01.09.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 09:42:49 -0700 (PDT)
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <20181101102405.GE23921@dhcp22.suse.cz>
 <cd2a55be-17f1-5da9-1154-8e291fe958cd@yandex-team.ru>
 <20181101125543.GH23921@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <ae51e16b-459c-7d59-6277-b1a197dbf5ff@yandex-team.ru>
Date: Thu, 1 Nov 2018 19:42:48 +0300
MIME-Version: 1.0
In-Reply-To: <20181101125543.GH23921@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 01.11.2018 15:55, Michal Hocko wrote:
> On Thu 01-11-18 13:48:17, Konstantin Khlebnikov wrote:
>>
>>
>> On 01.11.2018 13:24, Michal Hocko wrote:
>>> On Thu 01-11-18 13:09:16, Konstantin Khlebnikov wrote:
>>>> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
>>>
>>> I would go on and say that allocations with sizes too large can actually
>>> trigger a warning (once you have posted in the previous version outside
>>> of the changelog area) because that might be interesting to people -
>>> there are deployments to panic on warning and then a warning is much
>>> more important.
>>
>> It seems that warning isn't completely valid.
>>
>>
>> __alloc_pages_slowpath() handles this more gracefully:
>>
>> 	/*
>> 	 * In the slowpath, we sanity check order to avoid ever trying to
>> 	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
>> 	 * be using allocators in order of preference for an area that is
>> 	 * too large.
>> 	 */
>> 	if (order >= MAX_ORDER) {
>> 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>> 		return NULL;
>> 	}
>>
>>
>> Fast path is ready for order >= MAX_ORDER
>>
>>
>> Problem is in node_reclaim() which is called earlier than __alloc_pages_slowpath()
>> from surprising place - get_page_from_freelist()
>>
>>
>> Probably node_reclaim() simply needs something like this:
>>
>> 	if (order >= MAX_ORDER)
>> 		return NODE_RECLAIM_NOSCAN;
> 
> Maybe but the point is that triggering this warning is possible. Even if
> the warning is bogus it doesn't really make much sense to even try
> kmalloc if the size is not supported by the allocator.
> 

But __GFP_NOWARN allocation (like in this case) should just fail silently
without warnings regardless of reason because caller can deal with that.

Without __GFP_NOWARN allocator should print standard warning.

Caller anyway must handle NULL\ENOMEM result - this error path
should be used for handling impossible sizes too.
Of course it could check size first, just as optimization.
