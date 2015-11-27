Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id CF8CD6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 05:39:09 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so29305614igc.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:39:09 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id f127si1647337ioe.59.2015.11.27.02.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 02:39:09 -0800 (PST)
Received: by igcph11 with SMTP id ph11so25093398igc.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:39:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151127100210.GB25781@arm.com>
References: <1448543686-31869-1-git-send-email-aryabinin@virtuozzo.com>
	<CAKv+Gu_L1shTWp_5KydCW97Z6TbeXEB9gjmb2oUSuCHfC29M9A@mail.gmail.com>
	<5658106C.10207@virtuozzo.com>
	<20151127093529.GX3109@e104818-lin.cambridge.arm.com>
	<20151127100210.GB25781@arm.com>
Date: Fri, 27 Nov 2015 11:39:09 +0100
Message-ID: <CAKv+Gu9109GjRqdVZBKckuEkj261gzW=RQGXHjP19TXDAC_cBw@mail.gmail.com>
Subject: Re: [PATCH RFT] arm64: kasan: Make KASAN work with 16K pages + 48 bit VA
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 27 November 2015 at 11:02, Will Deacon <will.deacon@arm.com> wrote:
> On Fri, Nov 27, 2015 at 09:35:29AM +0000, Catalin Marinas wrote:
>> On Fri, Nov 27, 2015 at 11:12:28AM +0300, Andrey Ryabinin wrote:
>> > On 11/26/2015 07:40 PM, Ard Biesheuvel wrote:
>> > > On 26 November 2015 at 14:14, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> > >> Currently kasan assumes that shadow memory covers one or more entire PGDs.
>> > >> That's not true for 16K pages + 48bit VA space, where PGDIR_SIZE is bigger
>> > >> than the whole shadow memory.
>> > >>
>> > >> This patch tries to fix that case.
>> > >> clear_page_tables() is a new replacement of clear_pgs(). Instead of always
>> > >> clearing pgds it clears top level page table entries that entirely belongs
>> > >> to shadow memory.
>> > >> In addition to 'tmp_pg_dir' we now have 'tmp_pud' which is used to store
>> > >> puds that now might be cleared by clear_page_tables.
>> > >>
>> > >> Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
>> > >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> > >
>> > > I would argue that the Kasan code is complicated enough, and we should
>> > > avoid complicating it even further for a configuration that is highly
>> > > theoretical in nature.
>> > >
>> > > In a 16k configuration, the 4th level only adds a single bit of VA
>> > > space (which is, as I understand it, exactly the issue you need to
>> > > address here since the top level page table has only 2 entries and
>> > > hence does not divide by 8 cleanly), which means you are better off
>> > > using 3 levels unless you *really* need more than 128 TB of VA space.
>> > >
>> > > So can't we just live with the limitation, and keep the current code?
>> >
>> > No objections from my side. Let's keep the current code.
>>
>> Ard had a good point, so fine by me as well.
>
> Ok, so obvious follow-up question: why do we even support 48-bit + 16k
> pages in the kernel? Either it's useful, and we make things work with it,
> or it's not and we can drop it (or, at least, hide it behind EXPERT like
> we do for 36-bit).
>

So there's 10 kinds of features in the world, useful ones and !useful ones? :-)

I think 48-bit/16k is somewhat useful, and I think we should support
it. But I also think we should be pragmatic, and not go out of our way
to support the combinatorial expansion of all niche features enabled
together. I think it is perfectly fine to limit kasan support to
configurations whose top level translation table divides by 8 cleanly
(which only excludes 16k/48-bit anyway)

However, I think it deserves being hidden behind CONFIG_EXPERT more
than 36-bit/16k does.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
