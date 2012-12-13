Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0EC4C6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 00:34:42 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1168443pbc.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 21:34:42 -0800 (PST)
Message-ID: <1355376877.1567.2.camel@kernel.cn.ibm.com>
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have plenty
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 12 Dec 2012 23:34:37 -0600
In-Reply-To: <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
	 <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2012-12-12 at 16:43 -0500, Johannes Weiner wrote:
> dc0422c "mm: vmscan: only evict file pages when we have plenty" makes

Can't find dc0422c.

> a point of not going for anonymous memory while there is still enough
> inactive cache around.
> 
> The check was added only for global reclaim, but it is just as useful
> for memory cgroup reclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 157bb11..3874dcb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1671,6 +1671,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  		denominator = 1;
>  		goto out;
>  	}
> +	/*
> +	 * There is enough inactive page cache, do not reclaim
> +	 * anything from the anonymous working set right now.
> +	 */
> +	if (!inactive_file_is_low(lruvec)) {
> +		fraction[0] = 0;
> +		fraction[1] = 1;
> +		denominator = 1;
> +		goto out;
> +	}
>  
>  	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>  		get_lru_size(lruvec, LRU_INACTIVE_ANON);
> @@ -1688,15 +1698,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  			fraction[1] = 0;
>  			denominator = 1;
>  			goto out;
> -		} else if (!inactive_file_is_low_global(zone)) {
> -			/*
> -			 * There is enough inactive page cache, do not
> -			 * reclaim anything from the working set right now.
> -			 */
> -			fraction[0] = 0;
> -			fraction[1] = 1;
> -			denominator = 1;
> -			goto out;
>  		}
>  	}
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
