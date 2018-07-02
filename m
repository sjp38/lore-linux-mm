Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2B036B0010
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 07:40:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id v19-v6so5600036eds.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:40:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e26-v6si3513015edq.87.2018.07.02.04.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 04:40:39 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:40:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
Message-ID: <20180702114037.GJ19043@dhcp22.suse.cz>
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com

On Fri 29-06-18 10:29:17, Jia He wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") tried to optimize the loop in memmap_init_zone(). But
> there is still some room for improvement.

It would be great to shortly describe those optimization from high level
POV.

> 
> Patch 1 introduce new config to make codes more generic
> Patch 2 remain the memblock_next_valid_pfn on arm and arm64
> Patch 3 optimizes the memblock_next_valid_pfn()
> Patch 4~6 optimizes the early_pfn_valid()
> 
> As for the performance improvement, after this set, I can see the time
> overhead of memmap_init() is reduced from 27956us to 13537us in my
> armv8a server(QDF2400 with 96G memory, pagesize 64k).

So this is 13ms saving when booting 96G machine. Is this really worth
the additional code? Are there any other benefits?
[...]
>  arch/arm/Kconfig          |  4 +++
>  arch/arm/mm/init.c        |  1 +
>  arch/arm64/Kconfig        |  4 +++
>  arch/arm64/mm/init.c      |  1 +
>  include/linux/early_pfn.h | 79 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/memblock.h  |  2 ++
>  include/linux/mmzone.h    | 18 ++++++++++-
>  mm/Kconfig                |  3 ++
>  mm/memblock.c             |  9 ++++++
>  mm/page_alloc.c           |  5 ++-
>  10 files changed, 124 insertions(+), 2 deletions(-)
>  create mode 100644 include/linux/early_pfn.h

-- 
Michal Hocko
SUSE Labs
