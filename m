Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7596B005C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 05:55:20 -0400 (EDT)
Date: Wed, 27 May 2009 10:56:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
	and not VM_SHARED in hugetlbfs
Message-ID: <20090527095607.GB633@csn.ul.ie>
References: <Pine.LNX.4.64.0905262056150.958@sister.anvils> <20090527004859.GB6189@csn.ul.ie> <20090527111652.688B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090527111652.688B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, ebmunson@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 12:17:41PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > > > follow_hugetlb_page
> > > > 	This is checking of the zero page can be shared or not. Crap,
> > > > 	this one looks like it should have been converted to VM_MAYSHARE
> > > > 	as well.
> > > 
> > > Now, what makes you say that?
> > > 
> > > I really am eager to understand, because I don't comprehend
> > > that VM_SHARED at all. 
> > 
> > I think I understand it, but I keep changing my mind on whether
> > VM_SHARED is sufficient or not.
> > 
> > In this specific case, the zeropage must not be used by process A where
> > it's possible that process B has populated it with data. when I said "Crap"
> > earlier, the scenario I imagined went something like;
> > 
> > o Process A opens a hugetlbfs file read/write but does not map the file
> > o Process B opens the same hugetlbfs read-only and maps it
> >   MAP_SHARED. hugetlbfs allows mmaps to files that have not been ftruncate()
> >   so it can fault pages without SIGBUS
> > o Process A writes the file - currently this is impossible as hugetlbfs
> >   does not support write() but lets pretend it was possible
> > o Process B calls mlock() which calls into follow_hugetlb_page().
> >   VM_SHARED is not set because it's a read-only mapping and it returns
> >   the wrong page.
> > 
> > This last step is where I went wrong. As process 2 had no PTE for that
> > location, it would have faulted the page as normal and gotten the correct
> > page and never considered the zero page so VM_SHARED was ok after all.
> > 
> > But this is sufficiently difficult that I'm worried that there is some other
> > scenario where Process B uses the zero page when it shouldn't. Testing for
> > VM_MAYSHARE would prevent the zero page being used incorrectly whether the
> > mapping is read-only or read-write but maybe that's too paranoid.
> > 
> > Kosaki, can you comment on what impact (if any) testing for VM_MAYSHARE
> > would have here with respect to core-dumping?
> 
> Thank you for very kindful explanation.
> 
> Perhaps, I don't understand this issue yet. Honestly I didn't think this
> issue at my patch making time.
> 
> following is my current analysis. if I'm misunderstanding anythink, please
> correct me.
> 
> hugepage mlocking call make_pages_present().
> above case, follow_page_page() don't use ZERO_PAGE because vma don't have
> VM_SHARED.
> but that's ok. make_pages_present's intention is not get struct page,
> it is to make page population. in this case, we need follow_hugetlb_page() call
> hugetlb_fault(), I think.
> 
> 
> In the other hand, when core-dump case
> 
> .text segment: open(O_RDONLY) + mmap(MAP_SHARED)
> .data segment: open(O_RDONLY) + mmap(MAP_PRIVATE)
> 
> it mean .text can't use ZERO_PAGE. but I think no problem. In general
> .text is smaller than .data. It doesn't make so slowness.
> 

Ok, in that case, I'm going to leave VM_SHARED here alone rather than
switching it to VM_MAYSHARE. Right now, VM_SHARED appears to be covering
the cases we care about in this instance.

Thanks.

> 
> 
> > > I believe Kosaki-san's 4b2e38ad simply
> > > copied it from Linus's 672ca28e to mm/memory.c.  But even back
> > > when that change was made, I confessed to having lost the plot
> > > on it: so far as I can see, putting a VM_SHARED test in there
> > > just happened to prevent some VMware code going the wrong way,
> > > but I don't see the actual justification for it.
> > > 
> > 
> > Having no idea how vmware broke exactly, I'm not sure what exactly was
> > fixed. Maybe by not checking VM_SHARED, it was possible that a caller of
> > get_user_pages() would not see updates made by a parallel writer.
> > 
> > > So, given that I don't understand it in the first place,
> > > I can't really support changing that VM_SHARED to VM_MAYSHARE.
> > > 
> > 
> > Lets see what Kosaki says. If he's happy with VM_SHARED, I'll leave it
> > alone.
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
