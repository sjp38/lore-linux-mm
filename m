Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id A04ED6B0268
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 19:10:24 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t67so135481386ywg.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:10:24 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id h189si29904454qkc.13.2016.09.21.16.10.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 16:10:23 -0700 (PDT)
Subject: Re: [PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
References: <57E20B54.5020408@zoho.com>
 <alpine.DEB.2.10.1609211408140.20971@chino.kir.corp.google.com>
 <034db3ec-e2dc-a6da-6dab-f0803900e19d@zoho.com>
 <alpine.DEB.2.10.1609211544510.41473@chino.kir.corp.google.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <c5435f6f-d945-fae1-c17e-04530be08421@zoho.com>
Date: Thu, 22 Sep 2016 07:10:07 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1609211544510.41473@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/22 6:45, David Rientjes wrote:
> On Thu, 22 Sep 2016, zijun_hu wrote:
> 
>>>> correct a few logic error for __insert_vmap_area() since the else
>>>> if condition is always true and meaningless
>>>>
>>>> in order to fix this issue, if vmap_area inserted is lower than one
>>>> on rbtree then walk around left branch; if higher then right branch
>>>> otherwise intersects with the other then BUG_ON() is triggered
>>>>
>>>
>>> Under normal operation, you're right that the "else if" conditional should 
>>> always succeed: we don't want to BUG() unless there's a bug.  The original 
>>> code can catch instances when va->va_start == tmp_va->va_end where we 
>>> should BUG().  Your code silently ignores it.
>>>
>> Hmm, the BUG_ON() appears in the original code, i don't introduce it.
>> it maybe be better to consider va->va_start == tmp_va->va_end as normal case
>> and should not BUG_ON() it since the available range of vmap_erea include
>> the start boundary but the end, BTW, represented as [start, end)
>>
> 
> We don't support inserting when va->va_start == tmp_va->va_end, plain and 
> simple.  There's no reason to do so.  NACK to the patch.
> 
i am sorry i disagree with you because
1) in almost all context of vmalloc, original logic treat the special case as normal
   for example, __find_vmap_area() or alloc_vmap_area()
2) don't use the limited vmap area effectively, it maybe causes BUG_ON() easy
3) consider below case
   it provided there have been two vmap_areas [4, 12) and [20, 28), what will happens
   when alloc_vmap_area(8, 4, 6, 24,...)?  should we use [12,20) for our request?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
