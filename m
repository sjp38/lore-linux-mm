Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAF4A6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:44:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e123so6499539oig.7
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:44:24 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j8si344300otj.187.2017.10.13.08.44.23
        for <linux-mm@kvack.org>;
        Fri, 13 Oct 2017 08:44:23 -0700 (PDT)
Date: Fri, 13 Oct 2017 16:44:26 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Message-ID: <20171013154426.GC4746@arm.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com>
 <20171010155619.GA2517@arm.com>
 <CAOAebxv21+KtXPAk-xWz=+2fqWQDgp9SAFZz-N=XsuBxev=zcg@mail.gmail.com>
 <20171010171047.GC2517@arm.com>
 <CAOAebxtrSthSP4NAa0obBbsCK1KZxO+x0w5xNrpY6m2y9UZFvQ@mail.gmail.com>
 <CAOAebxu5WL-FQLgfCxNcWy36V6zsTO1v3LLqXv5rM1Pp9R-=YA@mail.gmail.com>
 <20171013144319.GB4746@arm.com>
 <CAOAebxv4h+8ej6JA_DZbXaNV5JsAk4MbcCLf1+2RvwKGF2+MxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxv4h+8ej6JA_DZbXaNV5JsAk4MbcCLf1+2RvwKGF2+MxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Fri, Oct 13, 2017 at 11:09:41AM -0400, Pavel Tatashin wrote:
> > It shouldn't be difficult to use section mappings with my patch, I just
> > don't really see the need to try to optimise TLB pressure when you're
> > running with KASAN enabled which already has something like a 3x slowdown
> > afaik. If it ends up being a big deal, we can always do that later, but
> > my main aim here is to divorce kasan from vmemmap because they should be
> > completely unrelated.
> 
> Yes, I understand that kasan makes system slow, but my point is why
> make it even slower? However, I am OK adding your patch to the series,
> BTW, symmetric changes will be needed for x86 as well sometime later.
> 
> >
> > This certainly doesn't sound right; mapping the shadow with pages shouldn't
> > lead to problems. I also can't seem to reproduce this myself -- could you
> > share your full .config and a pointer to the git tree that you're using,
> > please?
> 
> Config is attached. I am using my patch series + your patch + today's
> clone from https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Great, I hit the same problem with your .config. It might actually be
CONFIG_DEBUG_MEMORY_INIT which does it.

> Also, in a separate e-mail i sent out the qemu arguments.
> 
> >
> >> I feel, this patch requires more work, and I am troubled with using
> >> base pages instead of large pages.
> >
> > I'm happy to try fixing this, because I think splitting up kasan and vmemmap
> > is the right thing to do here.
> 
> Thank you very much.

Thanks for sharing the .config and tree. It looks like the problem is that
kimg_shadow_start and kimg_shadow_end are not page-aligned. Whilst I fix
them up in kasan_map_populate, they remain unaligned when passed to
kasan_populate_zero_shadow, which confuses the loop termination conditions
in e.g. zero_pte_populate and the shadow isn't configured properly.

Fixup diff below; please merge in with my original patch.

Will

--->8

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index b922826d9908..207b1acb823a 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -146,7 +146,7 @@ asmlinkage void __init kasan_early_init(void)
 static void __init kasan_map_populate(unsigned long start, unsigned long end,
				      int node)
 {
-	kasan_pgd_populate(start & PAGE_MASK, PAGE_ALIGN(end), node, false);
+	kasan_pgd_populate(start, end, node, false);
 }
 
 /*
@@ -183,8 +183,8 @@ void __init kasan_init(void)
	struct memblock_region *reg;
	int i;
 
-	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text);
-	kimg_shadow_end = (u64)kasan_mem_to_shadow(_end);
+	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text) & PAGE_MASK;
+	kimg_shadow_end = PAGE_ALIGN((u64)kasan_mem_to_shadow(_end));
 
	mod_shadow_start = (u64)kasan_mem_to_shadow((void *)MODULES_VADDR);
	mod_shadow_end = (u64)kasan_mem_to_shadow((void *)MODULES_END);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
