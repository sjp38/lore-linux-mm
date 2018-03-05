Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0C596B0062
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:32:02 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e14so4146741itd.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:32:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b76sor4147819itb.67.2018.03.05.12.32.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:32:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305182524.GT16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-12-git-send-email-joro@8bytes.org> <CAMzpN2h3xkhw_A4VeeA47=oykKgxXeumHM-q0QpaA8+fwFVRjw@mail.gmail.com>
 <20180305182524.GT16484@8bytes.org>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 5 Mar 2018 15:32:01 -0500
Message-ID: <CAMzpN2hHSpcxz+dTpHhZuXh7QuvOai9_Yc6W3dG6br4oCV56EQ@mail.gmail.com>
Subject: Re: [PATCH 11/34] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 5, 2018 at 1:25 PM, Joerg Roedel <joro@8bytes.org> wrote:
> Hi Brian,
>
> thanks for your review and helpful input.
>
> On Mon, Mar 05, 2018 at 11:41:01AM -0500, Brian Gerst wrote:
>> On Mon, Mar 5, 2018 at 5:25 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> > +.Lentry_from_kernel_\@:
>> > +
>> > +       /*
>> > +        * This handles the case when we enter the kernel from
>> > +        * kernel-mode and %esp points to the entry-stack. When this
>> > +        * happens we need to switch to the task-stack to run C code,
>> > +        * but switch back to the entry-stack again when we approach
>> > +        * iret and return to the interrupted code-path. This usually
>> > +        * happens when we hit an exception while restoring user-space
>> > +        * segment registers on the way back to user-space.
>> > +        *
>> > +        * When we switch to the task-stack here, we can't trust the
>> > +        * contents of the entry-stack anymore, as the exception handler
>> > +        * might be scheduled out or moved to another CPU. Therefore we
>> > +        * copy the complete entry-stack to the task-stack and set a
>> > +        * marker in the iret-frame (bit 31 of the CS dword) to detect
>> > +        * what we've done on the iret path.
>>
>> We don't need to worry about preemption changing the entry stack.  The
>> faults that IRET or segment loads can generate just run the exception
>> fixup handler and return.  Interrupts were disabled when the fault
>> occurred, so the kernel cannot be preempted.  The other case to watch
>> is #DB on SYSENTER, but that simply returns and doesn't sleep either.
>>
>> We can keep the same process as the existing debug/NMI handlers -
>> leave the current exception pt_regs on the entry stack and just switch
>> to the task stack for the call to the handler.  Then switch back to
>> the entry stack and continue.  No copying needed.
>
> Okay, I'll look into that. Will it even be true for fully preemptible
> and RT kernels that there can't be any preemption of these handlers?

See resume_kernel in the 32-bit entry for how preemption is handled on
return to kernel mode.  Looking at the RT patches, they still respect
disabling interrupts also disabling preemption.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
