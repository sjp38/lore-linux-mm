Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1BB946B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 04:32:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 09:19:07 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6B8OSH047382706
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 18:24:28 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6B8WSFX004950
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 18:32:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb_cgroup: Add list_del to remove unused page from hugepage_activelist when hugepage migration
In-Reply-To: <1341978718-6423-1-git-send-email-liwp.linux@gmail.com>
References: <1341978718-6423-1-git-send-email-liwp.linux@gmail.com>
Date: Wed, 11 Jul 2012 14:02:23 +0530
Message-ID: <87wr2aitpk.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Wanpeng Li <liwp.linux@gmail.com> writes:

> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>
> hugepage_activelist is used to track currently used HugeTLB pages.
> We can find the in-use HugeTLB pages to support HugeTLB cgroup
> removal. Don't keep unused page in hugetlb_activelist too long.
> Otherwise, on cgroup removal we should update the unused page's 
> charge to parent count. To reduce this overhead, remove unused page 
> from hugepage_activelist immediately.
>
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/hugetlb_cgroup.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index b834e8d..d819d66 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -398,6 +398,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
>  	spin_lock(&hugetlb_lock);
>  	h_cg = hugetlb_cgroup_from_page(oldhpage);
>  	set_hugetlb_cgroup(oldhpage, NULL);
> +	list_del(&oldhpage->lru);
>
>  	/* move the h_cg details to new cgroup */
>  	set_hugetlb_cgroup(newhpage, h_cg);

put_page on the oldhpage will do that. If we do list_del here
free_huge_page() will have error list_move().

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
