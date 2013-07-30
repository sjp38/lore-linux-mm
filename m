Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 882F56B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 12:49:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 02:33:44 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E315E357804E
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:49:41 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UGnOM17340288
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:49:31 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UGnX0j009088
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:49:34 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/18] mm, hugetlb: protect reserved pages when softofflining requests the pages
In-Reply-To: <1375075929-6119-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com> <1375075929-6119-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 30 Jul 2013 22:19:28 +0530
Message-ID: <8761vsq9gn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> alloc_huge_page_node() use dequeue_huge_page_node() without
> any validation check, so it can steal reserved page unconditionally.
> To fix it, check the number of free_huge_page in
> alloc_huge_page_node().


May be we should say. Don't use the reserve pool when soft offlining a huge
page. Check we have free pages outside the reserve pool before we
dequeue the huge page 

Reviewed-by: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>


>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6782b41..d971233 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -935,10 +935,11 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>   */
>  struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
>
>  	spin_lock(&hugetlb_lock);
> -	page = dequeue_huge_page_node(h, nid);
> +	if (h->free_huge_pages - h->resv_huge_pages > 0)
> +		page = dequeue_huge_page_node(h, nid);
>  	spin_unlock(&hugetlb_lock);
>
>  	if (!page)
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
