Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3262D6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:42:23 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f27so9338513ote.16
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:42:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t89sor2162409ota.12.2017.12.18.10.42.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 10:42:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171218115409.gtsw7ygh53sq2hcd@hirez.programming.kicks-ass.net>
References: <20171214113851.146259969@infradead.org> <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
 <20171215102529.vtsjhb7h7jiufkr3@hirez.programming.kicks-ass.net>
 <20171215113838.nqxcjyyhfy4g7ipk@hirez.programming.kicks-ass.net>
 <CAPcyv4ghxbdWoRF6U=PSLLQaUKGx55MzYSPVrtsBug7ETv5ybg@mail.gmail.com> <20171218115409.gtsw7ygh53sq2hcd@hirez.programming.kicks-ass.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Dec 2017 10:42:21 -0800
Message-ID: <CAPcyv4jFwH7KEJM1b7SvN4r011C9wHDa1C11r72ORzNeo0b8Hg@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Dec 18, 2017 at 3:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Dec 15, 2017 at 08:38:02AM -0800, Dan Williams wrote:
>
>> The motivation was that I noticed that get_user_pages_fast() was doing
>> a full pud_access_permitted() check, but the get_user_pages() slow
>> path was only doing a pud_write() check. That was inconsistent so I
>> went to go resolve that across all the pte types and ended up making a
>> mess of things,
>
>> I'm fine if the answer is that we should have went the
>> other way to only do write checks. However, when I was investigating
>> which way to go the aspect that persuaded me to start sprinkling
>> p??_access_permitted checks around was that the application behavior
>> changed between mmap access and direct-i/o access to the same buffer.
>
>> I assumed that different access behavior between those would be an
>> inconsistent surprise to userspace. Although, infinitely looping in
>> handle_mm_fault is an even worse surprise, apologies for that.
>
> Well, we all make a mess of things at time. I'm certainly guilty of
> that, so no worries there. But it really helps if your Changelogs at
> least describe what you're trying to do and why.

Yes, agreed. Unfortunately in this case all those details were
included in the lead in patch, and should have been duplicated to the
follow on cleanups. See:

1501899a898d mm: fix device-dax pud write-faults triggered by get_user_pages()

    "For now this just implements a simple check for the _PAGE_RW bit similar
    to pmd_write.  However, this implies that the gup-slow-path check is
    missing the extra checks that the gup-fast-path performs with
    pud_access_permitted.  Later patches will align all checks to use the
    'access_permitted' helper if the architecture provides it."

...and that paragraph would have saved you some wondering.

> So I think I covered what you set out to do. In any case, Linus took the
> whole lot back out, so we can look at this afresh.

Thanks Peter, appreciate it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
