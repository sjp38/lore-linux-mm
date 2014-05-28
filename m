Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 27E9E6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 23:54:19 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so10294156pad.30
        for <linux-mm@kvack.org>; Tue, 27 May 2014 20:54:18 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id cc3si21843026pad.47.2014.05.27.20.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 20:54:18 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id kx10so420174pab.14
        for <linux-mm@kvack.org>; Tue, 27 May 2014 20:54:17 -0700 (PDT)
Date: Tue, 27 May 2014 20:53:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: Avoid scanning invalidated region for cheap seek
In-Reply-To: <1401069659-29589-1-git-send-email-slaoub@gmail.com>
Message-ID: <alpine.LSU.2.11.1405272037080.1126@eggly.anvils>
References: <1401069659-29589-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: Shaohua Li <shli@kernel.org>, akpm@linux-foundation.org, ddstreet@ieee.org, mgorman@suse.de, k.kozlowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 May 2014, Chen Yucong wrote:

> For cheap seek, when we scan the region between si->lowset_bit
> and scan_base, if san_base is greater than si->highest_bit, the
> scan operation between si->highest_bit and scan_base is not
> unnecessary.
> 
> This patch can be used to avoid scanning invalidated region for
> cheap seek.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

I was going to suggest that you are adding a little code to a common
path, in order to optimize a very unlikely case: which does not seem
worthwhile to me.

But digging a little deeper, I think you have hit upon something more
interesting (though still in no need of your patch): it looks to me
like that is not even a common path, but dead code.

Shaohua, am I missing something, or does all SWP_SOLIDSTATE "seek is
cheap" now go your si->cluster_info scan_swap_map_try_ssd_cluster()
route?  So that the "last_in_cluster < scan_base" loop in the body
of scan_swap_map() is just redundant, and should have been deleted?

Hugh

> ---
>  mm/swapfile.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index beeeef8..7f0f27e 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -489,6 +489,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
>  {
>  	unsigned long offset;
>  	unsigned long scan_base;
> +	unsigned long upper_bound;
>  	unsigned long last_in_cluster = 0;
>  	int latency_ration = LATENCY_LIMIT;
>  
> @@ -551,9 +552,11 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
>  
>  		offset = si->lowest_bit;
>  		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
> +		upper_bound = (scan_base <= si->highest_bit) ?
> +				scan_base : (si->highest_bit + 1);
>  
>  		/* Locate the first empty (unaligned) cluster */
> -		for (; last_in_cluster < scan_base; offset++) {
> +		for (; last_in_cluster < upper_bound; offset++) {
>  			if (si->swap_map[offset])
>  				last_in_cluster = offset + SWAPFILE_CLUSTER;
>  			else if (offset == last_in_cluster) {
> -- 
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
