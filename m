Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88DA46B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 07:34:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t4-v6so927521plo.9
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 04:34:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id e39-v6si6860010plg.335.2018.04.05.04.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 04:34:58 -0700 (PDT)
Date: Thu, 5 Apr 2018 04:34:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 2/5] arm: arm64: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
Message-ID: <20180405113444.GB2647@bombadil.infradead.org>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
 <1522915478-5044-3-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522915478-5044-3-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

On Thu, Apr 05, 2018 at 01:04:35AM -0700, Jia He wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But there is
> still some room for improvement. E.g. if pfn and pfn+1 are in the same
> memblock region, we can simply pfn++ instead of doing the binary search
> in memblock_next_valid_pfn.

Sure, but I bet if we are >end_pfn, we're almost certainly going to the
start_pfn of the next block, so why not test that as well?

> +	/* fast path, return pfn+1 if next pfn is in the same region */
> +	if (early_region_idx != -1) {
> +		start_pfn = PFN_DOWN(regions[early_region_idx].base);
> +		end_pfn = PFN_DOWN(regions[early_region_idx].base +
> +				regions[early_region_idx].size);
> +
> +		if (pfn >= start_pfn && pfn < end_pfn)
> +			return pfn;

		early_region_idx++;
		start_pfn = PFN_DOWN(regions[early_region_idx].base);
		if (pfn >= end_pfn && pfn <= start_pfn)
			return start_pfn;
> +	}
