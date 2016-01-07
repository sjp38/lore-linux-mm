Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 403E36B0007
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 04:51:33 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id qh10so4547840pab.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 01:51:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id bd10si8016158pad.226.2016.01.07.01.51.32
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 01:51:32 -0800 (PST)
Date: Thu, 7 Jan 2016 09:51:28 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm/kasan: map KASAN zero page read only
Message-ID: <20160107095127.GQ6301@e104818-lin.cambridge.arm.com>
References: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
 <CAPAsAGxmjF-_ZZFwtaxZsXN9g7J2sn6O0L+pBiPdARsKC_644g@mail.gmail.com>
 <CAKv+Gu9b_2WWYhgQmdnAUk0G0W3dwWXdWmpEmMtKW+=-KaJYgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu9b_2WWYhgQmdnAUk0G0W3dwWXdWmpEmMtKW+=-KaJYgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, mingo <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jan 06, 2016 at 09:18:03PM +0100, Ard Biesheuvel wrote:
> On 6 January 2016 at 20:48, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> > 2016-01-06 18:54 GMT+03:00 Ard Biesheuvel <ard.biesheuvel@linaro.org>:
> >> The original x86_64-only version of KASAN mapped its zero page
> >> read-only, but this got lost when the code was generalised and
> >> ported to arm64, since, at the time, the PAGE_KERNEL_RO define
> >> did not exist. It has been added to arm64 in the mean time, so
> >> let's use it.
> >>
> >
> > Read-only wasn't lost. Just look at the next line:
> >      zero_pte = pte_wrprotect(zero_pte);
> >
> > PAGE_KERNEL_RO is not available on all architectures, thus it would be better
> > to not use it in generic code.
> 
> OK, I didn't see that. For some reason, it is not working for me on
> arm64, though.

It's because the arm64 set_pte_at() doesn't bother checking for
!PTE_WRITE to set PTE_RDONLY when mapping kernel pages. It works fine
for user though. That's because usually all read-only kernel mappings
already have PTE_RDONLY set via PAGE_KERNEL_RO.

We may need to change the set_pte_at logic a bit to cover the above
case.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
