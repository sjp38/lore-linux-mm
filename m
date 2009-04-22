Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE156B00FE
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:24:11 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n3MKOTU0026799
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:24:30 -0700
Received: from rv-out-0506.google.com (rvbf9.prod.google.com [10.140.82.9])
	by wpaz33.hot.corp.google.com with ESMTP id n3MKORKl010801
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:24:28 -0700
Received: by rv-out-0506.google.com with SMTP id f9so120628rvb.21
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:24:27 -0700 (PDT)
Date: Wed, 22 Apr 2009 13:24:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 16/22] Do not setup zonelist cache when there is only
 one node
In-Reply-To: <1240408407-21848-17-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904221319120.14558@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-17-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009, Mel Gorman wrote:

> There is a zonelist cache which is used to track zones that are not in
> the allowed cpuset or found to be recently full. This is to reduce cache
> footprint on large machines. On smaller machines, it just incurs cost
> for no gain. This patch only uses the zonelist cache when there are NUMA
> nodes.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> ---
>  mm/page_alloc.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7f45de1..e59bb80 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1467,8 +1467,11 @@ this_zone_full:
>  		if (NUMA_BUILD)
>  			zlc_mark_zone_full(zonelist, z);

If zonelist caching is never used for UMA machines, why should they ever 
call zlc_mark_zone_full()?  It will always dereference 
zonelist->zlcache_ptr and immediately return without doing anything.

Wouldn't it better to just add

	if (num_online_nodes() == 1)
		continue;

right before this call to zlc_mark_zone_full()?  This should compile out 
the remainder of the loop for !CONFIG_NUMA kernels anyway.

>  try_next_zone:
> -		if (NUMA_BUILD && !did_zlc_setup) {
> -			/* we do zlc_setup after the first zone is tried */
> +		if (NUMA_BUILD && !did_zlc_setup && num_online_nodes() > 1) {
> +			/*
> +			 * we do zlc_setup after the first zone is tried but only
> +			 * if there are multiple nodes make it worthwhile
> +			 */
>  			allowednodes = zlc_setup(zonelist, alloc_flags);
>  			zlc_active = 1;
>  			did_zlc_setup = 1;
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
