Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id CAD8D6B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 17:35:19 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so6108777pbc.21
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 14:35:19 -0700 (PDT)
Date: Mon, 30 Sep 2013 14:35:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb: correct missing private flag clearing
Message-Id: <20130930143514.63fc5b2b4316caed33e1c1b1@linux-foundation.org>
In-Reply-To: <1380527985-18499-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1380527985-18499-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, 30 Sep 2013 16:59:44 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> We should clear the page's private flag when returing the page to
> the page allocator or the hugepage pool. This patch fixes it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
> Hello, Andrew.
> 
> I sent the new version of commit ('07443a8') before you did pull request,
> but it isn't included. It may be losted :)
> So I send this fix. IMO, this is good for v3.12.
> 
> Thanks.
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index b49579c..691f226 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -653,6 +653,7 @@ static void free_huge_page(struct page *page)
>  	BUG_ON(page_count(page));
>  	BUG_ON(page_mapcount(page));
>  	restore_reserve = PagePrivate(page);
> +	ClearPagePrivate(page);
>  

You describe it as a fix, but what does it fix?  IOW, what are the
user-visible effects of the change?

update_and_free_page() already clears PG_private, but afaict the bit
remains unaltered if free_huge_page() takes the enqueue_huge_page()
route.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
