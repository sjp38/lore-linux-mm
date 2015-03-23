Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 66E306B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:44:42 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so172581678pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:44:42 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id am9si19952072pad.8.2015.03.22.19.44.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 19:44:41 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so176489386pac.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:44:41 -0700 (PDT)
Date: Sun, 22 Mar 2015 19:44:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 01/24] mm: update_lru_size warn and reset bad lru_size
In-Reply-To: <20150223093055.GA7322@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503221926070.4290@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils> <alpine.LSU.2.11.1502201949350.14414@eggly.anvils> <20150223093055.GA7322@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 Feb 2015, Kirill A. Shutemov wrote:
> On Fri, Feb 20, 2015 at 07:51:16PM -0800, Hugh Dickins wrote:
> > Though debug kernels have a VM_BUG_ON to help protect from misaccounting
> > lru_size, non-debug kernels are liable to wrap it around: and then the
> > vast unsigned long size draws page reclaim into a loop of repeatedly
> > doing nothing on an empty list, without even a cond_resched().
> > 
> > That soft lockup looks confusingly like an over-busy reclaim scenario,
> > with lots of contention on the lruvec lock in shrink_inactive_list():
> > yet has a totally different origin.
> > 
> > Help differentiate with a custom warning in mem_cgroup_update_lru_size(),
> > even in non-debug kernels; and reset the size to avoid the lockup.  But
> > the particular bug which suggested this change was mine alone, and since
> > fixed.
> 
> Do we need this kind of check for !MEMCG kernels?

I hope we don't: I hope that the MEMCG case can be a good enough canary
to catch the issues for !MEMCG too.  I thought that the !MEMCG stats were
maintained in such a different (per-cpu) way, whose batching would defeat
such checks without imposing unwelcome overhead - or am I wrong on that?

> 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> >  include/linux/mm_inline.h |    2 +-
> >  mm/memcontrol.c           |   24 ++++++++++++++++++++----
> >  2 files changed, 21 insertions(+), 5 deletions(-)
> > 
> > --- thpfs.orig/include/linux/mm_inline.h	2013-11-03 15:41:51.000000000 -0800
> > +++ thpfs/include/linux/mm_inline.h	2015-02-20 19:33:25.928096883 -0800
> > @@ -35,8 +35,8 @@ static __always_inline void del_page_fro
> >  				struct lruvec *lruvec, enum lru_list lru)
> >  {
> >  	int nr_pages = hpage_nr_pages(page);
> > -	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
> >  	list_del(&page->lru);
> > +	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
> >  	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
> >  }
> >  
> > --- thpfs.orig/mm/memcontrol.c	2015-02-08 18:54:22.000000000 -0800
> > +++ thpfs/mm/memcontrol.c	2015-02-20 19:33:25.928096883 -0800
> > @@ -1296,22 +1296,38 @@ out:
> >   * @lru: index of lru list the page is sitting on
> >   * @nr_pages: positive when adding or negative when removing
> >   *
> > - * This function must be called when a page is added to or removed from an
> > - * lru list.
> > + * This function must be called under lruvec lock, just before a page is added
> > + * to or just after a page is removed from an lru list (that ordering being so
> > + * as to allow it to check that lru_size 0 is consistent with list_empty).
> >   */
> >  void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
> >  				int nr_pages)
> >  {
> >  	struct mem_cgroup_per_zone *mz;
> >  	unsigned long *lru_size;
> > +	long size;
> > +	bool empty;
> >  
> >  	if (mem_cgroup_disabled())
> >  		return;
> >  
> >  	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
> >  	lru_size = mz->lru_size + lru;
> > -	*lru_size += nr_pages;
> > -	VM_BUG_ON((long)(*lru_size) < 0);
> > +	empty = list_empty(lruvec->lists + lru);
> > +
> > +	if (nr_pages < 0)
> > +		*lru_size += nr_pages;
> > +
> > +	size = *lru_size;
> > +	if (WARN(size < 0 || empty != !size,
> > +	"mem_cgroup_update_lru_size(%p, %d, %d): lru_size %ld but %sempty\n",
> > +			lruvec, lru, nr_pages, size, empty ? "" : "not ")) {
> 
> Formatting can be unscrewed this way:
> 
> 	if (WARN(size < 0 || empty != !size,
> 		"%s(%p, %d, %d): lru_size %ld but %sempty\n",
> 		__func__, lruvec, lru, nr_pages, size, empty ? "" : "not ")) {

Indeed, thanks.  Greg Thelen had made the same suggestion for a different
reason, I just didn't get to incorporate it this time around, but will do
better next time.

I don't expect to be reposting the whole series very soon, unless
someone asks for it: I think migration and recovery ought to be
supported before reposting.  But I might send a mini-series of
this and the other preparatory patches, maybe.

> 
> > +		VM_BUG_ON(1);
> > +		*lru_size = 0;
> > +	}
> > +
> > +	if (nr_pages > 0)
> > +		*lru_size += nr_pages;
> >  }
> >  
> >  bool mem_cgroup_is_descendant(struct mem_cgroup *memcg, struct mem_cgroup *root)
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
