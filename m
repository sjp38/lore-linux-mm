Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 261396B02A6
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:52:05 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so30302427wjd.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:52:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16si23443807wra.331.2017.01.24.08.52.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 08:52:03 -0800 (PST)
Date: Tue, 24 Jan 2017 17:52:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 1/3] mm/hugetlb: split alloc_fresh_huge_page_node
 into fast and slow path
Message-ID: <20170124165200.GB30832@dhcp22.suse.cz>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
 <1485244144-13487-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485244144-13487-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Tue 24-01-17 15:49:02, Jia He wrote:
> This patch split alloc_fresh_huge_page_node into 2 parts:
> - fast path without __GFP_REPEAT flag
> - slow path with __GFP_REPEAT flag
> 
> Thus, if there is a server with uneven numa memory layout:
> available: 7 nodes (0-6)
> node 0 cpus: 0 1 2 3 4 5 6 7
> node 0 size: 6603 MB
> node 0 free: 91 MB
> node 1 cpus:
> node 1 size: 12527 MB
> node 1 free: 157 MB
> node 2 cpus:
> node 2 size: 15087 MB
> node 2 free: 189 MB
> node 3 cpus:
> node 3 size: 16111 MB
> node 3 free: 205 MB
> node 4 cpus: 8 9 10 11 12 13 14 15
> node 4 size: 24815 MB
> node 4 free: 310 MB
> node 5 cpus:
> node 5 size: 4095 MB
> node 5 free: 61 MB
> node 6 cpus:
> node 6 size: 22750 MB
> node 6 free: 283 MB
> node distances:
> node   0   1   2   3   4   5   6
>   0:  10  20  40  40  40  40  40
>   1:  20  10  40  40  40  40  40
>   2:  40  40  10  20  40  40  40
>   3:  40  40  20  10  40  40  40
>   4:  40  40  40  40  10  20  40
>   5:  40  40  40  40  20  10  40
>   6:  40  40  40  40  40  40  10
> 
> In this case node 5 has less memory and we will alloc the hugepages
> from these nodes one by one.
> After this patch, we will not trigger too early direct memory/kswap
> reclaim for node 5 if there are enough memory in other nodes.

This description is doesn't explain what is the problem, why it matters
and how the fix actually works. Moreover it does opposite what is
claims. Which brings me to another question. How has this been tested? 

> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
>  mm/hugetlb.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c7025c1..f2415ce 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1364,10 +1364,19 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
>  
> +	/* fast path without __GFP_REPEAT */
>  	page = __alloc_pages_node(nid,
>  		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>  						__GFP_REPEAT|__GFP_NOWARN,
>  		huge_page_order(h));

this does opposite what the comment says.

> +
> +	/* slow path with __GFP_REPEAT*/
> +	if (!page)
> +		page = __alloc_pages_node(nid,
> +			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
> +					__GFP_NOWARN,
> +			huge_page_order(h));
> +
>  	if (page) {
>  		prep_new_huge_page(h, page, nid);
>  	}
> -- 
> 2.5.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
