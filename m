Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5D1616B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:39:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n163dOt8020753
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Feb 2009 12:39:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47B3B45DD7E
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:39:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2346F45DD7D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:39:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 082931DB803F
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:39:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B21CB1DB803C
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:39:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
In-Reply-To: <20090206031324.004715023@cmpxchg.org>
References: <20090206031125.693559239@cmpxchg.org> <20090206031324.004715023@cmpxchg.org>
Message-Id: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Feb 2009 12:39:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

I have some comment.

> File cache pages are saved to disk either through normal writeback by
> reclaim or by including them in the suspend image written to a
> swapfile.
> 
> Writing them either way should take the same amount of time but doing
> normal writeback and unmap changes the fault behaviour on resume from
> prefault to on-demand paging, smoothening out resume and giving
> previously cached pages the chance to stay out of memory completely if
> they are not used anymore.
> 
> Another reason for preferring file page eviction is that the locality
> principle is visible in fault patterns and swap might perform really
> bad with subsequent faulting of contiguously mapped pages.
> 
> Since anon and file pages now live on different lists, selectively
> scanning one type only is straight-forward.

I don't understand your point.
Which do you want to improve suspend performance or resume performance?

if we think suspend performance, we should consider swap device and file-backed device
are different block device.
the interleave of file-backed page out and swap out can improve total write out performce.

if we think resume performance, we shold how think the on-disk contenious of the swap consist
process's virtual address contenious.
it cause to reduce unnecessary seek.
but your patch doesn't this.

Could you explain this patch benefit?
and, I think you should mesure performence result.


<snip>


> @@ -2134,17 +2144,17 @@ unsigned long shrink_all_memory(unsigned
>  
>  	/*
>  	 * We try to shrink LRUs in 5 passes:
> -	 * 0 = Reclaim from inactive_list only
> -	 * 1 = Reclaim from active list but don't reclaim mapped
> -	 * 2 = 2nd pass of type 1
> -	 * 3 = Reclaim mapped (normal reclaim)
> -	 * 4 = 2nd pass of type 3
> +	 * 0 = Reclaim unmapped inactive file pages
> +	 * 1 = Reclaim unmapped file pages

I think your patch reclaim mapped file at priority 0 and 1 too.


> +	 * 2 = Reclaim file and inactive anon pages
> +	 * 3 = Reclaim file and anon pages
> +	 * 4 = Second pass 3
>  	 */
>  	for (pass = 0; pass < 5; pass++) {
>  		int prio;
>  
> -		/* Force reclaiming mapped pages in the passes #3 and #4 */
> -		if (pass > 2)
> +		/* Reclaim mapped pages in higher passes */
> +		if (pass > 1)
>  			sc.may_swap = 1;

Why need this line?
If you reclaim only file backed lru, may_swap isn't effective.
So, Can't we just remove this line and always set may_swap=1 ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
