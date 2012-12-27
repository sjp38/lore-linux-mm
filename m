Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id CF2DE6B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 17:41:07 -0500 (EST)
Message-ID: <50DCCE5A.4000805@oracle.com>
Date: Thu, 27 Dec 2012 17:40:26 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm, bootmem: panic in bootmem alloc functions even
 if slab is available
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <1356293711-23864-2-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/27/2012 05:25 PM, David Rientjes wrote:
> On Sun, 23 Dec 2012, Sasha Levin wrote:
> 
>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>> index 1324cd7..198a92f 100644
>> --- a/mm/bootmem.c
>> +++ b/mm/bootmem.c
>> @@ -763,9 +763,6 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>>  void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>>  				   unsigned long align, unsigned long goal)
>>  {
>> -	if (WARN_ON_ONCE(slab_is_available()))
>> -		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
>> -
>>  	return  ___alloc_bootmem_node(pgdat, size, align, goal, 0);
>>  }
>>  
> 
> All you're doing is removing the fallback if this happens to be called 
> with slab_is_available().  It's still possible that the slab allocator can 
> successfully allocate the memory, though.  So it would be rather 
> unfortunate to start panicking in a situation that used to only emit a 
> warning.
> 
> Why can't you panic only kzalloc_node() returns NULL and otherwise just 
> return the allocated memory?

That's exactly what happens with the patch. Note that in the current upstream
version there are several slab checks scattered all over.

In this case for example, I'm removing it from __alloc_bootmem_node(), but the
first code line of__alloc_bootmem_node_nopanic() is:

        if (WARN_ON_ONCE(slab_is_available()))
                return kzalloc(size, GFP_NOWAIT);

So the current behaviour is still preserved, but the code is simplified to
have only one place that allocates memory (both from the slab and from bootmem),
instead of having slab allocations sprinkled all over.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
