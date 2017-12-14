Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 481166B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:24:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a74so5839609pfg.20
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:24:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j191si3491908pgc.771.2017.12.14.14.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 14:24:51 -0800 (PST)
Date: Thu, 14 Dec 2017 23:24:39 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit
 forced
Message-ID: <20171214222439.rovm3t7iaakefati@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.647809433@infradead.org>
 <CALCETrW0=FnqZMU_MLebyy5m7jj=w=yHYx=u6vghFkdmG7vsww@mail.gmail.com>
 <CA+55aFz71Ycm3oez30zOCztx1sio8ioy3VED2rE0ORoExXBz2g@mail.gmail.com>
 <CALCETrU8=z92_ZtwR9EO56eeOBE1LbxOqigZGO_yahmcM2dE_A@mail.gmail.com>
 <CA+55aFyNN4Lhf4RhL95oeGvfng=H4wKSA3-MwzMo=KpBocQ7bA@mail.gmail.com>
 <CA+55aFxmwpkDNT0YcaiG-BQ5SUT6h6YkevVfNkU_eY-F2E-h7Q@mail.gmail.com>
 <20171214220226.GL3326@worktop>
 <CA+55aFzT=+Vc75O8yjGYcSiWVVvrRMOZT2Ydhs7S=0RUAtscAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzT=+Vc75O8yjGYcSiWVVvrRMOZT2Ydhs7S=0RUAtscAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 02:14:00PM -0800, Linus Torvalds wrote:
> On Thu, Dec 14, 2017 at 2:02 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > _Should_ being the operative word, because I cannot currently see it
> > DTRT. But maybe I'm missing the obvious -- I tend to do that at times.
> 
> At least the old get_user_pages_fast() code used to check the USER bit:
> 
>         unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;
> 
>         if (write)
>                 need_pte_bits |= _PAGE_RW;
> 
> but that may have been lost when we converted over to the generic code.

The generic gup_pte_range() has pte_access_permitted() (which has the
above test) in the right place.

> It shouldn't actually _matter_, since we'd need to change access_ok()
> anyway (and gup had better check that!)

get_user_pages_fast() (both of them) do indeed test access_ok(), but the
regular get_user_pages() does not, I suspect because it can operate on a
foreign mm.

And its the regular old get_user_pages() that's all sorts of broken wrt
!PAGE_USER too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
