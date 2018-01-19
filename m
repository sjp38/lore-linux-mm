Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CECB56B025E
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:55:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 194so804918wmv.9
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:55:29 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id p4si1782281edm.328.2018.01.19.01.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 01:55:25 -0800 (PST)
Date: Fri, 19 Jan 2018 10:55:23 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Message-ID: <20180119095523.GY28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
 <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
 <20180117091853.GI28161@8bytes.org>
 <CALCETrUPcWfNA6ETktcs2vmcrPgJs32xMpoATGn_BFk+1ueU7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUPcWfNA6ETktcs2vmcrPgJs32xMpoATGn_BFk+1ueU7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

Hey Andy,

On Wed, Jan 17, 2018 at 10:10:23AM -0800, Andy Lutomirski wrote:
> On Wed, Jan 17, 2018 at 1:18 AM, Joerg Roedel <joro@8bytes.org> wrote:

> > Just read up on vm86 mode control transfers and the stack layout then.
> > Looks like I need to check for eflags.vm=1 and copy four more registers
> > from/to the entry stack. Thanks for pointing that out.
> 
> You could just copy those slots unconditionally.  After all, you're
> slowing down entries by an epic amount due to writing CR3 on with PCID
> off, so four words copied should be entirely lost in the noise.  OTOH,
> checking for VM86 mode is just a single bt against EFLAGS.
> 
> With the modern (rewritten a year or two ago by Brian Gerst) vm86
> code, all the slots (those actually in pt_regs) are in the same
> location regardless of whether we're in VM86 mode or not, but we're
> still fiddling with the bottom of the stack.  Since you're controlling
> the switch to the kernel thread stack, you can easily just write the
> frame to the correct location, so you should not need to context
> switch sp1 -- you can do it sanely and leave sp1 as the actual bottom
> of the kernel stack no matter what.  In fact, you could probably avoid
> context switching sp0, either, which would be a nice cleanup.

I am not sure what you mean by "not context switching sp0/sp1" ...

> So I recommend the following.  Keep sp0 as the bottom of the sysenter
> stack no matter what.  Then do:
> 
> bt $X86_EFLAGS_VM_BIT
> jc .Lfrom_vm_\@
> 
> push 5 regs to real stack, starting at four-word offset (so they're in
> the right place)
> update %esp
> ...
> .Lupdate_esp_\@
> 
> .Lfrom_vm_\@:
> push 9 regs to real stack, starting at the bottom
> jmp .Lupdate_esp_\@
> 
> Does that seem reasonable?  It's arguably much nicer than what we have
> now.

But that looks like a good idea. Having a consistent stack with and
without vm86 is certainly a nice cleanup.


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
