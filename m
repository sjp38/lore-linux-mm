Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 45AC76B005C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 02:25:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D7CD13EE0BD
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:25:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEF8845DE5C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:25:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A6FD945DE58
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:25:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C2471DB8058
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:25:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 832F81DB804F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:25:34 +0900 (JST)
Date: Mon, 26 Dec 2011 16:24:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: hugetlb: fix non-atomic enqueue of huge page
Message-Id: <20111226162419.de03469e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
References: <CAJd=RBB-d19=Z0og0i5OrbUVCQFozaqMbVs9Fzw23j=-EFc+DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, stable@kernel.org

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

Hmm, at reporting this kind of bug...it's better to show when it's broken.
Maybe this commit a9869b837c098732bad84939015c0eb391b23e41
and it's better to cc stable.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
