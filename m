Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78C866B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:58:33 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 76so58934871pgh.11
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:58:33 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20111.outbound.protection.outlook.com. [40.107.2.111])
        by mx.google.com with ESMTPS id x88si1591451pff.121.2017.06.28.06.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 06:58:32 -0700 (PDT)
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
 <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
 <alpine.DEB.2.20.1706281425350.1970@nanos>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <cebda65a-1bdc-8b44-22e7-12fc1c45fa99@virtuozzo.com>
Date: Wed, 28 Jun 2017 17:00:15 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706281425350.1970@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>



On 06/28/2017 04:20 PM, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, Sebastian Andrzej Siewior wrote:
>> On 2017-06-28 14:15:18 [+0300], Andrey Ryabinin wrote:
>>> The main problem here is that arch_cmpxchg64_local() calls cmpxhg_local() instead of using arch_cmpxchg_local().
>>>
>>> So, the patch bellow should fix the problem, also this will fix double instrumentation of cmpcxchg64[_local]().
>>> But I haven't tested this patch yet.
>>
>> tested, works. Next step?
> 
> Check all other implementations in every architecture whether there is a
> similar problem .....
> 

This and similar problems could have been caught by -Wshadow warning:

In file included from ../arch/x86/include/asm/atomic.h:282:0,
                 from ../include/linux/atomic.h:4,
                 from ../include/linux/jump_label.h:183,
                 from ../arch/x86/include/asm/string_64.h:5,
                 from ../arch/x86/include/asm/string.h:4,
                 from ../include/linux/string.h:18,
                 from ../include/linux/bitmap.h:8,
                 from ../drivers/iommu/intel-iommu.c:24:
../include/asm-generic/atomic-instrumented.h:376:18: warning: declaration of a??____ptra?? shadows a previous local [-Wshadow]
  __typeof__(ptr) ____ptr = (ptr);  \
                  ^
../arch/x86/include/asm/cmpxchg_64.h:18:2: note: in expansion of macro a??cmpxchg_locala??
  cmpxchg_local((ptr), (o), (n));     \
  ^
../include/asm-generic/atomic-instrumented.h:392:2: note: in expansion of macro a??arch_cmpxchg64_locala??
  arch_cmpxchg64_local(____ptr, (old), (new)); \
  ^
../drivers/iommu/intel-iommu.c:2290:9: note: in expansion of macro a??cmpxchg64_locala??
   tmp = cmpxchg64_local(&pte->val, 0ULL, pteval);
         ^
../include/asm-generic/atomic-instrumented.h:390:18: note: shadowed declaration is here
  __typeof__(ptr) ____ptr = (ptr);  \
                  ^
../drivers/iommu/intel-iommu.c:2290:9: note: in expansion of macro a??cmpxchg64_locala??
   tmp = cmpxchg64_local(&pte->val, 0ULL, pteval);
         ^


But for some reason we use -Wshadow only on W=2 level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
