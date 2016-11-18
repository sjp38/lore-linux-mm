Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A10B6B0471
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:17:36 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y205so5134010qkb.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:17:36 -0800 (PST)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id m38si2769257qtf.200.2016.11.18.11.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 11:17:35 -0800 (PST)
Received: by mail-qk0-f176.google.com with SMTP id n204so276240710qke.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:17:35 -0800 (PST)
Subject: Re: [PATCHv3 6/6] arm64: Add support for CONFIG_DEBUG_VIRTUAL
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-7-git-send-email-labbott@redhat.com>
 <20161118175327.GE1197@leverpostej>
 <16e4b3da-c552-252d-108a-0681b71b12ef@redhat.com>
 <20161118190531.GJ1197@leverpostej>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <61391b21-933b-1983-b170-68e7fbc9fee6@redhat.com>
Date: Fri, 18 Nov 2016 11:17:29 -0800
MIME-Version: 1.0
In-Reply-To: <20161118190531.GJ1197@leverpostej>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On 11/18/2016 11:05 AM, Mark Rutland wrote:
> On Fri, Nov 18, 2016 at 10:42:56AM -0800, Laura Abbott wrote:
>> On 11/18/2016 09:53 AM, Mark Rutland wrote:
>>> On Thu, Nov 17, 2016 at 05:16:56PM -0800, Laura Abbott wrote:
> 
>>>> +#define __virt_to_phys_nodebug(x) ({					\
>>>>  	phys_addr_t __x = (phys_addr_t)(x);				\
>>>> -	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
>>>> -				 (__x - kimage_voffset); })
>>>> +	((__x & ~PAGE_OFFSET) + PHYS_OFFSET);				\
>>>> +})
>>>
>>> Given the KASAN failure, and the strong possibility that there's even
>>> more stuff lurking in common code, I think we should retain the logic to
>>> handle kernel image addresses for the timebeing (as x86 does). Once
>>> we've merged DEBUG_VIRTUAL, it will be easier to track those down.
>>
>> Agreed. I might see about adding another option DEBUG_STRICT_VIRTUAL
>> for catching bad __pa vs __pa_symbol usage and keep DEBUG_VIRTUAL for
>> catching addresses that will work in neither case.
> 
> I think it makes sense for DEBUG_VIRTUAL to do both, so long as the
> default behaviour (and fallback after a WARN for virt_to_phys()) matches
> what we currently do. We'll get useful diagnostics, but a graceful
> fallback.
> 

I was suggesting making the WARN optional for having this be more useful
before all the __pa_symbol stuff gets cleaned up. Maybe the WARN won't
actually be a hindrance.

Thanks,
Laura

> I think the helpers I suggested below do that?  Or have I misunderstood,
> and you mean something stricter (e.g. checking whether a lm address is
> is backed by something)?
> 
>>> phys_addr_t __virt_to_phys(unsigned long x)
>>> {
>>> 	WARN(!__is_lm_address(x),
>>> 	     "virt_to_phys() used for non-linear address: %pK\n",
>>> 	     (void*)x);
>>> 	
>>> 	return __virt_to_phys_nodebug(x);
>>> }
>>> EXPORT_SYMBOL(__virt_to_phys);
> 
>>> phys_addr_t __phys_addr_symbol(unsigned long x)
>>> {
>>> 	/*
>>> 	 * This is bounds checking against the kernel image only.
>>> 	 * __pa_symbol should only be used on kernel symbol addresses.
>>> 	 */
>>> 	VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START ||
>>> 		       x > (unsigned long) KERNEL_END);
>>>
>>> 	return __pa_symbol_nodebug(x);
>>> }
>>> EXPORT_SYMBOL(__phys_addr_symbol);
> 
> Thanks,
> Mark.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
