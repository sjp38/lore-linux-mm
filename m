Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5765A6B0275
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:11:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id k4so9780015pgq.15
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:11:16 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r3si2363775plo.432.2018.01.16.10.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 10:11:15 -0800 (PST)
Subject: Re: [PATCH 12/16] x86/mm/pae: Populate the user page-table with user
 pgd's
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-13-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <df637ada-c2f6-c137-0287-0964e29fc11f@intel.com>
Date: Tue, 16 Jan 2018 10:11:14 -0800
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-13-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/16/2018 08:36 AM, Joerg Roedel wrote:
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
> +#endif

Ugh.  The ghosts of PAE have come back to haunt us.

Could we do:

static inline bool pgd_supports_nx(unsigned long)
{
#ifdef CONFIG_X86_64
	return (__supported_pte_mask & _PAGE_NX);
#else
	/* No 32-bit page tables support NX at PGD level */
	return 0;
#endif
}

Nobody will ever spot the #ifdef the way you laid it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
