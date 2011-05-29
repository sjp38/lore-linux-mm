Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 11D486B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 08:16:56 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1651402pwi.14
        for <linux-mm@kvack.org>; Sun, 29 May 2011 05:16:53 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH] mm: fix kernel BUG at mm/rmap.c:1017!
Date: Sun, 29 May 2011 20:16:30 +0800
References: <alpine.LSU.2.00.1105281314220.13319@sister.anvils> <201105291823.47082.nai.xia@gmail.com>
In-Reply-To: <201105291823.47082.nai.xia@gmail.com>
MIME-Version: 1.0
Message-Id: <201105292016.30748.nai.xia@gmail.com>
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sunday 29 May 2011 18:23:46 Nai Xia wrote:
> On Sunday 29 May 2011 04:17:04 Hugh Dickins wrote:
> > I've hit the "address >= vma->vm_end" check in do_page_add_anon_rmap()
> > just once.  The stack showed khugepaged allocation trying to compact
> > pages: the call to page_add_anon_rmap() coming from remove_migration_pte().
> > 
> > That path holds anon_vma lock, but does not hold mmap_sem: it can
> > therefore race with a split_vma(), and in commit 5f70b962ccc2 "mmap:
> > avoid unnecessary anon_vma lock" we just took away the anon_vma lock
> > protection when adjusting vma->vm_end.
> > 
> > I don't think that particular BUG_ON ever caught anything interesting,
> > so better replace it by a comment, than reinstate the anon_vma locking.
> 
> Is there another racing between "vma->vm_pgoff = pgoff;" in 
> vma_adjust() and linear_page_index() in __page_set_anon_rmap() ?

Oh, sorry, please ignore this, this _is_ protected by anon_vma lock.

Nai Xia

> 
> 
> Nai Xia
> 
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> >  mm/rmap.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > --- linux.orig/mm/rmap.c	2011-05-27 19:05:27.000000000 -0700
> > +++ linux/mm/rmap.c	2011-05-27 20:07:44.601361236 -0700
> > @@ -1014,7 +1014,7 @@ void do_page_add_anon_rmap(struct page *
> >  		return;
> >  
> >  	VM_BUG_ON(!PageLocked(page));
> > -	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +	/* address might be in next vma when migration races vma_adjust */
> >  	if (first)
> >  		__page_set_anon_rmap(page, vma, address, exclusive);
> >  	else
> > @@ -1709,7 +1709,7 @@ void hugepage_add_anon_rmap(struct page
> >  
> >  	BUG_ON(!PageLocked(page));
> >  	BUG_ON(!anon_vma);
> > -	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +	/* address might be in next vma when migration races vma_adjust */
> >  	first = atomic_inc_and_test(&page->_mapcount);
> >  	if (first)
> >  		__hugepage_set_anon_rmap(page, vma, address, 0);
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
