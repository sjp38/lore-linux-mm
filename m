Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A82326B0371
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:17:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y193so91797823lfd.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:17:27 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 23si11643117lju.121.2017.03.21.10.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 10:17:26 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id v2so13702748lfi.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:17:26 -0700 (PDT)
Date: Tue, 21 Mar 2017 20:17:23 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Message-ID: <20170321171723.GB21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170321163712.20334-1-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
...
> diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
> index d6b784a5520d..d3d4d9abcaf8 100644
> --- a/arch/x86/kernel/process_64.c
> +++ b/arch/x86/kernel/process_64.c
> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>  		if (current->mm)
>  			current->mm->context.ia32_compat = TIF_X32;
>  		current->personality &= ~READ_IMPLIES_EXEC;
> -		/* in_compat_syscall() uses the presence of the x32
> -		   syscall bit flag to determine compat status */
> +		/*
> +		 * in_compat_syscall() uses the presence of the x32
> +		 * syscall bit flag to determine compat status.
> +		 * On the bitness of syscall relies x86 mmap() code,
> +		 * so set x32 syscall bit right here to make
> +		 * in_compat_syscall() work during exec().
> +		 */
> +		task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>  		current->thread.status &= ~TS_COMPAT;

Hi! I must admit I didn't follow close the overall series (so can't
comment much here :) but I have a slightly unrelated question -- is
there a way to figure out if task is running in x32 mode say with
some ptrace or procfs sign?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
