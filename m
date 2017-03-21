Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 535696B036C
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:28:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b2so358932489pgc.6
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:28:29 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0108.outbound.protection.outlook.com. [104.47.0.108])
        by mx.google.com with ESMTPS id b73si15471502pfk.291.2017.03.21.09.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 09:28:28 -0700 (PDT)
Subject: Re: [PATCH] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321155525.12220-1-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <28376471-644c-a695-b249-9d0f66ee3a3f@virtuozzo.com>
Date: Tue, 21 Mar 2017 19:24:46 +0300
MIME-Version: 1.0
In-Reply-To: <20170321155525.12220-1-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 06:55 PM, Dmitry Safonov wrote:
> After my changes to mmap(), its code now relies on the bitness of
> performing syscall. According to that, it chooses the base of allocation:
> mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
> It was done by:
>   commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
> 32-bit mmap()").
>
> The code afterwards relies on in_compat_syscall() returning true for
> 32-bit syscalls. It's usually so while we're in context of application
> that does 32-bit syscalls. But during exec() it is not valid for x32 ELF.
> The reason is that the application hasn't yet done any syscall, so x32
> bit has not being set.
> For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.
>
> I suggest to set x32 bit before first return to userspace, during
> setting personality at exec(). This way we can rely on
> in_compat_syscall() during exec().
>
> Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
> 32-bit mmap()")
> Cc: 0x7f454c46@gmail.com
> Cc: linux-mm@kvack.org
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: x86@kernel.org
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Reported-by: Adam Borowski <kilobyte@angband.pl>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>

Drop this one - I'll send updated v2 shortly slightly improving:
- specifying mmap() allocation path which failed during exec()
- fix comment style (looks like my editor didn't insert asterisks
   as they were missing before and check_patch didn't blame me)

> ---
>  arch/x86/kernel/process_64.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
> index d6b784a5520d..88d99d35a699 100644
> --- a/arch/x86/kernel/process_64.c
> +++ b/arch/x86/kernel/process_64.c
> @@ -520,7 +520,12 @@ void set_personality_ia32(bool x32)
>  			current->mm->context.ia32_compat = TIF_X32;
>  		current->personality &= ~READ_IMPLIES_EXEC;
>  		/* in_compat_syscall() uses the presence of the x32
> -		   syscall bit flag to determine compat status */
> +		   syscall bit flag to determine compat status.
> +		   On the bitness of syscall relies x86 mmap() code,
> +		   so set x32 syscall bit right here to make
> +		   in_compat_syscall() work during exec().
> +		 */
> +		task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>  		current->thread.status &= ~TS_COMPAT;
>  	} else {
>  		set_thread_flag(TIF_IA32);
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
