Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB006B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:12:34 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p13so4605187wmc.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:12:34 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id n1si554767edc.511.2018.03.05.05.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:12:33 -0800 (PST)
Date: Mon, 5 Mar 2018 14:12:31 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Message-ID: <20180305131231.GR16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org>
 <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 05, 2018 at 04:17:45AM -0800, Linus Torvalds wrote:
>     Restoring the segments can cause exceptions that need to be
>     handled. With PTI enabled, we still need to be on kernel cr3
>     when the exception happens. For the cr3-switch we need
>     at least one integer scratch register, so we can't switch
>     with the user integer registers already loaded.
> 
> 
> This fundamentally seems wrong.

Okay, right, with v3 it is wrong, in v2 I still thought I could get away
without remembering the entry-cr3, but didn't think about the #DB case
then.

In v3 I added code which remembers the entry-cr3 and handles the
entry-from-kernel-mode-with-user-cr3 case for all exceptions including
#DB.

> The things is, we *know* that we will restore two segment registers with the
> user cr3 already loaded: CS and SS get restored with the final iret.

Yeah, I know, but the iret-exception path is fine because it will
deliver a SIGILL and doesn't return to the faulting iret.

Anyway, I will remove these restore-reorderings, they are not needed
anymore.

> So has this been tested with
> 
>  - single-stepping through sysenter
> 
>    This takes a DB fault in the first kernel instruction. We're in kernel mode,
> but with user cr3.
> 
>  - ptracing and setting CS/SS to something bad
> 
>    That should test the "exception on iret" case - again in kernel mode, but
> with user cr3 restored for the return.

The iret-exception case is tested by the ldt_gdt selftest (the
do_multicpu_tests subtest). But I didn't actually tested single-stepping
through sysenter yet. I just re-ran the same tests I did with v2 on this
patch-set.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
