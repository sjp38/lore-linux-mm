Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 706EE6B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 17:07:42 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id s12so9567037otc.12
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:07:42 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b186-v6si8575209oia.116.2018.11.13.14.07.40
        for <linux-mm@kvack.org>;
        Tue, 13 Nov 2018 14:07:41 -0800 (PST)
Date: Tue, 13 Nov 2018 22:07:29 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v10 12/22] kasan, arm64: fix up fault handling logic
Message-ID: <20181113220728.2h3kz67b2bz36wty@blommer>
References: <cover.1541525354.git.andreyknvl@google.com>
 <4891a504adf61c0daf1e83642b6f7519328dfd5f.1541525354.git.andreyknvl@google.com>
 <20181108122228.xqwhpkjritrvqneq@lakrids.cambridge.arm.com>
 <CAAeHK+xPkbg_9P9oCkS-iB8S81vTxD3p5SbyWHy-vrp2ybkKmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xPkbg_9P9oCkS-iB8S81vTxD3p5SbyWHy-vrp2ybkKmg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Tue, Nov 13, 2018 at 04:01:27PM +0100, Andrey Konovalov wrote:
> On Thu, Nov 8, 2018 at 1:22 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Tue, Nov 06, 2018 at 06:30:27PM +0100, Andrey Konovalov wrote:
> >> show_pte in arm64 fault handling relies on the fact that the top byte of
> >> a kernel pointer is 0xff, which isn't always the case with tag-based
> >> KASAN.
> >
> > That's for the TTBR1 check, right?
> >
> > i.e. for the following to work:
> >
> >         if (addr >= VA_START)
> >
> > ... we need the tag bits to be an extension of bit 55...
> >
> >>
> >> This patch resets the top byte in show_pte.
> >>
> >> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >> ---
> >>  arch/arm64/mm/fault.c | 3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> >> index 7d9571f4ae3d..d9a84d6f3343 100644
> >> --- a/arch/arm64/mm/fault.c
> >> +++ b/arch/arm64/mm/fault.c
> >> @@ -32,6 +32,7 @@
> >>  #include <linux/perf_event.h>
> >>  #include <linux/preempt.h>
> >>  #include <linux/hugetlb.h>
> >> +#include <linux/kasan.h>
> >>
> >>  #include <asm/bug.h>
> >>  #include <asm/cmpxchg.h>
> >> @@ -141,6 +142,8 @@ void show_pte(unsigned long addr)
> >>       pgd_t *pgdp;
> >>       pgd_t pgd;
> >>
> >> +     addr = (unsigned long)kasan_reset_tag((void *)addr);
> >
> > ... but this ORs in (0xffUL << 56), which is not correct for addresses
> > which aren't TTBR1 addresses to begin with, where bit 55 is clear, and
> > throws away useful information.
> >
> > We could use untagged_addr() here, but that wouldn't be right for
> > kernels which don't use TBI1, and we'd erroneously report addresses
> > under the TTBR1 range as being in the TTBR1 range.
> >
> > I also see that the entry assembly for el{1,0}_{da,ia} clears the tag
> > for EL0 addresses.
> >
> > So we could have:
> >
> > static inline bool is_ttbr0_addr(unsigned long addr)
> > {
> >         /* entry assembly clears tags for TTBR0 addrs */
> >         return addr < TASK_SIZE_64;
> > }
> >
> > static inline bool is_ttbr1_addr(unsigned long addr)
> > {
> >         /* TTBR1 addresses may have a tag if HWKASAN is in use */
> >         return arch_kasan_reset_tag(addr) >= VA_START;
> > }
> >
> > ... and use those in the conditionals, leaving the addr as-is for
> > reporting purposes.
> 
> Actually it looks like 276e9327 ("arm64: entry: improve data abort
> handling of tagged pointers") already takes care of both user and
> kernel fault addresses and correctly removes tags from them. So I
> think we need to drop this patch.

The clear_address_tag macro added in that commit only removes tags from TTBR0
addresses, so that's not sufficient if the kernel is used tagged addresses
(which will be in the TTBR1 range).

Thanks,
Mark.
That commit only removes tags from TTBR0 addresses, 
