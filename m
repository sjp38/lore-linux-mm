Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4111A6B0257
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:35:35 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so113730729pab.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:35:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 18si7400896pfc.4.2015.11.27.01.35.34
        for <linux-mm@kvack.org>;
        Fri, 27 Nov 2015 01:35:34 -0800 (PST)
Date: Fri, 27 Nov 2015 09:35:29 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH RFT] arm64: kasan: Make KASAN work with 16K pages + 48
 bit VA
Message-ID: <20151127093529.GX3109@e104818-lin.cambridge.arm.com>
References: <1448543686-31869-1-git-send-email-aryabinin@virtuozzo.com>
 <CAKv+Gu_L1shTWp_5KydCW97Z6TbeXEB9gjmb2oUSuCHfC29M9A@mail.gmail.com>
 <5658106C.10207@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5658106C.10207@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Nov 27, 2015 at 11:12:28AM +0300, Andrey Ryabinin wrote:
> On 11/26/2015 07:40 PM, Ard Biesheuvel wrote:
> > On 26 November 2015 at 14:14, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> >> Currently kasan assumes that shadow memory covers one or more entire PGDs.
> >> That's not true for 16K pages + 48bit VA space, where PGDIR_SIZE is bigger
> >> than the whole shadow memory.
> >>
> >> This patch tries to fix that case.
> >> clear_page_tables() is a new replacement of clear_pgs(). Instead of always
> >> clearing pgds it clears top level page table entries that entirely belongs
> >> to shadow memory.
> >> In addition to 'tmp_pg_dir' we now have 'tmp_pud' which is used to store
> >> puds that now might be cleared by clear_page_tables.
> >>
> >> Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
> >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > 
> > I would argue that the Kasan code is complicated enough, and we should
> > avoid complicating it even further for a configuration that is highly
> > theoretical in nature.
> > 
> > In a 16k configuration, the 4th level only adds a single bit of VA
> > space (which is, as I understand it, exactly the issue you need to
> > address here since the top level page table has only 2 entries and
> > hence does not divide by 8 cleanly), which means you are better off
> > using 3 levels unless you *really* need more than 128 TB of VA space.
> > 
> > So can't we just live with the limitation, and keep the current code?
> 
> No objections from my side. Let's keep the current code.

Ard had a good point, so fine by me as well.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
