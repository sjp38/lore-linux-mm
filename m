Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 5E4516B0062
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:20:33 -0400 (EDT)
Date: Wed, 27 Jun 2012 20:18:01 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] [RESEND] arm: limit memblock base address for
	early_pte_alloc
Message-ID: <20120627191801.GD25319@n2100.arm.linux.org.uk>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <025701cd457e$d5065410$7f12fc30$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <025701cd457e$d5065410$7f12fc30$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kim, Jong-Sung" <neidhard.kim@lge.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Nicolas Pitre' <nico@linaro.org>, 'Catalin Marinas' <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, 'Chanho Min' <chanho.min@lge.com>, linux-mm@kvack.org

On Fri, Jun 08, 2012 at 10:58:50PM +0900, Kim, Jong-Sung wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Sent: Tuesday, June 05, 2012 4:12 PM
> > 
> > If we do arm_memblock_steal with a page which is not aligned with section
> > size, panic can happen during boot by page fault in map_lowmem.
> > 
> > Detail:
> > 
> > 1) mdesc->reserve can steal a page which is allocated at 0x1ffff000 by
> > memblock
> >    which prefers tail pages of regions.
> > 2) map_lowmem maps 0x00000000 - 0x1fe00000
> > 3) map_lowmem try to map 0x1fe00000 but it's not aligned by section due to
> 1.
> > 4) calling alloc_init_pte allocates a new page for new pte by
> memblock_alloc
> > 5) allocated memory for pte is 0x1fffe000 -> it's not mapped yet.
> > 6) memset(ptr, 0, sz) in early_alloc_aligned got PANICed!
> 
> May I suggest another simple approach? The first continuous couples of
> sections are always safely section-mapped inside alloc_init_section funtion.
> So, by limiting memblock_alloc to the end of the first continuous couples of
> sections at the start of map_lowmem, map_lowmem can safely memblock_alloc &
> memset even if we have one or more section-unaligned memory regions. The
> limit can be extended back to arm_lowmem_limit after the map_lowmem is done.

No.  What if the first block of memory is not large enough to handle all
the allocations?

I think the real problem is folk trying to reserve small amounts.  I have
said all reservations must be aligned to 1MB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
