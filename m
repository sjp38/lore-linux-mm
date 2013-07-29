Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id E4F716B003D
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:50:47 -0400 (EDT)
Date: Mon, 29 Jul 2013 14:50:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375123836-3qms0tvi-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1375075929-6119-14-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-14-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 13/18] mm, hugetlb: grab a page_table_lock after
 page_cache_release
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 02:32:04PM +0900, Joonsoo Kim wrote:
> We don't need to grab a page_table_lock when we try to release a page.
> So, defer to grab a page_table_lock.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 35ccdad..255bd9e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2630,10 +2630,11 @@ retry_avoidcopy:
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
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
