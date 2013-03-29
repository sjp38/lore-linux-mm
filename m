Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 038B96B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 12:23:55 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id d17so279721eek.39
        for <linux-mm@kvack.org>; Fri, 29 Mar 2013 09:23:54 -0700 (PDT)
Date: Fri, 29 Mar 2013 17:23:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page() (fwd)
Message-ID: <20130329162337.GA30407@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Forwarding off-list email

On Fri 29-03-13 18:24:01, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Fri 29-03-13 10:56:00, Aneesh Kumar K.V wrote:
> >> Michal Hocko <mhocko@suse.cz> writes:
> > [...]
> >> > Little bit offtopic:
> >> > Btw. hugetlb migration breaks to charging even before this patchset
> >> > AFAICS. The above put_page should remove the last reference and then it
> >> > will uncharge it but I do not see anything that would charge a new page.
> >> > This is all because regula LRU pages are uncharged when they are
> >> > unmapped. But this a different story not related to this series.
> >> 
> >> 
> >> But when we call that put_page, we would have alreayd move the cgroup
> >> information to the new page. We have
> >> 
> >> 	h_cg = hugetlb_cgroup_from_page(oldhpage);
> >> 	set_hugetlb_cgroup(oldhpage, NULL);
> >> 
> >> 	/* move the h_cg details to new cgroup */
> >> 	set_hugetlb_cgroup(newhpage, h_cg);
> >> 
> >> 
> >> in hugetlb_cgroup_migrate
> >
> > Yes but the res counter charge would be missing for the newpage after
> > put_page
> >
> 
> Moving this to private as i didn't get what you meant here. 
> 
> We unchage hugepage via 
> 
> __put_compound_page -> free_huge_page -> hugetlb_cgroup_uncharge_page
> 
> That does
> 
> 	h_cg = hugetlb_cgroup_from_page(page);
> 	if (unlikely(!h_cg))
> 		return;
> 
> During migrate we do 
> 	set_hugetlb_cgroup(oldhpage, NULL);
> 
> 	/* move the h_cg details to new cgroup */
> 	set_hugetlb_cgroup(newhpage, h_cg);
> 
> So when we do a put_page(oldhpage), we won't be finding any cgroup
> attached to it and hence won't be updating the cgroup res counter value.
> 
> So not sure what you mean by res counter change would be missing for the
> newpage after put_page. I may be missing something here. Can you explain
> ?

Dang! You are right of course. I have missed the !h_cg check in
hugetlb_cgroup_uncharge_page. 

Sorry about the confusion. I am so distracted by many issues these
days...

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
