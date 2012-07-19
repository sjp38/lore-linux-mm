Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2029D6B007D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 07:39:19 -0400 (EDT)
Date: Thu, 19 Jul 2012 13:39:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
Message-ID: <20120719113915.GC2864@tiehlicka.suse.cz>
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718212637.133475C0050@hpza9.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 18-07-12 14:26:36, Andrew Morton wrote:
> 
> The patch titled
>      Subject: hugetlb/cgroup: simplify pre_destroy callback
> has been added to the -mm tree.  Its filename is
>      hugetlb-cgroup-simplify-pre_destroy-callback.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Subject: hugetlb/cgroup: simplify pre_destroy callback
> 
> Since we cannot fail in hugetlb_cgroup_move_parent(), we don't really need
> to check whether cgroup have any change left after that.  Also skip those
> hstates for which we don't have any charge in this cgroup.

IIUC this depends on a non-existent (cgroup) patch. I guess something
like the patch at the end should address it. I haven't tested it though
so it is not signed-off-by yet.

> Based on an earlier patch from Wanpeng Li.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb_cgroup.c |   49 ++++++++++++++++++------------------------
>  1 file changed, 21 insertions(+), 28 deletions(-)
> 
> diff -puN mm/hugetlb_cgroup.c~hugetlb-cgroup-simplify-pre_destroy-callback mm/hugetlb_cgroup.c
> --- a/mm/hugetlb_cgroup.c~hugetlb-cgroup-simplify-pre_destroy-callback
> +++ a/mm/hugetlb_cgroup.c
> @@ -65,18 +65,6 @@ static inline struct hugetlb_cgroup *par
>  	return hugetlb_cgroup_from_cgroup(cg->parent);
>  }
>  
> -static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
> -{
> -	int idx;
> -	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
> -
> -	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> -		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
> -			return true;
> -	}
> -	return false;
> -}
> -
>  static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
>  {
>  	int idx;
> @@ -159,24 +147,29 @@ static int hugetlb_cgroup_pre_destroy(st
>  {
>  	struct hstate *h;
>  	struct page *page;
> -	int ret = 0, idx = 0;
> +	int ret = 0, idx;
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
>  
> -	do {
> -		if (cgroup_task_count(cgroup) ||
> -		    !list_empty(&cgroup->children)) {
> -			ret = -EBUSY;
> -			goto out;
> -		}
> -		for_each_hstate(h) {
> -			spin_lock(&hugetlb_lock);
> -			list_for_each_entry(page, &h->hugepage_activelist, lru)
> -				hugetlb_cgroup_move_parent(idx, cgroup, page);
>  
> -			spin_unlock(&hugetlb_lock);
> -			idx++;
> -		}
> -		cond_resched();
> -	} while (hugetlb_cgroup_have_usage(cgroup));
> +	if (cgroup_task_count(cgroup) ||
> +	    !list_empty(&cgroup->children)) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	for_each_hstate(h) {
> +		/*
> +		 * if we don't have any charge, skip this hstate
> +		 */
> +		idx = hstate_index(h);
> +		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
> +			continue;
> +		spin_lock(&hugetlb_lock);
> +		list_for_each_entry(page, &h->hugepage_activelist, lru)
> +			hugetlb_cgroup_move_parent(idx, cgroup, page);
> +		spin_unlock(&hugetlb_lock);
> +		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
> +	}
>  out:
>  	return ret;
>  }
> _

---
