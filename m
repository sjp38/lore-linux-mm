Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id B69816B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:54:39 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id y66so298130033oig.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:54:39 -0800 (PST)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id b188si6834699oih.29.2016.01.06.09.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 09:54:39 -0800 (PST)
Received: by mail-ob0-x22e.google.com with SMTP id xn1so31693690obc.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:54:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160106123346.GC19507@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com> <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jan 2016 09:54:19 -0800
Message-ID: <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Wed, Jan 6, 2016 at 4:33 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Dec 30, 2015 at 09:59:29AM -0800, Tony Luck wrote:
>> Starting with a patch from Andy Lutomirski <luto@amacapital.net>
>> that used linker relocation trickery to free up a couple of bits
>> in the "fixup" field of the exception table (and generalized the
>> uaccess_err hack to use one of the classes).
>
> So I still think that the other idea Andy gave with putting the handler
> in the exception table is much cleaner and straightforward.
>
> Here's a totally untested patch which at least builds here. I think this
> approach is much more extensible and simpler for the price of a couple
> of KBs of __ex_table size.
>
> ---
> diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
> index 189679aba703..43b509c88b13 100644
> --- a/arch/x86/include/asm/asm.h
> +++ b/arch/x86/include/asm/asm.h
> @@ -44,18 +44,20 @@
>
>  /* Exception table entry */
>  #ifdef __ASSEMBLY__
> -# define _ASM_EXTABLE(from,to)                                 \
> +# define _ASM_EXTABLE(from,to)                         \
>         .pushsection "__ex_table","a" ;                         \
>         .balign 8 ;                                             \
>         .long (from) - . ;                                      \
>         .long (to) - . ;                                        \
> +       .long 0 - .;                                            \

I assume that this zero is to save the couple of bytes for the
relocation entry on relocatable kernels?

If so, ...

> +inline ex_handler_t ex_fixup_handler(const struct exception_table_entry *x)
> +{
> +       return (ex_handler_t)&x->handler + x->handler;

I would check for zero here, because...

> +       new_ip  = ex_fixup_addr(e);
> +       handler = ex_fixup_handler(e);
> +
> +       if (!handler)
> +               handler = ex_handler_default;

the !handler condition here will never trigger because the offset was
already applied.

Otherwise this looks generally sane.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
