Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58A986B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 19:30:00 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id e80so5604719ote.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 16:30:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t31sor2842382ott.262.2017.12.15.16.29.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 16:29:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net> <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 16:29:58 -0800
Message-ID: <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 4:20 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Thu, Dec 14, 2017 at 11:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > So we actually need the pte_access_permitted() stuff if we want to
> > ensure we're not stepping on !PAGE_USER things.
>
> We really don't. Not in that complex and broken format, and not for every level.
>
> Also, while I think we *should* check the PAGE_USER bit when walking
> the page tables, like we used to, we should
>
>  (a) do it much more simply, not with that broken interface that takes
> insane and pointless flags
>
>  (b) not tie it together with this issue at all, since the PAGE_USER
> thing really is largely immaterial.
>
> The fact is, if we have non-user mappings in the user part of the
> address space, we _need_ to teach access_ok() about them, because
> fundamentally any "get_user()/put_user()" will happily ignore the lack
> of PAGE_USER (since those happen from kernel space).
>
> So I'd like to check PAGE_USER in GUP simply because it's a simple
> sanity check, not because it is important.
>
> And that whole "p??_access_permitted() checks against the current
> PKRU" is just incredible shit. It's currently broken, exactly because
> "current PKRU" isn't even well-defined when you do it across different
> threads, much less different address spaces.
>
> This is why I'm 100% convinced that the current
> "p??_access_permitted()" is just pure and utter garbage. And it's
> garbage at a _fundamental_ level, not because of some small
> implementation detail.

So do you want to do a straight revert of these that went in for 4.15:

5c9d2d5c269c mm: replace pte_write with pte_access_permitted in fault
+ gup paths
c7da82b894e9 mm: replace pmd_write with pmd_access_permitted in fault
+ gup paths
e7fe7b5cae90 mm: replace pud_write with pud_access_permitted in fault
+ gup paths

...or take Peter's patches that are trying to fix up the damage?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
