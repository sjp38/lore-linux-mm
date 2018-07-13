Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1C86B0006
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:22:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f13-v6so6384020wmb.4
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 10:22:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m193-v6sor1841806wma.79.2018.07.13.10.22.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 10:22:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180713105620.z6bjhqzfez2hll6r@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-8-git-send-email-joro@8bytes.org> <A66D58A6-3DC6-4CF3-B2A5-433C6E974060@amacapital.net>
 <20180713105620.z6bjhqzfez2hll6r@8bytes.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Jul 2018 10:21:39 -0700
Message-ID: <CALCETrW4XMD9TSTxK3h-3p5ZE5Z=DupiUBtiXnMmSprbXtJr3g@mail.gmail.com>
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Fri, Jul 13, 2018 at 3:56 AM, Joerg Roedel <joro@8bytes.org> wrote:
> Hi Andy,
>
> thanks for you valuable feedback.
>
> On Thu, Jul 12, 2018 at 02:09:45PM -0700, Andy Lutomirski wrote:
>> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> > -.macro SAVE_ALL pt_regs_ax=3D%eax
>> > +.macro SAVE_ALL pt_regs_ax=3D%eax switch_stacks=3D0
>> >    cld
>> > +    /* Push segment registers and %eax */
>> >    PUSH_GS
>> >    pushl    %fs
>> >    pushl    %es
>> >    pushl    %ds
>> >    pushl    \pt_regs_ax
>> > +
>> > +    /* Load kernel segments */
>> > +    movl    $(__USER_DS), %eax
>>
>> If \pt_regs_ax !=3D %eax, then this will behave oddly. Maybe it=E2=80=99=
s okay.
>> But I don=E2=80=99t see why this change was needed at all.
>
> This is a left-over from a previous approach I tried and then abandoned
> later. You are right, it is not needed.
>
>> > +/*
>> > + * Called with pt_regs fully populated and kernel segments loaded,
>> > + * so we can access PER_CPU and use the integer registers.
>> > + *
>> > + * We need to be very careful here with the %esp switch, because an N=
MI
>> > + * can happen everywhere. If the NMI handler finds itself on the
>> > + * entry-stack, it will overwrite the task-stack and everything we
>> > + * copied there. So allocate the stack-frame on the task-stack and
>> > + * switch to it before we do any copying.
>>
>> Ick, right. Same with machine check, though. You could alternatively
>> fix it by running NMIs on an irq stack if the irq count is zero.  How
>> confident are you that you got #MC right?
>
> Pretty confident, #MC uses the exception entry path which also handles
> entry-stack and user-cr3 correctly. It might go through through the slow
> paranoid exit path, but that's okay for #MC I guess.
>
> And when the #MC happens while we switch to the task stack and do the
> copying the same precautions as for NMI apply.
>
>> > + */
>> > +.macro SWITCH_TO_KERNEL_STACK
>> > +
>> > +    ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
>> > +
>> > +    /* Are we on the entry stack? Bail out if not! */
>> > +    movl    PER_CPU_VAR(cpu_entry_area), %edi
>> > +    addl    $CPU_ENTRY_AREA_entry_stack, %edi
>> > +    cmpl    %esp, %edi
>> > +    jae    .Lend_\@
>>
>> That=E2=80=99s an alarming assumption about the address space layout. Ho=
w
>> about an xor and an and instead of cmpl?  As it stands, if the address
>> layout ever changes, the failure may be rather subtle.
>
> Right, I implement a more restrictive check.

But the check needs to be correct or we'll mess up, right?  I think
the code will be much more robust and easier to review if you check
"on the entry stack" instead of ">=3D the entry stack".  (Or <=3D -- I can
never remember how this works in AT&T syntax.)

>
>> Anyway, wouldn=E2=80=99t it be easier to solve this by just not switchin=
g
>> stacks on entries from kernel mode and making the entry stack bigger?
>> Stick an assertion in the scheduling code that we=E2=80=99re not on an e=
ntry
>> stack, perhaps.
>
> That'll save us the check whether we are on the entry stack and replace
> it with a check whether we are coming from user/vm86 mode. I don't think
> that this will simplify things much and I am a bit afraid that it'll
> break unwritten assumptions elsewhere. It is probably something we can
> look into later separatly from the basic pti-x32 enablement.
>

Fair enough.  There's also the issue that NMI still has to switch CR3
if it hits with the wrong CR3.

I personally much prefer checking whether you came from user mode
rather than the stack address, but I'm okay with either approach here.
