Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7BE46B02F4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 05:05:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z91so6061670wrc.4
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:05:09 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id e11si2992501edl.513.2017.08.17.02.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 02:05:08 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id 49so1116113wrw.5
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:05:08 -0700 (PDT)
Date: Thu, 17 Aug 2017 11:05:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 09/14] x86/mm: Handle boot-time paging mode switching
 at early boot
Message-ID: <20170817090504.weaflrqpi5qplinr@gmail.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-10-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-10-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

>  	/* Prepare to add new identity pagetables on demand. */
> diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> index daf8936d0628..077e8b45784c 100644
> --- a/arch/x86/entry/entry_64.S
> +++ b/arch/x86/entry/entry_64.S
> @@ -273,8 +273,20 @@ return_from_SYSCALL_64:
>  	 * Change top bits to match most significant bit (47th or 56th bit
>  	 * depending on paging mode) in the address.
>  	 */
> +#ifdef CONFIG_X86_5LEVEL
> +	testl	$1, p4d_folded(%rip)
> +	jnz	1f
> +	shl	$(64 - 57), %rcx
> +	sar	$(64 - 57), %rcx
> +	jmp	2f
> +1:
> +	shl	$(64 - 48), %rcx
> +	sar	$(64 - 48), %rcx
> +2:
> +#else
>  	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
>  	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
> +#endif

So I really, really hate this change, as it slows down everything, not just LA57 
hardware, and slows down a critical system call hot path. (I expect enterprise 
distros to enable CONFIG_X86_5LEVEL.)

Could this use alternatives patching instead?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
