Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 53E756B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:35:26 -0400 (EDT)
Message-ID: <1376314512.3364.1.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2 05/20] mm, hugetlb: grab a page_table_lock after
 page_cache_release
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 12 Aug 2013 06:35:12 -0700
In-Reply-To: <1376040398-11212-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1376040398-11212-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Fri, 2013-08-09 at 18:26 +0900, Joonsoo Kim wrote:
> We don't need to grab a page_table_lock when we try to release a page.
> So, defer to grab a page_table_lock.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Davidlohr Bueso <davidlohr@hp.com>

> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c017c52..6c8eec2 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2627,10 +2627,11 @@ retry_avoidcopy:
>  	}
>  	spin_unlock(&mm->page_table_lock);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> -	/* Caller expects lock to be held */
> -	spin_lock(&mm->page_table_lock);
>  	page_cache_release(new_page);
>  	page_cache_release(old_page);
> +
> +	/* Caller expects lock to be held */
> +	spin_lock(&mm->page_table_lock);
>  	return 0;
>  }
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
