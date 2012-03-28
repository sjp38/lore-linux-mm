Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id BBCFA6B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 05:25:50 -0400 (EDT)
Date: Wed, 28 Mar 2012 11:25:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 02/10] hugetlbfs: don't use ERR_PTR with VM_FAULT*
 values
Message-ID: <20120328092547.GC20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331919570-2264-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri 16-03-12 23:09:22, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Using VM_FAULT_* codes with ERR_PTR will require us to make sure
> VM_FAULT_* values will not exceed MAX_ERRNO value.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c |   18 +++++++++++++-----
>  1 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d623e71..3782da8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
[...]
> @@ -1047,7 +1047,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>  		if (!page) {
>  			hugetlb_put_quota(inode->i_mapping, chg);
> -			return ERR_PTR(-VM_FAULT_SIGBUS);
> +			return ERR_PTR(-ENOSPC);

Hmm, so one error code abuse replaced by another?
I know that ENOMEM would revert 4a6018f7 which would be unfortunate but
ENOSPC doesn't feel right as well.

>  		}
>  	}
>  
> @@ -2395,6 +2395,7 @@ retry_avoidcopy:
>  	new_page = alloc_huge_page(vma, address, outside_reserve);
>  
>  	if (IS_ERR(new_page)) {
> +		int err = PTR_ERR(new_page);
>  		page_cache_release(old_page);
>  
>  		/*
> @@ -2424,7 +2425,10 @@ retry_avoidcopy:
>  
>  		/* Caller expects lock to be held */
>  		spin_lock(&mm->page_table_lock);
> -		return -PTR_ERR(new_page);
> +		if (err == -ENOMEM)
> +			return VM_FAULT_OOM;
> +		else
> +			return VM_FAULT_SIGBUS;
>  	}
>  
>  	/*
> @@ -2542,7 +2546,11 @@ retry:
>  			goto out;
>  		page = alloc_huge_page(vma, address, 0);
>  		if (IS_ERR(page)) {
> -			ret = -PTR_ERR(page);
> +			ret = PTR_ERR(page);
> +			if (ret == -ENOMEM)
> +				ret = VM_FAULT_OOM;
> +			else
> +				ret = VM_FAULT_SIGBUS;
>  			goto out;
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));
> -- 
> 1.7.9
> 

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
