Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC3F6B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 08:48:18 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so18961508lbb.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 05:48:17 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id jl10si1520713lbc.38.2015.04.01.05.48.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 05:48:16 -0700 (PDT)
Received: by lahf3 with SMTP id f3so35119757lah.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 05:48:15 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 2/2] mm: __free_pages batch up 0-order pages for freeing
References: <1427839895-16434-1-git-send-email-sasha.levin@oracle.com>
	<1427839895-16434-2-git-send-email-sasha.levin@oracle.com>
Date: Wed, 01 Apr 2015 14:48:13 +0200
In-Reply-To: <1427839895-16434-2-git-send-email-sasha.levin@oracle.com> (Sasha
	Levin's message of "Tue, 31 Mar 2015 18:11:33 -0400")
Message-ID: <87wq1w10c2.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Apr 01 2015, Sasha Levin <sasha.levin@oracle.com> wrote:

> Rather than calling free_hot_cold_page() for every page, batch them up in a
> list and pass them on to free_hot_cold_page_list(). This will let us defer
> them to a workqueue.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/page_alloc.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 812ca75..e58e795 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2997,12 +2997,16 @@ EXPORT_SYMBOL(get_zeroed_page);
>  
>  void __free_pages(struct page *page, unsigned int order)
>  {
> +	LIST_HEAD(hot_cold_pages);
> +
>  	if (put_page_testzero(page)) {
>  		if (order == 0)
> -			free_hot_cold_page(page, false);
> +			list_add(&page->lru, &hot_cold_pages);
>  		else
>  			__free_pages_ok(page, order);
>  	}
> +
> +	free_hot_cold_page_list(&hot_cold_pages, false);

Is there a reason to do this function call when the list is empty? In
other words, why can't this just be done inside the if (order == 0)?

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
