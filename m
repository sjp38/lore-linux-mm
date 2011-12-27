Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B90236B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 18:43:53 -0500 (EST)
Date: Tue, 27 Dec 2011 15:43:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page
Message-Id: <20111227154352.0595b3a8.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
References: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 23 Dec 2011 21:35:25 +0800
Hillf Danton <dhillf@gmail.com> wrote:

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

btw,

	/* Free the needed pages to the hugetlb pool */
	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
		if ((--needed) < 0)
			break;
		list_del(&page->lru);
		/*
		 * This page is now managed by the hugetlb allocator and has
		 * no users -- drop the buddy allocator's reference.
		 */
		put_page_testzero(page);
		VM_BUG_ON(page_count(page));
		enqueue_huge_page(h, page);
	}
	spin_unlock(&hugetlb_lock);


That VM_BUG_ON() largely duplicates the one in put_page_testzero().

(Putting a VM_BUG_ON() in put_page_testzero() was pretty expensive,
too.  I wonder how many people are enabling VM_BUG_ON()?  We should be
sparing in using these things)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
