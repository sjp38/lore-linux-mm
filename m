Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G1UV0W018563
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 10:30:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F122AC027
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 10:30:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F99412C044
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 10:30:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A88B1DB8041
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 10:30:31 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 095161DB8038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 10:30:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081015162232.f673fa59.akpm@linux-foundation.org>
References: <20081015162232.f673fa59.akpm@linux-foundation.org>
Message-Id: <20081016102752.9886.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 10:30:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

> I have a note here that this patch needs better justification.  But the
> changelog looks good and there are pretty graphs, so maybe my note is stale.
> 
> Can people please check it?
> 
> Thanks.

maybe, I can run benchmark it.
please wait few hour.



> 
> 
> 
> 
> From: Johannes Weiner <hannes@saeurebad.de>
> 
> File pages accessed only once through sequential-read mappings between
> fault and scan time are perfect candidates for reclaim.
> 
> This patch makes page_referenced() ignore these singular references and
> the pages stay on the inactive list where they likely fall victim to the
> next reclaim phase.
> 
> Already activated pages are still treated normally.  If they were accessed
> multiple times and therefor promoted to the active list, we probably want
> to keep them.
> 
> Benchmarks show that big (relative to the system's memory) MADV_SEQUENTIAL
> mappings read sequentially cause much less kernel activity.  Especially
> less LRU moving-around because we never activate read-once pages in the
> first place just to demote them again.
> 
> And leaving these perfect reclaim candidates on the inactive list makes
> it more likely for the real working set to survive the next reclaim
> scan.
> 
> Benchmark graphs and the test-application can be found here:
> 
> 	http://hannes.saeurebad.de/madvseq/
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/rmap.c |   20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
> 
> diff -puN mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings mm/rmap.c
> --- a/mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings
> +++ a/mm/rmap.c
> @@ -327,8 +327,18 @@ static int page_referenced_one(struct pa
>  		goto out_unmap;
>  	}
>  
> -	if (ptep_clear_flush_young_notify(vma, address, pte))
> -		referenced++;
> +	if (ptep_clear_flush_young_notify(vma, address, pte)) {
> +		/*
> +		 * If there was just one sequential access to the
> +		 * page, ignore it.  Otherwise, mark_page_accessed()
> +		 * will have promoted the page to the active list and
> +		 * it should be kept.
> +		 */
> +		if (VM_SequentialReadHint(vma) && !PageActive(page))
> +			ClearPageReferenced(page);
> +		else
> +			referenced++;
> +	}
>  
>  	/* Pretend the page is referenced if the task has the
>  	   swap token and is in the middle of a page fault. */
> @@ -449,9 +459,6 @@ int page_referenced(struct page *page, i
>  {
>  	int referenced = 0;
>  
> -	if (TestClearPageReferenced(page))
> -		referenced++;
> -
>  	if (page_mapped(page) && page->mapping) {
>  		if (PageAnon(page))
>  			referenced += page_referenced_anon(page, mem_cont);
> @@ -467,6 +474,9 @@ int page_referenced(struct page *page, i
>  		}
>  	}
>  
> +	if (TestClearPageReferenced(page))
> +		referenced++;
> +
>  	if (page_test_and_clear_young(page))
>  		referenced++;
>  
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
