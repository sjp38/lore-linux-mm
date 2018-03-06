Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3F1F6B0006
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 07:27:03 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so6078747wmb.3
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 04:27:03 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id n8si3599829edd.444.2018.03.06.04.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 04:27:02 -0800 (PST)
Date: Tue, 6 Mar 2018 13:27:01 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 11/34] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180306122701.GX16484@8bytes.org>
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

On Mon, Mar 05, 2018 at 11:41:01AM -0500, Brian Gerst wrote:
> We can keep the same process as the existing debug/NMI handlers -
> leave the current exception pt_regs on the entry stack and just switch
> to the task stack for the call to the handler.  Then switch back to
> the entry stack and continue.  No copying needed.

I looked into this and things are a bit more complicated than in the NMI
and debug handlers. The current code after pt_regs is set up relies on
%esp pointing to the pt_regs structure. But if pt_regs could be on
another stack we need to carry the pt_regs pointer in another register
through the whole ret_from_exception code-path until we actually switch
back the stack.

Since the code-path is used for all stack/cr3 entry/exit cases we need
to setup the extra pt_regs pointer unconditionally and update all places
that reference it through %esp.

It can certainly be done but it looks like another major surgery in the
entry code to optimize a slow-path for handling unlikely segment-loading
exceptions and debug traps. I am not sure if it's worth it.

Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
