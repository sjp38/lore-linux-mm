Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5EC6B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:20:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w137-v6so1559656wme.2
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:20:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k127-v6sor421057wme.67.2018.07.11.03.20.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 03:20:39 -0700 (PDT)
Date: Wed, 11 Jul 2018 12:20:35 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH v2 25/27] x86/cet: Add PTRACE interface for CET
Message-ID: <20180711102035.GB8574@gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-26-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710222639.8241-26-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>


* Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

> Add PTRACE interface for CET MSRs.

Please *always* describe new ABIs in the changelog, in a precise, well-documented 
way.

> diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
> index e2ee403865eb..ac2bc3a18427 100644
> --- a/arch/x86/kernel/ptrace.c
> +++ b/arch/x86/kernel/ptrace.c
> @@ -49,7 +49,9 @@ enum x86_regset {
>  	REGSET_IOPERM64 = REGSET_XFP,
>  	REGSET_XSTATE,
>  	REGSET_TLS,
> +	REGSET_CET64 = REGSET_TLS,
>  	REGSET_IOPERM32,
> +	REGSET_CET32,
>  };

Why does REGSET_CET64 alias on REGSET_TLS?

>  struct pt_regs_offset {
> @@ -1276,6 +1278,13 @@ static struct user_regset x86_64_regsets[] __ro_after_init = {
>  		.size = sizeof(long), .align = sizeof(long),
>  		.active = ioperm_active, .get = ioperm_get
>  	},
> +	[REGSET_CET64] = {
> +		.core_note_type = NT_X86_CET,
> +		.n = sizeof(struct cet_user_state) / sizeof(u64),
> +		.size = sizeof(u64), .align = sizeof(u64),
> +		.active = cetregs_active, .get = cetregs_get,
> +		.set = cetregs_set
> +	},

Ok, could we first please make this part of the regset code more readable and 
start the series with a standalone clean-up patch that changes these initializers 
to something more readable:

	[REGSET_CET64] = {
		.core_note_type	= NT_X86_CET,
		.n		= sizeof(struct cet_user_state) / sizeof(u64),
		.size		= sizeof(u64),
		.align		= sizeof(u64),
		.active		= cetregs_active,
		.get		= cetregs_get,
		.set		= cetregs_set
	},

? (I'm demonstrating the cleanup based on REGSET_CET64, but this should be done on 
every other entry first.)


> --- a/include/uapi/linux/elf.h
> +++ b/include/uapi/linux/elf.h
> @@ -401,6 +401,7 @@ typedef struct elf64_shdr {
>  #define NT_386_TLS	0x200		/* i386 TLS slots (struct user_desc) */
>  #define NT_386_IOPERM	0x201		/* x86 io permission bitmap (1=deny) */
>  #define NT_X86_XSTATE	0x202		/* x86 extended state using xsave */
> +#define NT_X86_CET	0x203		/* x86 cet state */

Acronyms in comments should be in capital letters.

Also, I think I asked this before: why does "Control Flow Enforcement" abbreviate 
to "CET" (which is a well-known acronym for "Central European Time"), not to CFE?

Thanks,

	Ingo
