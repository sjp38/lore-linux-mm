Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A9EA06B00EB
	for <linux-mm@kvack.org>; Thu, 24 May 2012 17:17:45 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1014155pbb.14
        for <linux-mm@kvack.org>; Thu, 24 May 2012 14:17:45 -0700 (PDT)
Date: Thu, 24 May 2012 14:17:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V6 02/14] hugetlbfs: don't use ERR_PTR with VM_FAULT*
 values
In-Reply-To: <1334573091-18602-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1205241417240.24113@chino.kir.corp.google.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1334573091-18602-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, 16 Apr 2012, Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Using VM_FAULT_* codes with ERR_PTR will require us to make sure
> VM_FAULT_* values will not exceed MAX_ERRNO value.
> 

Is it worth the extra branches?

> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c |   18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 766eb90..5a472a5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1123,10 +1123,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	 */
>  	chg = vma_needs_reservation(h, vma, addr);
>  	if (chg < 0)
> -		return ERR_PTR(-VM_FAULT_OOM);
> +		return ERR_PTR(-ENOMEM);
>  	if (chg)
>  		if (hugepage_subpool_get_pages(spool, chg))
> -			return ERR_PTR(-VM_FAULT_SIGBUS);
> +			return ERR_PTR(-ENOSPC);
>  
>  	spin_lock(&hugetlb_lock);
>  	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
> @@ -1136,7 +1136,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>  		if (!page) {
>  			hugepage_subpool_put_pages(spool, chg);
> -			return ERR_PTR(-VM_FAULT_SIGBUS);
> +			return ERR_PTR(-ENOSPC);
>  		}
>  	}
>  
> @@ -2486,6 +2486,7 @@ retry_avoidcopy:
>  	new_page = alloc_huge_page(vma, address, outside_reserve);
>  
>  	if (IS_ERR(new_page)) {
> +		int err = PTR_ERR(new_page);
>  		page_cache_release(old_page);
>  
>  		/*

PTR_ERR() returns long.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
