Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9908D6B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 19:32:31 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 96so5831545wrk.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 16:32:31 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 143si5485168wmn.117.2017.12.15.16.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 16:32:30 -0800 (PST)
Date: Sat, 16 Dec 2017 00:31:38 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171216003138.GJ21978@ZenIV.linux.org.uk>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
 <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Dec 15, 2017 at 04:20:31PM -0800, Linus Torvalds wrote:
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

Details, please - how *can* access_ok() be taught of that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
