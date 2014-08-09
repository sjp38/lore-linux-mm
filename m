Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C9D786B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 06:05:59 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so8592952pab.30
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 03:05:59 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id qq1si5825504pbb.121.2014.08.09.03.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 03:05:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Aug 2014 15:35:55 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B6C191258018
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 15:35:56 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s79A67ta56426522
	for <linux-mm@kvack.org>; Sat, 9 Aug 2014 15:36:07 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s79A5nk9011282
	for <linux-mm@kvack.org>; Sat, 9 Aug 2014 15:35:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch v2] mm, hugetlb_cgroup: align hugetlb cgroup limit to hugepage size
In-Reply-To: <alpine.DEB.2.02.1408081507180.15603@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com> <alpine.DEB.2.02.1408081507180.15603@chino.kir.corp.google.com>
Date: Sat, 09 Aug 2014 15:35:47 +0530
Message-ID: <87mwbem0zo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes <rientjes@google.com> writes:

> Memcg aligns memory.limit_in_bytes to PAGE_SIZE as part of the resource counter
> since it makes no sense to allow a partial page to be charged.
>
> As a result of the hugetlb cgroup using the resource counter, it is also aligned
> to PAGE_SIZE but makes no sense unless aligned to the size of the hugepage being
> limited.
>
> Align hugetlb cgroup limit to hugepage size.
>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> ---
>  v2: use huge_page_order() per Aneesh
>      Sorry for not cc'ing you initially, get_maintainer.pl failed me
>
>  mm/hugetlb_cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -275,6 +275,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  		ret = res_counter_memparse_write_strategy(buf, &val);
>  		if (ret)
>  			break;
> +		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));

Do we really need ULL ? max value should fit in unsigned long right ?

>  		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
>  		break;
>  	default:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
