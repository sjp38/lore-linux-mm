Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFE06B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:26:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e69so16403624pgc.15
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:26:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g10sor4947294pge.372.2017.12.12.11.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 11:26:33 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CA+55aFwzkdB7FoVcmyqBvHu2HyE+pBe_KEgN5G3KJx8ZCGW_jQ@mail.gmail.com>
Date: Tue, 12 Dec 2017 11:26:30 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <BF0E88FD-9438-4ABF-82BD-AA634F957C3D@amacapital.net>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de> <CA+55aFwzkdB7FoVcmyqBvHu2HyE+pBe_KEgN5G3KJx8ZCGW_jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>



> On Dec 12, 2017, at 11:05 AM, Linus Torvalds <torvalds@linux-foundation.or=
g> wrote:
>=20
>> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wro=
te:
>>=20
>> There is one exception; IRET will immediately load CS/SS and unrecoverabl=
y
>> #GP. To avoid this issue access the LDT descriptors used by CS/SS before
>> the IRET to userspace.
>=20
> Ok, so the other patch made me nervous, this just makes me go "Hell no!".
>=20
> This is exactly the kind of "now we get traps in random microcode
> places that have never been tested" kind of thing that I was talking
> about.
>=20
> Why is the iret exception unrecoverable anyway? Does anybody even know?
>=20

Weird microcode shit aside, a fault on IRET will return to kernel code with k=
ernel GS, and then the next time we enter the kernel we're backwards.  We co=
uld fix idtentry to get this right, but the code is already tangled enough.

This series is full of landmines, I think.  My latest patch set has a fully f=
unctional LDT with PTI on, and the only thing particularly scary about it is=
 that it fiddles with page tables.  Other than that, there's no VMA magic, n=
o RO magic, and no microcode magic.  And the LDT is still normal kernel memo=
ry, so we can ignore a whole pile of potential attacks.=20

Also, how does it make any sense to have a cached descriptor that's not acce=
ssed?  Xen PV does weird LDT page fault shit, and is works, so I suspect we'=
re just misunderstanding something.  The VMX spec kind of documents this...

>                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
