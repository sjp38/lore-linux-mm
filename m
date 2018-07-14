Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 641FF6B0280
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:21:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12-v6so12805268edi.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:21:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si6055643edg.337.2018.07.13.22.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:21:15 -0700 (PDT)
Date: Sat, 14 Jul 2018 07:21:10 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180714052110.cobtew6rms23ih37@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-11-git-send-email-joro@8bytes.org>
 <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 04:31:02PM -0700, Andy Lutomirski wrote:
> What you're really doing is keeping it available for an extra flag.
> Please update the comment as such.  But see below.

Thanks, will do.

> > +.macro PARANOID_EXIT_TO_KERNEL_MODE
> > +
> > +       /*
> > +        * Test if we entered the kernel with the entry-stack. Most
> > +        * likely we did not, because this code only runs on the
> > +        * return-to-kernel path.
> > +        */
> > +       testl   $CS_FROM_ENTRY_STACK, PT_CS(%esp)
> > +       jz      .Lend_\@
> > +
> > +       /* Unlikely slow-path */
> > +
> > +       /* Clear marker from stack-frame */
> > +       andl    $(~CS_FROM_ENTRY_STACK), PT_CS(%esp)
> > +
> > +       /* Copy the remaining task-stack contents to entry-stack */
> > +       movl    %esp, %esi
> > +       movl    PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
> 
> I'm confused.  Why do we need any special handling here at all?  How
> could we end up with the contents of the stack frame we interrupted in
> a corrupt state?
> 
> I guess I don't understand why this patch is needed.

The patch is needed because we can get exceptions in kernel-mode while
we are already on user-cr3 and entry-stack. In this case we need to
return with user-cr3 and entry-stack to the kernel too, otherwise we
would go to user-space with kernel-cr3.

So based on that, I did the above because the entry-stack is a per-cpu
data structure and I am not sure that we always return from the exception
on the same CPU where we got it. Therefore the path is called
PARANOID_... :)


Regards,

	Joerg
