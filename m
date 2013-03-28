Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 224296B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 04:53:25 -0400 (EDT)
Date: Thu, 28 Mar 2013 09:53:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Message-ID: <20130328085320.GC3018@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87boa69z6j.fsf@linux.vnet.ibm.com>
 <20130327135250.GI16579@dhcp22.suse.cz>
 <1364411964-iukb7m94-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364411964-iukb7m94-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Wed 27-03-13 15:19:24, Naoya Horiguchi wrote:
> On Wed, Mar 27, 2013 at 02:52:50PM +0100, Michal Hocko wrote:
> > On Tue 26-03-13 16:59:40, Aneesh Kumar K.V wrote:
> > > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> > [...]
> > > > diff --git v3.9-rc3.orig/mm/memory-failure.c v3.9-rc3/mm/memory-failure.c
> > > > index df0694c..4e01082 100644
> > > > --- v3.9-rc3.orig/mm/memory-failure.c
> > > > +++ v3.9-rc3/mm/memory-failure.c
> > > > @@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
> > > >  	int ret;
> > > >  	unsigned long pfn = page_to_pfn(page);
> > > >  	struct page *hpage = compound_head(page);
> > > > +	LIST_HEAD(pagelist);
> > > >
> > > >  	/*
> > > >  	 * This double-check of PageHWPoison is to avoid the race with
> > > > @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
> > > >  	unlock_page(hpage);
> > > >
> > > >  	/* Keep page count to indicate a given hugepage is isolated. */
> > > > -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> > > > -				MIGRATE_SYNC);
> > > > -	put_page(hpage);
> > > > +	list_move(&hpage->lru, &pagelist);
> > > 
> > > we use hpage->lru to add the hpage to h->hugepage_activelist. This will
> > > break a hugetlb cgroup removal isn't it ?
> > 
> > This particular part will not break removal because
> > hugetlb_cgroup_css_offline loops until hugetlb_cgroup_have_usage is 0.
> 
> Right.
> 
> > Little bit offtopic:
> > Btw. hugetlb migration breaks to charging even before this patchset
> > AFAICS. The above put_page should remove the last reference and then it
> > will uncharge it but I do not see anything that would charge a new page.
> > This is all because regula LRU pages are uncharged when they are
> > unmapped. But this a different story not related to this series.
> 
> It seems to me that alloc_huge_page_node() needs to call
> hugetlb_cgroup_charge_cgroup() before dequeuing a new hugepage.

This is not that easy because the new page has to be charged to the same
group as the original one but the migration process might be running in
the context of a different group.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
