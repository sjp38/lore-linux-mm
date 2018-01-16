Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C213E280247
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:10:59 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 33so8747643wrs.3
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:10:59 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z74si2349778wmc.120.2018.01.16.13.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 13:10:58 -0800 (PST)
Date: Tue, 16 Jan 2018 22:10:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 12/16] x86/mm/pae: Populate the user page-table with user
 pgd's
In-Reply-To: <1516120619-1159-13-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162207460.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-13-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:
>  
> +#ifdef CONFIG_X86_64
>  	/*
>  	 * If this is normal user memory, make it NX in the kernel
>  	 * pagetables so that, if we somehow screw up and return to
> @@ -134,10 +135,16 @@ pgd_t __pti_set_user_pgd(pgd_t *pgdp, pgd_t pgd)
>  	 *     may execute from it
>  	 *  - we don't have NX support
>  	 *  - we're clearing the PGD (i.e. the new pgd is not present).
> +	 *  - We run on a 32 bit kernel. 2-level paging doesn't support NX at
> +	 *    all and PAE paging does not support it on the PGD level. We can
> +	 *    set it in the PMD level there in the future, but that means we
> +	 *    need to unshare the PMDs between the kernel and the user
> +	 *    page-tables.
>  	 */
>  	if ((pgd.pgd & (_PAGE_USER|_PAGE_PRESENT)) == (_PAGE_USER|_PAGE_PRESENT) &&
>  	    (__supported_pte_mask & _PAGE_NX))
>  		pgd.pgd |= _PAGE_NX;

I'd suggest to have:

static inline pteval_t supported_pgd_mask(void)
{
	if (IS_ENABLED(CONFIG_X86_64))
		return __supported_pte_mask;
	return __supported_pte_mask & ~_PAGE_NX);
}

and get rid of the ifdeffery completely.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
