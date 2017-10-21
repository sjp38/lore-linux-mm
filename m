Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 148706B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 21:43:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i125so3386939lfe.23
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:43:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n27sor335128lja.56.2017.10.20.18.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 18:43:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020195934.32108-2-kirill.shutemov@linux.intel.com>
References: <20171020195934.32108-1-kirill.shutemov@linux.intel.com> <20171020195934.32108-2-kirill.shutemov@linux.intel.com>
From: Nitin Gupta <ngupta@vflare.org>
Date: Fri, 20 Oct 2017 18:43:55 -0700
Message-ID: <CAPkvG_cyvK9ds6_L2MWmFBwuzOa0jabiKr6KmVetVWOZOTX=Fg@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Oct 20, 2017 at 12:59 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> With boot-time switching between paging mode we will have variable
> MAX_PHYSMEM_BITS.
>
> Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
> configuration to define zsmalloc data structures.
>
> The patch introduces MAX_POSSIBLE_PHYSMEM_BITS to cover such case.
> It also suits well to handle PAE special case.
>


I see that with your upcoming patch, MAX_PHYSMEM_BITS is turned into a
variable for x86_64 case as: (pgtable_l5_enabled ? 52 : 46).

Even with this change, I don't see a need for this new
MAX_POSSIBLE_PHYSMEM_BITS constant.


> -#ifndef MAX_PHYSMEM_BITS
> -#ifdef CONFIG_HIGHMEM64G
> -#define MAX_PHYSMEM_BITS 36
> -#else /* !CONFIG_HIGHMEM64G */
> +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
> +#ifdef MAX_PHYSMEM_BITS
> +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
> +#else


This ifdef on HIGHMEM64G is redundant, as x86 already defines
MAX_PHYSMEM_BITS = 36 in PAE case. So, all that zsmalloc should do is:

#ifndef MAX_PHYSMEM_BITS
#define MAX_PHYSMEM_BITS BITS_PER_LONG
#endif

.. and then no change is needed for rest of derived constants like _PFN_BITS.

It is upto every arch to define correct MAX_PHYSMEM_BITS (variable or constant)
based on whatever configurations the arch supports. If not defined,
zsmalloc picks
a reasonable default of BITS_PER_LONG.

I will send a patch which makes the change to remove ifdef on CONFIG_HIGHMEM64G.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
