Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1D7440856
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:37:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i71so12348851itf.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:37:48 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id m76si2426376iod.246.2017.07.12.00.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 00:37:47 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id v193so1435905itc.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:37:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAK8P3a3J8uyTW2_iDpOi2Y5ONf7z3TR0zk3igp2uBrL8xsQd8Q@mail.gmail.com>
References: <1499842660-10665-1-git-send-email-geert@linux-m68k.org> <CAK8P3a3J8uyTW2_iDpOi2Y5ONf7z3TR0zk3igp2uBrL8xsQd8Q@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 12 Jul 2017 09:37:45 +0200
Message-ID: <CAMuHMdVDgLpK8r2D4rwmCXEYwdgf7=Tqspq=VgPHmuqcrY5bVA@mail.gmail.com>
Subject: Re: [PATCH] mm: Mark create_huge_pmd() inline to prevent build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Arnd,

On Wed, Jul 12, 2017 at 9:22 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wed, Jul 12, 2017 at 8:57 AM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
>> With gcc 4.1.2:
>>
>>     mm/memory.o: In function `create_huge_pmd':
>>     memory.c:(.text+0x93e): undefined reference to `do_huge_pmd_anonymous_page'
>>
>> Converting transparent_hugepage_enabled() from a macro to a static
>> inline function reduced the ability of the compiler to remove unused
>> code.
>>
>> Fix this by marking create_huge_pmd() inline.
>>
>> Fixes: 16981d763501c0e0 ("mm: improve readability of transparent_hugepage_enabled()")
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks!

>> ---
>> Interestingly, create_huge_pmd() is emitted in the assembler output, but
>> never called.
>
> I've never seen this before either. I know that early gcc-4 compilers
> would do this
> when a function is referenced from an unused function pointer, but not with
> a compile-time constant evaluation. I guess that transparent_hugepage_enabled
> is just slightly more complex than it gcc-4.1 can handle here.

You did mention seeing it with mips-gcc-4.1 in the thread "[RFC] minimum gcc
version for kernel: raise to gcc-4.3 or 4.6?", but didn't provide any further
details. Finally I started seeing it myself for m68k ;-)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
