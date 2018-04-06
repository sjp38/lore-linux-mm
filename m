Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1267D6B000E
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 06:23:20 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id g35-v6so339238otd.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 03:23:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 98-v6sor4513008otv.326.2018.04.06.03.23.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 03:23:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180406090920.GM16141@n2100.armlinux.org.uk>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
 <1522915478-5044-3-git-send-email-hejianet@gmail.com> <20180405113444.GB2647@bombadil.infradead.org>
 <1f809296-e88d-1090-0027-890782b91d6e@gmail.com> <20180405125054.GC2647@bombadil.infradead.org>
 <20180406090920.GM16141@n2100.armlinux.org.uk>
From: Daniel Vacek <neelx@redhat.com>
Date: Fri, 6 Apr 2018 12:23:17 +0200
Message-ID: <CACjP9X_pfM7pUCHVXvFk_5HQPufF0pF-wr1V92J+8AnS8qxePA@mail.gmail.com>
Subject: Re: [PATCH v7 2/5] arm: arm64: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, Jia He <hejianet@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On Fri, Apr 6, 2018 at 11:09 AM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> On Thu, Apr 05, 2018 at 05:50:54AM -0700, Matthew Wilcox wrote:
>> On Thu, Apr 05, 2018 at 08:44:12PM +0800, Jia He wrote:
>> >
>> >
>> > On 4/5/2018 7:34 PM, Matthew Wilcox Wrote:
>> > > On Thu, Apr 05, 2018 at 01:04:35AM -0700, Jia He wrote:
>> > > > Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> > > > where possible") optimized the loop in memmap_init_zone(). But there is
>> > > > still some room for improvement. E.g. if pfn and pfn+1 are in the same
>> > > > memblock region, we can simply pfn++ instead of doing the binary search
>> > > > in memblock_next_valid_pfn.
>> > > Sure, but I bet if we are >end_pfn, we're almost certainly going to the
>> > > start_pfn of the next block, so why not test that as well?
>> > >
>> > > > +       /* fast path, return pfn+1 if next pfn is in the same region */
>> > > > +       if (early_region_idx != -1) {
>> > > > +               start_pfn = PFN_DOWN(regions[early_region_idx].base);
>> > > > +               end_pfn = PFN_DOWN(regions[early_region_idx].base +
>> > > > +                               regions[early_region_idx].size);
>> > > > +
>> > > > +               if (pfn >= start_pfn && pfn < end_pfn)
>> > > > +                       return pfn;
>> > >           early_region_idx++;
>> > >           start_pfn = PFN_DOWN(regions[early_region_idx].base);
>> > >           if (pfn >= end_pfn && pfn <= start_pfn)
>> > >                   return start_pfn;
>> > Thanks, thus the binary search in next step can be discarded?
>>
>> I don't know all the circumstances in which this is called.  Maybe a linear
>> search with memo is more appropriate than a binary search.

This is actually a good point.

> That's been brought up before, and the reasoning appears to be
> something along the lines of...
>
> Academics and published wisdom is that on cached architectures, binary
> searches are bad because it doesn't operate efficiently due to the
> overhead from having to load cache lines.  Consequently, there seems
> to be a knee-jerk reaction that "all binary searches are bad, we must
> eliminate them."

a) This does not make sense. At least in general case.
b) It is not the case here. Here it's really mostly called with
sequentially incremented pfns, AFAICT.

> What is failed to be grasped here, though, is that it is typical that
> the number of entries in this array tend to be small, so the entire
> array takes up one or two cache lines, maybe a maximum of four lines
> depending on your cache line length and number of entries.
>
> This means that the binary search expense is reduced, and is lower
> than a linear search for the majority of cases.

In this case it hits mostly the last result or eventually the
sequentially next one.

> What is key here as far as performance is concerned is whether the
> general usage of pfn_valid() by the kernel is optimal.  We should
> not optimise only for the boot case, which means evaluating the
> effect of these changes with _real_ workloads, not just "does my
> machine boot a milliseconds faster".

IIUC, this is only used during early boot (and memory hotplug) and it
does not influence regular runtime. Whether the general usage of
pfn_valid() by the kernel is optimal is another good question, but
that's totally unrelated to this series, IMHO.

On the other hand I also wonder if this all really is worth the
negligible boot time speedup.

--nX

> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
> According to speedtest.net: 8.21Mbps down 510kbps up
