Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C23946B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 15:08:33 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d6-v6so2271860plo.15
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 12:08:33 -0700 (PDT)
Received: from 9pmail.ess.barracuda.com (9pmail.ess.barracuda.com. [64.235.154.211])
        by mx.google.com with ESMTPS id o25-v6si3609533pge.7.2018.06.21.12.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 12:08:32 -0700 (PDT)
Date: Thu, 21 Jun 2018 12:07:21 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH] Revert "mm: page_alloc: skip over regions of invalid
 pfns where possible"
Message-ID: <20180621190721.bdr42xmp6f2uba7x@pburton-laptop>
References: <20180316143855.29838-1-neelx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180316143855.29838-1-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, stable@vger.kernel.org

Hi Daniel,

Hmm... I only just noticed this because you CC'd an email address that
is no longer functional. I presume you're not using .mailmap, which
would have given you my current email address.

On Fri, Mar 16, 2018 at 03:38:55PM +0100, Daniel Vacek wrote:
> This reverts commit b92df1de5d289c0b5d653e72414bf0850b8511e0. The commit
> is meant to be a boot init speed up skipping the loop in memmap_init_zone()
> for invalid pfns. But given some specific memory mapping on x86_64 (or more
> generally theoretically anywhere but on arm with CONFIG_HAVE_ARCH_PFN_VALID)

My patch definitely wasn't ARM-specific & I have never tested it on ARM.
It was motivated by a MIPS platform with an extremely sparse memory map.
Could you explain why you think it depends on ARM or
CONFIG_HAVE_ARCH_PFN_VALID?

> the implementation also skips valid pfns which is plain wrong and causes
> 'kernel BUG at mm/page_alloc.c:1389!'

Which VM_BUG_ON is that? I don't see one on line 1389 as of commit
b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where
possible") or any mainline final release since.

> crash> log | grep -e BUG -e RIP -e Call.Trace -e move_freepages_block -e rmqueue -e freelist -A1
> kernel BUG at mm/page_alloc.c:1389!
> invalid opcode: 0000 [#1] SMP
> --
> RIP: 0010:[<ffffffff8118833e>]  [<ffffffff8118833e>] move_freepages+0x15e/0x160
> RSP: 0018:ffff88054d727688  EFLAGS: 00010087
> --
> Call Trace:
>  [<ffffffff811883b3>] move_freepages_block+0x73/0x80
>  [<ffffffff81189e63>] __rmqueue+0x263/0x460
>  [<ffffffff8118c781>] get_page_from_freelist+0x7e1/0x9e0
>  [<ffffffff8118caf6>] __alloc_pages_nodemask+0x176/0x420
> --
> RIP  [<ffffffff8118833e>] move_freepages+0x15e/0x160
>  RSP <ffff88054d727688>
> 
> crash> page_init_bug -v | grep RAM
> <struct resource 0xffff88067fffd2f8>          1000 -        9bfff       System RAM (620.00 KiB)
> <struct resource 0xffff88067fffd3a0>        100000 -     430bffff       System RAM (  1.05 GiB = 1071.75 MiB = 1097472.00 KiB)
> <struct resource 0xffff88067fffd410>      4b0c8000 -     4bf9cfff       System RAM ( 14.83 MiB = 15188.00 KiB)
> <struct resource 0xffff88067fffd480>      4bfac000 -     646b1fff       System RAM (391.02 MiB = 400408.00 KiB)
> <struct resource 0xffff88067fffd560>      7b788000 -     7b7fffff       System RAM (480.00 KiB)
> <struct resource 0xffff88067fffd640>     100000000 -    67fffffff       System RAM ( 22.00 GiB)
> 
> crash> page_init_bug | head -6
> <struct resource 0xffff88067fffd560>      7b788000 -     7b7fffff       System RAM (480.00 KiB)
> <struct page 0xffffea0001ede200>   1fffff00000000  0 <struct pglist_data 0xffff88047ffd9000> 1 <struct zone 0xffff88047ffd9800> DMA32          4096    1048575
> <struct page 0xffffea0001ede200> 505736 505344 <struct page 0xffffea0001ed8000> 505855 <struct page 0xffffea0001edffc0>
> <struct page 0xffffea0001ed8000>                0  0 <struct pglist_data 0xffff88047ffd9000> 0 <struct zone 0xffff88047ffd9000> DMA               1       4095
> <struct page 0xffffea0001edffc0>   1fffff00000400  0 <struct pglist_data 0xffff88047ffd9000> 1 <struct zone 0xffff88047ffd9800> DMA32          4096    1048575
> BUG, zones differ!
> 
> crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b787000 7b788000
>       PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
> ffffea0001e00000  78000000                0        0  0 0
> ffffea0001ed7fc0  7b5ff000                0        0  0 0
> ffffea0001ed8000  7b600000                0        0  0 0       <<<<
> ffffea0001ede1c0  7b787000                0        0  0 0
> ffffea0001ede200  7b788000                0        0  1 1fffff00000000

I'm not really sure what I'm looking at here. I presume you're saying
that memmap_init_zone() didn't initialize the struct page for
phys=0x7b788000?

Could you describe the memblock region list, and what ranges
memmap_init_zone() skipped over?

Thanks,
    Paul
