Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D20936B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 02:26:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id cf17-v6so13571972plb.2
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:26:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o12-v6sor4753494pfj.139.2018.07.13.23.26.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 23:26:58 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180714052110.cobtew6rms23ih37@suse.de>
Date: Fri, 13 Jul 2018 23:26:54 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-11-git-send-email-joro@8bytes.org> <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com> <20180714052110.cobtew6rms23ih37@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>



> On Jul 13, 2018, at 10:21 PM, Joerg Roedel <jroedel@suse.de> wrote:
>=20
>> On Fri, Jul 13, 2018 at 04:31:02PM -0700, Andy Lutomirski wrote:
>> What you're really doing is keeping it available for an extra flag.
>> Please update the comment as such.  But see below.
>=20
> Thanks, will do.
>=20
>>> +.macro PARANOID_EXIT_TO_KERNEL_MODE
>>> +
>>> +       /*
>>> +        * Test if we entered the kernel with the entry-stack. Most
>>> +        * likely we did not, because this code only runs on the
>>> +        * return-to-kernel path.
>>> +        */
>>> +       testl   $CS_FROM_ENTRY_STACK, PT_CS(%esp)
>>> +       jz      .Lend_\@
>>> +
>>> +       /* Unlikely slow-path */
>>> +
>>> +       /* Clear marker from stack-frame */
>>> +       andl    $(~CS_FROM_ENTRY_STACK), PT_CS(%esp)
>>> +
>>> +       /* Copy the remaining task-stack contents to entry-stack */
>>> +       movl    %esp, %esi
>>> +       movl    PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
>>=20
>> I'm confused.  Why do we need any special handling here at all?  How
>> could we end up with the contents of the stack frame we interrupted in
>> a corrupt state?
>>=20
>> I guess I don't understand why this patch is needed.
>=20
> The patch is needed because we can get exceptions in kernel-mode while
> we are already on user-cr3 and entry-stack. In this case we need to
> return with user-cr3 and entry-stack to the kernel too, otherwise we
> would go to user-space with kernel-cr3.
>=20
> So based on that, I did the above because the entry-stack is a per-cpu
> data structure and I am not sure that we always return from the exception
> on the same CPU where we got it. Therefore the path is called
> PARANOID_... :)

But we should just be able to IRET and end up right back on the entry stack w=
here we were when we got interrupted.

On x86_64, we *definitely* can=E2=80=99t schedule in NMI, MCE, or #DB becaus=
e we=E2=80=99re on a percpu stack. Are you *sure* we need this patch?

>=20
>=20
> Regards,
>=20
>    Joerg
>=20
