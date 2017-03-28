Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCCD6B039F
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:02:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o123so102210297pga.16
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:02:42 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0117.outbound.protection.outlook.com. [104.47.0.117])
        by mx.google.com with ESMTPS id t25si4153071pgo.353.2017.03.28.06.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 06:02:41 -0700 (PDT)
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321174711.29880-1-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1703212319440.3776@nanos>
 <cccc8f91-bd0d-fea0-b9b9-71653be38f61@virtuozzo.com>
 <alpine.DEB.2.20.1703281449070.3616@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <66372d92-8fc1-301e-df21-7020514d7dbb@virtuozzo.com>
Date: Tue, 28 Mar 2017 15:59:00 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1703281449070.3616@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On 03/28/2017 03:51 PM, Thomas Gleixner wrote:
> On Tue, 28 Mar 2017, Dmitry Safonov wrote:
>> On 03/22/2017 01:21 AM, Thomas Gleixner wrote:
>>> On Tue, 21 Mar 2017, Dmitry Safonov wrote:
>>>> v3:
>>>> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA).
>>>
>>> For correctness sake, this wants to be cleared in the IA32 path as
>>> well. It's not causing any harm, but ....
>>>
>>> I'll amend the patch.
>>
>> So, just a gentle reminder about this problem.
>> Should I resend v4 with clearing x32 bit in ia32 path?
>> Or should I resend with this fixup:
>> https://lkml.org/lkml/2017/3/22/343
>>
>> The fixup doesn't look as simple as clearing x32 syscall bit, but I may
>> be wrong.
>
> Something like the below should set it correctly for all possible
> scenarios.

Ok, I'll check the ifdeffery, define __NR_{x32_,ia32_}execve,
test it and resend v4 today or tomorrow.
Thanks.

>
> Thanks,
>
> 	tglx
>
> 8<------------------
>
>  arch/x86/kernel/process_64.c |   63 ++++++++++++++++++++++++++++---------------
>  1 file changed, 42 insertions(+), 21 deletions(-)
>
> --- a/arch/x86/kernel/process_64.c
> +++ b/arch/x86/kernel/process_64.c
> @@ -494,6 +494,8 @@ void set_personality_64bit(void)
>  	clear_thread_flag(TIF_IA32);
>  	clear_thread_flag(TIF_ADDR32);
>  	clear_thread_flag(TIF_X32);
> +	/* Pretend that this comes from a 64bit execve */
> +	task_pt_regs(current)->orig_ax = __NR_execve;
>
>  	/* Ensure the corresponding mm is not marked. */
>  	if (current->mm)
> @@ -506,32 +508,51 @@ void set_personality_64bit(void)
>  	current->personality &= ~READ_IMPLIES_EXEC;
>  }
>
> -void set_personality_ia32(bool x32)
> +static void __set_personality_x32(void)
> +{
> +#ifdef CONFIG_X86_X32
> +	clear_thread_flag(TIF_IA32);
> +	set_thread_flag(TIF_X32);
> +	if (current->mm)
> +		current->mm->context.ia32_compat = TIF_X32;
> +	current->personality &= ~READ_IMPLIES_EXEC;
> +	/*
> +	 * in_compat_syscall() uses the presence of the x32
> +	 * syscall bit flag to determine compat status.
> +	 * The x86 mmap() code relies on the syscall bitness
> +	 * so set x32 syscall bit right here to make
> +	 * in_compat_syscall() work during exec().
> +	 *
> +	 * Pretend to come from a x32 execve.
> +	 */
> +	task_pt_regs(current)->orig_ax = __NR_x32_execve | __X32_SYSCALL_BIT;
> +	current->thread.status &= ~TS_COMPAT;
> +#endif
> +}
> +
> +static void __set_personality_ia32(void)
>  {
> -	/* inherit personality from parent */
> +#ifdef CONFIG_COMPAT_32
> +	set_thread_flag(TIF_IA32);
> +	clear_thread_flag(TIF_X32);
> +	if (current->mm)
> +		current->mm->context.ia32_compat = TIF_IA32;
> +	current->personality |= force_personality32;
> +	/* Prepare the first "return" to user space */
> +	task_pt_regs(current)->orig_ax = __NR_ia32_execve;
> +	current->thread.status |= TS_COMPAT;
> +#endif
> +}
>
> +void set_personality_ia32(bool x32)
> +{
>  	/* Make sure to be in 32bit mode */
>  	set_thread_flag(TIF_ADDR32);
>
> -	/* Mark the associated mm as containing 32-bit tasks. */
> -	if (x32) {
> -		clear_thread_flag(TIF_IA32);
> -		set_thread_flag(TIF_X32);
> -		if (current->mm)
> -			current->mm->context.ia32_compat = TIF_X32;
> -		current->personality &= ~READ_IMPLIES_EXEC;
> -		/* in_compat_syscall() uses the presence of the x32
> -		   syscall bit flag to determine compat status */
> -		current->thread.status &= ~TS_COMPAT;
> -	} else {
> -		set_thread_flag(TIF_IA32);
> -		clear_thread_flag(TIF_X32);
> -		if (current->mm)
> -			current->mm->context.ia32_compat = TIF_IA32;
> -		current->personality |= force_personality32;
> -		/* Prepare the first "return" to user space */
> -		current->thread.status |= TS_COMPAT;
> -	}
> +	if (x32)
> +		__set_personality_x32();
> +	else
> +		__set_personality_ia32();
>  }
>  EXPORT_SYMBOL_GPL(set_personality_ia32);
>
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
