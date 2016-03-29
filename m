Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6747A6B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:25:07 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id r72so54510299wmg.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:25:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si16316486wmh.64.2016.03.29.05.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 05:25:06 -0700 (PDT)
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA741F.7010705@suse.cz>
Date: Tue, 29 Mar 2016 14:25:03 +0200
MIME-Version: 1.0
In-Reply-To: <56F4E104.9090505@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2016 07:56 AM, Xishi Qiu wrote:
> It is incorrect to use next_node to find a target node, it will
> return MAX_NUMNODES or invalid node. This will lead to crash in
> buddy system allocation.

One possible place of crash is:
alloc_huge_page_node()
     dequeue_huge_page_node()
         [accesses h->hugepage_freelists[nid] with size MAX_NUMANODES]

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Fixes: c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to 
handle hugepage")
Cc: stable
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_isolation.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 92c4c36..31555b6 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>   	 * now as a simple work-around, we use the next node for destination.
>   	 */
>   	if (PageHuge(page)) {
> -		nodemask_t src = nodemask_of_node(page_to_nid(page));
> -		nodemask_t dst;
> -		nodes_complement(dst, src);
> +		int node = next_online_node(page_to_nid(page));
> +		if (node == MAX_NUMNODES)
> +			node = first_online_node;
>   		return alloc_huge_page_node(page_hstate(compound_head(page)),
> -					    next_node(page_to_nid(page), dst));
> +					    node);
>   	}
>
>   	if (PageHighMem(page))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
