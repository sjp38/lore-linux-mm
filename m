Received: by ro-out-1112.google.com with SMTP id p7so1216840roc.0
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 14:35:26 -0800 (PST)
Message-ID: <4df4ef0c0801181435y67fee713h83f8e7f2a5b4e803@mail.gmail.com>
Date: Sat, 19 Jan 2008 01:35:25 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped files
In-Reply-To: <alpine.LFD.1.00.0801181406580.2957@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <alpine.LFD.1.00.0801181106340.2957@woody.linux-foundation.org>
	 <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
	 <4df4ef0c0801181158s3f783beaqead3d7049d4d3fa7@mail.gmail.com>
	 <alpine.LFD.1.00.0801181214440.2957@woody.linux-foundation.org>
	 <4df4ef0c0801181303o6656832g8b63d2a119a86a9c@mail.gmail.com>
	 <alpine.LFD.1.00.0801181325510.2957@woody.linux-foundation.org>
	 <4df4ef0c0801181404m186bb847sd556e031e908b0b6@mail.gmail.com>
	 <alpine.LFD.1.00.0801181406580.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/19, Linus Torvalds <torvalds@linux-foundation.org>:
>
>
> On Sat, 19 Jan 2008, Anton Salikhmetov wrote:
> >
> > The page_check_address() function is called from the
> > page_mkclean_one() routine as follows:
>
> .. and the page_mkclean_one() function is totally different.
>
> Lookie here, this is the correct and complex sequence:
>
> >                 entry = ptep_clear_flush(vma, address, pte);
> >                 entry = pte_wrprotect(entry);
> >                 entry = pte_mkclean(entry);
> >                 set_pte_at(mm, address, pte, entry);
>
> That's a rather expensive sequence, but it's done exactly because it has
> to be done that way. What it does is to
>
>  - *atomically* load the pte entry _and_ clear the old one in memory.
>
>    That's the
>
>         entry = ptep_clear_flush(vma, address, pte);
>
>    thing, and it basically means that it's doing some
>    architecture-specific magic to make sure that another CPU that accesses
>    the PTE at the same time will never actually modify the pte (because
>    it's clear and not valid)
>
>  - it then - while the page table is actually clear and invalid - takes
>    the old value and turns it into the new one:
>
>         entry = pte_wrprotect(entry);
>         entry = pte_mkclean(entry);
>
>  - and finally, it replaces the entry with the new one:
>
>         set_pte_at(mm, address, pte, entry);
>
>    which takes care to write the new entry in some specific way that is
>    atomic wrt other CPU's (ie on 32-bit x86 with a 64-bit page table
>    entry it writes the high word first, see the write barriers in
>    "native_set_pte()" in include/asm-x86/pgtable-3level.h
>
> Now, compare that subtle and correct thing with what is *not* correct:
>
>         if (pte_dirty(*pte) && pte_write(*pte))
>                 *pte = pte_wrprotect(*pte);
>
> which makes no effort at all to make sure that it's safe in case another
> CPU updates the accessed bit.
>
> Now, arguably it's unlikely to cause horrible problems at least on x86,
> because:
>
>  - we only do this if the pte is already marked dirty, so while we can
>    lose the accessed bit, we can *not* lose the dirty bit. And the
>    accessed bit isn't such a big deal.
>
>  - it's not doing any of the "be careful about" ordering things, but since
>    the really important bits aren't changing, ordering probably won't
>    practically matter.
>
> But the problem is that we have something like 24 different architectures,
> it's hard to make sure that none of them have issues.
>
> In other words: it may well work in practice. But when these things go
> subtly wrong, they are *really* nasty to find, and the unsafe sequence is
> really not how it's supposed to be done. For example, you don't even flush
> the TLB, so even if there are no cross-CPU issues, there's probably going
> to be writable entries in the TLB that now don't match the page tables.
>
> Will it matter? Again, probably impossible to see in practice. But ...

Linus, I am very grateful to you for your extremely clear explanation
of the issue I have overlooked!

Back to the msync() issue, I'm going to come back with a new design
for the bug fix.

Thank you once again.

Anton

>
>                 Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
