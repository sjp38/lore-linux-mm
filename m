Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id AC06E6B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:33:57 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so90973106lbb.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:33:57 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id g39si26589143lfi.77.2015.11.16.07.33.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 07:33:56 -0800 (PST)
Received: by lffu14 with SMTP id u14so88983040lff.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:33:55 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <5649F783.40109@gmail.com>
Date: Mon, 16 Nov 2015 18:34:27 +0300
MIME-Version: 1.0
In-Reply-To: <5649BAFD.6030005@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
> On 13/10/15 09:34, Catalin Marinas wrote:
>> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
>>> Andrey Ryabinin (3):
>>>    arm64: move PGD_SIZE definition to pgalloc.h
>>>    arm64: add KASAN support
>>>    Documentation/features/KASAN: arm64 supports KASAN now
>>>
>>> Linus Walleij (1):
>>>    ARM64: kasan: print memory assignment
>>
>> Patches queued for 4.4. Thanks.
>>
> 
> Hi,
> 
> I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-rc1:
> 
> 
> arch/arm64/mm/kasan_init.c: In function ?kasan_early_init?:
> include/linux/compiler.h:484:38: error: call to ?__compiletime_assert_95? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>                                       ^
> include/linux/compiler.h:467:4: note: in definition of macro ?__compiletime_assert?
>     prefix ## suffix();    \
>     ^
> include/linux/compiler.h:484:2: note: in expansion of macro ?_compiletime_assert?
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>   ^
> include/linux/bug.h:50:37: note: in expansion of macro ?compiletime_assert?
>  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                      ^
> include/linux/bug.h:74:2: note: in expansion of macro ?BUILD_BUG_ON_MSG?
>   BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
>   ^
> arch/arm64/mm/kasan_init.c:95:2: note: in expansion of macro ?BUILD_BUG_ON?
>   BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
> 
> 
> ---
> 
> The problem is that the PGDIR_SIZE is (1UL << 47) with 16K+48bit, which makes
> the KASAN_SHADOW_END unaligned(which is aligned to (1UL << (48 - 3)) ). Is the
> alignment really needed ? Thoughts on how best we could fix this ?
> 

Yes, it's really needed, because some code relies on this (e.g.  clear_pgs() and kasan_init()).
But it should be possible to get rid of this requirement.

At first we need to rework clear_pgs().
The purpose of clear_pgs() is to remove kasan shadow from swapper_pg_dir.
So clear_pgs() should clear the top most kasan_zero_* entries from page tables.
Previously it was enough to clear PGDs, in case of 16K_PAGES + 48BIT_VA we probably need to clear PMDs


We also have to change following part of kasan_init()
...
	/*
	 * We are going to perform proper setup of shadow memory.
	 * At first we should unmap early shadow (clear_pgds() call bellow).
	 * However, instrumented code couldn't execute without shadow memory.
	 * tmp_pg_dir used to keep early shadow mapped until full shadow
	 * setup will be finished.
	 */
	memcpy(tmp_pg_dir, swapper_pg_dir, sizeof(tmp_pg_dir));


Besides tmp_pg_dir we will need one more temporary page table to store those entries
which later will be removed from swapper_pg_dir by clear_pgds().



> Cheers
> Suzuki
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
