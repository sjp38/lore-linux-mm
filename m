Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A08D96B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 05:16:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j69so4618838itb.2
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 02:16:31 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0053.outbound.protection.outlook.com. [104.47.33.53])
        by mx.google.com with ESMTPS id 24si17006571ioi.95.2016.10.06.02.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 02:16:30 -0700 (PDT)
Date: Thu, 6 Oct 2016 11:16:18 +0200
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: arm64: kernel BUG at mm/page_alloc.c:1844!
Message-ID: <20161006091618.GG22012@rric.localdomain>
References: <20161005141313.GF22012@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161005141313.GF22012@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux@arm.linux.org.uk, linux-efi@vger.kernel.org, David Daney <david.daney@cavium.com>, Mark Salter <msalter@redhat.com>, Hanjun Guo <hanjun.guo@linaro.org>

On 05.10.16 16:13:13, Robert Richter wrote:
> I tried various changes to fix that, but without success so far:
> 
> a) I modified reserve_regions() to use memblock_reserve() instead of
> memblock_mark_nomap(). This marked efi regions as reserved instead of
> unmap. pfn_valid() now worked as before the nomap change. I could boot
> the system but noticed the following malloc assertion which looks like
> there is some mem corruption:
> 
>   emacs: malloc.c:2395: sysmalloc: Assertion `(old_top == initial_top (av) && old_size == 0) || ((unsigned long) (old_size) >= MINSIZE && prev_inuse (old_top) && ((unsigned long) old_end & (pagesize - 1)) == 0)' failed.
> 
> Other than that the system looked ok so far.
> 
> I checked pfn used by the process with kmem:mm_page_alloc_zone_locked,
> it looked correct with all pfn allocated from free memory, mem ranges
> reported by efi as reserved were not used.

I have updated the packages in my system and the problem went
away. Also I have run memtest for memory ranges close to efi
boundaries without any issues. So I assume this problem was userland
specific and unrelated to the original bug.

> 
> b) I found a quote that for sparsemem the entire memmap (all pages have a
> struct *page) for single section (include/linux/mmzone.h):
> 
>  "In SPARSEMEM, it is assumed that a valid section has a memmap for
>  the entire section."
> 
> So I implemented a arm64 private __early_pfn_valid() function that
> uses memblock_is_memory() to setup all pages of a zone. I got the same
> result as for a).
> 
> c) I modified (almost) all arch arm64 users of pfn_valid() to use
> memblock_mark_nomap() instead of pfn_valid() and changed pfn_valid()
> to use memblock_is_memory(). Same problem as a).

I am going to prepare a patch that implements c).

-Robert

> 
> d) Enabling HOLES_IN_ZONE config option does not looks correct for
> sparsemem, trying it anyway causes VM_BUG_ON_PAGE() in in line 1849
> since (uninitialized) struct *page is accessed. This did not work
> either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
