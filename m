Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAC7C6B026D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:48:20 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id y6so155555lfy.11
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:48:20 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [2a02:6b8:0:1465::fd])
        by mx.google.com with ESMTPS id 65-v6si5536158ljb.103.2018.11.01.03.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 03:48:19 -0700 (PDT)
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <20181101102405.GE23921@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <cd2a55be-17f1-5da9-1154-8e291fe958cd@yandex-team.ru>
Date: Thu, 1 Nov 2018 13:48:17 +0300
MIME-Version: 1.0
In-Reply-To: <20181101102405.GE23921@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org



On 01.11.2018 13:24, Michal Hocko wrote:
> On Thu 01-11-18 13:09:16, Konstantin Khlebnikov wrote:
>> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
> 
> I would go on and say that allocations with sizes too large can actually
> trigger a warning (once you have posted in the previous version outside
> of the changelog area) because that might be interesting to people -
> there are deployments to panic on warning and then a warning is much
> more important.

It seems that warning isn't completely valid.


__alloc_pages_slowpath() handles this more gracefully:

	/*
	 * In the slowpath, we sanity check order to avoid ever trying to
	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
	 * be using allocators in order of preference for an area that is
	 * too large.
	 */
	if (order >= MAX_ORDER) {
		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
		return NULL;
	}


Fast path is ready for order >= MAX_ORDER


Problem is in node_reclaim() which is called earlier than __alloc_pages_slowpath()
from surprising place - get_page_from_freelist()


Probably node_reclaim() simply needs something like this:

	if (order >= MAX_ORDER)
		return NODE_RECLAIM_NOSCAN;


> 
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> 
>> ---
>>   mm/util.c |    4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/util.c b/mm/util.c
>> index 8bf08b5b5760..f5f04fa22814 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -392,6 +392,9 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>>   	gfp_t kmalloc_flags = flags;
>>   	void *ret;
>>   
>> +	if (size > KMALLOC_MAX_SIZE)
>> +		goto fallback;
>> +
>>   	/*
>>   	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>>   	 * so the given set of flags has to be compatible.
>> @@ -422,6 +425,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>>   	if (ret || size <= PAGE_SIZE)
>>   		return ret;
>>   
>> +fallback:
>>   	return __vmalloc_node_flags_caller(size, node, flags,
>>   			__builtin_return_address(0));
>>   }
>>
> 
