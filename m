Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A21BE6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:26:44 -0500 (EST)
Received: by wmec201 with SMTP id c201so171065243wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 03:26:44 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id p3si27876332wjy.59.2015.11.16.03.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 03:26:43 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Message-ID: <5649BAFD.6030005@arm.com>
Date: Mon, 16 Nov 2015 11:16:13 +0000
MIME-Version: 1.0
In-Reply-To: <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On 13/10/15 09:34, Catalin Marinas wrote:
> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
>> Andrey Ryabinin (3):
>>    arm64: move PGD_SIZE definition to pgalloc.h
>>    arm64: add KASAN support
>>    Documentation/features/KASAN: arm64 supports KASAN now
>>
>> Linus Walleij (1):
>>    ARM64: kasan: print memory assignment
>
> Patches queued for 4.4. Thanks.
>

Hi,

I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-rc1=
:


arch/arm64/mm/kasan_init.c: In function =91kasan_early_init=92:
include/linux/compiler.h:484:38: error: call to =91__compiletime_assert_95=
=92 declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_S=
HADOW_END, PGDIR_SIZE)
   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                       ^
include/linux/compiler.h:467:4: note: in definition of macro =91__compileti=
me_assert=92
     prefix ## suffix();    \
     ^
include/linux/compiler.h:484:2: note: in expansion of macro =91_compiletime=
_assert=92
   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
   ^
include/linux/bug.h:50:37: note: in expansion of macro =91compiletime_asser=
t=92
  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                      ^
include/linux/bug.h:74:2: note: in expansion of macro =91BUILD_BUG_ON_MSG=
=92
   BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
   ^
arch/arm64/mm/kasan_init.c:95:2: note: in expansion of macro =91BUILD_BUG_O=
N=92
   BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));


---

The problem is that the PGDIR_SIZE is (1UL << 47) with 16K+48bit, which mak=
es
the KASAN_SHADOW_END unaligned(which is aligned to (1UL << (48 - 3)) ). Is =
the
alignment really needed ? Thoughts on how best we could fix this ?

Cheers
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
