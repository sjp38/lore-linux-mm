Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 45B886B0038
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:53:14 -0400 (EDT)
Received: by iofb144 with SMTP id b144so119139472iof.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:53:14 -0700 (PDT)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com. [209.85.223.180])
        by mx.google.com with ESMTPS id y42si3685764ioi.100.2015.09.25.10.53.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 10:53:13 -0700 (PDT)
Received: by iofh134 with SMTP id h134so118583798iof.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:53:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560033FD.9000109@ezchip.com>
References: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
	<CAPvkgC1JYZRc5BEXFxmR927r1asLYZw=oAMyUDcGPAOfC2Yy-A@mail.gmail.com>
	<560033FD.9000109@ezchip.com>
Date: Fri, 25 Sep 2015 10:53:13 -0700
Message-ID: <CAPvkgC0zUx64azwDy9A1MO98fLgSM8ZMzenDjJvt8OsBMzy-kA@mail.gmail.com>
Subject: Re: [PATCH] arm64: Add support for PTE contiguous bit.
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woods <dwoods@ezchip.com>
Cc: Chris Metcalf <cmetcalf@ezchip.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Hugh Dickins <hughd@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Suzuki K. Poulose" <suzuki.poulose@arm.com>

On 21 September 2015 at 09:44, David Woods <dwoods@ezchip.com> wrote:
>
> Steve,

Hi Dave,

>
> Thanks for your review and comments.  I take your points about the 16k
> granule - it's helpful to know that support is in the works. However, I'm
> not sure I agree with your reading of section 4.4.2. It's clear that for 16k
> granules, the number of contiguous pages is different for the PTE and PMD
> levels.  But I don't see anywhere it says that for 4K and 64K that the
> contig bit is not supported at the PMD level - just that the number of
> contiguous pages is the same at each level.

Many apologies, I appear to have led you down the garden path there.
Having double checked at ARM, the valid contiguous page sizes are indeed:
4K granule:
16 x ptes = 64K
16 x pmds = 32M
16 x puds = 16G

16K granule:
128 x ptes = 2M
32 x pmds = 1G

64K granule:
32 x ptes = 2M
32 x pmds = 16G

>
> I tried using the tarmac trace module of the ARM simulator to support this
> idea by turning on MMU tracing.  Using 4k granule, I created 64k and 32m
> pages and touched each location in the page.  In both cases, the trace
> recorded just one TLB fill (rather than the 16 you'd expect if the
> contiguous bit were being ignored) and it indicated the expected page size.
>
> 1817498494 clk cpu2 TLB FILL cpu2.S1TLB 64K 0x2000000000_NS vmid=0, nG
> asid=303:0x08fa360000_NS Normal InnerShareable Inner=WriteBackWriteAllocate
> Outer=WriteBackWriteAllocate xn=0 pxn=1 ContiguousHint=1
>
> 1263366314 clk cpu2 TLB FILL cpu2.UTLB 32M 0x2000000000_NS vmid=0, nG
> asid=300:0x08f6000000_NS Normal InnerShareable Inner=WriteBackWriteAllocate
> Outer=WriteBackWriteAllocate xn=0 pxn=1 ContiguousHint=1
>
> I'll try this with a 64k granule next.  I'm not sure what will happen with
> 16G pages since we are using an A53 model which I don't think supports such
> large pages.

The Cortex-A53 supported TLB sizes can be found in the TRM:
http://infocenter.arm.com/help/topic/com.arm.doc.ddi0500f/Chddiifa.html

My understanding is that the core is allowed to ignore the contiguous
bit if it doesn't support the particular TLB entry size, or substitute
in a slightly smaller TLB entry than hinted possible. Anyway, do give
it a go :-).

Cheers,
--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
