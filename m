Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C369E6B0266
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:29:20 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f62so5604115otf.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:29:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g33sor2774160oth.21.2017.12.15.17.29.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:29:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz2aY-0hG1E_x7Don1pwgDQkHZfP2J3qW+QbvcvLBWTNQ@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
 <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com> <CA+55aFz2aY-0hG1E_x7Don1pwgDQkHZfP2J3qW+QbvcvLBWTNQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 17:29:18 -0800
Message-ID: <CAPcyv4jgWtp5H_Z72Ot=fVkmRqUwL8Gq=0+xKg7C1TkmFN1OvQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 5:10 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Dec 15, 2017 at 4:29 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> So do you want to do a straight revert of these that went in for 4.15:
>
> I think that's the right thing to do, but would want to verify that
> there are no *other* issues than just the attempt at PKRU.
>
> The commit message does talk about PAGE_USER, and as mentioned I do
> think that's a good thing to check, I just don't think it should be
> done this way,
>
> Was there something else going behind these commits? Because if not,
> let's revert and then perhaps later introduce a more targeted thing?

Yes, these three can be safely reverted.

    5c9d2d5c269c mm: replace pte_write with pte_access_permitted...
    c7da82b894e9 mm: replace pmd_write with pmd_access_permitted...
    e7fe7b5cae90 mm: replace pud_write with pud_access_permitted...

They were part of a 4 patch series where this lead one below is the
one fix we actually need.

    1501899a898d mm: fix device-dax pud write-faults triggered by...

---

Now, the original access permitted was born out of a cleanup to
introduce pte_allows_gup(), this is where the PAGE_USER check came
from:

    1874f6895c92 x86/mm/gup: Simplify get_user_pages() PTE bit handling

...and that helper later grew pkey check support here:

   33a709b25a76 mm/gup, x86/mm/pkeys: Check VMAs and PTEs for protection keys

...sometime later it was all renamed and made kernel-global here when
the x86 gup implementation was converted to use the common
implementation:

    e7884f8ead4a mm/gup: Move permission checks into helpers

All this to say that these are not revert candidates and need
incremental patches if we want to back out the pkey checking for the
gup-fast path and re-work the PAGE_USER checking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
