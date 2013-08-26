Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C03D26B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:40:28 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 23:26:44 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C13572CE8052
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:38:15 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QDM3AC66191434
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:22:03 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7QDcEEx020766
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:38:15 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/20] mm, hugetlb: remove a check for return value of alloc_huge_page()
In-Reply-To: <1376040398-11212-16-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-16-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 26 Aug 2013 19:08:09 +0530
Message-ID: <87sixwd132.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Now, alloc_huge_page() only return -ENOSPEC if failed.
> So, we don't worry about other return value.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc666cf..24de2ca 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2544,7 +2544,6 @@ retry_avoidcopy:
>  	new_page = alloc_huge_page(vma, address, use_reserve);
>
>  	if (IS_ERR(new_page)) {
> -		long err = PTR_ERR(new_page);
>  		page_cache_release(old_page);
>
>  		/*
> @@ -2573,10 +2572,7 @@ retry_avoidcopy:
>
>  		/* Caller expects lock to be held */
>  		spin_lock(&mm->page_table_lock);
> -		if (err == -ENOMEM)
> -			return VM_FAULT_OOM;
> -		else
> -			return VM_FAULT_SIGBUS;
> +		return VM_FAULT_SIGBUS;
>  	}
>
>  	/*
> @@ -2707,11 +2703,7 @@ retry:
>
>  		page = alloc_huge_page(vma, address, use_reserve);
>  		if (IS_ERR(page)) {
> -			ret = PTR_ERR(page);
> -			if (ret == -ENOMEM)
> -				ret = VM_FAULT_OOM;
> -			else
> -				ret = VM_FAULT_SIGBUS;
> +			ret = VM_FAULT_SIGBUS;
>  			goto out;
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
