Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C412E6B0035
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 10:27:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so11807422pdb.3
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 07:27:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id f4si10672040pdk.150.2014.07.29.07.27.42
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 07:27:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <53D7A251.7010509@samsung.com>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1406633609-17586-2-git-send-email-kirill.shutemov@linux.intel.com>
 <53D7A251.7010509@samsung.com>
Subject: Re: [PATCH 1/2] mm: close race between do_fault_around() and
 fault_around_bytes_set()
Content-Transfer-Encoding: 7bit
Message-Id: <20140729142710.656A9E00A3@blue.fi.intel.com>
Date: Tue, 29 Jul 2014 17:27:10 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

Andrey Ryabinin wrote:
> On 07/29/14 15:33, Kirill A. Shutemov wrote:
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
> > index 9d66bc66f338..2ce07dc9b52b 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2772,12 +2772,12 @@ static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
> >  
> >  static inline unsigned long fault_around_pages(void)
> >  {
> > -	return fault_around_bytes >> PAGE_SHIFT;
> > +	return ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;
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
> > +	if (nr_pages <= 1)
> 
> unlikely() ?

Yep.
