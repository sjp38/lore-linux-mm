Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 7EA826B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 07:48:43 -0500 (EST)
Date: Tue, 27 Dec 2011 13:48:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page
Message-ID: <20111227124837.GF5344@tiehlicka.suse.cz>
References: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri 23-12-11 21:35:25, Hillf Danton wrote:
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page
> 
> If huge page is enqueued under the protection of hugetlb_lock, then
> the operation is atomic and safe.
> 
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Yes, looks correct even though the changelog could be more verbose.
The code is broken since .37

Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
> 
> --- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
> +++ b/mm/hugetlb.c	Fri Dec 23 21:16:28 2011
> @@ -901,7 +901,6 @@ retry:
>  	h->resv_huge_pages += delta;
>  	ret = 0;
> 
> -	spin_unlock(&hugetlb_lock);
>  	/* Free the needed pages to the hugetlb pool */
>  	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>  		if ((--needed) < 0)
> @@ -915,6 +914,7 @@ retry:
>  		VM_BUG_ON(page_count(page));
>  		enqueue_huge_page(h, page);
>  	}
> +	spin_unlock(&hugetlb_lock);
> 
>  	/* Free unnecessary surplus pages to the buddy allocator */
>  free:

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
