Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C59A6B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 05:10:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x15so468242wmc.7
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 02:10:31 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id v8si4580364wmc.274.2018.04.06.02.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 02:10:28 -0700 (PDT)
Date: Fri, 6 Apr 2018 10:09:20 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v7 2/5] arm: arm64: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
Message-ID: <20180406090920.GM16141@n2100.armlinux.org.uk>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
 <1522915478-5044-3-git-send-email-hejianet@gmail.com>
 <20180405113444.GB2647@bombadil.infradead.org>
 <1f809296-e88d-1090-0027-890782b91d6e@gmail.com>
 <20180405125054.GC2647@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405125054.GC2647@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia He <hejianet@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

On Thu, Apr 05, 2018 at 05:50:54AM -0700, Matthew Wilcox wrote:
> On Thu, Apr 05, 2018 at 08:44:12PM +0800, Jia He wrote:
> > 
> > 
> > On 4/5/2018 7:34 PM, Matthew Wilcox Wrote:
> > > On Thu, Apr 05, 2018 at 01:04:35AM -0700, Jia He wrote:
> > > > Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> > > > where possible") optimized the loop in memmap_init_zone(). But there is
> > > > still some room for improvement. E.g. if pfn and pfn+1 are in the same
> > > > memblock region, we can simply pfn++ instead of doing the binary search
> > > > in memblock_next_valid_pfn.
> > > Sure, but I bet if we are >end_pfn, we're almost certainly going to the
> > > start_pfn of the next block, so why not test that as well?
> > > 
> > > > +	/* fast path, return pfn+1 if next pfn is in the same region */
> > > > +	if (early_region_idx != -1) {
> > > > +		start_pfn = PFN_DOWN(regions[early_region_idx].base);
> > > > +		end_pfn = PFN_DOWN(regions[early_region_idx].base +
> > > > +				regions[early_region_idx].size);
> > > > +
> > > > +		if (pfn >= start_pfn && pfn < end_pfn)
> > > > +			return pfn;
> > > 		early_region_idx++;
> > > 		start_pfn = PFN_DOWN(regions[early_region_idx].base);
> > > 		if (pfn >= end_pfn && pfn <= start_pfn)
> > > 			return start_pfn;
> > Thanks, thus the binary search in next step can be discarded?
> 
> I don't know all the circumstances in which this is called.  Maybe a linear
> search with memo is more appropriate than a binary search.

That's been brought up before, and the reasoning appears to be
something along the lines of...

Academics and published wisdom is that on cached architectures, binary
searches are bad because it doesn't operate efficiently due to the
overhead from having to load cache lines.  Consequently, there seems
to be a knee-jerk reaction that "all binary searches are bad, we must
eliminate them."

What is failed to be grasped here, though, is that it is typical that
the number of entries in this array tend to be small, so the entire
array takes up one or two cache lines, maybe a maximum of four lines
depending on your cache line length and number of entries.

This means that the binary search expense is reduced, and is lower
than a linear search for the majority of cases.

What is key here as far as performance is concerned is whether the
general usage of pfn_valid() by the kernel is optimal.  We should
not optimise only for the boot case, which means evaluating the
effect of these changes with _real_ workloads, not just "does my
machine boot a milliseconds faster".

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
