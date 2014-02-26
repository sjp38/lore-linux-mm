Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 97ED56B0036
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:23:31 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id q10so1035494ead.10
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:23:30 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id 4si2693106eet.162.2014.02.26.07.23.29
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 07:23:30 -0800 (PST)
Date: Wed, 26 Feb 2014 17:20:51 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: NULL ptr deref in balance_dirty_pages_ratelimited
Message-ID: <20140226152051.GA31115@node.dhcp.inet.fi>
References: <530CEFE2.9090909@oracle.com>
 <CAA_GA1dJA9PmZnoNy59__Ek+KPS3xX4WuR_8=onY8mZSRQrKiQ@mail.gmail.com>
 <20140226140941.GA31230@node.dhcp.inet.fi>
 <CAA_GA1dRS9WghaoG3bYwnEVxdOXQTjcTrZQkgZEU+vq3Lbmm6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1dRS9WghaoG3bYwnEVxdOXQTjcTrZQkgZEU+vq3Lbmm6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Feb 26, 2014 at 10:48:30PM +0800, Bob Liu wrote:
> > Do you relay on unlock_page() to have a compiler barrier?
> >
> 
> Before your commit mapping is a local variable and be assigned before
> unlock_page():
> struct address_space *mapping = page->mapping;
> unlock_page(dirty_page);
> put_page(dirty_page);
> if ((dirtied || page_mkwrite) && mapping) {
> 
> 
> I'm afraid now "fault_page->mapping" might be changed to NULL after
> "if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {"
> and then passed down to balance_dirty_pages_ratelimited(NULL).

I see what you try to fix. I wounder if we need to do

mapping = ACCESS_ONCE(fault_page->mapping);

instead.

The question is if compiler on its own can eliminate intermediate variable
and dereference fault_page->mapping twice, as code with my patch does.
I ask because smp_mb__after_clear_bit() in unlock_page() does nothing on
some architectures.

> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index 548d97e..90cea22 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -3419,6 +3419,7 @@ static int do_shared_fault(struct mm_struct *mm,
> >> struct vm_area_struct *vma,
> >>   pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
> >>  {
> >>   struct page *fault_page;
> >> + struct address_space *mapping;
> >>   spinlock_t *ptl;
> >>   pte_t *pte;
> >>   int dirtied = 0;
> >> @@ -3454,13 +3455,14 @@ static int do_shared_fault(struct mm_struct
> >> *mm, struct vm_area_struct *vma,
> >>
> >>   if (set_page_dirty(fault_page))
> >>   dirtied = 1;
> >> + mapping = fault_page->mapping;
> >>   unlock_page(fault_page);
> >> - if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {
> >> + if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
> >>   /*
> >>   * Some device drivers do not set page.mapping but still
> >>   * dirty their pages
> >>   */
> >> - balance_dirty_pages_ratelimited(fault_page->mapping);
> >> + balance_dirty_pages_ratelimited(mapping);
> >>   }
> >>
> >>   /* file_update_time outside page_lock */
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> Please read the FAQ at  http://www.tux.org/lkml/
> >
> > --
> >  Kirill A. Shutemov
> 
> -- 
> Regards,
> --Bob

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
