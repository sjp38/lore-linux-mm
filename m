Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 690276B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:55:28 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so5806586ede.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:55:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q23-v6si1739302eda.97.2018.11.05.08.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:55:26 -0800 (PST)
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <80074d2a-2f8d-a9db-892b-105c0ad7cd47@suse.cz>
 <d033db53-129d-c031-db78-ba7f9fed5bf4@yandex-team.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <af5a1d05-7ee2-b339-1c50-73ae9d66d955@suse.cz>
Date: Mon, 5 Nov 2018 17:52:21 +0100
MIME-Version: 1.0
In-Reply-To: <d033db53-129d-c031-db78-ba7f9fed5bf4@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org

On 11/5/18 5:19 PM, Konstantin Khlebnikov wrote:
> 
> 
> On 05.11.2018 16:03, Vlastimil Babka wrote:
>> On 11/1/18 11:09 AM, Konstantin Khlebnikov wrote:
>>> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
>>>
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> Makes sense regardless of warnings stuff.
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>
>> But it must be moved below the GFP_KERNEL check!
> 
> But kmalloc cannot handle it regardless of GFP.

Sure, but that's less problematic than skipping to vmalloc() for
!GFP_KERNEL. Especially for large sizes where it's likely that page
tables might get allocated (with GFP_KERNEL).

> Ok maybe write something like this
> 
> if (size > KMALLOC_MAX_SIZE) {
> 	if (WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL)
> 		return NULL;
> 	goto do_vmalloc;
> }

Probably should check also for __GFP_NOWARN.

> or fix that uncertainty right in vmalloc
> 
> For now comment in vmalloc declares
> 
>   *	Any use of gfp flags outside of GFP_KERNEL should be consulted
>   *	with mm people.

Dunno, what does Michal think?

> =)
> 
>>
>>> ---
>>>   mm/util.c |    4 ++++
>>>   1 file changed, 4 insertions(+)
>>>
>>> diff --git a/mm/util.c b/mm/util.c
>>> index 8bf08b5b5760..f5f04fa22814 100644
>>> --- a/mm/util.c
>>> +++ b/mm/util.c
>>> @@ -392,6 +392,9 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>>>   	gfp_t kmalloc_flags = flags;
>>>   	void *ret;
>>>   
>>> +	if (size > KMALLOC_MAX_SIZE)
>>> +		goto fallback;
>>> +
>>>   	/*
>>>   	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>>>   	 * so the given set of flags has to be compatible.
>>> @@ -422,6 +425,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>>>   	if (ret || size <= PAGE_SIZE)
>>>   		return ret;
>>>   
>>> +fallback:
>>>   	return __vmalloc_node_flags_caller(size, node, flags,
>>>   			__builtin_return_address(0));
>>>   }
>>>
>>
