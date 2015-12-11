Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id C33AE6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:07:03 -0500 (EST)
Received: by obbsd4 with SMTP id sd4so41682145obb.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:07:03 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id a78si18698676oib.141.2015.12.11.12.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:07:02 -0800 (PST)
Received: by obciw8 with SMTP id iw8so91339804obc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:07:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
References: <cover.1449861203.git.tony.luck@intel.com> <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 12:06:42 -0800
Message-ID: <CALCETrUO+g9HbPa8yaA=1JpVxw9ReSvgokT_GDKwePigyGoZLQ@mail.gmail.com>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Thu, Dec 10, 2015 at 1:58 PM, Tony Luck <tony.luck@intel.com> wrote:
> Copy the existing page fault fixup mechanisms to create a new table
> to be used when fixing machine checks. Note:
> 1) At this time we only provide a macro to annotate assembly code
> 2) We assume all fixups will in code builtin to the kernel.
> 3) Only for x86_64
> 4) New code under CONFIG_MCE_KERNEL_RECOVERY
>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---

> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +int fixup_mcexception(struct pt_regs *regs, u64 addr)
> +{
> +       const struct exception_table_entry *fixup;
> +       unsigned long new_ip;
> +
> +       fixup = search_mcexception_tables(regs->ip);
> +       if (fixup) {
> +               new_ip = ex_fixup_addr(fixup);
> +
> +               regs->ip = new_ip;
> +               regs->ax = BIT(63) | addr;

Can this be an actual #define?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
