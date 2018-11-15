Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 425626B0320
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:33:05 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id p73-v6so23603358itb.7
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:33:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d68sor3448806iof.126.2018.11.15.05.33.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 05:33:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181114201738.sb2lla7umljsx3qx@blommer>
References: <cover.1541525354.git.andreyknvl@google.com> <4891a504adf61c0daf1e83642b6f7519328dfd5f.1541525354.git.andreyknvl@google.com>
 <20181108122228.xqwhpkjritrvqneq@lakrids.cambridge.arm.com>
 <CAAeHK+xPkbg_9P9oCkS-iB8S81vTxD3p5SbyWHy-vrp2ybkKmg@mail.gmail.com>
 <20181113220728.2h3kz67b2bz36wty@blommer> <CAAeHK+xe5LqbyWnYSDv2+QrLR=GK0JMzniAZBfL8kjXRwJravA@mail.gmail.com>
 <20181114201738.sb2lla7umljsx3qx@blommer>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 15 Nov 2018 14:33:02 +0100
Message-ID: <CAAeHK+zqkyb7rknhNT7ZUt0SBJb2s775UFnhpOjc0_yWHFgrvA@mail.gmail.com>
Subject: Re: [PATCH v10 12/22] kasan, arm64: fix up fault handling logic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Nov 14, 2018 at 9:17 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Wed, Nov 14, 2018 at 09:06:23PM +0100, Andrey Konovalov wrote:
>> On Tue, Nov 13, 2018 at 11:07 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> > On Tue, Nov 13, 2018 at 04:01:27PM +0100, Andrey Konovalov wrote:
>> >> On Thu, Nov 8, 2018 at 1:22 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> >> > On Tue, Nov 06, 2018 at 06:30:27PM +0100, Andrey Konovalov wrote:
>> >> >> show_pte in arm64 fault handling relies on the fact that the top byte of
>> >> >> a kernel pointer is 0xff, which isn't always the case with tag-based
>> >> >> KASAN.
>> >> >
>> >> > That's for the TTBR1 check, right?
>> >> >
>> >> > i.e. for the following to work:
>> >> >
>> >> >         if (addr >= VA_START)
>> >> >
>> >> > ... we need the tag bits to be an extension of bit 55...
>> >> >
>> >> >>
>> >> >> This patch resets the top byte in show_pte.
>> >> >>
>> >> >> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> >> >> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>> >> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> >> >> ---
>> >> >>  arch/arm64/mm/fault.c | 3 +++
>> >> >>  1 file changed, 3 insertions(+)
>> >> >>
>> >> >> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
>> >> >> index 7d9571f4ae3d..d9a84d6f3343 100644
>> >> >> --- a/arch/arm64/mm/fault.c
>> >> >> +++ b/arch/arm64/mm/fault.c
>> >> >> @@ -32,6 +32,7 @@
>> >> >>  #include <linux/perf_event.h>
>> >> >>  #include <linux/preempt.h>
>> >> >>  #include <linux/hugetlb.h>
>> >> >> +#include <linux/kasan.h>
>> >> >>
>> >> >>  #include <asm/bug.h>
>> >> >>  #include <asm/cmpxchg.h>
>> >> >> @@ -141,6 +142,8 @@ void show_pte(unsigned long addr)
>> >> >>       pgd_t *pgdp;
>> >> >>       pgd_t pgd;
>> >> >>
>> >> >> +     addr = (unsigned long)kasan_reset_tag((void *)addr);
>> >> >
>> >> > ... but this ORs in (0xffUL << 56), which is not correct for addresses
>> >> > which aren't TTBR1 addresses to begin with, where bit 55 is clear, and
>> >> > throws away useful information.
>> >> >
>> >> > We could use untagged_addr() here, but that wouldn't be right for
>> >> > kernels which don't use TBI1, and we'd erroneously report addresses
>> >> > under the TTBR1 range as being in the TTBR1 range.
>> >> >
>> >> > I also see that the entry assembly for el{1,0}_{da,ia} clears the tag
>> >> > for EL0 addresses.
>> >> >
>> >> > So we could have:
>> >> >
>> >> > static inline bool is_ttbr0_addr(unsigned long addr)
>> >> > {
>> >> >         /* entry assembly clears tags for TTBR0 addrs */
>> >> >         return addr < TASK_SIZE_64;
>> >> > }
>> >> >
>> >> > static inline bool is_ttbr1_addr(unsigned long addr)
>> >> > {
>> >> >         /* TTBR1 addresses may have a tag if HWKASAN is in use */
>> >> >         return arch_kasan_reset_tag(addr) >= VA_START;
>> >> > }
>> >> >
>> >> > ... and use those in the conditionals, leaving the addr as-is for
>> >> > reporting purposes.
>> >>
>> >> Actually it looks like 276e9327 ("arm64: entry: improve data abort
>> >> handling of tagged pointers") already takes care of both user and
>> >> kernel fault addresses and correctly removes tags from them. So I
>> >> think we need to drop this patch.
>> >
>> > The clear_address_tag macro added in that commit only removes tags from TTBR0
>> > addresses, so that's not sufficient if the kernel is used tagged addresses
>> > (which will be in the TTBR1 range).
>>
>> Do I understand correctly that TTBR0 means user space addresses and
>> TTBR1 means kernel addresses?
>
> Effectively, yes. The address space is split into two halves (with a gap in the
> middle). The high half (where we map the kernel) is covered by TTBR1, and the
> low half (where we map userspace) is covered by TTBR0.
>
> The TTBRs are the Translation Table Base Registers -- the two halves have
> separate page tables.
>
>> In that commit I see that the clear_address_tag() macro is used in el0_da and
>> in el1_da, which means that it untags both user and kernel addresses (on data
>> aborts). Do I misunderstand something?
>
> It's called for faults taken from EL0 and EL1, but it only removes the tags
> from addresses covered by TTBR0. The logic is:
>
>         .macro  clear_address_tag, dst, addr
>         tst     \addr, #(1 << 55)
>         bic     \dst, \addr, #(0xff << 56)
>         csel    \dst, \dst, \addr, eq
>         .endm
>
> ... which in C would be:
>
>         if (!(addr & (1UL << 55))) {
>                 addr &= ~(0xffUL << 56);
>         }
>
> ... and therefore does not affect TTBR1 addresses.

Got it, will fix in v11, thanks!
