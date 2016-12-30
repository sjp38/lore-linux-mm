Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5B106B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 02:24:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u5so594638853pgi.7
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 23:24:03 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id w90si56089890pfk.54.2016.12.29.23.24.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 23:24:02 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from epcas1p1.samsung.com (unknown [182.195.41.45])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OIZ0128GLW1BDE0@mailout1.samsung.com> for linux-mm@kvack.org;
 Fri, 30 Dec 2016 16:24:01 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <58660BBE.1040807@samsung.com>
Date: Fri, 30 Dec 2016 16:24:46 +0900
In-reply-to: <xa1th95m7r6w.fsf@mina86.com>
References: 
 <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz> <xa1th95m7r6w.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello Michal Hocko and and Michal Nazarewichz

On 2016e?? 12i?? 29i? 1/4  23:20, Michal Nazarewicz wrote:
> On Thu, Dec 29 2016, Michal Hocko wrote:
>> On Thu 29-12-16 11:28:02, Jaewon Kim wrote:
>>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
>>> This patch prints the error value and bitmap status to know available pages
>>> regarding fragmentation.
>>>
>>> This is an ENOMEM example with this patch.
>>> [   11.616321]  [2:   Binder:711_1:  740] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12
>>> [   11.616365]  [2:   Binder:711_1:  740] number of available pages: 4+7+7+8+38+166+127=>357 pages, total: 2048 pages
>> Could you be more specific why this part is useful?
The first line is useful to know why the allocation failed.
Actually CMA internally try all available regions because some regions can be failed because of EBUSY.
The second showing bitmap status is useful to know in detail on both ENONEM and EBUSY;
 ENOMEM:  not tried at all because of no available region
 EBUSY:  tried some region but all failed
>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>>> ---
>>>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/cma.c b/mm/cma.c
>>> index c960459..535aa39 100644
>>> --- a/mm/cma.c
>>> +++ b/mm/cma.c
>>> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>>  	unsigned long start = 0;
>>>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>>  	struct page *page = NULL;
>>> -	int ret;
>>> +	int ret = -ENOMEM;
>>>  
>>>  	if (!cma || !cma->count)
>>>  		return NULL;
>>> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>>  	trace_cma_alloc(pfn, page, count, align);
>>>  
>>>  	pr_debug("%s(): returned %p\n", __func__, page);
>>> +
>>> +	if (ret != 0) {
>>> +		unsigned int nr, nr_total = 0;
>>> +		unsigned long next_set_bit;
>>> +
>>> +		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>>> +			__func__, count, ret);
>>> +		mutex_lock(&cma->lock);
>>> +		printk("number of available pages: ");
>>> +		start = 0;
>>> +		for (;;) {
>>> +			bitmap_no = find_next_zero_bit(cma->bitmap, cma->count, start);
>>> +			next_set_bit = find_next_bit(cma->bitmap, cma->count, bitmap_no);
>>> +			nr = next_set_bit - bitmap_no;
>>> +			if (bitmap_no >= cma->count)
>>> +				break;
> Put this just next to a??bitmap_no = a?|a?? line.  No need to call
> find_next_bit if wea??re gonna break anyway.
thank you I fixed
>>> +			if (nr_total == 0)
>>> +				printk("%u", nr);
>>> +			else
>>> +				printk("+%u", nr);
> Perhaps also include location of the hole?  Something like:
>
> 		pr_cont("%s%u@%u", nr_total ? "+" : "", nr, bitmap_no);
Thank you I fixed with @%lu
>
>>> +			nr_total += nr;
>>> +			start = bitmap_no + nr;
>>> +		}
>>> +		printk("=>%u pages, total: %lu pages\n", nr_total, cma->count);
>>> +		mutex_unlock(&cma->lock);
>>> +	}
>>> +
> I wonder if this should be wrapped in
>
> #ifdef CMA_DEBUG
> a?|
> #endif
>
> On one hand ita??s relatively expensive (even involving mutex locking) on
> the other ita??s in allocation failure path.
bitmap status, I think, could be in side of CMA_DEBUG with the mutex
but the first error log, I hope, to be out of CMA_DEBUG.
>
>>>  	return page;
>>>  }
>>>  
>>> -- 
>>> 1.9.1
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> -- 
>> Michal Hocko
>> SUSE Labs
This is fixed patch following your comment.
Please review again
If it is OK, let me know whether I need to resend this patch as a new mail thread.
