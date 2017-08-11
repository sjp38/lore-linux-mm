Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04D296B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:27:51 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 6so22817502qts.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:27:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o43si1531141qtj.27.2017.08.11.13.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 13:27:49 -0700 (PDT)
Message-ID: <1502483265.6577.52.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Fri, 11 Aug 2017 16:27:45 -0400
In-Reply-To: <CA+55aFzA+7CeCdUi-13DfOeE3FfhtTPMMmBA4UQx8FixXiD4YA@mail.gmail.com>
References: <20170811191942.17487-1-riel@redhat.com>
	 <20170811191942.17487-3-riel@redhat.com>
	 <CA+55aFzA+7CeCdUi-13DfOeE3FfhtTPMMmBA4UQx8FixXiD4YA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm <linux-mm@kvack.org>, Florian Weimer <fweimer@redhat.com>, colm@allcosts.net, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Linux API <linux-api@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On Fri, 2017-08-11 at 12:42 -0700, Linus Torvalds wrote:
> On Fri, Aug 11, 2017 at 12:19 PM,A A <riel@redhat.com> wrote:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 0e517be91a89..f9b0ad7feb57 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1134,6 +1134,16 @@ int copy_page_range(struct mm_struct
> > *dst_mm, struct mm_struct *src_mm,
> > A A A A A A A A A A A A A A A A A A A A A A A A !vma->anon_vma)
> > A A A A A A A A A A A A A A A A return 0;
> > 
> > +A A A A A A A /*
> > +A A A A A A A A * With VM_WIPEONFORK, the child inherits the VMA from the
> > +A A A A A A A A * parent, but not its contents.
> > +A A A A A A A A *
> > +A A A A A A A A * A child accessing VM_WIPEONFORK memory will see all
> > zeroes;
> > +A A A A A A A A * a child accessing VM_DONTCOPY memory receives a
> > segfault.
> > +A A A A A A A A */
> > +A A A A A A A if (vma->vm_flags & VM_WIPEONFORK)
> > +A A A A A A A A A A A A A A A return 0;
> > +
> 
> Is this right?
> 
> Yes, you don't do the page table copies. Fine. But you leave vma with
> the the anon_vma pointer - doesn't that mean that it's still
> connected
> to the original anonvma chain, and we might end up swapping something
> in?

Swapping something in would require there to be a swap entry in
the page table entries, which we are not copying, so this should
not be a correctness issue.

> And even if that ends up not being an issue, I'd expect that you'd
> want to break the anon_vma chain just to not make it grow
> unnecessarily.

This is a good point. I can send a v4 that skips the anon_vma_fork()
call if VM_WIPEONFORK, and calls anon_vma_prepare(), instead.

> So my gut feel is that doing this in "copy_page_range()" is wrong,
> and
> the logic should be moved up to dup_mmap(), where we can also
> short-circuit the anon_vma chain entirely.
> 
> No?

There is another test in copy_page_range already which ends up
skipping the page table copy when it should not be done.

If you want, I can move that test into a should_copy_page_range()
function, and call that from dup_mmap(), skipping the call to
copy_page_range() if should_copy_page_range() returns false.

Having only one of the two sets of tests in dup_mmap(), and
the other in copy_page_range() seems wrong.

Just let me know what you prefer, and I'll put that in v4.

> The madvice() interface looks fine to me.

That was the main reason for adding you to the thread :)

kind regards,

Rik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
