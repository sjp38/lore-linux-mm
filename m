Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0356B0024
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:28:44 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id v8so4236439iob.0
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 05:28:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p133-v6sor1863245ite.42.2018.03.21.05.28.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 05:28:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: page_alloc: reduce unnecessary binary search in
 memblock_next_valid_pfn()
References: <1521619796-3846-1-git-send-email-hejianet@gmail.com>
 <1521619796-3846-2-git-send-email-hejianet@gmail.com>
 <CACjP9X92M3izDD-1s1vY6n6Hx3mxqNqeM4f+T3RNnBo8kjP4Qg@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <3f208ebe-572f-f2f6-003e-5a9cf49bb92f@gmail.com>
Date: Wed, 21 Mar 2018 20:28:18 +0800
MIME-Version: 1.0
In-Reply-To: <CACjP9X92M3izDD-1s1vY6n6Hx3mxqNqeM4f+T3RNnBo8kjP4Qg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>



On 3/21/2018 6:14 PM, Daniel Vacek Wrote:
> On Wed, Mar 21, 2018 at 9:09 AM, Jia He <hejianet@gmail.com> wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But there is
>> still some room for improvement. E.g. if pfn and pfn+1 are in the same
>> memblock region, we can simply pfn++ instead of doing the binary search
>> in memblock_next_valid_pfn.
> There is a revert-mm-page_alloc-skip-over-regions-of-invalid-pfns-where-possible.patch
> in -mm reverting b92df1de5d289c0b as it is fundamentally wrong by
> design causing system panics on some machines with rare but still
> valid mappings. Basically it skips valid pfns which are outside of
> usable memory ranges (outside of memblock memory regions).
Thanks for the infomation.
quote from you patch description:
 >But given some specific memory mapping on x86_64 (or more generally 
theoretically anywhere but on arm with CONFIG_HAVE_ARCH_PFN_VALID) > the 
implementation also skips valid pfns which is plain wrong and causes > 
'kernel BUG at mm/page_alloc.c:1389!'

Do you think memblock_next_valid_pfn can remain to be not reverted on 
arm64 with CONFIG_HAVE_ARCH_PFN_VALID? Arm64 can benifit from this 
optimization.

Cheers,
Jia
