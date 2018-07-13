Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3217B6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:56:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17-v6so5999663eds.22
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 03:56:24 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id b24-v6si621112edn.371.2018.07.13.03.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 03:56:22 -0700 (PDT)
Date: Fri, 13 Jul 2018 12:56:20 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline stack
Message-ID: <20180713105620.z6bjhqzfez2hll6r@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-8-git-send-email-joro@8bytes.org>
 <A66D58A6-3DC6-4CF3-B2A5-433C6E974060@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A66D58A6-3DC6-4CF3-B2A5-433C6E974060@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

Hi Andy,

thanks for you valuable feedback.

On Thu, Jul 12, 2018 at 02:09:45PM -0700, Andy Lutomirski wrote:
> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > -.macro SAVE_ALL pt_regs_ax=%eax
> > +.macro SAVE_ALL pt_regs_ax=%eax switch_stacks=0
> >    cld
> > +    /* Push segment registers and %eax */
> >    PUSH_GS
> >    pushl    %fs
> >    pushl    %es
> >    pushl    %ds
> >    pushl    \pt_regs_ax
> > +
> > +    /* Load kernel segments */
> > +    movl    $(__USER_DS), %eax
> 
> If \pt_regs_ax != %eax, then this will behave oddly. Maybe ita??s okay.
> But I dona??t see why this change was needed at all.

This is a left-over from a previous approach I tried and then abandoned
later. You are right, it is not needed.

> > +/*
> > + * Called with pt_regs fully populated and kernel segments loaded,
> > + * so we can access PER_CPU and use the integer registers.
> > + *
> > + * We need to be very careful here with the %esp switch, because an NMI
> > + * can happen everywhere. If the NMI handler finds itself on the
> > + * entry-stack, it will overwrite the task-stack and everything we
> > + * copied there. So allocate the stack-frame on the task-stack and
> > + * switch to it before we do any copying.
> 
> Ick, right. Same with machine check, though. You could alternatively
> fix it by running NMIs on an irq stack if the irq count is zero.  How
> confident are you that you got #MC right?

Pretty confident, #MC uses the exception entry path which also handles
entry-stack and user-cr3 correctly. It might go through through the slow
paranoid exit path, but that's okay for #MC I guess.

And when the #MC happens while we switch to the task stack and do the
copying the same precautions as for NMI apply.

> > + */
> > +.macro SWITCH_TO_KERNEL_STACK
> > +
> > +    ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
> > +
> > +    /* Are we on the entry stack? Bail out if not! */
> > +    movl    PER_CPU_VAR(cpu_entry_area), %edi
> > +    addl    $CPU_ENTRY_AREA_entry_stack, %edi
> > +    cmpl    %esp, %edi
> > +    jae    .Lend_\@
> 
> Thata??s an alarming assumption about the address space layout. How
> about an xor and an and instead of cmpl?  As it stands, if the address
> layout ever changes, the failure may be rather subtle.

Right, I implement a more restrictive check.

> Anyway, wouldna??t it be easier to solve this by just not switching
> stacks on entries from kernel mode and making the entry stack bigger?
> Stick an assertion in the scheduling code that wea??re not on an entry
> stack, perhaps.

That'll save us the check whether we are on the entry stack and replace
it with a check whether we are coming from user/vm86 mode. I don't think
that this will simplify things much and I am a bit afraid that it'll
break unwritten assumptions elsewhere. It is probably something we can
look into later separatly from the basic pti-x32 enablement.


Thanks,

	Joerg
