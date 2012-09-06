Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 9CA736B00A0
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 21:10:48 -0400 (EDT)
Received: by iagk10 with SMTP id k10so1806959iag.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 18:10:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209051756270.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-2-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209051756270.7625@chino.kir.corp.google.com>
Date: Wed, 5 Sep 2012 22:10:47 -0300
Message-ID: <CALF0-+UB6Wm0XLHk-+vQYdFsQqa9HM0n+ps5ST+ZZpL+NXRHiQ@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm, slob: Add support for kmalloc_track_caller()
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi David,

On Wed, Sep 5, 2012 at 9:57 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
>
>> @@ -454,15 +455,35 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>>                       gfp |= __GFP_COMP;
>>               ret = slob_new_pages(gfp, order, node);
>>
>> -             trace_kmalloc_node(_RET_IP_, ret,
>> +             trace_kmalloc_node(caller, ret,
>>                                  size, PAGE_SIZE << order, gfp, node);
>>       }
>>
>>       kmemleak_alloc(ret, size, 1, gfp);
>>       return ret;
>>  }
>> +
>> +void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>> +{
>> +     return __do_kmalloc_node(size, gfp, node, _RET_IP_);
>> +}
>>  EXPORT_SYMBOL(__kmalloc_node);
>>
>> +#ifdef CONFIG_TRACING
>> +void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
>> +{
>> +     return __do_kmalloc_node(size, gfp, -1, caller);
>
> NUMA_NO_NODE.
>

Mmm, you bring an interesting issue. If you look at mm/slob.c and
include/linux/slob_def.h
there are lots of places with -1 instead of NUMA_NO_NODE.

Do you think it's worth to prepare a patch fixing all of those?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
