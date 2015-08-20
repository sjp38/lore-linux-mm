Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8826B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:04:28 -0400 (EDT)
Received: by oiew67 with SMTP id w67so32199022oie.2
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:04:28 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id eg3si4176696oeb.41.2015.08.20.16.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 16:04:27 -0700 (PDT)
Subject: Re: [PATCH v3 1/10] x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
 <1438811013-30983-2-git-send-email-toshi.kani@hp.com>
 <alpine.DEB.2.11.1508202145540.3873@nanos>
From: Toshi Kani <toshi.kani@hp.com>
Message-ID: <55D65CF7.1020903@hp.com>
Date: Thu, 20 Aug 2015 17:04:23 -0600
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1508202145540.3873@nanos>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On 8/20/2015 1:46 PM, Thomas Gleixner wrote:
> On Wed, 5 Aug 2015, Toshi Kani wrote:
>
>> In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32bit
>> kernel configuration by re-defining it to CONFIG_X86_32.  However,
>> it does not re-define CONFIG_PGTABLE_LEVELS leaving it as 4 levels.
>> Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 as X86_PAE is not
>> set.
> You fail to explain WHY this is required. I have not yet spotted any
> code in vclock_gettime.c which is affected by this.

Sorry about that.  Without this patch 01, applying patch 02 & 03 causes 
the following compile errors in vclock_gettime.c.  This is because it 
includes pgtable_type.h (see blow), which now requires PUD_SHIFT and 
PMD_SHIFT defined properly.  In case of X86_32, pgtable_type.h includes 
pgtable_nopud.h and pgtable-nopmd.h, which define these SHIFTs when 
CONFIG_PGTABLE_LEVEL is set to 2 (or 3 if PAE is also defined).

In file included from ./arch/x86/include/asm/paravirt_types.h:44:0,
                  from ./arch/x86/include/asm/ptrace.h:71,
                  from ./arch/x86/include/asm/alternative.h:8,
                  from ./arch/x86/include/asm/bitops.h:16,
                  from include/linux/bitops.h:36,
                  from include/linux/kernel.h:10,
                  from include/linux/list.h:8,
                  from include/linux/preempt.h:10,
                  from include/linux/spinlock.h:50,
                  from include/linux/seqlock.h:35,
                  from include/linux/time.h:5,
                  from include/uapi/linux/timex.h:56,
                  from include/linux/timex.h:56,
                  from include/linux/clocksource.h:12,
                  from ./arch/x86/include/asm/vgtod.h:5,
                  from arch/x86/entry/vdso/vdso32/../vclock_gettime.c:15,
                  from arch/x86/entry/vdso/vdso32/vclock_gettime.c:30:
./arch/x86/include/asm/pgtable_types.h: In function pud_pfn_maska?>>
./arch/x86/include/asm/pgtable_types.h:282:23: error: PUD_SHIFTa?>> 
undeclared (first use in this function)
    return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
                        ^
./arch/x86/include/asm/pgtable_types.h:282:23: note: each undeclared 
identifier is reported only once for each function it appears in
./arch/x86/include/asm/pgtable_types.h: In function pud_flags_maska?>>
./arch/x86/include/asm/pgtable_types.h:290:25: error: PUD_SHIFTa?>> 
undeclared (first use in this function)
    return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
                          ^
./arch/x86/include/asm/pgtable_types.h: In function pmd_pfn_maska?>>
./arch/x86/include/asm/pgtable_types.h:303:23: error: PMD_SHIFTa?>> 
undeclared (first use in this function)
    return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
                        ^
./arch/x86/include/asm/pgtable_types.h: In function pmd_flags_maska?>>
./arch/x86/include/asm/pgtable_types.h:311:25: error: PMD_SHIFTa?>> 
undeclared (first use in this function)
    return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
                          ^
scripts/Makefile.build:258: recipe for target 
'arch/x86/entry/vdso/vdso32/vclock_gettime.o' failed
make[3]: *** [arch/x86/entry/vdso/vdso32/vclock_gettime.o] Error 1
make[3]: *** Waiting for unfinished jobs....

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
