Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF13B6B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 12:24:29 -0500 (EST)
Received: by padhx2 with SMTP id hx2so50869707pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:24:29 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id tz9si5473618pac.197.2015.11.18.09.24.28
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 09:24:28 -0800 (PST)
Date: Wed, 18 Nov 2015 17:24:23 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
Message-ID: <20151118172422.GA5799@e104818-lin.cambridge.arm.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com>
 <5649F783.40109@gmail.com>
 <20151116165100.GE6556@e104818-lin.cambridge.arm.com>
 <564C8C47.1080904@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <564C8C47.1080904@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Alexey Klimov <klimov.linux@gmail.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 18, 2015 at 05:33:43PM +0300, Andrey Ryabinin wrote:
> On 11/16/2015 07:51 PM, Catalin Marinas wrote:
> > On Mon, Nov 16, 2015 at 06:34:27PM +0300, Andrey Ryabinin wrote:
> >> On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
> >>> arch/arm64/mm/kasan_init.c:95:2: note: in expansion of macro a??BUILD_BUG_ONa??
> >>>   BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
> >>>
> >>> The problem is that the PGDIR_SIZE is (1UL << 47) with 16K+48bit, which makes
> >>> the KASAN_SHADOW_END unaligned(which is aligned to (1UL << (48 - 3)) ). Is the
> >>> alignment really needed ? Thoughts on how best we could fix this ?
> >>
> >> Yes, it's really needed, because some code relies on this (e.g.
> >> clear_pgs() and kasan_init()). But it should be possible to get rid of
> >> this requirement.
> > 
> > I don't think clear_pgds() and kasan_init() are the only problems. IIUC,
> > kasan_populate_zero_shadow() also assumes that KASan shadow covers
> > multiple pgds. You need some kind of recursive writing which avoids
> > populating an entry which is not empty (like kasan_early_pud_populate).
> 
> I think kasan_populate_zero_shadow() should be fine. We call pgd_populate() only
> if address range covers the entire pgd:
> 
> 		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
> ....
> 			pgd_populate(&init_mm, pgd, kasan_zero_pud);
> ....
> 
> and otherwise we check for pgd_none(*pgd):
> 		if (pgd_none(*pgd)) {
> 			pgd_populate(&init_mm, pgd,
> 				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
> 		}

OK, I missed the fact that zero_pud_populate() handles the pmd/pte
population with kasan_zero_*.

So if it's only tmp_pg_dir, as you said already, you can add a tmp_pud
for the case where KASAN_SHADOW_SIZE is smaller than PGDIR_SIZE and
change clear_pgds() to erase the puds.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
