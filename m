Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 9A7976B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:23:47 -0400 (EDT)
Date: Fri, 15 Jun 2012 14:23:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V2 1/2] hugetlb: Move all the in use pages to active list
Message-ID: <20120615122121.GA8100@tiehlicka.suse.cz>
References: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Fri 15-06-12 16:01:02, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> When we fail to allocate pages from the reserve pool, hugetlb
> do try to allocate huge pages using alloc_buddy_huge_page.
> Add these to the active list. We also need to add the huge
> page we allocate when we soft offline the oldpage to active
> list.

Yes, I have totally missed this.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/hugetlb.c |   11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c57740b..ec7b86e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -928,8 +928,14 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	page = dequeue_huge_page_node(h, nid);
>  	spin_unlock(&hugetlb_lock);
>  
> -	if (!page)
> +	if (!page) {
>  		page = alloc_buddy_huge_page(h, nid);
> +		if (page) {
> +			spin_lock(&hugetlb_lock);
> +			list_move(&page->lru, &h->hugepage_activelist);
> +			spin_unlock(&hugetlb_lock);
> +		}
> +	}
>  
>  	return page;
>  }
> @@ -1155,6 +1161,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  			hugepage_subpool_put_pages(spool, chg);
>  			return ERR_PTR(-ENOSPC);
>  		}
> +		spin_lock(&hugetlb_lock);
> +		list_move(&page->lru, &h->hugepage_activelist);
> +		spin_unlock(&hugetlb_lock);
>  	}
>  
>  	set_page_private(page, (unsigned long)spool);
> -- 
> 1.7.10
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
