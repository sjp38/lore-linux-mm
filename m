Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41FB26B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 21:09:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so56477612pfb.5
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 18:09:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t1si17543413pge.83.2017.03.05.18.09.06
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 18:09:07 -0800 (PST)
Date: Mon, 6 Mar 2017 11:09:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 05/11] mm: make the try_to_munlock void function
Message-ID: <20170306020901.GC8779@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-6-git-send-email-minchan@kernel.org>
 <98488e1a-0202-b88b-ca9c-1dc0d6c27ae5@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98488e1a-0202-b88b-ca9c-1dc0d6c27ae5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Mar 03, 2017 at 05:13:54PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> > the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> > the page if the page is not pte-mapped THP which cannot be
> > mlocked, either.
> 
> Right.
> 
> > 
> > With that, __munlock_isolated_page can use PageMlocked to check
> > whether try_to_munlock is successful or not without relying on
> > try_to_munlock's retval. It helps to make ttu/ttuo simple with
> > upcoming patches.
> 
> Right.
> 
> > 
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/rmap.h |  2 +-
> >  mm/mlock.c           |  6 ++----
> >  mm/rmap.c            | 16 ++++------------
> >  3 files changed, 7 insertions(+), 17 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index b556eef..1b0cd4c 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -235,7 +235,7 @@ int page_mkclean(struct page *);
> >   * called in munlock()/munmap() path to check for other vmas holding
> >   * the page mlocked.
> >   */
> > -int try_to_munlock(struct page *);
> > +void try_to_munlock(struct page *);
> >  
> >  void remove_migration_ptes(struct page *old, struct page *new, bool locked);
> >  
> > diff --git a/mm/mlock.c b/mm/mlock.c
> > index cdbed8a..d34a540 100644
> > --- a/mm/mlock.c
> > +++ b/mm/mlock.c
> > @@ -122,17 +122,15 @@ static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
> >   */
> >  static void __munlock_isolated_page(struct page *page)
> >  {
> > -	int ret = SWAP_AGAIN;
> > -
> >  	/*
> >  	 * Optimization: if the page was mapped just once, that's our mapping
> >  	 * and we don't need to check all the other vmas.
> >  	 */
> >  	if (page_mapcount(page) > 1)
> > -		ret = try_to_munlock(page);
> > +		try_to_munlock(page);
> >  
> >  	/* Did try_to_unlock() succeed or punt? */
> > -	if (ret != SWAP_MLOCK)
> > +	if (!PageMlocked(page))
> 
> Checks if the page is still mlocked or not.
> 
> >  		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
> >  
> >  	putback_lru_page(page);
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 0a48958..61ae694 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1540,18 +1540,10 @@ static int page_not_mapped(struct page *page)
> >   * Called from munlock code.  Checks all of the VMAs mapping the page
> >   * to make sure nobody else has this page mlocked. The page will be
> >   * returned with PG_mlocked cleared if no other vmas have it mlocked.
> > - *
> > - * Return values are:
> > - *
> > - * SWAP_AGAIN	- no vma is holding page mlocked, or,
> > - * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
> > - * SWAP_FAIL	- page cannot be located at present
> > - * SWAP_MLOCK	- page is now mlocked.
> >   */
> > -int try_to_munlock(struct page *page)
> > -{
> > -	int ret;
> >  
> > +void try_to_munlock(struct page *page)
> > +{
> >  	struct rmap_walk_control rwc = {
> >  		.rmap_one = try_to_unmap_one,
> >  		.arg = (void *)TTU_MUNLOCK,
> > @@ -1561,9 +1553,9 @@ int try_to_munlock(struct page *page)
> >  	};
> >  
> >  	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
> > +	VM_BUG_ON_PAGE(PageMlocked(page), page);
> 
> We are calling on the page to see if its mlocked from any of it's
> mapping VMAs. Then it is a possibility that the page is mlocked
> and the above condition is true and we print VM BUG report there.
> The point is if its a valid possibility why we have added the
> above check ?

If I read code properly,  __munlock_isolated_page calls try_to_munlock
always pass the TestClearPageMlocked page to try_to_munlock.
(e.g., munlock_vma_page and __munlock_pagevec) so I thought
try_to_munlock should be called non-PG_mlocked page and try_to_unmap_one
returns PG_mlocked page once it found a VM_LOCKED VMA for a page.
IOW, non-PG_mlocked page is precondition for try_to_munlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
