Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6739C6B0390
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 07:54:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 10so41893666pgb.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 04:54:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f17si3743080plj.72.2017.03.03.04.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 04:54:19 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23CsBwr015722
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 07:54:19 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28y34pfe37-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 07:54:18 -0500
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 18:24:15 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 76AB23940060
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:24:13 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v23Cs9Qs14024914
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 18:24:09 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v23CsCJx019313
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 18:24:12 +0530
Subject: Re: [RFC 07/11] mm: remove SWAP_AGAIN in ttu
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-8-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 18:24:06 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-8-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <fce4a36a-8b4b-333d-d846-9f6edd86c2e1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> In 2002, [1] introduced SWAP_AGAIN.
> At that time, ttuo used spin_trylock(&mm->page_table_lock) so it's

Small nit: Please expand "ttuo" here. TTU in the first place is also
not very clear but we have that in many places.

> really easy to contend and fail to hold a lock so SWAP_AGAIN to keep
> LRU status makes sense.

Okay.

> 
> However, now we changed it to mutex-based lock and be able to block
> without skip pte so there is a few of small window to return
> SWAP_AGAIN so remove SWAP_AGAIN and just return SWAP_FAIL.

Makes sense.

> 
> [1] c48c43e, minimal rmap
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/rmap.c   | 11 +++--------
>  mm/vmscan.c |  2 --
>  2 files changed, 3 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 47898a1..da18f21 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1492,13 +1492,10 @@ static int page_mapcount_is_zero(struct page *page)
>   * Return values are:
>   *
>   * SWAP_SUCCESS	- we succeeded in removing all mappings
> - * SWAP_AGAIN	- we missed a mapping, try again later
>   * SWAP_FAIL	- the page is unswappable
>   */
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
> -	int ret;
> -
>  	struct rmap_walk_control rwc = {
>  		.rmap_one = try_to_unmap_one,
>  		.arg = (void *)flags,
> @@ -1518,13 +1515,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  		rwc.invalid_vma = invalid_migration_vma;
>  
>  	if (flags & TTU_RMAP_LOCKED)
> -		ret = rmap_walk_locked(page, &rwc);
> +		rmap_walk_locked(page, &rwc);
>  	else
> -		ret = rmap_walk(page, &rwc);
> +		rmap_walk(page, &rwc);
>  
> -	if (!page_mapcount(page))
> -		ret = SWAP_SUCCESS;
> -	return ret;
> +	return !page_mapcount(page) ? SWAP_SUCCESS: SWAP_FAIL;

Its very simple now. So after the rmap_walk() if page is not mapped any
more return SWAP_SUCCESS otherwise SWAP_FAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
