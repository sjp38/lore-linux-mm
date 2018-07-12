Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CAE86B026E
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:49:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i123-v6so11199405pfc.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:49:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor2584893pfd.56.2018.07.12.13.49.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 13:49:15 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 03/39] x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1531308586-29340-4-git-send-email-joro@8bytes.org>
Date: Thu, 12 Jul 2018 13:49:13 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <823BAA9B-FACA-4E91-BE56-315FF569297C@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-4-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de



> On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>=20
> From: Joerg Roedel <jroedel@suse.de>
> We want x86_tss.sp0 point to the entry stack later to use
> it as a trampoline stack for other kernel entry points
> besides SYSENTER.

Makes sense: sp0 will be the entry stack. But:

>=20
>=20
>    /* Offset from the sysenter stack to tss.sp0 */
> -    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.s=
p0) -
> +    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.s=
p1) -
>           offsetofend(struct cpu_entry_area, entry_stack_page.stack));
>=20

The code reads differently. Did you perhaps mean TSS_task_stack?

Also, the =E2=80=9Ctop of task stack=E2=80=9D is a bit weird on 32-bit due t=
o vm86. Can you document *exactly* what goes in sp1?
