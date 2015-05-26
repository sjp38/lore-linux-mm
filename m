Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2146B0121
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:12:47 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so91705609pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:12:46 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id h13si21203821pdk.53.2015.05.26.07.12.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 May 2015 07:12:46 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOY00JTRNH5EH50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 26 May 2015 15:12:41 +0100 (BST)
Message-id: <55647F57.8010008@samsung.com>
Date: Tue, 26 May 2015 17:12:39 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <CACRpkda3Pe9L14_iyKEfeCx1F3XJSLbz_OVHLxX0Lzy9Gt9t9Q@mail.gmail.com>
In-reply-to: 
 <CACRpkda3Pe9L14_iyKEfeCx1F3XJSLbz_OVHLxX0Lzy9Gt9t9Q@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On 05/26/2015 04:35 PM, Linus Walleij wrote:
> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
> And then at boot I just get this:
> 
> kasan test: kmalloc_oob_right out-of-bounds to right
> kasan test: kmalloc_oob_left out-of-bounds to left
> kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-bounds to right
> kasan test: kmalloc_large_oob_rigth kmalloc large allocation:
> out-of-bounds to right
> kasan test: kmalloc_oob_krealloc_more out-of-bounds after krealloc more
> kasan test: kmalloc_oob_krealloc_less out-of-bounds after krealloc less
> kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-bytes access
> kasan test: kmalloc_oob_in_memset out-of-bounds in memset
> kasan test: kmalloc_uaf use-after-free
> kasan test: kmalloc_uaf_memset use-after-free in memset
> kasan test: kmalloc_uaf2 use-after-free after another kmalloc
> kasan test: kmem_cache_oob out-of-bounds in kmem_cache_alloc
> kasan test: kasan_stack_oob out-of-bounds on stack
> kasan test: kasan_global_oob out-of-bounds global variable
> 
> W00t no nice KASan warnings (which is what I expect).
> 
> This is my compiler by the way:
> $ arm-linux-gnueabihf-gcc --version
> arm-linux-gnueabihf-gcc (crosstool-NG linaro-1.13.1-4.9-2014.09 -
> Linaro GCC 4.9-2014.09) 4.9.2 20140904 (prerelease)
> 
> I did the same exercise on the foundation model (FVP) and I guess
> that is what you developed the patch set on because there I got
> nice KASan dumps:
> 

That's not kasan dumps. That is slub debug output.
KASan warnings starts with
	"BUG: KASan: use after free/out of bounds access "
line.

> I wonder were the problem lies, any hints where to start looking
> to fix this?
> 

I suspect that your compiler lack -fsantize=kernel-address support.
It seems that GCC 4.9.2 doesn't supports -fsanitize=address/kernel-address on aarch64.

I tested this patchset on Cavium Thunder-x and on FVP also and didn't observe any problems.

> Yours,
> Linus Walleij
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
