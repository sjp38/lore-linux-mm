Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 2EDD76B005D
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 06:10:43 -0500 (EST)
Date: Fri, 21 Dec 2012 09:10:13 -0200
From: Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH v2 2/2] vmscan: take at least one pass with shrinkers
Message-ID: <20121221111013.GB8852@andromeda.usersys.redhat.com>
References: <1356086810-6950-1-git-send-email-glommer@parallels.com>
 <1356086810-6950-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356086810-6950-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 21, 2012 at 02:46:50PM +0400, Glauber Costa wrote:
> In very low free kernel memory situations, it may be the case that we
> have less objects to free than our initial batch size. If this is the
> case, it is better to shrink those, and open space for the new workload
> then to keep them and fail the new allocations.
> 
> More specifically, this happens because we encode this in a loop with
> the condition: "while (total_scan >= batch_size)". So if we are in such
> a case, we'll not even enter the loop.
> 
> This patch modifies turns it into a do () while {} loop, that will
> guarantee that we scan it at least once, while keeping the behaviour
> exactly the same for the cases in which total_scan > batch_size.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Dave Chinner <david@fromorbit.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  mm/vmscan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7f30961..fcd1aa0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -280,7 +280,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  					nr_pages_scanned, lru_pages,
>  					max_pass, delta, total_scan);
>  
> -		while (total_scan >= batch_size) {
> +		do {
>  			int nr_before;
>  
>  			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
> @@ -294,7 +294,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  			total_scan -= batch_size;
>  
>  			cond_resched();
> -		}
> +		} while (total_scan >= batch_size);
>  
>  		/*
>  		 * move the unused scan count back into the shrinker in a
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks Good,
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
-- 
Carlos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
