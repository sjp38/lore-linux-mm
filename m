Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 722A06B2FEC
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:06:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3-v6so5624773pgc.8
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:06:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s24-v6sor2373100pfm.12.2018.08.24.07.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 07:06:54 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net> <20180824131026.GB11868@brain-police>
 <20180824132419.GA9983@roeck-us.net> <20180824133427.GC11868@brain-police>
 <20180824135048.GF11868@brain-police>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <7d0111f4-c369-43a8-72c6-1a7390cdebdd@roeck-us.net>
Date: Fri, 24 Aug 2018 07:06:51 -0700
MIME-Version: 1.0
In-Reply-To: <20180824135048.GF11868@brain-police>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On 08/24/2018 06:50 AM, Will Deacon wrote:

>> -#include <asm-generic/tlb.h>
>> +struct mmu_gather;
>>   
>>   static inline void tlb_flush(struct mmu_gather *tlb)
>>   {
>>   	flush_tlb_mm(tlb->mm);
> 
> Bah, didn't spot the dereference so this won't work either. You basically
> just need to copy what I did for arm64 in d475fac95779.
> 

Yes, this seems to work. It doesn't really need "struct mmu_gather;" -
I assume that is included from elsewhere - but I added it to be safe.

Can you send a full patch, or do you want me to do it ?

Thanks,
Guenter

---
diff --git a/arch/riscv/include/asm/tlb.h b/arch/riscv/include/asm/tlb.h
index c229509288ea..439dc7072e05 100644
--- a/arch/riscv/include/asm/tlb.h
+++ b/arch/riscv/include/asm/tlb.h
@@ -14,6 +14,10 @@
  #ifndef _ASM_RISCV_TLB_H
  #define _ASM_RISCV_TLB_H

+struct mmu_gather;
+
+static void tlb_flush(struct mmu_gather *tlb);
+
  #include <asm-generic/tlb.h>

  static inline void tlb_flush(struct mmu_gather *tlb)
