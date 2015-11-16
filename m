Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id F203F6B0263
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:04:00 -0500 (EST)
Received: by igvi2 with SMTP id i2so82001655igv.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:04:00 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id yt6si24027905igb.75.2015.11.16.11.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 11:04:00 -0800 (PST)
Received: by igvg19 with SMTP id g19so81237710igv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:04:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116190156.GH8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-12-git-send-email-ard.biesheuvel@linaro.org>
	<20151116190156.GH8644@n2100.arm.linux.org.uk>
Date: Mon, 16 Nov 2015 20:04:00 +0100
Message-ID: <CAKv+Gu8w+2GA5tV4roYtEsza+mkCZKYX_=tT2t=+eh-ZO1Y2fA@mail.gmail.com>
Subject: Re: [PATCH v2 11/12] ARM: wire up UEFI init and runtime support
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 20:01, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 07:32:36PM +0100, Ard Biesheuvel wrote:
>> +static inline void efi_set_pgd(struct mm_struct *mm)
>> +{
>> +     if (unlikely(mm->context.vmalloc_seq != init_mm.context.vmalloc_seq))
>> +             __check_vmalloc_seq(mm);
>> +
>> +     cpu_switch_mm(mm->pgd, mm);
>> +
>> +     flush_tlb_all();
>> +     if (icache_is_vivt_asid_tagged())
>> +             __flush_icache_all();
>> +}
>
> I don't think that's sufficient.  There's a gap between switching the mm
> and flushing the TLBs where we could have different global TLB entries
> from those in the page tables - and that can cause problems with CPUs
> which speculatively prefetch.  Some CPUs raise exceptions for this...
>

OK. So you mean set TTBR to the zero page, perform the TLB flush and
only then switch to the new page tables?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
