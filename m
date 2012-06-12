Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EB4BF6B004D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 04:25:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7651D3EE081
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:25:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 527DE45DE54
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:25:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FF6845DE50
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:25:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 204DF1DB8042
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:25:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9FC81DB8038
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 17:25:21 +0900 (JST)
Message-ID: <4FD6FC76.8040203@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 17:23:18 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V8 12/16] hugetlb/cgroup: Add support for cgroup removal
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/09 17:59), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch add support for cgroup removal. If we don't have parent
> cgroup, the charges are moved to root cgroup.
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

I'm sorry if already pointed out....

> ---
>   mm/hugetlb_cgroup.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++++--
>   1 file changed, 79 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 48efd5a..9458fe3 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -99,10 +99,87 @@ static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
>   	kfree(h_cgroup);
>   }
> 
> +
> +static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
> +				      struct page *page)
> +{
> +	int csize;
> +	struct res_counter *counter;
> +	struct res_counter *fail_res;
> +	struct hugetlb_cgroup *page_hcg;
> +	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
> +	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
> +
> +	if (!get_page_unless_zero(page))
> +		goto out;

It seems this doesn't necessary...this is under hugetlb_lock().

> +
> +	page_hcg = hugetlb_cgroup_from_page(page);
> +	/*
> +	 * We can have pages in active list without any cgroup
> +	 * ie, hugepage with less than 3 pages. We can safely
> +	 * ignore those pages.
> +	 */
> +	if (!page_hcg || page_hcg != h_cg)
> +		goto err_out;
> +
> +	csize = PAGE_SIZE<<  compound_order(page);
> +	if (!parent) {
> +		parent = root_h_cgroup;
> +		/* root has no limit */
> +		res_counter_charge_nofail(&parent->hugepage[idx],
> +					  csize,&fail_res);
                                              ^^^
space ?

> +	}
> +	counter =&h_cg->hugepage[idx];
> +	res_counter_uncharge_until(counter, counter->parent, csize);
> +
> +	set_hugetlb_cgroup(page, parent);
> +err_out:
> +	put_page(page);
> +out:
> +	return 0;
> +}
> +
> +/*
> + * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
> + * the parent cgroup.
> + */
>   static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
>   {
> -	/* We will add the cgroup removal support in later patches */
> -	   return -EBUSY;
> +	struct hstate *h;
> +	struct page *page;
> +	int ret = 0, idx = 0;
> +
> +	do {
> +		if (cgroup_task_count(cgroup) ||
> +		    !list_empty(&cgroup->children)) {
> +			ret = -EBUSY;
> +			goto out;
> +		}

> +		/*
> +		 * If the task doing the cgroup_rmdir got a signal
> +		 * we don't really need to loop till the hugetlb resource
> +		 * usage become zero.
> +		 */
> +		if (signal_pending(current)) {
> +			ret = -EINTR;
> +			goto out;
> +		}

I'll post a patch to remove this check from memcg because memcg's rmdir
always succeed now. So, could you remove this ?


> +		for_each_hstate(h) {
> +			spin_lock(&hugetlb_lock);
> +			list_for_each_entry(page,&h->hugepage_activelist, lru) {
> +				ret = hugetlb_cgroup_move_parent(idx, cgroup, page);
> +				if (ret) {

When 'ret' should be !0 ?
If hugetlb_cgroup_move_parent() always returns 0, the check will not be necessary.

Thanks,
-Kame

> +					spin_unlock(&hugetlb_lock);
> +					goto out;
> +				}
> +			}
> +			spin_unlock(&hugetlb_lock);
> +			idx++;
> +		}
> +		cond_resched();
> +	} while (hugetlb_cgroup_have_usage(cgroup));
> +out:
> +	return ret;
>   }
> 
>   int hugetlb_cgroup_charge_page(int idx, unsigned long nr_pages,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
