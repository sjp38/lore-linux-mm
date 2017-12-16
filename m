Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9CE6B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:05:56 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c196so3498020ioc.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e9sor4117100ioe.155.2017.12.15.17.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:05:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171216003138.GJ21978@ZenIV.linux.org.uk>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com> <20171216003138.GJ21978@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 15 Dec 2017 17:05:54 -0800
Message-ID: <CA+55aFz3yvU=kVmwGdvVgTrG4UW24Eg19VNCbV9Umwqr8262mw@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Dec 15, 2017 at 4:31 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> The fact is, if we have non-user mappings in the user part of the
>> address space, we _need_ to teach access_ok() about them, because
>> fundamentally any "get_user()/put_user()" will happily ignore the lack
>> of PAGE_USER (since those happen from kernel space).
>
> Details, please - how *can* access_ok() be taught of that?

We'd have to do something like put the !PAGE_USER mapping at the top
of the user address space, and then simply make user_addr_max()
smaller than the actual user page table size.

Or some other silly hack.

I do not believe there is any sane way to have !PAGE_USER in
_general_, if you actually want to limit access to it.

(We _could_ use !PAGE_USER for things that aren't really strictly
about security - ie  we could have used it for the NUMA balancing
instead of using the P bit, and just let put_user/get_user blow
through them).

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
