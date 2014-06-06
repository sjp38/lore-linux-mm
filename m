Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 765116B0069
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 10:21:49 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so2530978pbb.31
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 07:21:49 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id bz3si19765362pbd.157.2014.06.06.07.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 06 Jun 2014 07:21:48 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N6R002Z83VXKD00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Jun 2014 15:21:33 +0100 (BST)
Message-id: <5391CD5A.20503@samsung.com>
Date: Fri, 06 Jun 2014 18:16:58 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: rmap: fix use-after-free in __put_anon_vma
References: <1402054255-4930-1-git-send-email-a.ryabinin@samsung.com>
 <20140606115620.GS3213@twins.programming.kicks-ass.net>
In-reply-to: <20140606115620.GS3213@twins.programming.kicks-ass.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dvyukov@google.com, koct9i@gmail.com

On 06/06/14 15:56, Peter Zijlstra wrote:
> On Fri, Jun 06, 2014 at 03:30:55PM +0400, Andrey Ryabinin wrote:
>> While working address sanitizer for kernel I've discovered use-after-free
>> bug in __put_anon_vma.
>> For the last anon_vma, anon_vma->root freed before child anon_vma.
>> Later in anon_vma_free(anon_vma) we are referencing to already freed anon_vma->root
>> to check rwsem.
>> This patch puts freeing of child anon_vma before freeing of anon_vma->root.
> 
> Yes, I think that is right indeed.
> 
> Very hard to hit, but valid since not all callers hold rcu_read_lock().
> 
>>
>> Cc: stable@vger.kernel.org # v3.0+
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> ---
>>  mm/rmap.c | 7 ++++---
>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 9c3e773..161bffc7 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1564,10 +1564,11 @@ void __put_anon_vma(struct anon_vma *anon_vma)
>>  {
>>  	struct anon_vma *root = anon_vma->root;
>>  
>> -	if (root != anon_vma && atomic_dec_and_test(&root->refcount))
>> +	if (root != anon_vma && atomic_dec_and_test(&root->refcount)) {
>> +		anon_vma_free(anon_vma);
>>  		anon_vma_free(root);
>> -
>> -	anon_vma_free(anon_vma);
>> +	} else
>> +		anon_vma_free(anon_vma);
>>  }
> 
> Why not simply move the freeing of anon_vma before the root, like:
> 
> 	anon_vma_free(anon_vma);
> 	if (root != anon_vma && atomic_dec_and_test(&root->refcount))
> 		anon_vma_free(root);
> 
> ?
> 

IMO It looks more logical to decrement root's refcounter before freeing child vma.
In fact I wasn't completely sure that it is safe to do so. But after some digging,
now it looks safe to me.







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
