Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C40186B0261
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:41:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q1so12618305pgv.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:41:30 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 31si5328794plj.417.2018.01.17.15.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 15:41:29 -0800 (PST)
Received: from mail-it0-f54.google.com (mail-it0-f54.google.com [209.85.214.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EAB7F2177D
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 23:41:28 +0000 (UTC)
Received: by mail-it0-f54.google.com with SMTP id b5so11323678itc.3
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:41:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-15-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-15-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Jan 2018 15:41:07 -0800
Message-ID: <CALCETrWDiXxuUSS4jF7=tNtCYyQX7bSHQLF76bAd_whz1zPcjw@mail.gmail.com>
Subject: Re: [PATCH 14/16] x86/mm/legacy: Populate the user page-table with
 user pgd's
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Also populate the user-spage pgd's in the user page-table.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/pgtable-2level.h | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
> index 685ffe8a0eaf..d96486d23c58 100644
> --- a/arch/x86/include/asm/pgtable-2level.h
> +++ b/arch/x86/include/asm/pgtable-2level.h
> @@ -19,6 +19,9 @@ static inline void native_set_pte(pte_t *ptep , pte_t pte)
>
>  static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
> +       pmd.pud.p4d.pgd = pti_set_user_pgd(&pmdp->pud.p4d.pgd, pmd.pud.p4d.pgd);
> +#endif
>         *pmdp = pmd;
>  }
>

Nothing against your patch, but this seems like a perfectly fine place
to rant: I *hate* the way we deal with page table folding.  Grr.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
