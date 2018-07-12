Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8892B6B0272
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:09:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u16-v6so19286926pfm.15
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 14:09:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16-v6sor5246336pfy.18.2018.07.12.14.09.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 14:09:48 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1531308586-29340-8-git-send-email-joro@8bytes.org>
Date: Thu, 12 Jul 2018 14:09:45 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A66D58A6-3DC6-4CF3-B2A5-433C6E974060@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-8-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de



> On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>=20
> From: Joerg Roedel <jroedel@suse.de>
>=20
> Use the entry-stack as a trampoline to enter the kernel. The
> entry-stack is already in the cpu_entry_area and will be
> mapped to userspace when PTI is enabled.
>=20
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
> arch/x86/entry/entry_32.S        | 136 +++++++++++++++++++++++++++++++----=
----
> arch/x86/include/asm/switch_to.h |   6 +-
> arch/x86/kernel/asm-offsets.c    |   1 +
> arch/x86/kernel/cpu/common.c     |   5 +-
> arch/x86/kernel/process.c        |   2 -
> arch/x86/kernel/process_32.c     |  10 +--
> 6 files changed, 121 insertions(+), 39 deletions(-)
>=20
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 61303fa..528db7d 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -154,25 +154,36 @@
>=20
> #endif /* CONFIG_X86_32_LAZY_GS */
>=20
> -.macro SAVE_ALL pt_regs_ax=3D%eax
> +.macro SAVE_ALL pt_regs_ax=3D%eax switch_stacks=3D0
>    cld
> +    /* Push segment registers and %eax */
>    PUSH_GS
>    pushl    %fs
>    pushl    %es
>    pushl    %ds
>    pushl    \pt_regs_ax
> +
> +    /* Load kernel segments */
> +    movl    $(__USER_DS), %eax

If \pt_regs_ax !=3D %eax, then this will behave oddly. Maybe it=E2=80=99s ok=
ay. But I don=E2=80=99t see why this change was needed at all.

> +    movl    %eax, %ds
> +    movl    %eax, %es
> +    movl    $(__KERNEL_PERCPU), %eax
> +    movl    %eax, %fs
> +    SET_KERNEL_GS %eax
> +
> +    /* Push integer registers and complete PT_REGS */
>    pushl    %ebp
>    pushl    %edi
>    pushl    %esi
>    pushl    %edx
>    pushl    %ecx
>    pushl    %ebx
> -    movl    $(__USER_DS), %edx
> -    movl    %edx, %ds
> -    movl    %edx, %es
> -    movl    $(__KERNEL_PERCPU), %edx
> -    movl    %edx, %fs
> -    SET_KERNEL_GS %edx
> +
> +    /* Switch to kernel stack if necessary */
> +.if \switch_stacks > 0
> +    SWITCH_TO_KERNEL_STACK
> +.endif
> +
> .endm
>=20
> /*
> @@ -269,6 +280,72 @@
> .Lend_\@:
> #endif /* CONFIG_X86_ESPFIX32 */
> .endm
> +
> +
> +/*
> + * Called with pt_regs fully populated and kernel segments loaded,
> + * so we can access PER_CPU and use the integer registers.
> + *
> + * We need to be very careful here with the %esp switch, because an NMI
> + * can happen everywhere. If the NMI handler finds itself on the
> + * entry-stack, it will overwrite the task-stack and everything we
> + * copied there. So allocate the stack-frame on the task-stack and
> + * switch to it before we do any copying.

Ick, right. Same with machine check, though. You could alternatively fix it b=
y running NMIs on an irq stack if the irq count is zero.  How confident are y=
ou that you got #MC right?

> + */
> +.macro SWITCH_TO_KERNEL_STACK
> +
> +    ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
> +
> +    /* Are we on the entry stack? Bail out if not! */
> +    movl    PER_CPU_VAR(cpu_entry_area), %edi
> +    addl    $CPU_ENTRY_AREA_entry_stack, %edi
> +    cmpl    %esp, %edi
> +    jae    .Lend_\@

That=E2=80=99s an alarming assumption about the address space layout. How ab=
out an xor and an and instead of cmpl?  As it stands, if the address layout e=
ver changes, the failure may be rather subtle.

Anyway, wouldn=E2=80=99t it be easier to solve this by just not switching st=
acks on entries from kernel mode and making the entry stack bigger?  Stick a=
n assertion in the scheduling code that we=E2=80=99re not on an entry stack,=
 perhaps.
