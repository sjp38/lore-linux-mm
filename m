Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC4A36B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:44:04 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 207so10909203iti.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:44:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m15sor3214649itb.117.2017.12.14.13.44.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 13:44:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
 <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com> <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 13:44:03 -0800
Message-ID: <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 1:22 PM, Andy Lutomirski <luto@kernel.org> wrote:
>
> Which kind of kills the whole thing.  There's no way the idea of
> putting the LDT in a VMA is okay if it's RW.

Sure there is.

I really don't understand why you guys think it has to be RO.

All it has to be is not _user_ accessible. And that's a requirement
regardless, because no way in hell should users be able to read the
damn thing.

So it clearly needs to have the PAGE_USER bit clear (to avoid users
accessing it directly), and it needs to be marked somehow for
get_user_pages() to refuse it too, and access_ok() needs to fail it so
that we can't do get_user/put_user on it.

But the whole RO vs RW is not fundamentally critical.

Now, I do agree that RO is much much better in general, and it avoids
the requirement to play games with "access_ok()" and friends (assuming
we're just ok with users reading it), but I disagree with the whole
"this is fundamental".

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
