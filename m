Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id B36E36B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:55:31 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id 18so38319063obc.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:55:31 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id e198si7846215oih.37.2015.12.16.09.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 09:55:31 -0800 (PST)
Received: by mail-oi0-x236.google.com with SMTP id y66so28771826oig.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:55:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
References: <cover.1450283985.git.tony.luck@intel.com> <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 16 Dec 2015 09:55:11 -0800
Message-ID: <CALCETrVHqi9ixUQbeN82T14CVom1N6QegSNR+r=jtjRgcfC0kg@mail.gmail.com>
Subject: Re: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Dec 15, 2015 at 5:29 PM, Tony Luck <tony.luck@intel.com> wrote:
> Copy the existing page fault fixup mechanisms to create a new table
> to be used when fixing machine checks. Note:
> 1) At this time we only provide a macro to annotate assembly code
> 2) We assume all fixups will in code builtin to the kernel.
> 3) Only for x86_64
> 4) New code under CONFIG_MCE_KERNEL_RECOVERY (default 'n')
>
> Signed-off-by: Tony Luck <tony.luck@intel.com>

Looks generally good.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

with trivial caveats:


>  int __init mcheck_init(void)
>  {
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +       if (__stop___mcex_table > __start___mcex_table)
> +               sort_extable(__start___mcex_table, __stop___mcex_table);
> +#endif

This doesn't matter unless we sprout a lot of these, but it could be
worthwhile to update sortextable.h as well.

> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +int fixup_mcexception(struct pt_regs *regs)
> +{
> +       const struct exception_table_entry *fixup;
> +       unsigned long new_ip;
> +
> +       fixup = search_mcexception_tables(regs->ip);
> +       if (fixup) {
> +               new_ip = ex_fixup_addr(fixup);
> +
> +               regs->ip = new_ip;

You could very easily save a line of code here :)

> +               return 1;
> +       }
> +
> +       return 0;
> +}
> +#endif
> +

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
