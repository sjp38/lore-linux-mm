Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7F9D56B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 11:46:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 22 Jul 2013 21:10:52 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E911E1258052
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 21:15:23 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6MFkoDm39715034
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 21:16:50 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6MFjwOL017370
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:45:59 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 01/10] mm, hugetlb: move up the code which check availability of free huge page
In-Reply-To: <1374482191-3500-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com> <1374482191-3500-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 22 Jul 2013 21:15:56 +0530
Message-ID: <871u6qoax7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> In this time we are holding a hugetlb_lock, so hstate values can't
> be changed. If we don't have any usable free huge page in this time,
> we don't need to proceede the processing. So move this code up.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e2bfbf7..fc4988c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -539,10 +539,6 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	struct zoneref *z;
>  	unsigned int cpuset_mems_cookie;
>
> -retry_cpuset:
> -	cpuset_mems_cookie = get_mems_allowed();
> -	zonelist = huge_zonelist(vma, address,
> -					htlb_alloc_mask, &mpol, &nodemask);
>  	/*
>  	 * A child process with MAP_PRIVATE mappings created by their parent
>  	 * have no page reserves. This check ensures that reservations are
> @@ -556,6 +552,11 @@ retry_cpuset:
>  	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
>  		goto err;
>
> +retry_cpuset:
> +	cpuset_mems_cookie = get_mems_allowed();
> +	zonelist = huge_zonelist(vma, address,
> +					htlb_alloc_mask, &mpol, &nodemask);
> +
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  						MAX_NR_ZONES - 1, nodemask) {
>  		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
> @@ -574,7 +575,6 @@ retry_cpuset:
>  	return page;
>
>  err:
> -	mpol_cond_put(mpol);
>  	return NULL;
>  }
>
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
