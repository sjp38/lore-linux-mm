Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4AA6B0268
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:43:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e26so15523482pfi.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:43:36 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d9si5381198plj.186.2018.01.17.15.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 15:43:35 -0800 (PST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B1222179F
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 23:43:35 +0000 (UTC)
Received: by mail-it0-f43.google.com with SMTP id c16so11317940itc.5
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:43:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-9-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-9-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Jan 2018 15:43:14 -0800
Message-ID: <CALCETrU1HOJa6i5aLjEBPjw6B6KmzBXCig9m-iawVt63P1ZpUQ@mail.gmail.com>
Subject: Re: [PATCH 08/16] x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Allocate a kernel and a user page-table root when PTI is
> enabled. Also allocate a full page per root for PAEm because
> otherwise the bit to flip in cr3 to switch between them
> would be non-constant, which creates a lot of hassle.
> Keep that for a later optimization.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/kernel/head_32.S | 23 ++++++++++++++++++-----
>  arch/x86/mm/pgtable.c     | 11 ++++++-----
>  2 files changed, 24 insertions(+), 10 deletions(-)
>
> diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
> index c29020907886..fc550559bf58 100644
> --- a/arch/x86/kernel/head_32.S
> +++ b/arch/x86/kernel/head_32.S
> @@ -512,28 +512,41 @@ ENTRY(initial_code)
>  ENTRY(setup_once_ref)
>         .long setup_once
>
> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
> +#define        PGD_ALIGN       (2 * PAGE_SIZE)
> +#define PTI_USER_PGD_FILL      1024
> +#else
> +#define        PGD_ALIGN       (PAGE_SIZE)
> +#define PTI_USER_PGD_FILL      0
> +#endif
>  /*
>   * BSS section
>   */
>  __PAGE_ALIGNED_BSS
> -       .align PAGE_SIZE
> +       .align PGD_ALIGN
>  #ifdef CONFIG_X86_PAE
>  .globl initial_pg_pmd
>  initial_pg_pmd:
>         .fill 1024*KPMDS,4,0
> +       .fill PTI_USER_PGD_FILL,4,0

Couldn't this be simplified to just .align PGD_ALIGN, 0 without the .fill?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
