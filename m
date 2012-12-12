Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B4BF76B0088
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:55:17 -0500 (EST)
Message-ID: <50C8FCE0.1060408@redhat.com>
Date: Wed, 12 Dec 2012 16:53:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have plenty
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> dc0422c "mm: vmscan: only evict file pages when we have plenty" makes
> a point of not going for anonymous memory while there is still enough
> inactive cache around.
>
> The check was added only for global reclaim, but it is just as useful
> for memory cgroup reclaim.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   mm/vmscan.c | 19 ++++++++++---------
>   1 file changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 157bb11..3874dcb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1671,6 +1671,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>   		denominator = 1;
>   		goto out;
>   	}
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
>   	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>   		get_lru_size(lruvec, LRU_INACTIVE_ANON);
> @@ -1688,15 +1698,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>   			fraction[1] = 0;
>   			denominator = 1;
>   			goto out;
> -		} else if (!inactive_file_is_low_global(zone)) {
> -			/*
> -			 * There is enough inactive page cache, do not
> -			 * reclaim anything from the working set right now.
> -			 */
> -			fraction[0] = 0;
> -			fraction[1] = 1;
> -			denominator = 1;
> -			goto out;
>   		}
>   	}
>
>

I believe the if() block should be moved to AFTER
the check where we make sure we actually have enough
file pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
