Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CD2ED6B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 01:47:50 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so6697440pad.9
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 22:47:50 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id uk2si5184158pbc.200.2014.08.07.22.47.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 22:47:49 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 8 Aug 2014 11:17:44 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B4D623940018
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 11:17:40 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s785m23g6422812
	for <linux-mm@kvack.org>; Fri, 8 Aug 2014 11:18:03 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s785lcYk010381
	for <linux-mm@kvack.org>; Fri, 8 Aug 2014 11:17:39 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch] mm, hugetlb_cgroup: align hugetlb cgroup limit to hugepage size
In-Reply-To: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
Date: Fri, 08 Aug 2014 11:17:37 +0530
Message-ID: <87sil7mt1i.fsf@linux.vnet.ibm.com>
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
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/hugetlb_cgroup.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -275,6 +275,8 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
>  		ret = res_counter_memparse_write_strategy(buf, &val);
>  		if (ret)
>  			break;
> +		val = ALIGN(val, 1 << (huge_page_order(&hstates[idx]) +
> +				       PAGE_SHIFT));

you can use  1UL << huge_page_shift(hstate); ?

>  		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
>  		break;
>  	default:
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
