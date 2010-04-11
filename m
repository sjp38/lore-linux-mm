Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AAB7F6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 02:40:58 -0400 (EDT)
Message-ID: <4BC16EF2.5060802@cs.helsinki.fi>
Date: Sun, 11 Apr 2010 09:40:50 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: __kmalloc_node_track_caller should trace kmalloc_large_node
 case
References: <1270718804-27268-1-git-send-email-dfeng@redhat.com> <alpine.DEB.2.00.1004081202570.21040@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1004081202570.21040@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Xiaotian Feng <dfeng@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Ingo Molnar <mingo@elte.hu>, Vegard Nossum <vegard.nossum@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Thu, 8 Apr 2010, Xiaotian Feng wrote:
> 
>> commit 94b528d (kmemtrace: SLUB hooks for caller-tracking functions)
>> missed tracing kmalloc_large_node in __kmalloc_node_track_caller. We
>> should trace it same as __kmalloc_node.
>>
>> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
>> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
>> Cc: Matt Mackall <mpm@selenic.com>
>> Cc: David Rientjes <rientjes@google.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
>> Cc: Ingo Molnar <mingo@elte.hu>
>> Cc: Vegard Nossum <vegard.nossum@gmail.com>
>> ---
>>  mm/slub.c |   11 +++++++++--
>>  1 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index b364844..a3a5a18 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3335,8 +3335,15 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
>>  	struct kmem_cache *s;
>>  	void *ret;
>>  
>> -	if (unlikely(size > SLUB_MAX_SIZE))
>> -		return kmalloc_large_node(size, gfpflags, node);
>> +	if (unlikely(size > SLUB_MAX_SIZE)) {
>> +		ret = kmalloc_large_node(size, gfpflags, node);
>> +
>> +		trace_kmalloc_node(caller, ret,
>> +				   size, PAGE_SIZE << get_order(size),
>> +				   gfpflags, node);
>> +
>> +		return ret;
>> +	}
>>  
>>  	s = get_slab(size, gfpflags);
>>  

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
