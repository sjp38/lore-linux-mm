Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBC196B000D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 13:25:26 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so11495791wrh.23
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 10:25:26 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id t17si2686794edd.174.2018.03.05.10.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 10:25:25 -0800 (PST)
Date: Mon, 5 Mar 2018 19:25:24 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 11/34] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180305182524.GT16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-12-git-send-email-joro@8bytes.org>
 <CAMzpN2h3xkhw_A4VeeA47=oykKgxXeumHM-q0QpaA8+fwFVRjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMzpN2h3xkhw_A4VeeA47=oykKgxXeumHM-q0QpaA8+fwFVRjw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

Hi Brian,

thanks for your review and helpful input.

On Mon, Mar 05, 2018 at 11:41:01AM -0500, Brian Gerst wrote:
> On Mon, Mar 5, 2018 at 5:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > +.Lentry_from_kernel_\@:
> > +
> > +       /*
> > +        * This handles the case when we enter the kernel from
> > +        * kernel-mode and %esp points to the entry-stack. When this
> > +        * happens we need to switch to the task-stack to run C code,
> > +        * but switch back to the entry-stack again when we approach
> > +        * iret and return to the interrupted code-path. This usually
> > +        * happens when we hit an exception while restoring user-space
> > +        * segment registers on the way back to user-space.
> > +        *
> > +        * When we switch to the task-stack here, we can't trust the
> > +        * contents of the entry-stack anymore, as the exception handler
> > +        * might be scheduled out or moved to another CPU. Therefore we
> > +        * copy the complete entry-stack to the task-stack and set a
> > +        * marker in the iret-frame (bit 31 of the CS dword) to detect
> > +        * what we've done on the iret path.
> 
> We don't need to worry about preemption changing the entry stack.  The
> faults that IRET or segment loads can generate just run the exception
> fixup handler and return.  Interrupts were disabled when the fault
> occurred, so the kernel cannot be preempted.  The other case to watch
> is #DB on SYSENTER, but that simply returns and doesn't sleep either.
> 
> We can keep the same process as the existing debug/NMI handlers -
> leave the current exception pt_regs on the entry stack and just switch
> to the task stack for the call to the handler.  Then switch back to
> the entry stack and continue.  No copying needed.

Okay, I'll look into that. Will it even be true for fully preemptible
and RT kernels that there can't be any preemption of these handlers?

> > +       /* Mark stackframe as coming from entry stack */
> > +       orl     $CS_FROM_ENTRY_STACK, PT_CS(%esp)
> 
> Not all 32-bit processors will zero-extend segment pushes.  You will
> need to explicitly clear the bit in the case where we didn't switch
> CR3.

Okay, thanks, will add that.


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
