Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 918BF6B0254
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:37:16 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so131160342pac.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:37:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ks7si4373635pdb.218.2015.08.11.09.37.15
        for <linux-mm@kvack.org>;
        Tue, 11 Aug 2015 09:37:15 -0700 (PDT)
Date: Tue, 11 Aug 2015 17:37:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v5 5/6] arm64: add KASAN support
Message-ID: <20150811163709.GI23307@e104818-lin.cambridge.arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-6-git-send-email-ryabinin.a.a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439259499-13913-6-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Marek <mmarek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Aug 11, 2015 at 05:18:18AM +0300, Andrey Ryabinin wrote:
> This patch adds arch specific code for kernel address sanitizer
> (see Documentation/kasan.txt).
> 
> 1/8 of kernel addresses reserved for shadow memory. There was no
> big enough hole for this, so virtual addresses for shadow were
> stolen from vmalloc area.
> 
> At early boot stage the whole shadow region populated with just
> one physical page (kasan_zero_page). Later, this page reused
> as readonly zero shadow for some memory that KASan currently
> don't track (vmalloc).
> After mapping the physical memory, pages for shadow memory are
> allocated and mapped.
> 
> Functions like memset/memmove/memcpy do a lot of memory accesses.
> If bad pointer passed to one of these function it is important
> to catch this. Compiler's instrumentation cannot do this since
> these functions are written in assembly.
> KASan replaces memory functions with manually instrumented variants.
> Original functions declared as weak symbols so strong definitions
> in mm/kasan/kasan.c could replace them. Original functions have aliases
> with '__' prefix in name, so we could call non-instrumented variant
> if needed.
> Some files built without kasan instrumentation (e.g. mm/slub.c).
> Original mem* function replaced (via #define) with prefixed variants
> to disable memory access checks for such files.
> 
> Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
> Tested-by: Linus Walleij <linus.walleij@linaro.org>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
