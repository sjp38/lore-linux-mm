Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2066B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:07:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so31171416itn.4
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:07:28 -0800 (PST)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id e19si2604855ioj.160.2016.12.15.08.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 08:07:27 -0800 (PST)
Received: by mail-it0-x229.google.com with SMTP id j191so34105000ita.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:07:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161215153930.GA8111@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org> <20161215153930.GA8111@rric.localdomain>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 15 Dec 2016 16:07:26 +0000
Message-ID: <CAKv+Gu8K+mokbjzM8EpTJoCp3XAKK1_Doq1Zx=A2CCWTT6FbYg@mail.gmail.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On 15 December 2016 at 15:39, Robert Richter <robert.richter@cavium.com> wrote:
> I was going to do some measurements but my kernel crashes now with a
> page fault in efi_rtc_probe():
>
> [   21.663393] Unable to handle kernel paging request at virtual address 20251000
> [   21.663396] pgd = ffff000009090000
> [   21.663401] [20251000] *pgd=0000010ffff90003
> [   21.663402] , *pud=0000010ffff90003
> [   21.663404] , *pmd=0000000fdc030003
> [   21.663405] , *pte=00e8832000250707
>
> The sparsemem config requires the whole section to be initialized.
> Your patches do not address this.
>

96000047 is a third level translation fault, and the PTE address has
RES0 bits set. I don't see how this is related to sparsemem, could you
explain?

> On 14.12.16 09:11:47, Ard Biesheuvel wrote:
>> +config HOLES_IN_ZONE
>> +     def_bool y
>> +     depends on NUMA
>
> This enables pfn_valid_within() for arm64 and causes the check for
> each page of a section. The arm64 implementation of pfn_valid() is
> already expensive (traversing memblock areas). Now, this is increased
> by a factor of 2^18 for 4k page size (16384 for 64k). We need to
> initialize the whole section to avoid that.
>

I know that. But if you want something for -stable, we should have
something that is correct first, and only then care about the
performance hit (if there is one)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
