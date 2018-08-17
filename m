Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9AAD6B05A4
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 21:38:19 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id s12-v6so1851847ybm.19
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:38:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d193-v6sor241397ybc.98.2018.08.16.18.38.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 18:38:19 -0700 (PDT)
Subject: Re: [RESEND PATCH v10 6/6] mm: page_alloc: reduce unnecessary binary
 search in early_pfn_valid()
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-7-git-send-email-hejianet@gmail.com>
 <c6ed43ee-b09e-1f75-43b3-6cd2808d13f3@microsoft.com>
From: Pavel Tatashin <pasha.tatashin@gmail.com>
Message-ID: <831be9a1-6401-3af0-b68b-b3e25db806f9@gmail.com>
Date: Thu, 16 Aug 2018 21:38:15 -0400
MIME-Version: 1.0
In-Reply-To: <c6ed43ee-b09e-1f75-43b3-6cd2808d13f3@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, pavel.tatashin@microsoft.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>



On 8/16/18 9:35 PM, Pasha Tatashin wrote:
> 
> 
> On 7/6/18 5:01 AM, Jia He wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But there is
>> still some room for improvement. E.g. in early_pfn_valid(), if pfn and
>> pfn+1 are in the same memblock region, we can record the last returned
>> memblock region index and check whether pfn++ is still in the same
>> region.
>>
>> Currently it only improve the performance on arm/arm64 and will have no
>> impact on other arches.
>>
>> For the performance improvement, after this set, I can see the time
>> overhead of memmap_init() is reduced from 27956us to 13537us in my
>> armv8a server(QDF2400 with 96G memory, pagesize 64k).
> 
> This series would be a lot simpler if patches 4, 5, and 6 were dropped.
> The extra complexity does not make sense to save 0.0001s/T during not.
s/not/boot

> 
> Patches 1-3, look OK, but without patches 4-5 __init_memblock should be
> made local static as I suggested earlier.
s/__init_memblock/early_region_idx
