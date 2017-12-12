Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD3BD6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 16:46:43 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o20so155467wro.8
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:46:43 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x8si102026wrd.308.2017.12.12.13.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 13:46:42 -0800 (PST)
Date: Tue, 12 Dec 2017 22:46:07 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
In-Reply-To: <alpine.DEB.2.20.1712122219580.2289@nanos>
Message-ID: <alpine.DEB.2.20.1712122244221.2289@nanos>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de> <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com> <alpine.DEB.2.20.1712122017100.2289@nanos> <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
 <alpine.DEB.2.20.1712122124320.2289@nanos> <alpine.DEB.2.20.1712122219580.2289@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, 12 Dec 2017, Thomas Gleixner wrote:

> On Tue, 12 Dec 2017, Thomas Gleixner wrote:
> > On Tue, 12 Dec 2017, Dave Hansen wrote:
> > 
> > > On 12/12/2017 11:21 AM, Thomas Gleixner wrote:
> > > > The only critical interaction is the return to user path (user CS/SS) and
> > > > we made sure with the LAR touching that these are precached in the CPU
> > > > before we go into fragile exit code.
> > > 
> > > How do we make sure that it _stays_ cached?
> > > 
> > > Surely there is weird stuff like WBINVD or SMI's that can come at very
> > > inconvenient times and wipe it out of the cache.
> > 
> > This does not look like cache in the sense of memory cache. It seems to be
> > CPU internal state and I just stuffed WBINVD and alternatively CLFLUSH'ed
> > the entries after the 'touch' via LAR. Still works.
> 
> Dave pointed me once more to the following paragraph in the SDM, which
> Peter and I looked at before and we tried that w/o success:
> 
>     If the segment descriptors in the GDT or an LDT are placed in ROM, the
>     processor can enter an indefinite loop if software or the processor
>     attempts to update (write to) the ROM-based segment descriptors. To
>     prevent this problem, set the accessed bits for all segment descriptors
>     placed in a ROM. Also, remove operating-system or executive code that
>     attempts to modify segment descriptors located in ROM.
> 
> Now that made me go back to the state of the patch series which made us
> make that magic 'touch' and write fault handler. The difference to the code
> today is that it did not prepopulate the user visible mapping.
> 
> We added that later because we were worried about not being able to
> populate it in the #PF due to memory pressure without ripping out the magic
> cure again.
> 
> But I did now and actually removing both the user exit magic 'touch' code
> and the write fault handler keeps it working.
> 
> Removing the prepopulate code makes it break again with a #GP in
> IRET/SYSRET.
> 
> What happens there is that the IRET pops SS (with a minimal testcase) which
> causes the #PF. That populates the PTE and returns happily. Right after
> that the #GP comes in with IP pointing to the user space instruction right
> after the syscall.
> 
> That simplifies and descaryfies that code massively.
> 
> Darn, I should have gone back and check every part again as I usually do,
> but my fried brain failed.

The magic write ACCESS bit handler is a left over from the early attempts
not to force ACCESS=1 when setting up the descriptor entry.

Bah. My patch stack history proves where the 3 cross roads are where I took
the wrong turn.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
