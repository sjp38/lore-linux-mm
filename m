Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D005E6B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 08:11:53 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n186so25016611wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 05:11:53 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id wx2si1833235wjc.78.2015.12.15.05.11.41
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 05:11:42 -0800 (PST)
Date: Tue, 15 Dec 2015 14:11:35 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151215131135.GE25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Thu, Dec 10, 2015 at 04:21:50PM -0800, Tony Luck wrote:
> Using __copy_user_nocache() as inspiration create a memory copy
> routine for use by kernel code with annotations to allow for
> recovery from machine checks.
> 
> Notes:
> 1) Unlike the original we make no attempt to copy all the bytes
>    up to the faulting address. The original achieves that by
>    re-executing the failing part as a byte-by-byte copy,
>    which will take another page fault. We don't want to have
>    a second machine check!
> 2) Likewise the return value for the original indicates exactly
>    how many bytes were not copied. Instead we provide the physical
>    address of the fault (thanks to help from do_machine_check()
> 3) Provide helpful macros to decode the return value.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/include/asm/uaccess_64.h |  5 +++
>  arch/x86/kernel/x8664_ksyms_64.c  |  2 +
>  arch/x86/lib/copy_user_64.S       | 91 +++++++++++++++++++++++++++++++++++++++
>  3 files changed, 98 insertions(+)

...

> + * mcsafe_memcpy - Uncached memory copy with machine check exception handling
> + * Note that we only catch machine checks when reading the source addresses.
> + * Writes to target are posted and don't generate machine checks.
> + * This will force destination/source out of cache for more performance.

... and the non-temporal version is the optimal one even though we're
defaulting to copy_user_enhanced_fast_string for memcpy on modern Intel
CPUs...?

Btw, it should be also inside an ifdef if we're going to ifdef
CONFIG_MCE_KERNEL_RECOVERY everywhere else.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
