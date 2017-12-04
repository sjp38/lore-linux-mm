Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 271DE6B0280
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:55:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so13542943pfe.22
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:55:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bf4si10124945plb.142.2017.12.04.08.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 08:55:19 -0800 (PST)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com [209.85.214.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 91DAC219AE
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 16:55:19 +0000 (UTC)
Received: by mail-it0-f42.google.com with SMTP id d137so8207122itc.2
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:55:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171204150609.511885345@linutronix.de>
References: <20171204140706.296109558@linutronix.de> <20171204150609.511885345@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 4 Dec 2017 08:54:57 -0800
Message-ID: <CALCETrVfasJMa_++EB-bFm_MzHAzKqvjRPsaBo2m8YTzRomkxg@mail.gmail.com>
Subject: Re: [patch 57/60] x86/mm/kpti: Add Kconfig
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Dec 4, 2017 at 6:08 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> Finally allow CONFIG_KERNEL_PAGE_TABLE_ISOLATION to be enabled.
>
> PARAVIRT generally requires that the kernel not manage its own page tables.
> It also means that the hypervisor and kernel must agree wholeheartedly
> about what format the page tables are in and what they contain.
> KERNEL_PAGE_TABLE_ISOLATION, unfortunately, changes the rules and they
> can not be used together.
>
> I've seen conflicting feedback from maintainers lately about whether they
> want the Kconfig magic to go first or last in a patch series.  It's going
> last here because the partially-applied series leads to kernels that can
> not boot in a bunch of cases.  I did a run through the entire series with
> CONFIG_KERNEL_PAGE_TABLE_ISOLATION=y to look for build errors, though.
>
> [ tglx: Removed SMP and !PARAVIRT dependencies as they not longer exist ]
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: keescook@google.com
> Cc: Denys Vlasenko <dvlasenk@redhat.com>
> Cc: moritz.lipp@iaik.tugraz.at
> Cc: linux-mm@kvack.org
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Brian Gerst <brgerst@gmail.com>
> Cc: hughd@google.com
> Cc: daniel.gruss@iaik.tugraz.at
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Josh Poimboeuf <jpoimboe@redhat.com>
> Cc: michael.schwarz@iaik.tugraz.at
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: richard.fellner@student.tugraz.at
> Link: https://lkml.kernel.org/r/20171123003524.88C90659@viggo.jf.intel.com
>
> ---
>  security/Kconfig |   10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -54,6 +54,16 @@ config SECURITY_NETWORK
>           implement socket and networking access controls.
>           If you are unsure how to answer this question, answer N.
>
> +config KERNEL_PAGE_TABLE_ISOLATION
> +       bool "Remove the kernel mapping in user mode"
> +       depends on X86_64 && JUMP_LABEL

select JUMP_LABEL perhaps?

> +       help
> +         This feature reduces the number of hardware side channels by
> +         ensuring that the majority of kernel addresses are not mapped
> +         into userspace.
> +
> +         See Documentation/x86/pagetable-isolation.txt for more details.
> +
>  config SECURITY_INFINIBAND
>         bool "Infiniband Security Hooks"
>         depends on SECURITY && INFINIBAND
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
