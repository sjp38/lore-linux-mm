Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ED9E96B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:43:52 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so36259437pdb.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:43:52 -0800 (PST)
Received: from mail-gw1-out.broadcom.com (mail-gw1-out.broadcom.com. [216.31.210.62])
        by mx.google.com with ESMTP id f10si8144205pas.19.2015.02.24.13.43.51
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 13:43:52 -0800 (PST)
Message-ID: <54ECF091.8070508@broadcom.com>
Date: Tue, 24 Feb 2015 13:43:45 -0800
From: Danesh Petigara <dpetigara@broadcom.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cma: fix CMA aligned offset calculation
References: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com> <xa1twq37ow1n.fsf@mina86.com>
In-Reply-To: <xa1twq37ow1n.fsf@mina86.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, akpm@linux-foundation.org
Cc: m.szyprowski@samsung.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org



On 2/24/2015 1:10 PM, Michal Nazarewicz wrote:
> On Tue, Feb 24 2015, Danesh Petigara <dpetigara@broadcom.com> wrote:
>> The CMA aligned offset calculation is incorrect for
>> non-zero order_per_bit values.
>>
>> For example, if cma->order_per_bit=1, cma->base_pfn=
>> 0x2f800000 and align_order=12, the function returns
>> a value of 0x17c00 instead of 0x400.
>>
>> This patch fixes the CMA aligned offset calculation.
>>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Danesh Petigara <dpetigara@broadcom.com>
>> Reviewed-by: Gregory Fong <gregory.0xf0@gmail.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
>> ---
>>  mm/cma.c | 10 +++++++---
>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index 75016fd..58f37bd 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -70,9 +70,13 @@ static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
>>  
>>  	if (align_order <= cma->order_per_bit)
>>  		return 0;
>> -	alignment = 1UL << (align_order - cma->order_per_bit);
>> -	return ALIGN(cma->base_pfn, alignment) -
>> -		(cma->base_pfn >> cma->order_per_bit);
>> +
>> +	/*
>> +	 * Find a PFN aligned to the specified order and return
>> +	 * an offset represented in order_per_bits.
>> +	 */
> 
> It probably makes sense to move this comment outside of the function as
> function documentation.
> 

Thanks for the feedback. Will send out patch v2 with the comment moved
outside the function and also remove the unused 'alignment' variable.

>> +	return (ALIGN(cma->base_pfn, (1UL << align_order))
>> +		- cma->base_pfn) >> cma->order_per_bit;
>>  }
>>  
>>  static unsigned long cma_bitmap_maxno(struct cma *cma)
>> -- 
>> 1.9.1
>>
> 

Best regards,
Danesh Petigara

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
