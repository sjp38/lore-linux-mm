Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A54846B0103
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:14:14 -0400 (EDT)
Date: Mon, 11 Jun 2012 15:14:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 12/16] hugetlb/cgroup: Add support for cgroup removal
Message-ID: <20120611131411.GN12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120611085258.GD12402@tiehlicka.suse.cz>
 <87fwa25gqj.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fwa25gqj.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon 11-06-12 15:10:20, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@suse.cz> writes:
[...]
> >> +static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
> >> +				      struct page *page)
> >
> > deserves a comment about the locking (needs to be called with
> > hugetlb_lock).
> 
> will do
> 
> >
> >> +{
> >> +	int csize;
> >> +	struct res_counter *counter;
> >> +	struct res_counter *fail_res;
> >> +	struct hugetlb_cgroup *page_hcg;
> >> +	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
> >> +	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
> >> +
> >> +	if (!get_page_unless_zero(page))
> >> +		goto out;
> >> +
> >> +	page_hcg = hugetlb_cgroup_from_page(page);
> >> +	/*
> >> +	 * We can have pages in active list without any cgroup
> >> +	 * ie, hugepage with less than 3 pages. We can safely
> >> +	 * ignore those pages.
> >> +	 */
> >> +	if (!page_hcg || page_hcg != h_cg)
> >> +		goto err_out;
> >
> > How can we have page_hcg != NULL && page_hcg != h_cg?
> 
> pages belonging to other cgroup ?

OK, I've forgot that you are iterating over all active huge pages in
hugetlb_cgroup_pre_destroy. What prevents you from doing the filtering
in the caller? 
I am also wondering why you need to play with the page reference
counting here. You are under hugetlb_lock so the page cannot disappear
in the meantime or am I missing something?
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
