Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 00D456B006E
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 11:18:14 -0500 (EST)
Date: Thu, 13 Dec 2012 17:18:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/8] mm: vmscan: clean up get_scan_count()
Message-ID: <20121213161812.GI21644@dhcp22.suse.cz>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 12-12-12 16:43:38, Johannes Weiner wrote:
> Reclaim pressure balance between anon and file pages is calculated
> through a tuple of numerators and a shared denominator.
> 
> Exceptional cases that want to force-scan anon or file pages configure
> the numerators and denominator such that one list is preferred, which
> is not necessarily the most obvious way:
> 
>     fraction[0] = 1;
>     fraction[1] = 0;
>     denominator = 1;
>     goto out;
> 
> Make this easier by making the force-scan cases explicit and use the
> fractionals only in case they are calculated from reclaim history.
> 
> And bring the variable declarations/definitions in order.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I like this.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

[...]
> @@ -1638,14 +1645,15 @@ static int vmscan_swappiness(struct scan_control *sc)
>  static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  			   unsigned long *nr)
>  {
> -	unsigned long anon, file, free;
> +	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	u64 fraction[2], uninitialized_var(denominator);
> +	struct zone *zone = lruvec_zone(lruvec);
>  	unsigned long anon_prio, file_prio;
> +	enum scan_balance scan_balance;
> +	unsigned long anon, file, free;
> +	bool force_scan = false;
>  	unsigned long ap, fp;
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> -	u64 fraction[2], denominator;
>  	enum lru_list lru;
> -	bool force_scan = false;
> -	struct zone *zone = lruvec_zone(lruvec);

You really do love trees, don't you :P

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
