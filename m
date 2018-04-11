Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9A096B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 00:47:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 61-v6so464888plz.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 21:47:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7-v6sor39168pls.24.2018.04.10.21.47.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 21:47:32 -0700 (PDT)
Subject: Re: [PATCH v5 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm and arm64
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com>
 <1522636236-12625-2-git-send-email-hejianet@gmail.com>
 <CAKv+Gu96_sC1Q6-w4O-AXFZzNnH1WoGwJfqvSR+Q_k_bZbrUGg@mail.gmail.com>
 <41445229-043c-976f-3961-13770163444f@gmail.com>
 <CAKv+Gu_CwWnW15jyTCY55akAikEjbgK4zRq_9=YuSDot3O3dQg@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <4577f3be-1183-c857-6933-ca182fb34a2f@gmail.com>
Date: Wed, 11 Apr 2018 12:47:18 +0800
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_CwWnW15jyTCY55akAikEjbgK4zRq_9=YuSDot3O3dQg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>



On 4/2/2018 3:53 PM, Ard Biesheuvel Wrote:
> On 2 April 2018 at 09:49, Jia He <hejianet@gmail.com> wrote:
>>
>> On 4/2/2018 2:55 PM, Ard Biesheuvel Wrote:
>>> On 2 April 2018 at 04:30, Jia He <hejianet@gmail.com> wrote:
>>>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>>>> where possible") optimized the loop in memmap_init_zone(). But it causes
>>>> possible panic bug. So Daniel Vacek reverted it later.
>>>>
>>>> But as suggested by Daniel Vacek, it is fine to using memblock to skip
>>>> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
>>>>
>>>> On arm and arm64, memblock is used by default. But generic version of
>>>> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
>>>> not always return the next valid one but skips more resulting in some
>>>> valid frames to be skipped (as if they were invalid). And that's why
>>>> kernel was eventually crashing on some !arm machines.
>>>>
>>>> And as verified by Eugeniu Rosca, arm can benifit from commit
>>>> b92df1de5d28. So remain the memblock_next_valid_pfn on arm{,64} and move
>>>> the related codes to arm64 arch directory.
>>>>
>>>> Suggested-by: Daniel Vacek <neelx@redhat.com>
>>>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>>> Hello Jia,
>>>
>>> Apologies for chiming in late.
>> no problem, thanks for your comments  ;-)
>>>
>>> If we are going to rearchitect this, I'd rather we change the loop in
>>> memmap_init_zone() so that we skip to the next valid PFN directly
>>> rather than skipping to the last invalid PFN so that the pfn++ in the
>> hmm... Maybe this macro name makes you confused
>>
>> pfn = skip_to_last_invalid_pfn(pfn);
>>
>> how about skip_to_next_valid_pfn?
>>
>>> for () results in the next value. Can we replace the pfn++ there with
>>> a function calls that defaults to 'return pfn + 1', but does the skip
>>> for architectures that implement it?
>> I am not sure I understand your question here.
>> With this patch, on !arm arches, skip_to_last_invalid_pfn is equal to (pfn),
>> and will be increased
>> when for{} loop continue. We only *skip* to the start pfn of next valid
>> region when
>> CONFIG_HAVE_MEMBLOCK and CONFIG_HAVE_ARCH_PFN_VALID(arm/arm64 supports
>> both).
>>
> What I am saying is that the loop in memmap_init_zone
>
> for (pfn = start_pfn; pfn < end_pfn; pfn++) { ... }
>
> should be replaced by something like
>
> for (pfn = start_pfn; pfn < end_pfn; pfn = next_valid_pfn(pfn))
After further thinking, IMO, pfn = next_valid_pfn(pfn) might have impact on

memmap_init_zone loop.

e.g.context != MEMMAP_EARLY, pfn will not be checked by early_pfn_valid, thus
It will change the memhotplug logic.

So I would choose the old implementation:
		if (!early_pfn_valid(pfn)) {
			pfn = next_valid_pfn(pfn) - 1;
			continue;
		}
Any comments? Thanks

-- 
Cheers,
Jia
