Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B42976B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:01:21 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id k190so65875iok.2
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:01:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor6955095ion.161.2017.12.12.11.01.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 11:01:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173334.345422294@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Dec 2017 11:01:18 -0800
Message-ID: <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> When the LDT is mapped RO, the CPU will write fault the first time it uses
> a segment descriptor in order to set the ACCESS bit (for some reason it
> doesn't always observe that it already preset). Catch the fault and set the
> ACCESS bit in the handler.

This really scares me.

We use segments in some critical code in the kernel, like the whole
percpu data etc. Stuff that definitely shouldn't fault.

Yes, those segments should damn well be already marked accessed when
the segment is loaded, but apparently that isn't reliable.

So it potentially takes faults in random and very critical places.
It's probably dependent on microarchitecture on exactly when the
cached segment copy has the accessed bit set or not.

Also, I worry about crazy errata with TSS etc - this whole RO LDT
thing also introduces lots of possible new fault points in microcode
that nobody sane has ever done before, no?

> +       desc = (struct desc_struct *) ldt->entries;
> +       entry = (address - start) / LDT_ENTRY_SIZE;
> +       desc[entry].type |= 0x01;

This is also pretty disgusting.

Why isn't it just something like

      desc = (void *)(address & ~(LDT_ENTRY_SIZE-1));
      desc->type != 0x01;

since the ldt should all be aligned anyway.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
