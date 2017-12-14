Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2EB46B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:11:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j3so5817240pfh.16
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:11:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11sor1466793pfl.12.2017.12.14.14.11.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 14:11:06 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CA+55aFxmwpkDNT0YcaiG-BQ5SUT6h6YkevVfNkU_eY-F2E-h7Q@mail.gmail.com>
Date: Thu, 14 Dec 2017 14:11:03 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <B3532E4F-408A-450A-96FF-17763916934C@amacapital.net>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org> <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com> <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com> <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com> <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com> <CA+55aFxmwpkDNT0YcaiG-BQ5SUT6h6YkevVfNkU_eY-F2E-h7Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>


> On Dec 14, 2017, at 1:48 PM, Linus Torvalds <torvalds@linux-foundation.org=
> wrote:
>=20
> On Thu, Dec 14, 2017 at 1:44 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>=20
>> So it clearly needs to have the PAGE_USER bit clear (to avoid users
>> accessing it directly), and it needs to be marked somehow for
>> get_user_pages() to refuse it too, and access_ok() needs to fail it so
>> that we can't do get_user/put_user on it.
>=20
> Actually, just clearing PAGE_USER should make gup avoid it automatically.
>=20
> So really the only other thing it needs is to have access_ok() avoid
> it so that the kernel can't be fooled into accessing it for the user.
>=20
> That does probably mean having to put it at the top of the user
> address space and playing games with user_addr_max(). Which is not
> wonderful, but certainly not rocket surgery either.

That seems to rather defeat the point of using a VMA, though.  And it means w=
e still have to do a full cmp instead of just checking a sign bit in access_=
ok if we ever manage to kill set_fs().

Again, I have an apparently fully functional patch to alias the LDT at a hig=
h (kernel) address where we can cleanly map it in the user pagetables withou=
t any of this VMA stuff.  It's much less code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
