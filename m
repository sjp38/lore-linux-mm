Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D37A6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 21:38:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t78-v6so5962859pfa.8
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 18:38:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2-v6sor2104974pfh.88.2018.07.05.18.38.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 18:38:48 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: Re: [PATCH v9 2/6] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm/arm64
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <1530239363-2356-3-git-send-email-hejianet@gmail.com>
 <CAGM2reZ3zYdrYBEGTdy+LLm_HPREyqYeUqqQnU1GCPd3k98z3Q@mail.gmail.com>
Message-ID: <f3de1c65-c706-710f-4088-48f4b711bac5@gmail.com>
Date: Fri, 6 Jul 2018 09:38:29 +0800
MIME-Version: 1.0
In-Reply-To: <CAGM2reZ3zYdrYBEGTdy+LLm_HPREyqYeUqqQnU1GCPd3k98z3Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, ard.biesheuvel@linaro.org, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, pombredanne@nexb.com, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, ptesarik@suse.com, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com


Hi Pavel, sorry for the late reply

On 6/30/2018 1:07 AM, Pavel Tatashin Wrote:
> On Thu, Jun 28, 2018 at 10:30 PM Jia He <hejianet@gmail.com> wrote:
>>
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But it causes
>> possible panic bug. So Daniel Vacek reverted it later.
>>
>> But as suggested by Daniel Vacek, it is fine to using memblock to skip
>> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
>>
>> On arm and arm64, memblock is used by default. But generic version of
>> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
>> not always return the next valid one but skips more resulting in some
>> valid frames to be skipped (as if they were invalid). And that's why
>> kernel was eventually crashing on some !arm machines.
> 
> Hi Jia,
> 
> Is this a bug? Should we make other arches that support memblock to
> use memblock_is_map_memory() ? it is more expensive, but if the
> default is broken, maybe it makes sense to change?
> 
IIUC, the bug is in memblock_next_valid_pfn instead of pfn_valid.
memblock_next_valid_pfn will return the incorrect next valid pfn on
!arm arches (e.g. X86). Please refer to b92df1de5.

Currently only arm/arm64 use MEMBLOCK_NOMAP, it is really beyond my
power to implement it on all other arches ;-)


-- 
Cheers,
Jia
