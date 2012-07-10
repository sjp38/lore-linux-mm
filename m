Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 517656B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 13:41:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 10 Jul 2012 23:11:19 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6AHfFGm3670498
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 23:11:15 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6ANB21C011345
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 09:11:03 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm/hugetlb_cgroup: Add huge_page_order check to avoid incorrectly uncharge
In-Reply-To: <1341914712-4588-1-git-send-email-liwp.linux@gmail.com>
References: <1341914712-4588-1-git-send-email-liwp.linux@gmail.com>
Date: Tue, 10 Jul 2012 23:11:07 +0530
Message-ID: <87394z1pl8.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Wanpeng Li <liwp.linux@gmail.com> writes:

> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>
> Against linux-next:
>
> Function alloc_huge_page will call hugetlb_cgroup_charge_cgroup
> to charge pages, the compound page have less than 3 pages will not
> charge to hugetlb cgroup. When alloc_huge_page fails it will call
> hugetlb_cgroup_uncharge_cgroup to uncharge pages, however,
> hugetlb_cgroup_uncharge_cgroup doesn't have huge_page_order check.
> That means it will uncharge pages even if the compound page have less
> than 3 pages. Add huge_page_order check to avoid this incorrectly
> uncharge.
>
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

 Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>



> ---
>  mm/hugetlb_cgroup.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index b834e8d..2b9e214 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -252,6 +252,9 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>
>  	if (hugetlb_cgroup_disabled() || !h_cg)
>  		return;
> +
> +	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
> +		return;
>
>  	res_counter_uncharge(&h_cg->hugepage[idx], csize);
>  	return;
> -- 
> 1.7.5.4

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
