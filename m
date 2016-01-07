Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D65D6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 05:01:42 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 1so200200601ion.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 02:01:42 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id g33si37000494ioi.97.2016.01.07.02.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 02:01:40 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id 77so216101671ioc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 02:01:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160107095127.GQ6301@e104818-lin.cambridge.arm.com>
References: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
	<CAPAsAGxmjF-_ZZFwtaxZsXN9g7J2sn6O0L+pBiPdARsKC_644g@mail.gmail.com>
	<CAKv+Gu9b_2WWYhgQmdnAUk0G0W3dwWXdWmpEmMtKW+=-KaJYgw@mail.gmail.com>
	<20160107095127.GQ6301@e104818-lin.cambridge.arm.com>
Date: Thu, 7 Jan 2016 11:01:40 +0100
Message-ID: <CAKv+Gu-tvGYp7hFZgOfo3ZDkFBrEC5isXuwhZinwncpSEhkLYg@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: map KASAN zero page read only
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, mingo <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 7 January 2016 at 10:51, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Wed, Jan 06, 2016 at 09:18:03PM +0100, Ard Biesheuvel wrote:
>> On 6 January 2016 at 20:48, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>> > 2016-01-06 18:54 GMT+03:00 Ard Biesheuvel <ard.biesheuvel@linaro.org>:
>> >> The original x86_64-only version of KASAN mapped its zero page
>> >> read-only, but this got lost when the code was generalised and
>> >> ported to arm64, since, at the time, the PAGE_KERNEL_RO define
>> >> did not exist. It has been added to arm64 in the mean time, so
>> >> let's use it.
>> >>
>> >
>> > Read-only wasn't lost. Just look at the next line:
>> >      zero_pte = pte_wrprotect(zero_pte);
>> >
>> > PAGE_KERNEL_RO is not available on all architectures, thus it would be better
>> > to not use it in generic code.
>>
>> OK, I didn't see that. For some reason, it is not working for me on
>> arm64, though.
>
> It's because the arm64 set_pte_at() doesn't bother checking for
> !PTE_WRITE to set PTE_RDONLY when mapping kernel pages. It works fine
> for user though. That's because usually all read-only kernel mappings
> already have PTE_RDONLY set via PAGE_KERNEL_RO.
>
> We may need to change the set_pte_at logic a bit to cover the above
> case.
>

Yes, that would be useful. I had an interesting dive down a rabbit
hole yesterday due to the fact that the kasan zero page (which backs a
substantial chunk of the shadow area) was getting written to by one
mapping, and reporting KAsan errors via another.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
