Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9DE616B007B
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 15:49:42 -0400 (EDT)
Message-ID: <4C87E8D2.4050005@kernel.dk>
Date: Wed, 08 Sep 2010 21:49:38 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] bounce: call flush_dcache_page after bounce_copy_vec
References: <1283892334-9238-1-git-send-email-gking@nvidia.com> <20100908124716.830a0055.akpm@linux-foundation.org>
In-Reply-To: <20100908124716.830a0055.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary King <gking@nvidia.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, tj@kernel.org, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On 09/08/2010 09:47 PM, Andrew Morton wrote:
> On Tue,  7 Sep 2010 13:45:34 -0700
> Gary King <gking@nvidia.com> wrote:
> 
>> I have been seeing problems on Tegra 2 (ARMv7 SMP) systems with HIGHMEM
>> enabled on 2.6.35 (plus some patches targetted at 2.6.36 to perform
>> cache maintenance lazily), and the root cause appears to be that the
>> mm bouncing code is calling flush_dcache_page before it copies the
>> bounce buffer into the bio.
>>
>> The patch below reorders these two operations, and eliminates numerous
>> arbitrary application crashes on my dev system.
>>
>> Gary
>>
>> --
>> >From 678c9bca8d8a8f254f28af91e69fad3aa1be7593 Mon Sep 17 00:00:00 2001
>> From: Gary King <gking@nvidia.com>
>> Date: Mon, 6 Sep 2010 15:37:12 -0700
>> Subject: bounce: call flush_dcache_page after bounce_copy_vec
>>
>> the bounced page needs to be flushed after data is copied into it,
>> to ensure that architecture implementations can synchronize
>> instruction and data caches if necessary.
>>
>> Signed-off-by: Gary King <gking@nvidia.com>
>> ---
>>  mm/bounce.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/bounce.c b/mm/bounce.c
>> index 13b6dad..1481de6 100644
>> --- a/mm/bounce.c
>> +++ b/mm/bounce.c
>> @@ -116,8 +116,8 @@ static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
>>  		 */
>>  		vfrom = page_address(fromvec->bv_page) + tovec->bv_offset;
>>  
>> -		flush_dcache_page(tovec->bv_page);
>>  		bounce_copy_vec(tovec, vfrom);
>> +		flush_dcache_page(tovec->bv_page);
>>  	}
>>  }
> 
> Oh my, that was bad.

Indeed, I wonder how that could have been wrong for so long.

> I queued your fix for 2.6.36 and tagged it for -stable backporting,
> thanks.

Thanks, you can add my acked-by.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
