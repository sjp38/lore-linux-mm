Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDA16B002D
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:12:28 -0400 (EDT)
Message-ID: <4E931A15.3090400@jp.fujitsu.com>
Date: Mon, 10 Oct 2011 12:15:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
References: <alpine.DEB.2.00.1110071529110.15540@router.home>
In-Reply-To: <alpine.DEB.2.00.1110071529110.15540@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@gentwo.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie

(10/7/2011 4:32 PM), Christoph Lameter wrote:
> MCL_FUTURE does not move pages between lru list and draining the LRU per
> cpu pagevecs is a nasty activity. Avoid doing it unecessarily.
> 
> Signed-off-by: Christoph Lameter <cl@gentwo.org>
> 
> 
> ---
>  mm/mlock.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/mlock.c
> ===================================================================
> --- linux-2.6.orig/mm/mlock.c	2011-10-07 14:57:52.000000000 -0500
> +++ linux-2.6/mm/mlock.c	2011-10-07 15:01:06.000000000 -0500
> @@ -549,7 +549,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (!can_do_mlock())
>  		goto out;
> 
> -	lru_add_drain_all();	/* flush pagevec */
> +	if (flags & MCL_CURRENT)
> +		lru_add_drain_all();	/* flush pagevec */
> 
>  	down_write(&current->mm->mmap_sem);

Looks good to me. I guess I introduced this fault. sorry about that.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
