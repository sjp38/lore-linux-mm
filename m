Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9A3A6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:32:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q129-v6so1674888oic.9
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 05:32:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w133-v6sor1926981oig.177.2018.06.21.05.32.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 05:32:50 -0700 (PDT)
MIME-Version: 1.0
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com> <1529532570-21765-4-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1529532570-21765-4-git-send-email-rick.p.edgecombe@intel.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 21 Jun 2018 14:32:38 +0200
Message-ID: <CAG48ez1QbKgoBCb-M=L+M5DJHj0URhNvS34h+Ax6RudckgCEEA@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmalloc: Add debugfs modfraginfo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rick.p.edgecombe@intel.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen.c.accardi@intel.com, Dave Hansen <dave.hansen@intel.com>, arjan.van.de.ven@intel.com

On Thu, Jun 21, 2018 at 12:12 AM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> Add debugfs file "modfraginfo" for providing info on module space
> fragmentation.  This can be used for determining if loadable module
> randomization is causing any problems for extreme module loading situations,
> like huge numbers of modules or extremely large modules.
>
> Sample output when RANDOMIZE_BASE and X86_64 is configured:
> Largest free space:             847253504
> External Memory Fragementation: 20%
> Allocations in backup area:     0
>
> Sample output otherwise:
> Largest free space:             847253504
> External Memory Fragementation: 20%
[...]
> +       seq_printf(m, "Largest free space:\t\t%lu\n", largest_free);
> +       if (total_free)
> +               seq_printf(m, "External Memory Fragementation:\t%lu%%\n",

"Fragmentation"

> +                       100-(100*largest_free/total_free));
> +       else
> +               seq_puts(m, "External Memory Fragementation:\t0%%\n");

"Fragmentation"

[...]
> +static const struct file_operations debug_module_frag_operations = {
> +       .open       = proc_module_frag_debug_open,
> +       .read       = seq_read,
> +       .llseek     = seq_lseek,
> +       .release    = single_release,
> +};
>
> +static void debug_modfrag_init(void)
> +{
> +       debugfs_create_file("modfraginfo", 0x0400, NULL, NULL,
> +                       &debug_module_frag_operations);

0x0400 is 02000, which is the setgid bit. I think you meant to type 0400?
