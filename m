Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 549196B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:23:34 -0400 (EDT)
Received: by wibg7 with SMTP id g7so107289832wib.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:23:33 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id bb6si18996978wib.113.2015.03.30.08.23.32
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 08:23:32 -0700 (PDT)
Date: Mon, 30 Mar 2015 18:23:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page
 counts on split
Message-ID: <20150330152321.GB5849@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
 <87k2xylg8w.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k2xylg8w.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 30, 2015 at 07:49:43PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > Currently, we rely on compound_lock() to get page counts stable on
> > splitting page refcounting. To get it work we also take the lock on
> > get_page() and put_page() which is hot path.
> >
> > This patch rework splitting code to setup migration entries to stabilaze
> > page count/mapcount before distribute refcounts. It means we don't need
> > to compound lock in get_page()/put_page().
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/migrate.h |   3 +
> >  include/linux/mm.h      |   1 +
> >  include/linux/pagemap.h |   9 ++-
> >  mm/huge_memory.c        | 188 +++++++++++++++++++++++++++++++++++-------------
> >  mm/internal.h           |  26 +++++--
> >  mm/migrate.c            |  79 +++++++++++---------
> >  mm/rmap.c               |  21 ------
> >  7 files changed, 218 insertions(+), 109 deletions(-)
> >
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 78baed5f2952..b9bc86c24829 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -43,6 +43,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
> >  		struct page *newpage, struct page *page,
> >  		struct buffer_head *head, enum migrate_mode mode,
> >  		int extra_count);
> > +extern int __remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> > +		unsigned long addr, pte_t *ptep, struct page *old);
> > +
> >  #else
> >
> >  static inline void putback_movable_pages(struct list_head *l) {}
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 28aeae6e553b..43a9993f1333 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -981,6 +981,7 @@ extern struct address_space *page_mapping(struct page *page);
> >  /* Neutral page->mapping pointer to address_space or anon_vma or other */
> >  static inline void *page_rmapping(struct page *page)
> >  {
> > +	page = compound_head(page);
> >  	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
> >  }
> >
> 
> The above hunk is related to this patch ?. Are we calling page_rmapping
> on tail pages now ? If so it needs additonal comment why we handle them
> differently now. Or split it to a seperate patch ?

This change is already in -mm via my patchset on tail pages vs. ->mapping
and page falgs.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
