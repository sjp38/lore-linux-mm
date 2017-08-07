Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACA76B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:33:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v11so802333oif.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:33:40 -0700 (PDT)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id s67si5411605oig.379.2017.08.07.10.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 10:33:39 -0700 (PDT)
Received: by mail-it0-x230.google.com with SMTP id 77so6877532itj.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:33:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 Aug 2017 10:33:38 -0700
Message-ID: <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Kostya Serebryany <kcc@google.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f39fdbc5fab5
> breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
> about address space layout for substantial performance gains. There
> are multiple people complaining about this already:
> https://github.com/google/sanitizers/issues/837
> https://twitter.com/kayseesee/status/894594085608013825
> https://bugzilla.kernel.org/show_bug.cgi?id=196537
> AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
> expecting that non-pie binaries will be below 2GB and pie
> binaries/modules will be at 0x55 or 0x7f. This is not the first time
> kernel address space shuffling breaks sanitizers. The last one was the
> move to 0x55.

What are the requirements for 32-bit and 64-bit memory layouts for
ASan currently, so we can adjust the ET_DYN base to work with existing
ASan?

I would note that on 64-bit the ELF_ET_DYN_BASE adjustment avoids the
entire 2GB space to stay out of the way of 32-bit address-using VMs,
for example.

What ranges should be avoided currently? We need to balance this
against the need to keep the PIE away from a growing heap...

> Is it possible to make this change less aggressive and keep the
> executable under 2GB?

_Under_ 2GB? It's possible we're going to need some VM tunable to
adjust these things if we're facing incompatible requirements...

ASan does seem especially fragile about these kinds of changes. Can
future versions of ASan be more dynamic about this?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
