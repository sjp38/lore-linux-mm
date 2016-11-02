Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D34616B0281
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 19:56:45 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q197so79487776oic.6
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 16:56:45 -0700 (PDT)
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com. [209.85.218.48])
        by mx.google.com with ESMTPS id e94si3124581otb.79.2016.11.02.16.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 16:56:45 -0700 (PDT)
Received: by mail-oi0-f48.google.com with SMTP id v84so47499735oie.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 16:56:45 -0700 (PDT)
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
Date: Wed, 2 Nov 2016 17:56:42 -0600
MIME-Version: 1.0
In-Reply-To: <20161102225241.GA19591@remoulade>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On 11/02/2016 04:52 PM, Mark Rutland wrote:
> On Wed, Nov 02, 2016 at 03:00:53PM -0600, Laura Abbott wrote:
>>
>> __pa_symbol is technically the marco that should be used for kernel
>> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.
>
> Nit: s/marco/macro/
>
> I see there are some other uses of __pa() that look like they could/should be
> __pa_symbol(), e.g. in mark_rodata_ro().
>
> I guess strictly speaking those need to be updated to? Or is there a reason
> that we should not?
>

If the concept of __pa_symbol is okay then yes I think all uses of __pa
should eventually be converted for consistency and debugging.

> Thanks,
> Mark.
>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>>  arch/arm64/mm/init.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index 212c4d1..3236eb0 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -209,8 +209,8 @@ void __init arm64_memblock_init(void)
>>  	 * linear mapping. Take care not to clip the kernel which may be
>>  	 * high in memory.
>>  	 */
>> -	memblock_remove(max_t(u64, memstart_addr + linear_region_size, __pa(_end)),
>> -			ULLONG_MAX);
>> +	memblock_remove(max_t(u64, memstart_addr + linear_region_size,
>> +			__pa_symbol(_end)), ULLONG_MAX);
>>  	if (memstart_addr + linear_region_size < memblock_end_of_DRAM()) {
>>  		/* ensure that memstart_addr remains sufficiently aligned */
>>  		memstart_addr = round_up(memblock_end_of_DRAM() - linear_region_size,
>> --
>> 2.10.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
