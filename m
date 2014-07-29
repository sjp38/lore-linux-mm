Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8845F6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:16:46 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so363139wes.7
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:16:45 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id a3si22831755wib.72.2014.07.29.16.16.44
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 16:16:45 -0700 (PDT)
Date: Wed, 30 Jul 2014 02:16:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: close race between do_fault_around() and
 fault_around_bytes_set()
Message-ID: <20140729231636.GA17685@node.dhcp.inet.fi>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1406633609-17586-2-git-send-email-kirill.shutemov@linux.intel.com>
 <53D7A251.7010509@samsung.com>
 <20140729142710.656A9E00A3@blue.fi.intel.com>
 <alpine.DEB.2.02.1407291531080.20991@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407291531080.20991@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue, Jul 29, 2014 at 03:36:57PM -0700, David Rientjes wrote:
> On Tue, 29 Jul 2014, Kirill A. Shutemov wrote:
> 
> > Things can go wrong if fault_around_bytes will be changed under
> > do_fault_around(): between fault_around_mask() and fault_around_pages().
> > 
> > Let's read fault_around_bytes only once during do_fault_around() and
> > calculate mask based on the reading.
> > 
> > Note: fault_around_bytes can only be updated via debug interface. Also
> > I've tried but was not able to trigger a bad behaviour without the
> > patch. So I would not consider this patch as urgent.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/memory.c | 17 +++++++++++------
> >  1 file changed, 11 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 9d66bc66f338..7f4f0c41c9e9 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2772,12 +2772,12 @@ static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
> >  
> >  static inline unsigned long fault_around_pages(void)
> >  {
> > -	return fault_around_bytes >> PAGE_SHIFT;
> > +	return ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;
> 
> Not sure why this is being added here, ACCESS_ONCE() would be needed 
> depending on the context in which the return value is used, 
> do_read_fault() won't need it.

Fair enough. I'll move it.

> >  }
> >  
> > -static inline unsigned long fault_around_mask(void)
> > +static inline unsigned long fault_around_mask(unsigned long nr_pages)
> >  {
> > -	return ~(fault_around_bytes - 1) & PAGE_MASK;
> > +	return ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
> >  }
> >  
> >  
> 
> This patch is corrupted because of the newline here that doesn't exist in 
> linux-next.

I'll recheck.

> > @@ -2844,12 +2844,17 @@ late_initcall(fault_around_debugfs);
> >  static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
> >  		pte_t *pte, pgoff_t pgoff, unsigned int flags)
> >  {
> > -	unsigned long start_addr;
> > +	unsigned long start_addr, nr_pages;
> >  	pgoff_t max_pgoff;
> >  	struct vm_fault vmf;
> >  	int off;
> >  
> > -	start_addr = max(address & fault_around_mask(), vma->vm_start);
> > +	nr_pages = fault_around_pages();
> > +	/* race with fault_around_bytes_set() */
> > +	if (unlikely(nr_pages <= 1))
> > +		return;
> 
> Why exactly is this unlikely if fault_around_bytes is tunable via debugfs 
> to equal PAGE_SIZE?  I assume we're expecting nobody is going to be doing 
> that, otherwise we'll hit the unlikely() branch here every time.

No. We hit do_fault_around() only after fault_around_pages() check in
do_read_fault(): so only in race case.

> So either the unlikely or the tunable should be removed.
> 
> The problem is that fault_around_bytes isn't documented so we don't even 
> know the min value without looking at the source code.

I would prefer to drop tunable, it will make code a bit simplier.
Andrew, iirc you've asked for it. Do you still think we need the handle?

> I also don't see how nr_pages can be < 1.

As Andrey has pointed, the 'if' is not needed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
