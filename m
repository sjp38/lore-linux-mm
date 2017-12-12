Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7474A6B0253
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:21:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v69so12852815wrb.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:21:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r136si165682wmf.262.2017.12.12.11.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 11:21:53 -0800 (PST)
Date: Tue, 12 Dec 2017 20:21:22 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
In-Reply-To: <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712122017100.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de> <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Linus Torvalds wrote:

> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > From: Thomas Gleixner <tglx@linutronix.de>
> >
> > When the LDT is mapped RO, the CPU will write fault the first time it uses
> > a segment descriptor in order to set the ACCESS bit (for some reason it
> > doesn't always observe that it already preset). Catch the fault and set the
> > ACCESS bit in the handler.
> 
> This really scares me.
> 
> We use segments in some critical code in the kernel, like the whole
> percpu data etc. Stuff that definitely shouldn't fault.
> 
> Yes, those segments should damn well be already marked accessed when
> the segment is loaded, but apparently that isn't reliable.

That has nothing to do with the user installed LDT. The kernel does not use
and rely on LDT at all.

The only critical interaction is the return to user path (user CS/SS) and
we made sure with the LAR touching that these are precached in the CPU
before we go into fragile exit code. Luto has some concerns
vs. load_gs[_index] and we'll certainly look into that some more.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
