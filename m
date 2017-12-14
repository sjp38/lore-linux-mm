Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6CB26B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:48:51 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p144so10681623itc.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:48:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u35sor2688343iou.218.2017.12.14.13.48.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 13:48:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
 <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
 <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com> <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 13:48:50 -0800
Message-ID: <CA+55aFxmwpkDNT0YcaiG-BQ5SUT6h6YkevVfNkU_eY-F2E-h7Q@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 1:44 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So it clearly needs to have the PAGE_USER bit clear (to avoid users
> accessing it directly), and it needs to be marked somehow for
> get_user_pages() to refuse it too, and access_ok() needs to fail it so
> that we can't do get_user/put_user on it.

Actually, just clearing PAGE_USER should make gup avoid it automatically.

So really the only other thing it needs is to have access_ok() avoid
it so that the kernel can't be fooled into accessing it for the user.

That does probably mean having to put it at the top of the user
address space and playing games with user_addr_max(). Which is not
wonderful, but certainly not rocket surgery either.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
