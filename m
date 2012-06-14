Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 310B56B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 05:02:40 -0400 (EDT)
Message-ID: <4FD9A79D.9030303@huawei.com>
Date: Thu, 14 Jun 2012 16:58:05 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V9 11/15] hugetlb/cgroup: Add charge/uncharge routines
 for hugetlb cgroup
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339583254-895-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339583254-895-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

> +int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,

> +				 struct hugetlb_cgroup **ptr)
> +{
> +	int ret = 0;
> +	struct res_counter *fail_res;
> +	struct hugetlb_cgroup *h_cg = NULL;
> +	unsigned long csize = nr_pages * PAGE_SIZE;
> +
> +	if (hugetlb_cgroup_disabled())
> +		goto done;
> +	/*
> +	 * We don't charge any cgroup if the compound page have less
> +	 * than 3 pages.
> +	 */
> +	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
> +		goto done;
> +again:
> +	rcu_read_lock();
> +	h_cg = hugetlb_cgroup_from_task(current);
> +	if (!h_cg)


In no circumstances should h_cg be NULL.

> +		h_cg = root_h_cgroup;
> +
> +	if (!css_tryget(&h_cg->css)) {
> +		rcu_read_unlock();
> +		goto again;
> +	}
> +	rcu_read_unlock();
> +
> +	ret = res_counter_charge(&h_cg->hugepage[idx], csize, &fail_res);
> +	css_put(&h_cg->css);
> +done:
> +	*ptr = h_cg;
> +	return ret;
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
