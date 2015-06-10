Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9F89F6B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:23:11 -0400 (EDT)
Received: by laar3 with SMTP id r3so26643096laa.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:23:11 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id o7si7994183lbw.36.2015.06.10.00.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 00:23:09 -0700 (PDT)
Received: by labpy14 with SMTP id py14so26808513lab.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:23:09 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:23:05 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/6] mm: mark dirty bit on swapped-in page
Message-ID: <20150610072305.GB13008@uranus>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
 <1433312145-19386-4-git-send-email-minchan@kernel.org>
 <20150609190737.GV13008@uranus>
 <20150609235206.GB12689@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609235206.GB12689@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

On Wed, Jun 10, 2015 at 08:52:06AM +0900, Minchan Kim wrote:
> > > +++ b/mm/memory.c
> > > @@ -2557,9 +2557,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  
> > >  	inc_mm_counter_fast(mm, MM_ANONPAGES);
> > >  	dec_mm_counter_fast(mm, MM_SWAPENTS);
> > > -	pte = mk_pte(page, vma->vm_page_prot);
> > > +
> > > +	/* Mark dirty bit of page table because MADV_FREE relies on it */
> > > +	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
> > >  	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> > > -		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> > > +		pte = maybe_mkwrite(pte, vma);
> > >  		flags &= ~FAULT_FLAG_WRITE;
> > >  		ret |= VM_FAULT_WRITE;
> > >  		exclusive = 1;
> > 
> > Hi Minchan! Really sorry for delay in reply. Look, I don't understand
> > the moment -- if page has fault on read then before the patch the
> > PTE won't carry the dirty flag but now we do set it up unconditionally
> > and to me it looks somehow strange at least because this as well
> > sets soft-dirty bit on pages which were not modified but only swapped
> > out. Am I missing something obvious?
> 
> It's same one I sent a while ago and you said it's okay at that time. ;-)

Ah, I recall. If there is no way to escape dirtifying the page in pte itself
maybe we should at least not make it softdirty on read faults?

> Okay, It might be lack of description compared to one I sent long time ago
> because I moved some part of description to another patch and I didn't Cc
> you. Sorry. I hope below will remind you.
> 
> https://www.mail-archive.com/linux-kernel%40vger.kernel.org/msg857827.html
> 
> In summary, the problem is that in MADV_FREE point of view,
> clean anonymous page(ie, no dirty) in  page table entry has a problem
> about sudden discarding under us by reclaimer. Otherwise, VM cannot
> discard MADV_FREE hinted pages by PageDirty flag of page descriptor.
> 
> This patchset aims for solving the problem.
> Please feel free to ask if you have questions without wasting your time
> unless you can remind after reading above URL
> 
> Thanks for looking!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
