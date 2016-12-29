Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 933CB6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 04:25:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n189so561180009pga.4
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:25:59 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id p125si52908100pfp.119.2016.12.29.01.25.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 01:25:58 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcas1p3.samsung.com (unknown [182.195.41.47])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OIX01J7OWV8ED60@mailout4.samsung.com> for linux-mm@kvack.org;
 Thu, 29 Dec 2016 18:25:56 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <5864D6CE.7070001@samsung.com>
Date: Thu, 29 Dec 2016 18:26:38 +0900
In-reply-to: <20161229091449.GG29208@dhcp22.suse.cz>
References: 
 <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2016e?? 12i?? 29i? 1/4  18:14, Michal Hocko wrote:
> On Thu 29-12-16 11:28:02, Jaewon Kim wrote:
>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
>> This patch prints the error value and bitmap status to know available pages
>> regarding fragmentation.
>>
>> This is an ENOMEM example with this patch.
>> [   11.616321]  [2:   Binder:711_1:  740] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12
>> [   11.616365]  [2:   Binder:711_1:  740] number of available pages: 4+7+7+8+38+166+127=>357 pages, total: 2048 pages
> Could you be more specific why this part is useful?
Hi
Without this patch we do not know why CMA allocation failed.
Additionally in case of ENOMEM, with bitmap status we can figure out that
if it is too small CMA region issue or if it is fragmentation issue.
>  
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index c960459..535aa39 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>  	unsigned long start = 0;
>>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>  	struct page *page = NULL;
>> -	int ret;
>> +	int ret = -ENOMEM;
>>  
>>  	if (!cma || !cma->count)
>>  		return NULL;
>> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>  	trace_cma_alloc(pfn, page, count, align);
>>  
>>  	pr_debug("%s(): returned %p\n", __func__, page);
>> +
>> +	if (ret != 0) {
>> +		unsigned int nr, nr_total = 0;
>> +		unsigned long next_set_bit;
>> +
>> +		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>> +			__func__, count, ret);
>> +		mutex_lock(&cma->lock);
>> +		printk("number of available pages: ");
>> +		start = 0;
>> +		for (;;) {
>> +			bitmap_no = find_next_zero_bit(cma->bitmap, cma->count, start);
>> +			next_set_bit = find_next_bit(cma->bitmap, cma->count, bitmap_no);
>> +			nr = next_set_bit - bitmap_no;
>> +			if (bitmap_no >= cma->count)
>> +				break;
>> +			if (nr_total == 0)
>> +				printk("%u", nr);
>> +			else
>> +				printk("+%u", nr);
>> +			nr_total += nr;
>> +			start = bitmap_no + nr;
>> +		}
>> +		printk("=>%u pages, total: %lu pages\n", nr_total, cma->count);
>> +		mutex_unlock(&cma->lock);
>> +	}
>> +
>>  	return page;
>>  }
>>  
>> -- 
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
