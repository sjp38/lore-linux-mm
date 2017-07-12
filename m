Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 192756810BE
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:22:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t188so1341120oih.15
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:22:53 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id b205si1206639oia.375.2017.07.12.00.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 00:22:52 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id p188so12566230oia.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:22:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1499842660-10665-1-git-send-email-geert@linux-m68k.org>
References: <1499842660-10665-1-git-send-email-geert@linux-m68k.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 12 Jul 2017 09:22:51 +0200
Message-ID: <CAK8P3a3J8uyTW2_iDpOi2Y5ONf7z3TR0zk3igp2uBrL8xsQd8Q@mail.gmail.com>
Subject: Re: [PATCH] mm: Mark create_huge_pmd() inline to prevent build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 12, 2017 at 8:57 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
>
> With gcc 4.1.2:
>
>     mm/memory.o: In function `create_huge_pmd':
>     memory.c:(.text+0x93e): undefined reference to `do_huge_pmd_anonymous_page'
>
> Converting transparent_hugepage_enabled() from a macro to a static
> inline function reduced the ability of the compiler to remove unused
> code.
>
> Fix this by marking create_huge_pmd() inline.
>
> Fixes: 16981d763501c0e0 ("mm: improve readability of transparent_hugepage_enabled()")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Arnd Bergmann <arnd@arndb.de>

> ---
> Interestingly, create_huge_pmd() is emitted in the assembler output, but
> never called.

I've never seen this before either. I know that early gcc-4 compilers
would do this
when a function is referenced from an unused function pointer, but not with
a compile-time constant evaluation. I guess that transparent_hugepage_enabled
is just slightly more complex than it gcc-4.1 can handle here.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
