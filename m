Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 358848E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:46:33 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t7-v6so4003010ljg.9
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:46:33 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 10-v6si63556345ljd.200.2019.01.11.10.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:46:31 -0800 (PST)
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
References: <20181211133453.2835077-1-arnd@arndb.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <478333ec-1866-2908-1111-8b3dda135278@virtuozzo.com>
Date: Fri, 11 Jan 2019 21:46:50 +0300
MIME-Version: 1.0
In-Reply-To: <20181211133453.2835077-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Anders Roxell <anders.roxell@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/11/18 4:34 PM, Arnd Bergmann wrote:
> Building little-endian allmodconfig kernels on arm64 started failing
> with the generated atomic.h implementation, since we now try to call
> kasan helpers from the EFI stub:
> 
> aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in function `atomic_set':
> include/generated/atomic-instrumented.h:44: undefined reference to `__efistub_kasan_check_write'
> 
> I suspect that we get similar problems in other files that explicitly
> disable KASAN for some reason but call atomic_t based helper functions.
> 
> We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> that the compiler sets instead of checking CONFIG_KASAN, but this in turn
> requires a small hack in mm/kasan/common.c so we do see the extern
> declaration there instead of the inline function.
> 
> Fixes: b1864b828644 ("locking/atomics: build atomic headers as required")
> Reported-by: Anders Roxell <anders.roxell@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
