Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D07326B0269
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:19:32 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id y5-v6so2809590ljj.19
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:19:32 -0800 (PST)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id q12-v6si28822877ljg.5.2018.11.05.08.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:19:30 -0800 (PST)
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <80074d2a-2f8d-a9db-892b-105c0ad7cd47@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <d033db53-129d-c031-db78-ba7f9fed5bf4@yandex-team.ru>
Date: Mon, 5 Nov 2018 19:19:28 +0300
MIME-Version: 1.0
In-Reply-To: <80074d2a-2f8d-a9db-892b-105c0ad7cd47@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org



On 05.11.2018 16:03, Vlastimil Babka wrote:
> On 11/1/18 11:09 AM, Konstantin Khlebnikov wrote:
>> Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Makes sense regardless of warnings stuff.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> But it must be moved below the GFP_KERNEL check!

But kmalloc cannot handle it regardless of GFP.

Ok maybe write something like this

if (size > KMALLOC_MAX_SIZE) {
	if (WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL)
		return NULL;
	goto do_vmalloc;
}

or fix that uncertainty right in vmalloc

For now comment in vmalloc declares

  *	Any use of gfp flags outside of GFP_KERNEL should be consulted
  *	with mm people.

=)

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
