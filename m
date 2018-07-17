Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61CBE6B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:06:33 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z13-v6so791294wrt.19
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:06:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3-v6sor886741wre.17.2018.07.17.13.06.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 13:06:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180717071545.ojdall7tatbjtfai@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-11-git-send-email-joro@8bytes.org> <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
 <20180714052110.cobtew6rms23ih37@suse.de> <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
 <20180714080159.hqp36q7fxzb2ktlq@suse.de> <75BDF04F-9585-438C-AE04-918FBE00A174@amacapital.net>
 <20180717071545.ojdall7tatbjtfai@suse.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Jul 2018 13:06:11 -0700
Message-ID: <CALCETrXAF6+mkDL4+uQdHQdJ=G70YVu_k55P_x6Mgi4hXe3oYw@mail.gmail.com>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Tue, Jul 17, 2018 at 12:15 AM, Joerg Roedel <jroedel@suse.de> wrote:
> On Sat, Jul 14, 2018 at 07:36:47AM -0700, Andy Lutomirski wrote:
>> But I=E2=80=99m still unconvinced. If any code executed with IRQs enable=
d on
>> the entry stack, then that code is terminally buggy. If you=E2=80=99re
>> executing with IRQs off, you=E2=80=99re not going to get migrated.  64-b=
it
>> kernels run on percpu stacks all the time, and it=E2=80=99s not a proble=
m.
>
> The code switches to the kernel-stack and kernel-cr3 and just remembers
> where it came from (to handle the entry-from-kernel with entry-stack
> and/or user-cr3 case). IRQs are disabled in the entry-code path. But
> ultimately it calls into C code to handle the exception. And there IRQs
> might get enabled again.
>
>> IRET errors are genuinely special and, if they=E2=80=99re causing a prob=
lem
>> for you, we should fix them the same way we deal with them on x86_64.
>
> Right, IRET is handled differently and doesn't need this patch. But the
> segment-writing exceptions do.
>
> If you insist on it I can try to implement the assumption that we don't
> get preempted in this code-path. That will safe us some cycles for
> copying stack contents in this unlikely slow-path. But we definitly need
> to handle the entry-from-kernel with entry-stack and/or user-cr3 case
> correctly and make a switch to kernel-stack/cr3 because we are going to
> call into C-code.
>
>

Yes, we obviously need to restore the correct cr3.  But I really don't
like the code that rewrites the stack frame that we're about to IRET
to, especially when it doesn't seem to serve a purpose.  I'd much
rather the code just get its CR3 right and do the IRET and trust that
the frame it's returning to is still there.
