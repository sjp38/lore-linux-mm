Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 53F386B00E2
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:17:01 -0400 (EDT)
Date: Mon, 11 Jun 2012 11:16:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 10/16] hugetlb/cgroup: Add the cgroup pointer to page
 lru
Message-ID: <20120611091658.GG12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120611081653.GB12402@tiehlicka.suse.cz>
 <87oboq5ifb.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87oboq5ifb.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon 11-06-12 14:33:52, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Sat 09-06-12 14:29:55, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> Add the hugetlb cgroup pointer to 3rd page lru.next.
> >
> > Interesting and I really like the idea much more than tracking by
> > page_cgroup.
> >
> >> This limit the usage to hugetlb cgroup to only hugepages with 3 or
> >> more normal pages. I guess that is an acceptable limitation.
> >
> > Agreed.
> >
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >
> > Other than some nits I like this.
> > Thanks!
> >
> >> ---
> >>  include/linux/hugetlb_cgroup.h |   31 +++++++++++++++++++++++++++++++
> >>  mm/hugetlb.c                   |    4 ++++
> >>  2 files changed, 35 insertions(+)
> >> 
> >> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> >> index 5794be4..ceff1d5 100644
> >> --- a/include/linux/hugetlb_cgroup.h
> >> +++ b/include/linux/hugetlb_cgroup.h
> >> @@ -26,6 +26,26 @@ struct hugetlb_cgroup {
> >>  };
> >>  
> >>  #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> >> +static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
> >> +{
> >> +	if (!PageHuge(page))
> >> +		return NULL;
> >> +	if (compound_order(page) < 3)
> >
> > Why 3? I think you wanted 2 here, right?
> 
> Yes that should be 2. I updated that in an earlier. Already in v9
> version I have locally.

ohh, I should have read replies to the patch first where you already
mentioned that you are aware of that.
Maybe it would be worth something like:
/* Minimum page order trackable by hugetlb cgroup.
 * At least 3 pages are necessary for all the tracking information.
 */
#define HUGETLB_CGROUP_MIN_ORDER	2

> >> @@ -591,6 +592,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
> >>  				1 << PG_active | 1 << PG_reserved |
> >>  				1 << PG_private | 1 << PG_writeback);
> >>  	}
> >> +	BUG_ON(hugetlb_cgroup_from_page(page));
> >
> > What about VM_BUG_ON?
> 
> Will do, So when do one decide to choose VM_BUG_ON against BUG_ON ?

I think that VM_ variant is more approapriate here because it is more a
debugging thing rather than a hard failure invariant.

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
