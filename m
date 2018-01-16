Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A87486B027D
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:59:03 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id u4so4503306iti.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:59:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 103sor1395796iok.306.2018.01.16.10.59.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 10:59:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Jan 2018 10:59:01 -0800
Message-ID: <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
> here is my current WIP code to enable PTI on x86-32. It is
> still in a pretty early state, but it successfully boots my
> KVM guest with PAE and with legacy paging. The existing PTI
> code for x86-64 already prepares a lot of the stuff needed
> for 32 bit too, thanks for that to all the people involved
> in its development :)

Yes, I'm very happy to see that this is actually not nearly as bad as
I feared it might be,

Some of those #ifdef's in the PTI code you added might want more
commentary about what the exact differences are. And maybe they could
be done more cleanly with some abstraction. But nothing looked
_horrible_.

> The code has not run on bare-metal yet, I'll test that in
> the next days once I setup a 32 bit box again. I also havn't
> tested Wine and DosEMU yet, so this might also be broken.

.. and please run all the segment and syscall selfchecks that Andy has written.

But yes, checking bare metal, and checking the "odd" applications like
Wine and dosemu (and kvm etc) within the PTI kernel is certainly a
good idea.

> One of the things that are surely broken is XEN_PV support.
> I'd appreciate any help with testing and bugfixing on that
> front.

Xen PV and PTI don't work together even on x86-64 afaik, the Xen
people apparently felt it wasn't worth it.  See the

        if (hypervisor_is_type(X86_HYPER_XEN_PV)) {
                pti_print_if_insecure("disabled on XEN PV.");
                return;
        }

in pti_check_boottime_disable().

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
