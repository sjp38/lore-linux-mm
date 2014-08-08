Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C4BDA6B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 04:21:29 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so5224009wgh.1
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 01:21:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si2065853wic.36.2014.08.08.01.21.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 01:21:28 -0700 (PDT)
Date: Fri, 8 Aug 2014 10:21:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, hugetlb_cgroup: align hugetlb cgroup limit to
 hugepage size
Message-ID: <20140808082126.GA4004@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1408071333001.1762@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 07-08-14 13:34:12, David Rientjes wrote:
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

huge_page_shift as proposed by Aneesh looks better.

Acked-by: Michal Hocko <mhocko@suse.cz>

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
>  		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
>  		break;
>  	default:

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
