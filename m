Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 6B1376B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 03:24:47 -0400 (EDT)
Date: Mon, 17 Jun 2013 16:24:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 7/8] vrange: Add method to purge volatile ranges
Message-ID: <20130617072446.GB3251@bbox>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
 <1371010971-15647-8-git-send-email-john.stultz@linaro.org>
 <20130617071331.GA3251@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617071331.GA3251@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 17, 2013 at 04:13:31PM +0900, Minchan Kim wrote:
> Hello John,
> 
> I am rewriting purging path and found a bug from this patch.
> I might forget it so I will send this comment for recording.
> 
> On Tue, Jun 11, 2013 at 09:22:50PM -0700, John Stultz wrote:
> > From: Minchan Kim <minchan@kernel.org>
> > 
> > This patch adds discarding function to purge volatile ranges under
> > memory pressure. Logic is as following:
> > 
> > 1. Memory pressure happens
> > 2. VM start to reclaim pages
> > 3. Check the page is in volatile range.
> > 4. If so, zap the page from the process's page table.
> >    (By semantic vrange(2), we should mark it with another one to
> >     make page fault when you try to access the address. It will
> >     be introduced later patch)
> > 5. If page is unmapped from all processes, discard it instead of swapping.
> > 
> > This patch does not address the case where there is no swap, which
> > keeps anonymous pages from being aged off the LRUs. Minchan has
> > additional patches that add support for purging anonymous pages
> > 
> > XXX: First pass at file purging. Seems to work, but is likely broken
> > and needs close review.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Android Kernel Team <kernel-team@android.com>
> > Cc: Robert Love <rlove@google.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> > Cc: Dave Chinner <david@fromorbit.com>
> > Cc: Neil Brown <neilb@suse.de>
> > Cc: Andrea Righi <andrea@betterlinux.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Cc: Mike Hommey <mh@glandium.org>
> > Cc: Taras Glek <tglek@mozilla.com>
> > Cc: Dhaval Giani <dgiani@mozilla.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> > Cc: Michel Lespinasse <walken@google.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > [jstultz: Reworked to add purging of file pages, commit log tweaks]
> > Signed-off-by: John Stultz <john.stultz@linaro.org>
> > ---
> >  include/linux/rmap.h   |  12 +-
> >  include/linux/swap.h   |   1 +
> >  include/linux/vrange.h |   7 ++
> >  mm/ksm.c               |   2 +-
> >  mm/rmap.c              |  30 +++--
> >  mm/swapfile.c          |  36 ++++++
> >  mm/vmscan.c            |  16 ++-
> >  mm/vrange.c            | 332 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  8 files changed, 420 insertions(+), 16 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index 6dacb93..6432dfb 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -83,6 +83,8 @@ enum ttu_flags {
> >  };
> >  
> 
> < snip >
> 
> > @@ -662,7 +663,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
> >   */
> >  int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> >  			unsigned long address, unsigned int *mapcount,
> > -			unsigned long *vm_flags)
> > +			unsigned long *vm_flags, int *is_vrange)
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	int referenced = 0;
> > @@ -724,6 +725,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> >  				referenced++;
> >  		}
> >  		pte_unmap_unlock(pte, ptl);
> > +		if (is_vrange &&
> > +			vrange_address(mm, address, address + PAGE_SIZE - 1))
> > +			*is_vrange = 1;
> 
> < snip >
> 
> > +static bool __vrange_address(struct vrange_root *vroot,
> > +			unsigned long start, unsigned long end)
> > +{
> > +	struct interval_tree_node *node;
> > +
> > +	node = interval_tree_iter_first(&vroot->v_rb, start, end);
> > +	return node ? true : false;
> > +}
> > +
> > +bool vrange_address(struct mm_struct *mm,
> > +			unsigned long start, unsigned long end)
> > +{
> > +	struct vrange_root *vroot;
> > +	unsigned long vstart_idx, vend_idx;
> > +	struct vm_area_struct *vma;
> > +	bool ret;
> > +
> > +	vma = find_vma(mm, start);
> 
> It seems to be tweaked by you while you are refactoring with file-vrange
> The problem of the code is that you couldn't use vma without holding
> the lock of mmap_sem and you couldn't use the lock in purging path
> because you couldn't know other tasks's state so it might be a dealock
> if you try to hold a lock.

It was sent by mistake with not completing. :(
Exactly speaking, the find_vma is a problem and we don't need it.
Couldn't we pass just vma, NOT mm?
Have you seen any problem?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
