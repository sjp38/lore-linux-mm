Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7706B0283
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 20:05:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 128so78480144oih.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 17:05:42 -0700 (PDT)
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com. [209.85.218.48])
        by mx.google.com with ESMTPS id e198si3363864oig.24.2016.11.02.17.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 17:05:41 -0700 (PDT)
Received: by mail-oi0-f48.google.com with SMTP id x4so47827039oix.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 17:05:41 -0700 (PDT)
Subject: Re: [PATCHv2 6/6] arm64: Add support for CONFIG_DEBUG_VIRTUAL
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-7-labbott@redhat.com>
 <20161102230642.GB19591@remoulade>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <a77c2162-6eb9-09c8-e84f-03a207b59c6b@redhat.com>
Date: Wed, 2 Nov 2016 18:05:38 -0600
MIME-Version: 1.0
In-Reply-To: <20161102230642.GB19591@remoulade>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On 11/02/2016 05:06 PM, Mark Rutland wrote:
> On Wed, Nov 02, 2016 at 03:00:54PM -0600, Laura Abbott wrote:
>> +CFLAGS_physaddr.o		:= -DTEXT_OFFSET=$(TEXT_OFFSET)
>> +obj-$(CONFIG_DEBUG_VIRTUAL)	+= physaddr.o
>
>> diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
>> new file mode 100644
>> index 0000000..874c782
>> --- /dev/null
>> +++ b/arch/arm64/mm/physaddr.c
>> @@ -0,0 +1,34 @@
>> +#include <linux/mm.h>
>> +
>> +#include <asm/memory.h>
>> +
>> +unsigned long __virt_to_phys(unsigned long x)
>> +{
>> +	phys_addr_t __x = (phys_addr_t)x;
>> +
>> +	if (__x & BIT(VA_BITS - 1)) {
>> +		/*
>> +		 * The linear kernel range starts in the middle of the virtual
>> +		 * adddress space. Testing the top bit for the start of the
>> +		 * region is a sufficient check.
>> +		 */
>> +		return (__x & ~PAGE_OFFSET) + PHYS_OFFSET;
>> +	} else {
>> +		VIRTUAL_BUG_ON(x < kimage_vaddr || x >= (unsigned long)_end);
>> +		return (__x - kimage_voffset);
>> +	}
>> +}
>> +EXPORT_SYMBOL(__virt_to_phys);
>> +
>> +unsigned long __phys_addr_symbol(unsigned long x)
>> +{
>> +	phys_addr_t __x = (phys_addr_t)x;
>> +
>> +	/*
>> +	 * This is intentionally different than above to be a tighter check
>> +	 * for symbols.
>> +	 */
>> +	VIRTUAL_BUG_ON(x < kimage_vaddr + TEXT_OFFSET || x > (unsigned long) _end);
>
> Can't we use _text instead of kimage_vaddr + TEXT_OFFSET? That way we don't
> need CFLAGS_physaddr.o.
>
> Or KERNEL_START / KERNEL_END from <asm/memory.h>?
>
> Otherwise, this looks good to me (though I haven't grokked the need for
> __pa_symbol() yet).

I guess it's a question of what's clearer. I like kimage_vaddr +
TEXT_OFFSET because it clearly states we are checking from the
start of the kernel image vs. _text only shows the start of the
text region. Yes, it's technically the same but a little less
obvious. I suppose that could be solved with some more elaboration
in the comment.

Thanks,
Laura

>
> Thanks,
> Mark.
>
>> +	return (__x - kimage_voffset);
>> +}
>> +EXPORT_SYMBOL(__phys_addr_symbol);
>> --
>> 2.10.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
