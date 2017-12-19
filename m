Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3499B6B0261
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:10:23 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y15so11242896wrc.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:10:23 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.184])
        by mx.google.com with ESMTPS id q6si3588452edg.489.2017.12.19.04.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 04:10:21 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch 11/16] x86/ldt: Force access bit for CS/SS
Date: Tue, 19 Dec 2017 12:10:34 +0000
Message-ID: <2956b9271ecf4a859ef8eb112940cd3b@AcuMS.aculab.com>
References: <20171212173221.496222173@linutronix.de>
 <20171212173334.176469949@linutronix.de>
 <CA+55aFwzkdB7FoVcmyqBvHu2HyE+pBe_KEgN5G3KJx8ZCGW_jQ@mail.gmail.com>
 <BF0E88FD-9438-4ABF-82BD-AA634F957C3D@amacapital.net>
In-Reply-To: <BF0E88FD-9438-4ABF-82BD-AA634F957C3D@amacapital.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andy Lutomirski' <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

From: Andy Lutomirski
> Sent: 12 December 2017 19:27
...
> > Why is the iret exception unrecoverable anyway? Does anybody even know?
> >
>=20
> Weird microcode shit aside, a fault on IRET will return to kernel code wi=
th kernel GS, and then the
> next time we enter the kernel we're backwards.  We could fix idtentry to =
get this right, but the code
> is already tangled enough.
...

Notwithstanding a readonly LDT, the iret (and pop %ds, pop %es that probabl=
y
precede it) are all likely to fault in kernel if the segment registers are =
invalid.
(Setting %fs and %gs for 32 bit processes is left to the reader.)

Unlike every other fault in the kernel code segment, gsbase will contain
the user value, not the kernel one.

The kernel code must detect this somehow and correct everything before (pro=
bably)
generating a SIGSEGV and returning to the user's signal handler with the
invalid segment registers in the signal context.

Assuming this won't happen (because the segment registers are always valid)
is likely to be a recipe for disaster (or an escalation).

I guess the problem with a readonly LDT is that you don't want to fault
setting the 'accesses' bit.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
