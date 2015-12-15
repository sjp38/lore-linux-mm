Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id A27076B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:45:06 -0500 (EST)
Received: by mail-qk0-f170.google.com with SMTP id p187so24927979qkd.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:45:06 -0800 (PST)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id x4si2079663qkx.21.2015.12.15.09.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 09:45:04 -0800 (PST)
Received: by mail-qk0-x22e.google.com with SMTP id p187so24926605qkd.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:45:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151215131135.GE25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
	<23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
	<20151215131135.GE25973@pd.tnic>
Date: Tue, 15 Dec 2015 09:45:04 -0800
Message-ID: <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Dec 15, 2015 at 5:11 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Thu, Dec 10, 2015 at 04:21:50PM -0800, Tony Luck wrote:
>> Using __copy_user_nocache() as inspiration create a memory copy
>> routine for use by kernel code with annotations to allow for
>> recovery from machine checks.
>>
>> Notes:
>> 1) Unlike the original we make no attempt to copy all the bytes
>>    up to the faulting address. The original achieves that by
>>    re-executing the failing part as a byte-by-byte copy,
>>    which will take another page fault. We don't want to have
>>    a second machine check!
>> 2) Likewise the return value for the original indicates exactly
>>    how many bytes were not copied. Instead we provide the physical
>>    address of the fault (thanks to help from do_machine_check()
>> 3) Provide helpful macros to decode the return value.
>>
>> Signed-off-by: Tony Luck <tony.luck@intel.com>
>> ---
>>  arch/x86/include/asm/uaccess_64.h |  5 +++
>>  arch/x86/kernel/x8664_ksyms_64.c  |  2 +
>>  arch/x86/lib/copy_user_64.S       | 91 +++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 98 insertions(+)
>
> ...
>
>> + * mcsafe_memcpy - Uncached memory copy with machine check exception handling
>> + * Note that we only catch machine checks when reading the source addresses.
>> + * Writes to target are posted and don't generate machine checks.
>> + * This will force destination/source out of cache for more performance.
>
> ... and the non-temporal version is the optimal one even though we're
> defaulting to copy_user_enhanced_fast_string for memcpy on modern Intel
> CPUs...?

At least the pmem driver use case does not want caching of the
source-buffer since that is the raw "disk" media.  I.e. in
pmem_do_bvec() we'd use this to implement memcpy_from_pmem().
However, caching the destination-buffer may prove beneficial since
that data is likely to be consumed immediately by the thread that
submitted the i/o.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
