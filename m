Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1793E6B0003
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:52:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m130so774211wma.1
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 05:52:18 -0700 (PDT)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id 65si4637245wrp.37.2018.03.22.05.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 05:52:14 -0700 (PDT)
Date: Thu, 22 Mar 2018 13:52:04 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH 1/4] mm: page_alloc: reduce unnecessary binary search in
 memblock_next_valid_pfn()
Message-ID: <20180322125204.GA8892@vmlxhi-102.adit-jv.com>
References: <1521619796-3846-1-git-send-email-hejianet@gmail.com>
 <1521619796-3846-2-git-send-email-hejianet@gmail.com>
 <CACjP9X92M3izDD-1s1vY6n6Hx3mxqNqeM4f+T3RNnBo8kjP4Qg@mail.gmail.com>
 <3f208ebe-572f-f2f6-003e-5a9cf49bb92f@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <3f208ebe-572f-f2f6-003e-5a9cf49bb92f@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Daniel Vacek <neelx@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>, Eugeniu Rosca <erosca@de.adit-jv.com>

On Wed, Mar 21, 2018 at 08:28:18PM +0800, Jia He wrote:
> 
> 
> On 3/21/2018 6:14 PM, Daniel Vacek Wrote:
> >On Wed, Mar 21, 2018 at 9:09 AM, Jia He <hejianet@gmail.com> wrote:
> >>Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> >>where possible") optimized the loop in memmap_init_zone(). But there is
> >>still some room for improvement. E.g. if pfn and pfn+1 are in the same
> >>memblock region, we can simply pfn++ instead of doing the binary search
> >>in memblock_next_valid_pfn.
> >There is a revert-mm-page_alloc-skip-over-regions-of-invalid-pfns-where-possible.patch
> >in -mm reverting b92df1de5d289c0b as it is fundamentally wrong by
> >design causing system panics on some machines with rare but still
> >valid mappings. Basically it skips valid pfns which are outside of
> >usable memory ranges (outside of memblock memory regions).
> Thanks for the infomation.
> quote from you patch description:
> >But given some specific memory mapping on x86_64 (or more generally
> theoretically anywhere but on arm with CONFIG_HAVE_ARCH_PFN_VALID) > the
> implementation also skips valid pfns which is plain wrong and causes >
> 'kernel BUG at mm/page_alloc.c:1389!'
> 
> Do you think memblock_next_valid_pfn can remain to be not reverted on arm64
> with CONFIG_HAVE_ARCH_PFN_VALID? Arm64 can benifit from this optimization.

I confirm that the boot time of Rcar-H3 arm64 platform greatly
benefits from v4.11-rc1 commit b92df1de5d28 ("mm: page_alloc: skip over
regions of invalid pfns where possible"). The startup improvement is
roughly ~140ms, which will be lost if the mentioned commit is reverted.

For more details on my measurements, please see linux-next commit
283f1645e236 ("mm: page_alloc: skip over regions of invalid pfns on
UMA").

Whichever way you decide to go forward (reimplement/fix b92df1de5d28
or create an <arch>_next_valid_pfn), I am willing to participate in
testing your proposals on RCAR SoCs. TIA.

Thanks,
Eugeniu.
