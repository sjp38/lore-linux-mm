Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4107F6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:51:07 -0500 (EST)
Received: by padhx2 with SMTP id hx2so180294937pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:51:07 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id zo6si51578263pbc.29.2015.11.16.08.51.06
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 08:51:06 -0800 (PST)
Date: Mon, 16 Nov 2015 16:51:00 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
Message-ID: <20151116165100.GE6556@e104818-lin.cambridge.arm.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com>
 <5649F783.40109@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5649F783.40109@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, linux-arm-kernel@lists.infradead.org

On Mon, Nov 16, 2015 at 06:34:27PM +0300, Andrey Ryabinin wrote:
> On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
> > On 13/10/15 09:34, Catalin Marinas wrote:
> >> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
> >>> Andrey Ryabinin (3):
> >>>    arm64: move PGD_SIZE definition to pgalloc.h
> >>>    arm64: add KASAN support
> >>>    Documentation/features/KASAN: arm64 supports KASAN now
> >>>
> >>> Linus Walleij (1):
> >>>    ARM64: kasan: print memory assignment
> >>
> >> Patches queued for 4.4. Thanks.
> > 
> > I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-rc1:
> > 
> > arch/arm64/mm/kasan_init.c: In function a??kasan_early_inita??:
> > include/linux/compiler.h:484:38: error: call to a??__compiletime_assert_95a?? declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE)
> >   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> >                                       ^
> > include/linux/compiler.h:467:4: note: in definition of macro a??__compiletime_asserta??
> >     prefix ## suffix();    \
> >     ^
> > include/linux/compiler.h:484:2: note: in expansion of macro a??_compiletime_asserta??
> >   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
> >   ^
> > include/linux/bug.h:50:37: note: in expansion of macro a??compiletime_asserta??
> >  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
> >                                      ^
> > include/linux/bug.h:74:2: note: in expansion of macro a??BUILD_BUG_ON_MSGa??
> >   BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
> >   ^
> > arch/arm64/mm/kasan_init.c:95:2: note: in expansion of macro a??BUILD_BUG_ONa??
> >   BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
> > 
> > The problem is that the PGDIR_SIZE is (1UL << 47) with 16K+48bit, which makes
> > the KASAN_SHADOW_END unaligned(which is aligned to (1UL << (48 - 3)) ). Is the
> > alignment really needed ? Thoughts on how best we could fix this ?
> 
> Yes, it's really needed, because some code relies on this (e.g.
> clear_pgs() and kasan_init()). But it should be possible to get rid of
> this requirement.

I don't think clear_pgds() and kasan_init() are the only problems. IIUC,
kasan_populate_zero_shadow() also assumes that KASan shadow covers
multiple pgds. You need some kind of recursive writing which avoids
populating an entry which is not empty (like kasan_early_pud_populate).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
