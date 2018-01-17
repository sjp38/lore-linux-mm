Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFDD280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:18:55 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f3so3622943wmc.8
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:18:55 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 34si4217284edp.249.2018.01.17.01.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:18:54 -0800 (PST)
Date: Wed, 17 Jan 2018 10:18:53 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Message-ID: <20180117091853.GI28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
 <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 02:45:27PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > +.macro SWITCH_TO_KERNEL_STACK nr_regs=0 check_user=0
> 
> How about marking nr_regs with :req to force everyone to be explicit?

Yeah, that's more readable, I'll change it.

> > +       /*
> > +        * TSS_sysenter_stack is the offset from the bottom of the
> > +        * entry-stack
> > +        */
> > +       movl  TSS_sysenter_stack + ((\nr_regs + 1) * 4)(%esp), %esp
> 
> This is incomprehensible.  You're adding what appears to be the offset
> of sysenter_stack within the TSS to something based on esp and
> dereferencing that to get the new esp.  That't not actually what
> you're doing, but please change asm_offsets.c (as in my previous
> email) to avoid putting serious arithmetic in it and then do the
> arithmetic right here so that it's possible to follow what's going on.

Probably this needs better comments. So TSS_sysenter_stack is the offset
from to tss.sp0 (tss.sp1 later) from the _bottom_ of the stack. But in
this macro the stack might not be empty, it has a configurable (by
\nr_regs) number of dwords on it. Before this instruction we also do a
push %edi, so we need (\nr_regs + 1).

This can't be put into asm_offset.c, as the actual offset depends on how
much is on the stack.

> >  ENTRY(entry_INT80_32)
> >         ASM_CLAC
> >         pushl   %eax                    /* pt_regs->orig_ax */
> > +
> > +       /* Stack layout: ss, esp, eflags, cs, eip, orig_eax */
> > +       SWITCH_TO_KERNEL_STACK nr_regs=6 check_user=1
> > +
> 
> Why check_user?

You are right, check_user shouldn't ne needed as INT80 is never called
from kernel mode.

> >  ENTRY(nmi)
> >         ASM_CLAC
> > +
> > +       /* Stack layout: ss, esp, eflags, cs, eip */
> > +       SWITCH_TO_KERNEL_STACK nr_regs=5 check_user=1
> 
> This is wrong, I think.  If you get an nmi in kernel mode but while
> still on the sysenter stack, you blow up.  IIRC we have some crazy
> code already to handle this (for nmi and #DB), and maybe that's
> already adequate or can be made adequate, but at the very least this
> needs a big comment explaining why it's okay.

If we get an nmi while still on the sysenter stack, then we are not
entering the handler from user-space and the above code will do
nothing and behave as before.

But you are right, it might blow up. There is a problem with the cr3
switch, because the nmi can happen in kernel mode before the cr3 is
switched, then this handler will not do the cr3 switch itself and crash
the kernel. But the stack switching should be fine, I think.

> > +       /*
> > +        * TODO: Find a way to let cpu_current_top_of_stack point to
> > +        * cpu_tss_rw.x86_tss.sp1. Doing so now results in stack corruption with
> > +        * iret exceptions.
> > +        */
> > +       this_cpu_write(cpu_tss_rw.x86_tss.sp1, next_p->thread.sp0);
> 
> Do you know what the issue is?

No, not yet, I will look into that again. But first I want to get
this series stable enough as it is.

> As a general comment, the interaction between this patch and vm86 is a
> bit scary.  In vm86 mode, the kernel gets entered with extra stuff on
> the stack, which may screw up all your offsets.

Just read up on vm86 mode control transfers and the stack layout then.
Looks like I need to check for eflags.vm=1 and copy four more registers
from/to the entry stack. Thanks for pointing that out.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
