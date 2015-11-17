Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 890E76B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 10:46:57 -0500 (EST)
Received: by lbbsy6 with SMTP id sy6so8019190lbb.2
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 07:46:57 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o1si31122549lbw.157.2015.11.17.07.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 07:46:55 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com> <5649F783.40109@gmail.com>
 <564B40A7.1000206@arm.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <564B4BFC.1020905@virtuozzo.com>
Date: Tue, 17 Nov 2015 18:47:08 +0300
MIME-Version: 1.0
In-Reply-To: <564B40A7.1000206@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>



On 11/17/2015 05:58 PM, Suzuki K. Poulose wrote:
> On 16/11/15 15:34, Andrey Ryabinin wrote:
>> On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
>>> On 13/10/15 09:34, Catalin Marinas wrote:
>>>> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
> 
>>> Hi,
>>>
>>> I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-rc1:
>>>
>>>
>>> arch/arm64/mm/kasan_init.c: In function ?kasan_early_init?:
>>> include/linux/compiler.h:484:38: error: call to ?__compiletime_assert_95? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
>>>    _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>>>                                        ^
> 
> ...
> 
>>
>> Yes, it's really needed, because some code relies on this (e.g.  clear_pgs() and kasan_init()).
>> But it should be possible to get rid of this requirement.
> 
> And the other important point I missed mentioning was that, my tool chain doesn't
> support KASAN. But still the KASAN support files are still compiled and generates
> the above error. Shouldn't we disable it at build time if we detect that compiler
> doesn't support it ? Something like we do for LSE_ATOMICS.
> 

We should either add proper Kconfig dependency for now, or just make it work.


From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] arm64: KASAN depends on !(ARM64_16K_PAGES && ARM64_VA_BITS_48)

On KASAN + 16K_PAGES + 48BIT_VA
 arch/arm64/mm/kasan_init.c: In function ?kasan_early_init?:
 include/linux/compiler.h:484:38: error: call to ?__compiletime_assert_95? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
    _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)

Currently KASAN will not work on 16K_PAGES and 48BIT_VA, so
forbid such configuration to avoid above build failure.

Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/arm64/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 9ac16a4..bf7de69 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -49,7 +49,7 @@ config ARM64
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_JUMP_LABEL
-	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
+	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
