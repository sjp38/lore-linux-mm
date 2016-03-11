Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 098286B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 18:03:06 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id fp4so127754165obb.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:03:06 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id ub2si8141613obb.1.2016.03.11.15.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 15:03:05 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id m7so127555335obh.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:03:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160311225001.GA30106@linux.intel.com>
References: <20160310191507.29771.46591.stgit@dwillia2-desk3.jf.intel.com>
	<20160311225001.GA30106@linux.intel.com>
Date: Fri, 11 Mar 2016 15:03:05 -0800
Message-ID: <CAPcyv4iv6JESzp4fcsSA06OGhWKVvP5i=Qx=N66TwvDYhkvkjg@mail.gmail.com>
Subject: Re: [PATCH] x86, pmem: use memcpy_mcsafe() for memcpy_from_pmem()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 11, 2016 at 2:50 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Thu, Mar 10, 2016 at 11:15:53AM -0800, Dan Williams wrote:
>> Update the definition of memcpy_from_pmem() to return 0 or -EIO on
>> error.  Implement x86::arch_memcpy_from_pmem() with memcpy_mcsafe().
>>
>> Cc: Borislav Petkov <bp@alien8.de>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>> Andrew, now that all the pre-requisites for this patch are in -next
>> (tip/core/ras, tip/x86/asm, nvdimm/libnvdimm-for-next) may I ask you to
>> carry it in -mm?
>>
>> Alternatively I can do an octopus merge and post a branch, but that
>> seems messy/risky for me to be merging 3 branches that are still subject
>> to a merge window disposition.
>>
>>  arch/x86/include/asm/pmem.h |    9 +++++++++
>>  drivers/nvdimm/pmem.c       |    4 ++--
>>  include/linux/pmem.h        |   14 ++++++++------
>>  3 files changed, 19 insertions(+), 8 deletions(-)
> <>
>> diff --git a/include/linux/pmem.h b/include/linux/pmem.h
>> index 3ec5309e29f3..c46c5cf6538e 100644
>> --- a/include/linux/pmem.h
>> +++ b/include/linux/pmem.h
>> @@ -66,14 +66,16 @@ static inline void arch_invalidate_pmem(void __pmem *addr, size_t size)
>>  #endif
>>
>>  /*
>> - * Architectures that define ARCH_HAS_PMEM_API must provide
>> - * implementations for arch_memcpy_to_pmem(), arch_wmb_pmem(),
>> - * arch_copy_from_iter_pmem(), arch_clear_pmem(), arch_wb_cache_pmem()
>> - * and arch_has_wmb_pmem().
>
> Why did you delete the above comment?  I believe it adds value?  Or do you
> think the fact that another architecture will get compile errors if the arch_*
> functions aren't defined is documentation enough?

That and this line-wrapped function-list caused merge conflicts across
the past couple development cycles.  The maintenance overhead to
continue to maintain it didn't seem worth it especially since we have
the compiler to keep people honest.

>> + * memcpy_from_pmem - read from persistent memory with error handling
>> + * @dst: destination buffer
>> + * @src: source buffer
>
> Missing kerneldoc for @size?
>

I'll fix that up in v2 when Tony reworks the memcpy_mcsafe() return value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
