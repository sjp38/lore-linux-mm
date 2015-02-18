Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 38F636B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 22:33:42 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wo20so59903633obc.5
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 19:33:41 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id t62si7900717oif.6.2015.02.17.19.33.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 19:33:41 -0800 (PST)
Received: by mail-ob0-f171.google.com with SMTP id gq1so60973715obb.2
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 19:33:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150217223105.GI26165@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
	<CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
	<alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
	<20150217104443.GC9784@pd.tnic>
	<alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
	<20150217123933.GC26165@pd.tnic>
	<CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com>
	<20150217223105.GI26165@pd.tnic>
Date: Tue, 17 Feb 2015 19:33:40 -0800
Message-ID: <CAGXu5jKQDfhvr04OAxeFO+nhpnVgQ40444SvBPpCZkF4CVa28g@mail.gmail.com>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 17, 2015 at 2:31 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Feb 17, 2015 at 08:45:53AM -0800, Kees Cook wrote:
>> Maybe it should say:
>>
>> Kernel offset: disabled
>>
>> for maximum clarity?
>
> I.e.:
>
> ---
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 78c91bbf50e2..16b6043cb073 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -843,10 +843,14 @@ static void __init trim_low_memory_range(void)
>  static int
>  dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
>  {
> -       pr_emerg("Kernel Offset: 0x%lx from 0x%lx "
> -                "(relocation range: 0x%lx-0x%lx)\n",
> -                (unsigned long)&_text - __START_KERNEL, __START_KERNEL,
> -                __START_KERNEL_map, MODULES_VADDR-1);
> +       if (kaslr_enabled)
> +               pr_emerg("Kernel Offset: 0x%lx from 0x%lx (relocation range: 0x%lx-0x%lx)\n",
> +                        (unsigned long)&_text - __START_KERNEL,
> +                        __START_KERNEL,
> +                        __START_KERNEL_map,
> +                        MODULES_VADDR-1);
> +       else
> +               pr_emerg("Kernel Offset: disabled\n");
>
>         return 0;
>  }
> ---
>
> ?

You are the best. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> --
> Regards/Gruss,
>     Boris.
>
> ECO tip #101: Trim your mails when you reply.
> --



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
