Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E0C2D6B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 22:45:28 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p982jPbV021745
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:45:25 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by hpaq13.eem.corp.google.com with ESMTP id p982j4HH010666
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:45:23 -0700
Received: by pzd13 with SMTP id 13so14885533pzd.7
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 19:45:18 -0700 (PDT)
Date: Fri, 7 Oct 2011 19:45:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
In-Reply-To: <alpine.DEB.2.00.1110071529110.15540@router.home>
Message-ID: <alpine.DEB.2.00.1110071943060.13992@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071529110.15540@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Fri, 7 Oct 2011, Christoph Lameter wrote:

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

I understand the intention of lru_add_drain_all() to try to avoid a 
later failure when moving to the unevictable list and why flushing it's 
necessary for MCL_FUTURE, but I think this should be written

	if (!(flags & MCL_FUTURE))
		...

since flags may be extended sometime in the future.  After that's fixed, 
feel free to add my

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
