Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9416B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:21:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so16949574pfj.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 00:21:26 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r132si40373321pgr.231.2016.10.20.00.21.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 00:21:25 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/vmalloc.c: correct logic errors when insert
 vmap_area
References: <c2bd0f5d-8d2a-4cba-2663-5c075cd252f2@zoho.com>
 <20161012144610.GN17128@dhcp22.suse.cz> <57FF2C3C.5070507@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <58087049.8080106@zoho.com>
Date: Thu, 20 Oct 2016 15:20:41 +0800
MIME-Version: 1.0
In-Reply-To: <57FF2C3C.5070507@zoho.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, akpm@linux-foundation.org, rientjes@google.com, tj@kernel.org, sfr@canb.auug.org.au, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, Michal Hocko <mhocko@kernel.org>

On 10/13/2016 02:39 PM, zijun_hu wrote:

Hi Nicholas,
could you give some comments for this patch?

thanks a lot
> Hi Nicholas,
> 
> i find __insert_vmap_area() is introduced by you
> could you offer comments for this patch related to that funciton
> 
> thanks
> 
> On 10/12/2016 10:46 PM, Michal Hocko wrote:
>> [Let's CC Nick who has written this code]
>>
>> On Wed 12-10-16 22:30:13, zijun_hu wrote:
>>> From: zijun_hu <zijun_hu@htc.com>
>>>
>>> the KVA allocator organizes vmap_areas allocated by rbtree. in order to
>>> insert a new vmap_area @i_va into the rbtree, walk around the rbtree from
>>> root and compare the vmap_area @t_va met on the rbtree against @i_va; walk
>>> toward the left branch of @t_va if @i_va is lower than @t_va, and right
>>> branch if higher, otherwise handle this error case since @i_va has overlay
>>> with @t_va; however, __insert_vmap_area() don't follow the desired
>>> procedure rightly, moreover, it includes a meaningless else if condition
>>> and a redundant else branch as shown by comments in below code segments:
>>> static void __insert_vmap_area(struct vmap_area *va)
>>> {
>>> as a internal interface parameter, we assume vmap_area @va has nonzero size
>>> ...
>>> 			if (va->va_start < tmp->va_end)
>>> 					p = &(*p)->rb_left;
>>> 			else if (va->va_end > tmp->va_start)
>>> 					p = &(*p)->rb_right;
>>> this else if condition is always true and meaningless due to
>>> va->va_end > va->va_start >= tmp_va->va_end > tmp_va->va_start normally
>>> 			else
>>> 					BUG();
>>> this BUG() is meaningless too due to never be reached normally
>>> ...
>>> }
>>>
>>> it looks like the else if condition and else branch are canceled. no errors
>>> are caused since the vmap_area @va to insert as a internal interface
>>> parameter doesn't have overlay with any one on the rbtree normally. however
>>>  __insert_vmap_area() looks weird and really has several logic errors as
>>> pointed out above when it is viewed as a separate function.
>>
>> I have tried to read this several times but I am completely lost to
>> understand what the actual bug is and how it causes vmap_area sorting to
>> misbehave. So is this a correctness issue, performance improvement or
>> theoretical fix for an incorrect input?
>>
>>> fix by walking around vmap_area rbtree as described above to insert
>>> a vmap_area.
>>>
>>> BTW, (va->va_end == tmp_va->va_start) is consider as legal case since it
>>> indicates vmap_area @va left neighbors with @tmp_va tightly.
>>>
>>> Fixes: db64fe02258f ("mm: rewrite vmap layer")
>>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>>> ---
>>>  mm/vmalloc.c | 8 ++++----
>>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>> index 5daf3211b84f..8b80931654b7 100644
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -321,10 +321,10 @@ static void __insert_vmap_area(struct vmap_area *va)
>>>  
>>>  		parent = *p;
>>>  		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
>>> -		if (va->va_start < tmp_va->va_end)
>>> -			p = &(*p)->rb_left;
>>> -		else if (va->va_end > tmp_va->va_start)
>>> -			p = &(*p)->rb_right;
>>> +		if (va->va_end <= tmp_va->va_start)
>>> +			p = &parent->rb_left;
>>> +		else if (va->va_start >= tmp_va->va_end)
>>> +			p = &parent->rb_right;
>>>  		else
>>>  			BUG();
>>>  	}
>>> -- 
>>> 1.9.1
>>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
