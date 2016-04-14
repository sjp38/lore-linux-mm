Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 028E66B028C
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:33:18 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id fn8so149162023igb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:33:17 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id k185si5112517iof.134.2016.04.14.08.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 08:33:16 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id g185so107249479ioa.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:33:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160414152532.GD4584@arm.com>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
	<1459349164-27175-10-git-send-email-ard.biesheuvel@linaro.org>
	<20160414152532.GD4584@arm.com>
Date: Thu, 14 Apr 2016 17:33:15 +0200
Message-ID: <CAKv+Gu_EwTuJEgUs61GOdGeCnB4XWiqdaLL3hhbK-Uu3+-px8g@mail.gmail.com>
Subject: Re: [PATCH v2 9/9] mm: replace open coded page to virt conversion
 with page_to_virt()
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, nios2-dev@lists.rocketboards.org, lftan@altera.com, Jonas Bonn <jonas@southpole.se>, linux@lists.openrisc.net, Mark Rutland <mark.rutland@arm.com>, Steve Capper <steve.capper@linaro.org>

On 14 April 2016 at 17:25, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Mar 30, 2016 at 04:46:04PM +0200, Ard Biesheuvel wrote:
>> The open coded conversion from struct page address to virtual address in
>> lowmem_page_address() involves an intermediate conversion step to pfn
>> number/physical address. Since the placement of the struct page array
>> relative to the linear mapping may be completely independent from the
>> placement of physical RAM (as is that case for arm64 after commit
>> dfd55ad85e 'arm64: vmemmap: use virtual projection of linear region'),
>> the conversion to physical address and back again should factor out of
>> the equation, but unfortunately, the shifting and pointer arithmetic
>> involved prevent this from happening, and the resulting calculation
>> essentially subtracts the address of the start of physical memory and
>> adds it back again, in a way that prevents the compiler from optimizing
>> it away.
>>
>> Since the start of physical memory is not a build time constant on arm64,
>> the resulting conversion involves an unnecessary memory access, which
>> we would like to get rid of. So replace the open coded conversion with
>> a call to page_to_virt(), and use the open coded conversion as its
>> default definition, to be overriden by the architecture, if desired.
>> The existing arch specific definitions of page_to_virt are all equivalent
>> to this default definition, so by itself this patch is a no-op.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>
> Acked-by: Will Deacon <will.deacon@arm.com>
>
> I assume you'll post this patch (and the nios2/openrisc) patches as
> individual patches targetting the relevant trees?
>

Sure, as they are completely independent from the rest of the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
