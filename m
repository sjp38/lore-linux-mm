Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9A16B00C0
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 19:24:59 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so8965pac.11
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:24:59 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qz5si3642537pbb.179.2014.06.09.16.24.57
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 16:24:58 -0700 (PDT)
Date: Tue, 10 Jun 2014 08:24:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
Message-ID: <20140609232459.GA8171@bbox>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Jun 09, 2014 at 09:27:16PM +0800, Chen Yucong wrote:
> Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> original scan targets introduces extra 40 bytes on the stack. This patch
> is able to avoid this situation and the call to memcpy(). At the same time,
> it does not change the relative design idea.
> 
> ratio = original_nr_file / original_nr_anon;
> 
> If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
>  x = nr_file - ratio * nr_anon;
> 
> if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
>  x = nr_anon - nr_file / ratio;

Nice cleanup!

Below one nitpick.

> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  mm/vmscan.c |   28 +++++++++-------------------
>  1 file changed, 9 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8ffe4e..daaf89c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2057,8 +2057,7 @@ out:
>  static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
> -	unsigned long targets[NR_LRU_LISTS];
> -	unsigned long nr_to_scan;
> +	unsigned long nr_to_scan, ratio;
>  	enum lru_list lru;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> @@ -2067,8 +2066,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  
>  	get_scan_count(lruvec, sc, nr);
>  
> -	/* Record the original scan target for proportional adjustments later */
> -	memcpy(targets, nr, sizeof(nr));
> +	ratio = (nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1) /
> +			(nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1);
>  
>  	/*
>  	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
> @@ -2088,7 +2087,6 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
>  		unsigned long nr_anon, nr_file, percentage;
> -		unsigned long nr_scanned;
>  
>  		for_each_evictable_lru(lru) {
>  			if (nr[lru]) {
> @@ -2123,15 +2121,13 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  			break;
>  
>  		if (nr_file > nr_anon) {
> -			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
> -						targets[LRU_ACTIVE_ANON] + 1;
> +			nr_to_scan = nr_file - ratio * nr_anon;
> +			percentage = nr[LRU_FILE] * 100 / nr_file;
>  			lru = LRU_BASE;
> -			percentage = nr_anon * 100 / scan_target;
>  		} else {
> -			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
> -						targets[LRU_ACTIVE_FILE] + 1;
> +			nr_to_scan = nr_anon - nr_file / ratio;
> +			percentage = nr[LRU_BASE] * 100 / nr_anon;

If both nr_file and nr_anon are zero, then the nr_anon could be zero
if HugePage are reclaimed so that it could pass the below check

        if (nr_reclaimed < nr_to_reclaim || scan_adjusted)


>  			lru = LRU_FILE;
> -			percentage = nr_file * 100 / scan_target;
>  		}
>  
>  		/* Stop scanning the smaller of the LRU */
> @@ -2143,14 +2139,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  		 * scan target and the percentage scanning already complete
>  		 */
>  		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
> -		nr_scanned = targets[lru] - nr[lru];
> -		nr[lru] = targets[lru] * (100 - percentage) / 100;
> -		nr[lru] -= min(nr[lru], nr_scanned);
> -
> -		lru += LRU_ACTIVE;
> -		nr_scanned = targets[lru] - nr[lru];
> -		nr[lru] = targets[lru] * (100 - percentage) / 100;
> -		nr[lru] -= min(nr[lru], nr_scanned);
> +		nr[lru] = nr_to_scan * percentage / 100;
> +		nr[lru + LRU_ACTIVE] = nr_to_scan - nr[lru];
>  
>  		scan_adjusted = true;
>  	}
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
