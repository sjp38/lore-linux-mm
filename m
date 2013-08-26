Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 9B4936B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 10:09:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 19:30:42 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A8C6E394005A
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:39:40 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QEBRUC35913852
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:41:27 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7QE9n92017068
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:39:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 17/20] mm, hugetlb: move up anon_vma_prepare()
In-Reply-To: <1376040398-11212-18-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-18-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 26 Aug 2013 19:39:48 +0530
Message-ID: <87k3j8czmb.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> If we fail with a allocated hugepage, we need some effort to recover
> properly. So, it is better not to allocate a hugepage as much as possible.
> So move up anon_vma_prepare() which can be failed in OOM situation.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2372f75..7e9a651 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2520,6 +2520,17 @@ retry_avoidcopy:
>  	spin_unlock(&mm->page_table_lock);
>
>  	/*
> +	 * When the original hugepage is shared one, it does not have
> +	 * anon_vma prepared.
> +	 */
> +	if (unlikely(anon_vma_prepare(vma))) {
> +		page_cache_release(old_page);
> +		/* Caller expects lock to be held */
> +		spin_lock(&mm->page_table_lock);
> +		return VM_FAULT_OOM;
> +	}
> +
> +	/*
>  	 * If the process that created a MAP_PRIVATE mapping is about to
>  	 * perform a COW due to a shared page count, attempt to satisfy
>  	 * the allocation without using the existing reserves. The pagecache
> @@ -2578,18 +2589,6 @@ retry_avoidcopy:
>  		return VM_FAULT_SIGBUS;
>  	}
>
> -	/*
> -	 * When the original hugepage is shared one, it does not have
> -	 * anon_vma prepared.
> -	 */
> -	if (unlikely(anon_vma_prepare(vma))) {
> -		page_cache_release(new_page);
> -		page_cache_release(old_page);
> -		/* Caller expects lock to be held */
> -		spin_lock(&mm->page_table_lock);
> -		return VM_FAULT_OOM;
> -	}
> -
>  	copy_user_huge_page(new_page, old_page, address, vma,
>  			    pages_per_huge_page(h));
>  	__SetPageUptodate(new_page);
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
