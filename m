Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF4346B009C
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:45:39 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id h16so1004371oag.20
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:45:39 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id tm2si1853899oeb.146.2014.02.26.07.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 07:45:38 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 26 Feb 2014 08:45:38 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id EE2C21FF0043
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 08:45:35 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1QFjAJN8651094
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 16:45:10 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1QFn3lr011866
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 08:49:03 -0700
Date: Wed, 26 Feb 2014 07:45:34 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: mm: NULL ptr deref in balance_dirty_pages_ratelimited
Message-ID: <20140226154534.GJ8264@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <530CEFE2.9090909@oracle.com>
 <CAA_GA1dJA9PmZnoNy59__Ek+KPS3xX4WuR_8=onY8mZSRQrKiQ@mail.gmail.com>
 <20140226140941.GA31230@node.dhcp.inet.fi>
 <CAA_GA1dRS9WghaoG3bYwnEVxdOXQTjcTrZQkgZEU+vq3Lbmm6Q@mail.gmail.com>
 <20140226152051.GA31115@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226152051.GA31115@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Bob Liu <lliubbo@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, Feb 26, 2014 at 05:20:51PM +0200, Kirill A. Shutemov wrote:
> On Wed, Feb 26, 2014 at 10:48:30PM +0800, Bob Liu wrote:
> > > Do you relay on unlock_page() to have a compiler barrier?
> > >
> > 
> > Before your commit mapping is a local variable and be assigned before
> > unlock_page():
> > struct address_space *mapping = page->mapping;
> > unlock_page(dirty_page);
> > put_page(dirty_page);
> > if ((dirtied || page_mkwrite) && mapping) {
> > 
> > 
> > I'm afraid now "fault_page->mapping" might be changed to NULL after
> > "if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {"
> > and then passed down to balance_dirty_pages_ratelimited(NULL).
> 
> I see what you try to fix. I wounder if we need to do
> 
> mapping = ACCESS_ONCE(fault_page->mapping);
> 
> instead.
> 
> The question is if compiler on its own can eliminate intermediate variable
> and dereference fault_page->mapping twice, as code with my patch does.
> I ask because smp_mb__after_clear_bit() in unlock_page() does nothing on
> some architectures.

The compiler is most definitely within its rights to eliminate intermediate
variables if you don't use something like ACCESS_ONCE().  For more info,
see the LWN writeup:  http://lwn.net/Articles/508991/

							Thanx, Paul

> > >>
> > >> diff --git a/mm/memory.c b/mm/memory.c
> > >> index 548d97e..90cea22 100644
> > >> --- a/mm/memory.c
> > >> +++ b/mm/memory.c
> > >> @@ -3419,6 +3419,7 @@ static int do_shared_fault(struct mm_struct *mm,
> > >> struct vm_area_struct *vma,
> > >>   pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
> > >>  {
> > >>   struct page *fault_page;
> > >> + struct address_space *mapping;
> > >>   spinlock_t *ptl;
> > >>   pte_t *pte;
> > >>   int dirtied = 0;
> > >> @@ -3454,13 +3455,14 @@ static int do_shared_fault(struct mm_struct
> > >> *mm, struct vm_area_struct *vma,
> > >>
> > >>   if (set_page_dirty(fault_page))
> > >>   dirtied = 1;
> > >> + mapping = fault_page->mapping;
> > >>   unlock_page(fault_page);
> > >> - if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {
> > >> + if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
> > >>   /*
> > >>   * Some device drivers do not set page.mapping but still
> > >>   * dirty their pages
> > >>   */
> > >> - balance_dirty_pages_ratelimited(fault_page->mapping);
> > >> + balance_dirty_pages_ratelimited(mapping);
> > >>   }
> > >>
> > >>   /* file_update_time outside page_lock */
> > >> --
> > >> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > >> the body of a message to majordomo@vger.kernel.org
> > >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >> Please read the FAQ at  http://www.tux.org/lkml/
> > >
> > > --
> > >  Kirill A. Shutemov
> > 
> > -- 
> > Regards,
> > --Bob
> 
> -- 
>  Kirill A. Shutemov
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
