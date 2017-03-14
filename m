Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE7836B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 03:35:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so360584805pge.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 00:35:03 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z13si13965224pfj.93.2017.03.14.00.35.01
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 00:35:02 -0700 (PDT)
Date: Tue, 14 Mar 2017 16:34:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 02/10] mm: remove SWAP_DIRTY in ttu
Message-ID: <20170314073416.GA29720@bbox>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
 <1489365353-28205-3-git-send-email-minchan@kernel.org>
 <099201d29bc3$e3ab2d60$ab018820$@alibaba-inc.com>
MIME-Version: 1.0
In-Reply-To: <099201d29bc3$e3ab2d60$ab018820$@alibaba-inc.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>


Hello Hillf,

On Mon, Mar 13, 2017 at 02:34:37PM +0800, Hillf Danton wrote:
> 
> On March 13, 2017 8:36 AM Minchan Kim wrote: 
> > 
> > If we found lazyfree page is dirty, try_to_unmap_one can just
> > SetPageSwapBakced in there like PG_mlocked page and just return
> > with SWAP_FAIL which is very natural because the page is not
> > swappable right now so that vmscan can activate it.
> > There is no point to introduce new return value SWAP_DIRTY
> > in ttu at the moment.
> > 
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> 
> >  include/linux/rmap.h | 1 -
> >  mm/rmap.c            | 6 +++---
> >  mm/vmscan.c          | 3 ---
> >  3 files changed, 3 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index fee10d7..b556eef 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -298,6 +298,5 @@ static inline int page_mkclean(struct page *page)
> >  #define SWAP_AGAIN	1
> >  #define SWAP_FAIL	2
> >  #define SWAP_MLOCK	3
> > -#define SWAP_DIRTY	4
> > 
> >  #endif	/* _LINUX_RMAP_H */
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 9dbfa6f..d47af09 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1414,7 +1414,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  			 */
> >  			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
> >  				WARN_ON_ONCE(1);
> > -				ret = SWAP_FAIL;
> > +				ret = false;
> Nit:
> Hm looks like stray merge.
> Not sure it's really needed. 

rebase fail ;-O

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
