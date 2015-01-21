Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 972AE6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 05:29:13 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id im6so5470192vcb.9
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 02:29:13 -0800 (PST)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com. [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id ew2si3842455vdc.39.2015.01.21.02.29.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 02:29:12 -0800 (PST)
Received: by mail-vc0-f171.google.com with SMTP id hq11so4589110vcb.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 02:29:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150120140546.DDCB8D4@black.fi.intel.com>
References: <54BD33DC.40200@ti.com>
	<20150119174317.GK20386@saruman>
	<20150120001643.7D15AA8@black.fi.intel.com>
	<20150120114555.GA11502@n2100.arm.linux.org.uk>
	<20150120140546.DDCB8D4@black.fi.intel.com>
Date: Wed, 21 Jan 2015 11:29:11 +0100
Message-ID: <CAJKOXPdBzSTM0EaFv5C_on8fAPDERkHOtTwVyN04kTRErAE+KA@mail.gmail.com>
Subject: Re: [next-20150119]regression (mm)?
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, Nishanth Menon <nm@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

2015-01-20 15:05 GMT+01:00 Kirill A. Shutemov <kirill.shutemov@linux.intel.com>:
> Russell King - ARM Linux wrote:
>> On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
>> > Better option would be converting 2-lvl ARM configuration to
>> > <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
>>
>> Well, IMHO the folded approach in asm-generic was done the wrong way
>> which barred ARM from ever using it.
>
> Okay, I see.
>
> Regarding the topic bug. Completely untested patch is below. Could anybody
> check if it helps?
>
> From 34b9182d08ef2b541829e305fcc91ef1d26b27ea Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 20 Jan 2015 15:47:22 +0200
> Subject: [PATCH] arm: define __PAGETABLE_PMD_FOLDED for !LPAE
>
> ARM uses custom implementation of PMD folding in 2-level page table case.
> Generic code expects to see __PAGETABLE_PMD_FOLDED to be defined if PMD is
> folded, but ARM doesn't do this. Let's fix it.
>
> Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
> It also fixes problems with recently-introduced pmd accounting on ARM
> without LPAE.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Nishanth Menon <nm@ti.com>
> ---
>  arch/arm/include/asm/pgtable-2level.h | 2 ++
>  1 file changed, 2 insertions(+)

Helps for this issue on Exynos 4412 (Trats2) and Exynos 5420 (Arndale Octa):
Tested-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Off-topic: "Using smp_processor_id() in preemptible" still screams [1]

[1] https://lkml.org/lkml/2015/1/20/162

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
