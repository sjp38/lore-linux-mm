Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2946B3223
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 19:32:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g9-v6so6681704pgc.16
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 16:32:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11-v6sor2243744pgu.72.2018.08.24.16.32.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 16:32:13 -0700 (PDT)
Date: Fri, 24 Aug 2018 16:32:12 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build failures)
In-Reply-To: <20180824135048.GF11868@brain-police>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-86a3cd0c-c3dc-42a9-a955-01fbce9d2797@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux@roeck-us.net, npiggin@gmail.com, peterz@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, davem@davemloft.net, schwidefsky@de.ibm.com, mpe@ellerman.id.au, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org

On Fri, 24 Aug 2018 06:50:48 PDT (-0700), Will Deacon wrote:
> On Fri, Aug 24, 2018 at 02:34:27PM +0100, Will Deacon wrote:
>> On Fri, Aug 24, 2018 at 06:24:19AM -0700, Guenter Roeck wrote:
>> > On Fri, Aug 24, 2018 at 02:10:27PM +0100, Will Deacon wrote:
>> > > On Fri, Aug 24, 2018 at 06:07:22AM -0700, Guenter Roeck wrote:
>> > > > On Thu, Aug 23, 2018 at 06:47:09PM +1000, Nicholas Piggin wrote:
>> > > > > The generic tlb_end_vma does not call invalidate_range mmu notifier,
>> > > > > and it resets resets the mmu_gather range, which means the notifier
>> > > > > won't be called on part of the range in case of an unmap that spans
>> > > > > multiple vmas.
>> > > > >
>> > > > > ARM64 seems to be the only arch I could see that has notifiers and
>> > > > > uses the generic tlb_end_vma. I have not actually tested it.
>> > > > >
>> > > > > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> > > > > Acked-by: Will Deacon <will.deacon@arm.com>
>> > > >
>> > > > This patch breaks riscv builds in mainline.
>> > >
>> > > Looks very similar to the breakage we hit on arm64. diff below should fix
>> > > it.
>> > >
>> >
>> > Unfortunately it doesn't.
>> >
>> > In file included from ./arch/riscv/include/asm/pgtable.h:26:0,
>> >                  from ./include/linux/memremap.h:7,
>> >                  from ./include/linux/mm.h:27,
>> >                  from arch/riscv/mm/fault.c:23:
>> > ./arch/riscv/include/asm/tlb.h: In function a??tlb_flusha??:
>> > ./arch/riscv/include/asm/tlb.h:19:18: error: dereferencing pointer to incomplete type a??struct mmu_gathera??
>> >   flush_tlb_mm(tlb->mm);
>> >                   ^
>>
>> Sorry, I was a bit quick of the mark there. You'll need a forward
>> declaration for the paramater type. Here it is with a commit message,
>> although still untested because I haven't got round to setting up a riscv
>> toolchain yet.

FWIW, Arnd built them last time he updated the cross tools so you should be 
able to get GCC 8.1.0 for RISC-V from there.  I use this make.cross script that 
I stole from the Intel 0-day robot

    https://github.com/palmer-dabbelt/home/blob/master/.local/src/local-scripts/make.cross.bash

If I'm reading it correctly the tools come from here

    http://cdn.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0/x86_64-gcc-8.1.0-nolibc-riscv64-linux.tar.gz

I use the make.cross script as it makes it super easy to test my 
across-the-tree patches on other people's ports.

>>
>> Will
>>
>> --->8
>>
>> From adb9be33d68320edcda80d540a97a647792894d2 Mon Sep 17 00:00:00 2001
>> From: Will Deacon <will.deacon@arm.com>
>> Date: Fri, 24 Aug 2018 14:33:48 +0100
>> Subject: [PATCH] riscv: tlb: Provide definition of tlb_flush() before
>>  including tlb.h
>>
>> As of commit fd1102f0aade ("mm: mmu_notifier fix for tlb_end_vma"),
>> asm-generic/tlb.h now calls tlb_flush() from a static inline function,
>> so we need to make sure that it's declared before #including the
>> asm-generic header in the arch header.
>>
>> Since tlb_flush() is a one-liner for riscv, we can define it before
>> including asm-generic/tlb.h as long as we provide a forward declaration
>> of struct mmu_gather.
>>
>> Reported-by: Guenter Roeck <linux@roeck-us.net>
>> Signed-off-by: Will Deacon <will.deacon@arm.com>
>> ---
>>  arch/riscv/include/asm/tlb.h | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/riscv/include/asm/tlb.h b/arch/riscv/include/asm/tlb.h
>> index c229509288ea..a3d1380ad970 100644
>> --- a/arch/riscv/include/asm/tlb.h
>> +++ b/arch/riscv/include/asm/tlb.h
>> @@ -14,11 +14,13 @@
>>  #ifndef _ASM_RISCV_TLB_H
>>  #define _ASM_RISCV_TLB_H
>>
>> -#include <asm-generic/tlb.h>
>> +struct mmu_gather;
>>
>>  static inline void tlb_flush(struct mmu_gather *tlb)
>>  {
>>  	flush_tlb_mm(tlb->mm);
>
> Bah, didn't spot the dereference so this won't work either. You basically
> just need to copy what I did for arm64 in d475fac95779.
>
> Will
