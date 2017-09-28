Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB59F6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:35:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z46so318807wrz.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:35:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c135sor70025wmc.50.2017.09.28.01.35.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:35:27 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:35:24 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 15/19] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170928083524.rbdyv4xfdejrr6qa@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-16-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-16-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch converts the of CONFIG_X86_5LEVEL check to runtime checks for
> p4d folding.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/fault.c            |  2 +-
>  arch/x86/mm/ident_map.c        |  2 +-
>  arch/x86/mm/init_64.c          | 30 ++++++++++++++++++------------
>  arch/x86/mm/kasan_init_64.c    | 12 ++++++------
>  arch/x86/mm/kaslr.c            |  6 +++---
>  arch/x86/platform/efi/efi_64.c |  2 +-
>  arch/x86/power/hibernate_64.c  |  6 +++---
>  7 files changed, 33 insertions(+), 27 deletions(-)

> +/*
> + * When memory was added make sure all the processes MM have
> + * suitable PGD entries in the local PGD level page.
> + */
> +void sync_global_pgds(unsigned long start, unsigned long end)
> +{
> +	if (pgtable_l5_enabled)
> +		sync_global_pgds_57(start, end);
> +	else
> +		sync_global_pgds_48(start, end);
> +}

We should use the _l4 and _l5 postfixes instead of random _57 and _48 that is 
pretty cryptic to most readers of the code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
