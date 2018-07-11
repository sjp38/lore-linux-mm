Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 551826B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:44:24 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so15145500plt.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:44:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o3-v6si1817431pls.82.2018.07.11.08.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:44:23 -0700 (PDT)
Message-ID: <1531323638.13297.24.camel@intel.com>
Subject: Re: [RFC PATCH v2 25/27] x86/cet: Add PTRACE interface for CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 08:40:38 -0700
In-Reply-To: <20180711102035.GB8574@gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-26-yu-cheng.yu@intel.com>
	 <20180711102035.GB8574@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 12:20 +0200, Ingo Molnar wrote:
> * Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> 
> > 
> > Add PTRACE interface for CET MSRs.
> Please *always* describe new ABIs in the changelog, in a precise,
> well-documentedA 
> way.

Ok!

> > 
> > diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
> > index e2ee403865eb..ac2bc3a18427 100644
> > --- a/arch/x86/kernel/ptrace.c
> > +++ b/arch/x86/kernel/ptrace.c
> > @@ -49,7 +49,9 @@ enum x86_regset {
> > A 	REGSET_IOPERM64 = REGSET_XFP,
> > A 	REGSET_XSTATE,
> > A 	REGSET_TLS,
> > +	REGSET_CET64 = REGSET_TLS,
> > A 	REGSET_IOPERM32,
> > +	REGSET_CET32,
> > A };
> Why does REGSET_CET64 alias on REGSET_TLS?

In x86_64_regsets[], there is no [REGSET_TLS]. A The core dump code
cannot handle holes in the array.

> 
> > 
> > A struct pt_regs_offset {
> > @@ -1276,6 +1278,13 @@ static struct user_regset x86_64_regsets[]
> > __ro_after_init = {
> > A 		.size = sizeof(long), .align = sizeof(long),
> > A 		.active = ioperm_active, .get = ioperm_get
> > A 	},
> > +	[REGSET_CET64] = {
> > +		.core_note_type = NT_X86_CET,
> > +		.n = sizeof(struct cet_user_state) / sizeof(u64),
> > +		.size = sizeof(u64), .align = sizeof(u64),
> > +		.active = cetregs_active, .get = cetregs_get,
> > +		.set = cetregs_set
> > +	},
> Ok, could we first please make this part of the regset code more
> readable andA 
> start the series with a standalone clean-up patch that changes these
> initializersA 
> to something more readable:
> 
> 	[REGSET_CET64] = {
> 		.core_note_type	= NT_X86_CET,
> 		.n		= sizeof(struct cet_user_state) /
> sizeof(u64),
> 		.size		= sizeof(u64),
> 		.align		= sizeof(u64),
> 		.active		= cetregs_active,
> 		.get		= cetregs_get,
> 		.set		= cetregs_set
> 	},
> 
> ? (I'm demonstrating the cleanup based on REGSET_CET64, but this
> should be done onA 
> every other entry first.)
> 

I will fix it.

> 
> > 
> > --- a/include/uapi/linux/elf.h
> > +++ b/include/uapi/linux/elf.h
> > @@ -401,6 +401,7 @@ typedef struct elf64_shdr {
> > A #define NT_386_TLS	0x200		/* i386 TLS slots
> > (struct user_desc) */
> > A #define NT_386_IOPERM	0x201		/* x86 io
> > permission bitmap (1=deny) */
> > A #define NT_X86_XSTATE	0x202		/* x86 extended
> > state using xsave */
> > +#define NT_X86_CET	0x203		/* x86 cet state */
> Acronyms in comments should be in capital letters.
> 
> Also, I think I asked this before: why does "Control Flow
> Enforcement" abbreviateA 
> to "CET" (which is a well-known acronym for "Central European Time"),
> not to CFE?
> 

I don't know if I can change that, will find out.

Thanks,
Yu-cheng
