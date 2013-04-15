Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E75E06B0037
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 01:38:39 -0400 (EDT)
Received: by mail-gg0-f201.google.com with SMTP id q6so426489ggc.0
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 22:38:39 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 19/32] hugepage: convert huge zero page shrinker to new shrinker API
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<1365429659-22108-20-git-send-email-glommer@parallels.com>
Date: Sun, 14 Apr 2013 22:38:37 -0700
Message-ID: <xr93y5ck73qa.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>

On Mon, Apr 08 2013, Glauber Costa wrote:

> It consists of:
>
> * returning long instead of int
> * separating count from scan
> * returning the number of freed entities in scan
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Dave Chinner <dchinner@redhat.com>

Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
>  mm/huge_memory.c | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e2f7f5aa..8bf43d3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -212,24 +212,30 @@ static void put_huge_zero_page(void)
>  	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
>  }
>  
> -static int shrink_huge_zero_page(struct shrinker *shrink,
> -		struct shrink_control *sc)
> +
> +static long shrink_huge_zero_page_count(struct shrinker *shrink,
> +					struct shrink_control *sc)
>  {
> -	if (!sc->nr_to_scan)
> -		/* we can free zero page only if last reference remains */
> -		return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
> +	/* we can free zero page only if last reference remains */
> +	return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
> +}
>  
> +static long shrink_huge_zero_page_scan(struct shrinker *shrink,
> +				       struct shrink_control *sc)
> +{
>  	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
>  		unsigned long zero_pfn = xchg(&huge_zero_pfn, 0);
>  		BUG_ON(zero_pfn == 0);
>  		__free_page(__pfn_to_page(zero_pfn));
> +		return HPAGE_PMD_NR;
>  	}
>  
>  	return 0;
>  }
>  
>  static struct shrinker huge_zero_page_shrinker = {
> -	.shrink = shrink_huge_zero_page,
> +	.scan_objects = shrink_huge_zero_page_scan,
> +	.count_objects = shrink_huge_zero_page_count,
>  	.seeks = DEFAULT_SEEKS,
>  };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
