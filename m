Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 98F726B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:11:59 -0400 (EDT)
Date: Thu, 29 Mar 2012 10:11:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 08/10] hugetlbfs: Add a list for tracking in-use
 HugeTLB pages
Message-ID: <20120329081157.GD30465@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120328135845.GH20949@tiehlicka.suse.cz>
 <87vclo1v8l.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vclo1v8l.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 28-03-12 23:08:34, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Fri 16-03-12 23:09:28, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> hugepage_activelist will be used to track currently used HugeTLB pages.
> >> We need to find the in-use HugeTLB pages to support memcg removal.
> >> On memcg removal we update the page's memory cgroup to point to
> >> parent cgroup.
> >> 
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >>  include/linux/hugetlb.h |    1 +
> >>  mm/hugetlb.c            |   23 ++++++++++++++++++-----
> >>  2 files changed, 19 insertions(+), 5 deletions(-)
> >> 
> >> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> >> index cbd8dc5..6919100 100644
> >> --- a/include/linux/hugetlb.h
> >> +++ b/include/linux/hugetlb.h
> > [...]
> >> @@ -2319,14 +2322,24 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> >>  		page = pte_page(pte);
> >>  		if (pte_dirty(pte))
> >>  			set_page_dirty(page);
> >> -		list_add(&page->lru, &page_list);
> >> +
> >> +		spin_lock(&hugetlb_lock);
> >> +		list_move(&page->lru, &page_list);
> >> +		spin_unlock(&hugetlb_lock);
> >
> > Why do we really need the spinlock here?
> 
> 
> It does a list_del from hugepage_activelist.

right you are.
sorry

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
