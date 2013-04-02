Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 06E446B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 05:45:27 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:45:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Message-ID: <20130402094524.GF24345@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87boa69z6j.fsf@linux.vnet.ibm.com>
 <20130327135250.GI16579@dhcp22.suse.cz>
 <874nfqesut.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874nfqesut.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon 01-04-13 10:43:14, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Tue 26-03-13 16:59:40, Aneesh Kumar K.V wrote:
> >> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> > [...]
> >> > diff --git v3.9-rc3.orig/mm/memory-failure.c v3.9-rc3/mm/memory-failure.c
> >> > index df0694c..4e01082 100644
> >> > --- v3.9-rc3.orig/mm/memory-failure.c
> >> > +++ v3.9-rc3/mm/memory-failure.c
> >> > @@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
> >> >  	int ret;
> >> >  	unsigned long pfn = page_to_pfn(page);
> >> >  	struct page *hpage = compound_head(page);
> >> > +	LIST_HEAD(pagelist);
> >> >
> >> >  	/*
> >> >  	 * This double-check of PageHWPoison is to avoid the race with
> >> > @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
> >> >  	unlock_page(hpage);
> >> >
> >> >  	/* Keep page count to indicate a given hugepage is isolated. */
> >> > -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> >> > -				MIGRATE_SYNC);
> >> > -	put_page(hpage);
> >> > +	list_move(&hpage->lru, &pagelist);
> >> 
> >> we use hpage->lru to add the hpage to h->hugepage_activelist. This will
> >> break a hugetlb cgroup removal isn't it ?
> >
> > This particular part will not break removal because
> > hugetlb_cgroup_css_offline loops until hugetlb_cgroup_have_usage is 0.
> >
> 
> But we still need to hold hugetlb_lock around that right ?

Right. Racing hugetlb_cgroup_move_parent and hugetlb_cgroup_migrate could
lead to newpage pointing to NULL cgroup. That could be fixed by checking
old page cgroup for NULL inside hugetlb_lock and using
list_for_each_safe in hugetlb_cgroup_css_offline no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
