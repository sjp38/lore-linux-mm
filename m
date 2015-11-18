Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 14F4A82F81
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:33:14 -0500 (EST)
Received: by lbbsy6 with SMTP id sy6so25378100lbb.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:33:13 -0800 (PST)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id n195si2090082lfn.81.2015.11.18.06.33.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 06:33:12 -0800 (PST)
Received: by lbbkw15 with SMTP id kw15so25509424lbb.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:33:12 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com> <5649F783.40109@gmail.com>
 <20151116165100.GE6556@e104818-lin.cambridge.arm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <564C8C47.1080904@gmail.com>
Date: Wed, 18 Nov 2015 17:33:43 +0300
MIME-Version: 1.0
In-Reply-To: <20151116165100.GE6556@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, linux-arm-kernel@lists.infradead.org



On 11/16/2015 07:51 PM, Catalin Marinas wrote:
> On Mon, Nov 16, 2015 at 06:34:27PM +0300, Andrey Ryabinin wrote:
>> On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
>>> On 13/10/15 09:34, Catalin Marinas wrote:
>>>> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
>>>>> Andrey Ryabinin (3):
>>>>>    arm64: move PGD_SIZE definition to pgalloc.h
>>>>>    arm64: add KASAN support
>>>>>    Documentation/features/KASAN: arm64 supports KASAN now
>>>>>
>>>>> Linus Walleij (1):
>>>>>    ARM64: kasan: print memory assignment
>>>>
>>>> Patches queued for 4.4. Thanks.
>>>
>>> I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-rc1:
>>>
>>> arch/arm64/mm/kasan_init.c: In function a??kasan_early_inita??:
>>> include/linux/compiler.h:484:38: error: call to a??__compiletime_assert_95a?? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
>>>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>>>                                       ^
>>> include/linux/compiler.h:467:4: note: in definition of macro a??__compiletime_asserta??
>>>     prefix ## suffix();    \
>>>     ^
>>> include/linux/compiler.h:484:2: note: in expansion of macro a??_compiletime_asserta??
>>>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>>>   ^
>>> include/linux/bug.h:50:37: note: in expansion of macro a??compiletime_asserta??
>>>  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>>>                                      ^
>>> include/linux/bug.h:74:2: note: in expansion of macro a??BUILD_BUG_ON_MSGa??
>>>   BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
>>>   ^
>>> arch/arm64/mm/kasan_init.c:95:2: note: in expansion of macro a??BUILD_BUG_ONa??
>>>   BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
>>>
>>> The problem is that the PGDIR_SIZE is (1UL << 47) with 16K+48bit, which makes
>>> the KASAN_SHADOW_END unaligned(which is aligned to (1UL << (48 - 3)) ). Is the
>>> alignment really needed ? Thoughts on how best we could fix this ?
>>
>> Yes, it's really needed, because some code relies on this (e.g.
>> clear_pgs() and kasan_init()). But it should be possible to get rid of
>> this requirement.
> 
> I don't think clear_pgds() and kasan_init() are the only problems. IIUC,
> kasan_populate_zero_shadow() also assumes that KASan shadow covers
> multiple pgds. You need some kind of recursive writing which avoids
> populating an entry which is not empty (like kasan_early_pud_populate).
> 

I think kasan_populate_zero_shadow() should be fine. We call pgd_populate() only
if address range covers the entire pgd:

		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
....
			pgd_populate(&init_mm, pgd, kasan_zero_pud);
....

and otherwise we check for pgd_none(*pgd):
		if (pgd_none(*pgd)) {
			pgd_populate(&init_mm, pgd,
				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
		}


Is there any way to run 16K pages on emulated environment?
I've tried:
 - ARM V8 Foundation Platformr0p0 (platform build 9.4.59)
 - QEMU 2.4.0
and both just doesn't boot for me on 4.4-rc1 with 16k pages config.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
