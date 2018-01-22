Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 492A4800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 05:11:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s9so4738752wra.10
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 02:11:20 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id c10si80807edf.457.2018.01.22.02.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 02:11:19 -0800 (PST)
Date: Mon, 22 Jan 2018 11:11:18 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Message-ID: <20180122101118.GG28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org>
 <CALCETrUqJ8Vga5pGWUuOox5cw6ER-4MhZXLb-4JPyh+Txsp4tg@mail.gmail.com>
 <20180117091853.GI28161@8bytes.org>
 <CALCETrUPcWfNA6ETktcs2vmcrPgJs32xMpoATGn_BFk+1ueU7g@mail.gmail.com>
 <20180119095523.GY28161@8bytes.org>
 <CALCETrWSUJY=Har-Fvcby4SY_BPSh=WL0X_MqsT2z+tfNshWDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWSUJY=Har-Fvcby4SY_BPSh=WL0X_MqsT2z+tfNshWDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

Hey Andy,

On Fri, Jan 19, 2018 at 08:30:33AM -0800, Andy Lutomirski wrote:
> I meant that we could have sp0 have a genuinely constant value per
> cpu.  That means that the entry trampoline ends up with RIP, etc in a
> different place depending on whether VM was in use, but the entry
> trampoline code should be able to handle that.  sp1 would have a value
> that varies by task, but it could just point to the top of the stack
> instead of being changed depending on whether VM is in use.  Instead,
> the entry trampoline would offset the registers as needed to keep
> pt_regs in the right place.
> 
> I think you already figured all of that out, though :)

Yes, and after looking a while into it, it would make a nice cleanup for
the entry code. On the other side, it would change the layout for the
in-kernel 'struct pt_regs', so that the user-visible pt_regs ends up
with a different layout than the one we use in the the kernel.

This can certainly be all worked out, but it makes this nice entry-code
cleanup not so nice and clean anymore. At least the work required to
make it work without breaking user-space is not in the scope of this
patch-set.


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
