Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B81C6B0009
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 12:48:59 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id h33so2640430plh.19
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 09:48:59 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a67si1571pgc.151.2018.02.09.09.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 09:48:58 -0800 (PST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B08E21789
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 17:48:57 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id x128so11939544ite.0
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 09:48:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1518168340-9392-21-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org> <1518168340-9392-21-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 9 Feb 2018 17:48:36 +0000
Message-ID: <CALCETrUgk3s0uDZrHqy-HjudFXLeWN=oKz6EH9i-NCdWQEnAqw@mail.gmail.com>
Subject: Re: [PATCH 20/31] x86/mm/pae: Populate the user page-table with user pgd's
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Fri, Feb 9, 2018 at 9:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> When we populate a PGD entry, make sure we populate it in
> the user page-table too.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/pgtable-3level.h | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
> index bc4af54..1a0661b 100644
> --- a/arch/x86/include/asm/pgtable-3level.h
> +++ b/arch/x86/include/asm/pgtable-3level.h
> @@ -98,6 +98,9 @@ static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
>
>  static inline void native_set_pud(pud_t *pudp, pud_t pud)
>  {
> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
> +       pud.p4d.pgd = pti_set_user_pgd(&pudp->p4d.pgd, pud.p4d.pgd);
> +#endif
>         set_64bit((unsigned long long *)(pudp), native_pud_val(pud));
>  }
>
> @@ -194,6 +197,10 @@ static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
>  {
>         union split_pud res, *orig = (union split_pud *)pudp;
>
> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
> +       pti_set_user_pgd(&pudp->p4d.pgd, __pgd(0));
> +#endif
> +
>         /* xchg acts as a barrier before setting of the high bits */
>         res.pud_low = xchg(&orig->pud_low, 0);
>         res.pud_high = orig->pud_high;

Can you rename the helper from pti_set_user_pgd() to
pti_set_user_top_level_entry() or similar?  The name was already a bit
absurd, but now it's just nuts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
