Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 642226B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 07:31:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id z18-v6so2103041lfg.17
        for <linux-mm@kvack.org>; Mon, 07 May 2018 04:31:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l18-v6sor5012500ljb.52.2018.05.07.04.31.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 04:31:23 -0700 (PDT)
Date: Mon, 7 May 2018 14:31:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Proof-of-concept: better(?) page-table manipulation API
Message-ID: <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
References: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
 <CALCETrVzD8oPv=h2q91AMdCHn3S782GmvsY-+mwoaPUw=5N7HQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVzD8oPv=h2q91AMdCHn3S782GmvsY-+mwoaPUw=5N7HQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 07, 2018 at 04:51:57AM +0000, Andy Lutomirski wrote:
> On Tue, Apr 24, 2018 at 8:44 AM Kirill A. Shutemov <
> kirill.shutemov@linux.intel.com> wrote:
> 
> > Hi everybody,
> 
> > I've proposed to talk about page able manipulation API on the LSF/MM'2018,
> > so I need something material to talk about.
> 
> 
> I gave it a quick read.  I like the concept a lot, and I have a few
> comments.

Thank you for the input.

> > +/*
> > + * How manu bottom level we account to mm->pgtables_bytes
> > + */
> > +#define PT_ACCOUNT_LVLS 3
> > +
> > +struct pt_ptr {
> > +       unsigned long *ptr;
> > +       int lvl;
> > +};
> > +
> 
> I think you've inherited something that I consider to be a defect in the
> old code: you're conflating page *tables* with page table *entries*.  Your
> 'struct pt_ptr' sounds like a pointer to an entire page table, but AFAICT
> you're using it to point to a specific entry within a table.  I think that
> both the new core code and the code that uses it would be clearer and less
> error prone if you made the distinction explicit.  I can think of two clean
> ways to do it:
> 
> 1. Add a struct pt_entry_ptr, and make it so that get_ptv(), etc take a
> pt_entry_ptr instead of a pt_ptr.  Add a helper to find a pt_entry_ptr
> given a pt_ptr and either an index or an address.
> 
> 2. Don't allow pointers to page table entries at all.  Instead, get_ptv()
> would take an address or an index parameter.

Well, I'm not sure how useful pointer to whole page tables are.
Where do you them useful?

How I see the picture so far:

- ptp_t represent a pointer to an entry in a page table.

  In x86-64 case I pretend that CR3 is single-entry page table. It
  requires a special threatement in ptp_page_vaddr(), but works fine
  otherwise.

- ptv_t represents a value that dereferenced from ptp_t or can be set to
  ptp_t.

It's trivial to find the start of page table if we would need it by
masking out botom bits from ptp->ptr. It works on x86 and should be
possible on any architecture.

> Also, what does lvl == 0 mean?  Is it the top or the bottom?  I think a
> comment would be helpful.

It is bottom. But it should be up to architecture to decide.

> 
> > +/*
> > + * When walking page tables, get the address of the next boundary,
> > + * or the end address of the range if that comes earlier.  Although no
> > + * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
> > + */
> 
> I read this comment twice, and I still don't get it.  Can you clarify what
> this function does and why you would use it?

That's basically ported variant of p?d_addr_end. It helps step address by
right value for the page table entry and handles wrapping properly.

See example in copy_pt_range().

> > +/* Operations on page table pointers */
> > +
> > +/* Initialize ptp_t with pointer to top page table level. */
> > +static inline ptp_t ptp_init(struct mm_struct *mm)
> > +{
> > +       struct pt_ptr ptp ={
> > +               .ptr = (unsigned long *)mm->pgd,
> > +               .lvl = PT_TOP_LEVEL,
> > +       };
> > +
> > +       return ptp;
> > +}
> > +
> 
> On some architectures, there are multiple page table roots.  For example,
> ARM64 has a root for the kernel half of the address space and a root for
> the user half (at least -- I don't fully understand it).  x86 PAE sort-of
> has four roots.  Would it make sense to expose this in the API for
> real?

I will give it a thought.

Is there a reason not to threat it as an additional page table layer and
deal with it in a unified way?

> For example, ptp_init(mm) could be replaced with ptp_init(mm, addr).  This
> would make it a bit cleaner to handle an separate user and kernel tables.
>   (As it stands, what is supposed to happen on ARM if you do
> ptp_init(something that isn't init_mm) and then walk it to look for a
> kernel address?)

IIUC, we can handle it in ptp_walk() since we have all may handle root in
a special way as I do for x86-64.

> Also, ptp_init() seems oddly named for me.  ptp_get_root_for_mm(),
> perhaps?  There could also be ptp_get_kernel_root() to get the root for the
> init_mm's tables.

Yeah, sounds better.

> > +static inline void ptp_walk(ptp_t *ptp, unsigned long addr)
> > +{
> > +       ptp->ptr = (unsigned long *)ptp_page_vaddr(ptp);
> > +       ptp->ptr += __pt_index(addr, --ptp->lvl);
> > +}
> 
> Can you add a comment that says what this function does?

Okay, I will.

> Why does it not change the level?

It does. --ptp->lvl.

> > +
> > +static void ptp_free(struct mm_struct *mm, ptv_t ptv)
> > +{
> > +       if (ptv.lvl < PT_SPLIT_LOCK_LVLS)
> > +               ptlock_free(pfn_to_page(ptv_pfn(ptv)));
> > +}
> > +
> 
> As it stands, this is a function that seems easy easy to misuse given the
> confusion between page tables and page table entries.

Hm. I probably have a blind spot, but I don't see it.

The function has to be named better for sure.

> Finally, a general comment.  Actually fully implementing this the way
> you've done it seems like a giant mess given that you need to support all
> architectures.  But couldn't you implement the new API as a wrapper around
> the old API so you automatically get all architectures?

I will look into this. But I'm not sure if it possbile without measurable
overhead.

-- 
 Kirill A. Shutemov
