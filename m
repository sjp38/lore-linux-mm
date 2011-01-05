Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D66BF6B008C
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 12:24:36 -0500 (EST)
Date: Wed, 5 Jan 2011 17:24:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Fix handling of parse errors in sysctl
Message-ID: <20110105172412.GA29257@csn.ul.ie>
References: <1294247329-11682-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1294247329-11682-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, caiqian@redhat.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 05, 2011 at 10:08:49AM -0700, Eric B Munson wrote:
> This patch is a candidate for stable.
> 
> ==== CUT HERE ====
> 
> When parsing changes to the huge page pool sizes made from userspace
> via the sysctl interface, bogus input values are being covered up
> by nr_hugepages_store_common and nr_overcommit_hugepages_store
> returning 0 when strict_strtoul returns an error. 

Not just that, it can infinite loop so it's a fairly serious problem.

> This patch changes
> the return value for these functions to -EINVAL when strict_strtoul
> returns an error.
> 
> Reported-by: CAI Qian <caiqian@redhat.com>
> 
> Signed-off-by: Eric B Munson <emunson@mgebm.net>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/hugetlb.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8585524..5cb71a9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1440,7 +1440,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  
>  	err = strict_strtoul(buf, 10, &count);
>  	if (err)
> -		return 0;
> +		return -EINVAL;
>  
>  	h = kobj_to_hstate(kobj, &nid);
>  	if (nid == NUMA_NO_NODE) {
> @@ -1519,7 +1519,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
>  
>  	err = strict_strtoul(buf, 10, &input);
>  	if (err)
> -		return 0;
> +		return -EINVAL;
>  
>  	spin_lock(&hugetlb_lock);
>  	h->nr_overcommit_huge_pages = input;

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
