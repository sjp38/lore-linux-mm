Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 072856B0070
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:35:54 -0400 (EDT)
Date: Fri, 15 Jun 2012 14:35:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V2 2/2] hugetlb/cgroup: Assign the page hugetlb cgroup
 when we move the page to active list.
Message-ID: <20120615123543.GB8100@tiehlicka.suse.cz>
References: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339756263-20378-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339756263-20378-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Fri 15-06-12 16:01:03, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> page's hugetlb cgroup assign and moving to active list should happen with
> hugetlb_lock held. Otherwise when we remove the hugetlb cgroup we would
> iterate the active list and will find page with NULL hugetlb cgroup values.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/hugetlb.c        |   14 +++++++++-----
>  mm/hugetlb_cgroup.c |    3 +--
>  2 files changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec7b86e..10160cb 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1150,9 +1150,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	}
>  	spin_lock(&hugetlb_lock);
>  	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
> -	spin_unlock(&hugetlb_lock);
> -
> -	if (!page) {
> +	if (page) {
> +		/* update page cgroup details */
> +		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
> +					     h_cg, page);
> +		spin_unlock(&hugetlb_lock);
> +	} else {
> +		spin_unlock(&hugetlb_lock);
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>  		if (!page) {
>  			hugetlb_cgroup_uncharge_cgroup(idx,
> @@ -1163,14 +1167,14 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		}
>  		spin_lock(&hugetlb_lock);
>  		list_move(&page->lru, &h->hugepage_activelist);
> +		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
> +					     h_cg, page);
>  		spin_unlock(&hugetlb_lock);
>  	}
>  
>  	set_page_private(page, (unsigned long)spool);
>  
>  	vma_commit_reservation(h, vma, addr);
> -	/* update page cgroup details */
> -	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
>  	return page;
>  }
>  
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 8e7ca0a..d4f3f7b 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -218,6 +218,7 @@ done:
>  	return ret;
>  }
>  
> +/* Should be called with hugetlb_lock held */
>  void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
>  				  struct hugetlb_cgroup *h_cg,
>  				  struct page *page)
> @@ -225,9 +226,7 @@ void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
>  	if (hugetlb_cgroup_disabled() || !h_cg)
>  		return;
>  
> -	spin_lock(&hugetlb_lock);
>  	set_hugetlb_cgroup(page, h_cg);
> -	spin_unlock(&hugetlb_lock);
>  	return;
>  }
>  
> -- 
> 1.7.10
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
