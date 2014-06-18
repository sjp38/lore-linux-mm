Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CF1EB6B0037
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 05:01:11 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so7198314wiv.14
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:01:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si15835224wiw.11.2014.06.18.02.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jun 2014 02:01:09 -0700 (PDT)
Message-ID: <53A15544.2010505@redhat.com>
Date: Wed, 18 Jun 2014 11:00:52 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
In-Reply-To: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>, akpm@linux-foundation.org
Cc: minchan@kernel.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/17/2014 06:55 AM, Chen Yucong wrote:
> Via https://lkml.org/lkml/2013/4/10/897, we can know that the relative design
> idea is to keep
> 
>     scan_target[anon] : scan_target[file]
>         == really_scanned_num[anon] : really_scanned_num[file]
> 
> But we can find the following snippet in shrink_lruvec():
> 
>     if (nr_file > nr_anon) {
>         ...
>     } else {
>         ...
>     }
> 
> However, the above code fragment broke the design idea. We can assume:
> 
>       nr[LRU_ACTIVE_FILE] = 30
>       nr[LRU_INACTIVE_FILE] = 30
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 40
> 
> When the value of (nr_reclaimed < nr_to_reclaim) become false, there are
> the following results:
> 
>       nr[LRU_ACTIVE_FILE] = 15
>       nr[LRU_INACTIVE_FILE] = 15
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 25
>       nr_file = 30
>       nr_anon = 25
>       file_percent = 30 / 60 = 0.5
>       anon_percent = 25 / 40 = 0.65
> 
> According to the above design idea, we should scan some pages from ANON,
> but in fact we execute the an error code path due to "if (nr_file > nr_anon)".
> In this way, nr[lru] is likely to be a negative number. Luckily,
> "nr[lru] -= min(nr[lru], nr_scanned)" can help us to filter this situation,
> but it has rebelled against our design idea.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  mm/vmscan.c |   39 ++++++++++++++++++---------------------
>  1 file changed, 18 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8ffe4e..2c35e34 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2057,8 +2057,7 @@ out:
>  static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
> -	unsigned long targets[NR_LRU_LISTS];
> -	unsigned long nr_to_scan;
> +	unsigned long file_target, anon_target;
>  	enum lru_list lru;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> @@ -2067,8 +2066,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  
>  	get_scan_count(lruvec, sc, nr);
>  
> -	/* Record the original scan target for proportional adjustments later */
> -	memcpy(targets, nr, sizeof(nr));
> +	file_target = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
> +	anon_target = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];

Current code adds 1 to these value to avoid divide by zero error.

>  
>  	/*
>  	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
> @@ -2087,8 +2086,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	blk_start_plug(&plug);
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
> -		unsigned long nr_anon, nr_file, percentage;
> -		unsigned long nr_scanned;
> +		unsigned long nr_anon, nr_file, file_percent, anon_percent;
> +		unsigned long nr_to_scan, nr_scanned, percentage;
>  
>  		for_each_evictable_lru(lru) {
>  			if (nr[lru]) {
> @@ -2122,16 +2121,19 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  		if (!nr_file || !nr_anon)
>  			break;
>  
> -		if (nr_file > nr_anon) {
> -			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
> -						targets[LRU_ACTIVE_ANON] + 1;
> +		file_percent = nr_file * 100 / file_target;
> +		anon_percent = nr_anon * 100 / anon_target;

Here it could happen.

Jerome

> +
> +		if (file_percent > anon_percent) {
>  			lru = LRU_BASE;
> -			percentage = nr_anon * 100 / scan_target;
> +			nr_scanned = file_target - nr_file;
> +			nr_to_scan = file_target * (100 - anon_percent) / 100;
> +			percentage = nr[LRU_FILE] * 100 / nr_file;
>  		} else {
> -			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
> -						targets[LRU_ACTIVE_FILE] + 1;
>  			lru = LRU_FILE;
> -			percentage = nr_file * 100 / scan_target;
> +			nr_scanned = anon_target - nr_anon;
> +			nr_to_scan = anon_target * (100 - file_percent) / 100;
> +			percentage = nr[LRU_BASE] * 100 / nr_anon;
>  		}
>  
>  		/* Stop scanning the smaller of the LRU */
> @@ -2143,14 +2145,9 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
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
> +		nr_to_scan -= min(nr_to_scan, nr_scanned);
> +		nr[lru] = nr_to_scan * percentage / 100;
> +		nr[lru + LRU_ACTIVE] = nr_to_scan - nr[lru];
>  
>  		scan_adjusted = true;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
