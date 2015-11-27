Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id A6A8D6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 03:12:20 -0500 (EST)
Received: by lffu14 with SMTP id u14so120857704lff.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:12:19 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l20si20815556lfi.69.2015.11.27.00.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 00:12:18 -0800 (PST)
Subject: Re: [PATCH RFT] arm64: kasan: Make KASAN work with 16K pages + 48 bit
 VA
References: <1448543686-31869-1-git-send-email-aryabinin@virtuozzo.com>
 <CAKv+Gu_L1shTWp_5KydCW97Z6TbeXEB9gjmb2oUSuCHfC29M9A@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5658106C.10207@virtuozzo.com>
Date: Fri, 27 Nov 2015 11:12:28 +0300
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_L1shTWp_5KydCW97Z6TbeXEB9gjmb2oUSuCHfC29M9A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Mark Rutland <mark.rutland@arm.com>

On 11/26/2015 07:40 PM, Ard Biesheuvel wrote:
> On 26 November 2015 at 14:14, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> Currently kasan assumes that shadow memory covers one or more entire PGDs.
>> That's not true for 16K pages + 48bit VA space, where PGDIR_SIZE is bigger
>> than the whole shadow memory.
>>
>> This patch tries to fix that case.
>> clear_page_tables() is a new replacement of clear_pgs(). Instead of always
>> clearing pgds it clears top level page table entries that entirely belongs
>> to shadow memory.
>> In addition to 'tmp_pg_dir' we now have 'tmp_pud' which is used to store
>> puds that now might be cleared by clear_page_tables.
>>
>> Reported-by: Suzuki K. Poulose <Suzuki.Poulose@arm.com>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> I would argue that the Kasan code is complicated enough, and we should
> avoid complicating it even further for a configuration that is highly
> theoretical in nature.
> 
> In a 16k configuration, the 4th level only adds a single bit of VA
> space (which is, as I understand it, exactly the issue you need to
> address here since the top level page table has only 2 entries and
> hence does not divide by 8 cleanly), which means you are better off
> using 3 levels unless you *really* need more than 128 TB of VA space.
> 
> So can't we just live with the limitation, and keep the current code?
 

No objections from my side. Let's keep the current code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
