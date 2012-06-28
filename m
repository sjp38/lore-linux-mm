Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3404B6B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 05:09:01 -0400 (EDT)
Date: Thu, 28 Jun 2012 10:08:27 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] [RESEND] arm: limit memblock base address for
	early_pte_alloc
Message-ID: <20120628090827.GH19026@n2100.arm.linux.org.uk>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <20120627161224.GB2310@linaro.org> <alpine.LFD.2.02.1206280019160.31003@xanadu.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1206280019160.31003@xanadu.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Dave Martin <dave.martin@linaro.org>, Minchan Kim <minchan@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Chanho Min <chanho.min@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jongsung Kim <neidhard.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, Jun 28, 2012 at 12:33:02AM -0400, Nicolas Pitre wrote:
> I propose the following two patches instead -- both patches are included 
> inline not to break the email thread.  What do you think?
> 
> ---------- >8
> 
> From: Nicolas Pitre <nicolas.pitre@linaro.org>
> Date: Wed, 27 Jun 2012 23:02:31 -0400
> Subject: [PATCH] ARM: head.S: simplify initial page table mapping
> 
> Let's map the initial RAM up to the end of the kernel.bss plus 64MB
> instead of the strict kernel image area.  This simplifies the code
> as the kernel image only needs to be handled specially in the XIP case.
> This also give some room for the early memory allocator to use before
> the real mapping is finally installed with the actual amount of memory.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>

Why is this needed?  The initial allocation is sufficient, and you really
should not be wanting to _allocate_ memory in your ->reserve method and
have it be _usable_ at that point.

> Early on the only accessible memory comes from the initial mapping
> performed in head.S, minus those page table entries cleared in
> prepare_page_table().  Eventually the full lowmem is available once
> map_lowmem() has mapped it.  Let's have this properly reflected in the
> memblock allocator limit.

Err, I don't think you understand what's going on here.

The sequence is:

1. setup the initial mappings so we can run the kernel in virtual space.
2. provide the memory areas to memblock
3. ask the platform to reserve whatever memory it wants from memblock
   [this means using memblock_reserve or arm_memblock_steal).  The
   reserved memory is *not* expected to be mapped at this point, and is
   therefore inaccessible.
4. Setup the lowmem mappings.

And when we're setting up the lowmem mappings, we do *not* expect to
create any non-section page mappings, which again means we have no reason
to use the memblock allocator to obtain memory that we want to immediately
use.

So I don't know where you're claim of being "fragile" is coming from.

What is fragile is people wanting to use arm_memblock_steal() without
following the rules for it I layed down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
