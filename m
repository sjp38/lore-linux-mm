Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27366B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:09:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so6353319pgp.6
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 10:09:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w1-v6si2014477plq.115.2018.07.20.10.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 10:09:48 -0700 (PDT)
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3665C20874
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:09:48 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id g6-v6so11968559wrp.0
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 10:09:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1532103744-31902-4-git-send-email-joro@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <1532103744-31902-4-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 20 Jul 2018 10:09:26 -0700
Message-ID: <CALCETrWmd3arHdkTzAS7reLRjm96jrJC-1O5dYAPwbh2EqKMSA@mail.gmail.com>
Subject: Re: [PATCH 3/3] x86/entry/32: Copy only ptregs on paranoid entry/exit path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, Jul 20, 2018 at 9:22 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> The code that switches from entry- to task-stack when we
> enter from kernel-mode copies the full entry-stack contents
> to the task-stack.
>
> That is because we don't trust that the entry-stack
> contents. But actually we can trust its contents if we are
> not scheduled between entry and exit.
>
> So do less copying and move only the ptregs over to the
> task-stack in this code-path.
>
> Suggested-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S | 70 +++++++++++++++++++++++++----------------------
>  1 file changed, 38 insertions(+), 32 deletions(-)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 2767c62..90166b2 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -469,33 +469,48 @@
>          * segment registers on the way back to user-space or when the
>          * sysenter handler runs with eflags.tf set.
>          *
> -        * When we switch to the task-stack here, we can't trust the
> -        * contents of the entry-stack anymore, as the exception handler
> -        * might be scheduled out or moved to another CPU. Therefore we
> -        * copy the complete entry-stack to the task-stack and set a
> -        * marker in the iret-frame (bit 31 of the CS dword) to detect
> -        * what we've done on the iret path.
> +        * When we switch to the task-stack here, we extend the
> +        * stack-frame we copy to include the entry-stack %esp and a
> +        * pseudo %ss value so that we have a full ptregs struct on the
> +        * stack. We set a marker in the frame (bit 31 of the CS dword).
>          *
> -        * On the iret path we copy everything back and switch to the
> -        * entry-stack, so that the interrupted kernel code-path
> -        * continues on the same stack it was interrupted with.
> +        * On the iret path we read %esp from the PT_OLDESP slot on the
> +        * stack and copy ptregs (except oldesp and oldss) to it, when
> +        * we find the marker set. Then we switch to the %esp we read,
> +        * so that the interrupted kernel code-path continues on the
> +        * same stack it was interrupted with.


Can you give an example of the exact scenario in which any of this
copying happens and why it's needed?  IMO you should just be able to
*run* on the entry stack without copying anything at all.
