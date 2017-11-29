Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE476B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:17:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so1811190pfg.14
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 23:17:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d76si874533pfk.321.2017.11.28.23.17.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 23:17:41 -0800 (PST)
Date: Wed, 29 Nov 2017 08:17:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129071737.vjg2sckpkzelifr2@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <29679b8f-53d9-b928-7721-9450dde38104@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29679b8f-53d9-b928-7721-9450dde38104@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 28-11-17 17:39:50, Mike Kravetz wrote:
> On 11/28/2017 06:12 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > hugepage migration relies on __alloc_buddy_huge_page to get a new page.
> > This has 2 main disadvantages.
> > 1) it doesn't allow to migrate any huge page if the pool is used
> > completely which is not an exceptional case as the pool is static and
> > unused memory is just wasted.
> > 2) it leads to a weird semantic when migration between two numa nodes
> > might increase the pool size of the destination NUMA node while the page
> > is in use. The issue is caused by per NUMA node surplus pages tracking
> > (see free_huge_page).
> > 
> > Address both issues by changing the way how we allocate and account
> > pages allocated for migration. Those should temporal by definition.
> > So we mark them that way (we will abuse page flags in the 3rd page)
> > and update free_huge_page to free such pages to the page allocator.
> > Page migration path then just transfers the temporal status from the
> > new page to the old one which will be freed on the last reference.
> 
> In general, I think this will work.  Some questions below.
> 
> > The global surplus count will never change during this path but we still
> > have to be careful when freeing a page from a node with surplus pages
> > on the node.
> 
> Not sure about the "freeing page from a node with surplus pages" comment.
> If allocating PageHugeTemporary pages does not adjust surplus counts, then
> there should be no concern at the time of freeing.
> 
> Could this comment be a hold over from a previous implementation attempt?
> 

Not really. You have to realize that the original page could be surplus
on its node. More on that below.

[...]
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 8189c92fac82..037bf0f89463 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1283,7 +1283,13 @@ void free_huge_page(struct page *page)
> >  	if (restore_reserve)
> >  		h->resv_huge_pages++;
> >  
> > -	if (h->surplus_huge_pages_node[nid]) {
> > +	if (PageHugeTemporary(page)) {
> > +		list_del(&page->lru);
> > +		ClearPageHugeTemporary(page);
> > +		update_and_free_page(h, page);
> > +		if (h->surplus_huge_pages_node[nid])
> > +			h->surplus_huge_pages_node[nid]--;
> 
> I think this is not correct.  Should the lines dealing with per-node
> surplus counts even be here?  If the lines above are correct, then it
> implies that the sum of per node surplus counts could exceed (or get out
> of sync with) the global surplus count.

You are right, I guess. This per-node accounting makes the whole thing
real pain. I am worried that we will free next page from the same node
and reduce the overal pool size. I will think about it some more.

> > +	} else if (h->surplus_huge_pages_node[nid]) {
> >  		/* remove the page from active list */
> >  		list_del(&page->lru);
> >  		update_and_free_page(h, page);
> > @@ -1531,7 +1537,11 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  	return rc;
> >  }
> >  
> > -static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
> > +/*
> > + * Allocates a fresh surplus page from the page allocator. Temporary
> > + * requests (e.g. page migration) can pass enforce_overcommit == false
> 
> 'enforce_overcommit == false' perhaps part of an earlier implementation
> attempt?

yeah.

[...]

> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 4d0be47a322a..b3345f8174a9 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1326,6 +1326,19 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
> >  		hugetlb_cgroup_migrate(hpage, new_hpage);
> >  		put_new_page = NULL;
> >  		set_page_owner_migrate_reason(new_hpage, reason);
> > +
> > +		/*
> > +		 * transfer temporary state of the new huge page. This is
> > +		 * reverse to other transitions because the newpage is going to
> > +		 * be final while the old one will be freed so it takes over
> > +		 * the temporary status.
> > +		 * No need for any locking here because destructor cannot race
> > +		 * with us.
> > +		 */
> > +		if (PageHugeTemporary(new_hpage)) {
> > +			SetPageHugeTemporary(hpage);
> > +			ClearPageHugeTemporary(new_hpage);
> > +		}
> >  	}
> >  
> >  	unlock_page(hpage);
> > 
> 
> I'm still trying to wrap my head around all the different scenarios.
> In general, this new code only 'kicks in' if the there is not a free
> pre-allocated huge page for migration.  Right?

yes

> So, if there are free huge pages they are 'consumed' during migration
> and the number of available pre-allocated huge pages is reduced?  Or,
> is that not exactly how it works?  Or does it depend in the purpose
> of the migration?

Well, if we have pre-allocated pages then we just consume them and they
will not get Temporary status so the additional code doesn't kick in.

> The only reason I ask is because this new method of allocating a surplus
> page (if successful) results in no decrease of available huge pages.
> Perhaps all migrations should attempt to allocate surplus pages and not
> impact the pre-allocated number of available huge pages.

That could reduce the chances of the migration success because
allocating a fresh huge page can fail.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
