Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82F036B0433
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:46:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so262448009pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:46:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z7si8891214pgz.226.2016.11.18.08.46.44
        for <linux-mm@kvack.org>;
        Fri, 18 Nov 2016 08:46:44 -0800 (PST)
Date: Fri, 18 Nov 2016 16:46:02 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv3 5/6] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161118164602.GD1197@leverpostej>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-6-git-send-email-labbott@redhat.com>
 <20161118143543.GC1197@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161118143543.GC1197@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, lorenzo.pieralisi@arm.com
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Nov 18, 2016 at 02:35:44PM +0000, Mark Rutland wrote:
> Hi Laura,
> 
> On Thu, Nov 17, 2016 at 05:16:55PM -0800, Laura Abbott wrote:
> > 
> > __pa_symbol is technically the marco that should be used for kernel
> > symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> > will do bounds checking.
> > 
> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> > ---
> > v3: Conversion of more sites besides just _end. Addition of __lm_sym_addr
> > macro to take care of the _va(__pa_symbol(..)) idiom.
> > 
> > Note that a copy of __pa_symbol was added to avoid a mess of headers
> > since the #ifndef __pa_symbol case is defined in linux/mm.h
> 
> I think we also need to fix up virt_to_phys(__cpu_soft_restart) in
> arch/arm64/kernel/cpu-reset.h. Otherwise, this looks complete for uses
> falling under arch/arm64/.

I think I spoke too soon. :(

In the kasan code, use of tmp_pg_dir, kasan_zero_{page,pte,pmd,pud} all
need to be vetted, as those are in the image, but get passed directly to
functions which will end up doing a virt_to_phys behind the scenes (e.g.
cpu_replace_ttbr1(), pmd_populate_kernel()).

There's also some virt_to_pfn(<symbol>) usage that needs to be fixed up
in arch/arm64/kernel/hibernate.c.

... there's also more of that in common kernel code. :(

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
