Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14926B02B1
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 22:11:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e19-v6so242724pgv.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 19:11:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e12-v6sor429pge.244.2018.07.02.19.11.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 19:11:31 -0700 (PDT)
Subject: Re: [PATCH v9 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <20180702114037.GJ19043@dhcp22.suse.cz>
From: Jia He <hejianet@gmail.com>
Message-ID: <779be6bf-db64-9175-f4c0-2baa0ea6defd@gmail.com>
Date: Tue, 3 Jul 2018 10:11:11 +0800
MIME-Version: 1.0
In-Reply-To: <20180702114037.GJ19043@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com



On 7/2/2018 7:40 PM, Michal Hocko Wrote:
> On Fri 29-06-18 10:29:17, Jia He wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") tried to optimize the loop in memmap_init_zone(). But
>> there is still some room for improvement.
> 
> It would be great to shortly describe those optimization from high level
> POV.
> 
>>
>> Patch 1 introduce new config to make codes more generic
>> Patch 2 remain the memblock_next_valid_pfn on arm and arm64
>> Patch 3 optimizes the memblock_next_valid_pfn()
>> Patch 4~6 optimizes the early_pfn_valid()
>>
>> As for the performance improvement, after this set, I can see the time
>> overhead of memmap_init() is reduced from 27956us to 13537us in my
>> armv8a server(QDF2400 with 96G memory, pagesize 64k).
> 
> So this is 13ms saving when booting 96G machine. Is this really worth
> the additional code? Are there any other benefits?
Sorry, Michal
I missed one thing.
This 13ms optimization is merely the result of my patch 3~6
Patch 1 is originated by Paul Burton in commit b92df1de5d289.
In its description,
===
James said "I have tested this patch on a virtual model of a Samurai CPU
    with a sparse memory map.  The kernel boot time drops from 109 to
    62 seconds. "
===

-- 
Cheers,
Jia
> [...]
>>  arch/arm/Kconfig          |  4 +++
>>  arch/arm/mm/init.c        |  1 +
>>  arch/arm64/Kconfig        |  4 +++
>>  arch/arm64/mm/init.c      |  1 +
>>  include/linux/early_pfn.h | 79 +++++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/memblock.h  |  2 ++
>>  include/linux/mmzone.h    | 18 ++++++++++-
>>  mm/Kconfig                |  3 ++
>>  mm/memblock.c             |  9 ++++++
>>  mm/page_alloc.c           |  5 ++-
>>  10 files changed, 124 insertions(+), 2 deletions(-)
>>  create mode 100644 include/linux/early_pfn.h
> 
