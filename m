Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 14EDB6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:04:49 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id p187so8154595oia.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:04:49 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0091.outbound.protection.outlook.com. [157.55.234.91])
        by mx.google.com with ESMTPS id dp7si3867112obb.40.2016.01.27.08.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 08:04:48 -0800 (PST)
Subject: Re: [PATCH v2 RESEND 1/2] arm, arm64: change_memory_common with
 numpages == 0 should be no-op.
References: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
 <1453820393-31179-2-git-send-email-mika.penttila@nextfour.com>
 <20160126155919.GA28238@arm.com>
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Message-ID: <56A8EA96.9060305@nextfour.com>
Date: Wed, 27 Jan 2016 18:04:38 +0200
MIME-Version: 1.0
In-Reply-To: <20160126155919.GA28238@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, catalin.marinas@arm.com


Hi Will,

On 26.01.2016 17:59, Will Deacon wrote:
> Hi Mika,
>
> On Tue, Jan 26, 2016 at 04:59:52PM +0200, mika.penttila@nextfour.com wrote:
>> From: Mika Penttila <mika.penttila@nextfour.com>
>>
>> This makes the caller set_memory_xx() consistent with x86.
>>
>> arm64 part is rebased on 4.5.0-rc1 with Ard's patch
>>  lkml.kernel.org/g/<1453125665-26627-1-git-send-email-ard.biesheuvel@linaro.org>
>> applied.
>>
>> Signed-off-by: Mika Penttila mika.penttila@nextfour.com
>> Reviewed-by: Laura Abbott <labbott@redhat.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>>
>> ---
>>  arch/arm/mm/pageattr.c   | 3 +++
>>  arch/arm64/mm/pageattr.c | 3 +++
>>  2 files changed, 6 insertions(+)
>>
>> diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
>> index cf30daf..d19b1ad 100644
>> --- a/arch/arm/mm/pageattr.c
>> +++ b/arch/arm/mm/pageattr.c
>> @@ -49,6 +49,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>>  		WARN_ON_ONCE(1);
>>  	}
>>  
>> +	if (!numpages)
>> +		return 0;
>> +
>>  	if (start < MODULES_VADDR || start >= MODULES_END)
>>  		return -EINVAL;
>>  
>> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
>> index 1360a02..b582fc2 100644
>> --- a/arch/arm64/mm/pageattr.c
>> +++ b/arch/arm64/mm/pageattr.c
>> @@ -53,6 +53,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>>  		WARN_ON_ONCE(1);
>>  	}
>>  
>> +	if (!numpages)
>> +		return 0;
>> +
> Thanks for this. I can reproduce the failure on my Juno board, so I'd
> like to queue this for 4.5 since it fixes a real issue. I've taken the
> liberty of rebasing the arm64 part to my fixes branch and writing a
> commit message. Does the patch below look ok to you?
>
> Will
>
> --->8
>
> From 57adec866c0440976c96a4b8f5b59fb411b1cacb Mon Sep 17 00:00:00 2001
> From: =?UTF-8?q?Mika=20Penttil=C3=A4?= <mika.penttila@nextfour.com>
> Date: Tue, 26 Jan 2016 15:47:25 +0000
> Subject: [PATCH] arm64: mm: avoid calling apply_to_page_range on empty range
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
>
> Calling apply_to_page_range with an empty range results in a BUG_ON
> from the core code. This can be triggered by trying to load the st_drv
> module with CONFIG_DEBUG_SET_MODULE_RONX enabled:
>
>   kernel BUG at mm/memory.c:1874!
>   Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>   Modules linked in:
>   CPU: 3 PID: 1764 Comm: insmod Not tainted 4.5.0-rc1+ #2
>   Hardware name: ARM Juno development board (r0) (DT)
>   task: ffffffc9763b8000 ti: ffffffc975af8000 task.ti: ffffffc975af8000
>   PC is at apply_to_page_range+0x2cc/0x2d0
>   LR is at change_memory_common+0x80/0x108
>
> This patch fixes the issue by making change_memory_common (called by the
> set_memory_* functions) a NOP when numpages == 0, therefore avoiding the
> erroneous call to apply_to_page_range and bringing us into line with x86
> and s390.
>
> Cc: <stable@vger.kernel.org>
> Reviewed-by: Laura Abbott <labbott@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Mika Penttila <mika.penttila@nextfour.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  arch/arm64/mm/pageattr.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index 3571c7309c5e..cf6240741134 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -57,6 +57,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>  	if (end < MODULES_VADDR || end >= MODULES_END)
>  		return -EINVAL;
>  
> +	if (!numpages)
> +		return 0;
> +
>  	data.set_mask = set_mask;
>  	data.clear_mask = clear_mask;
>  

Yes I'm fine with that,
Thanks!
Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
