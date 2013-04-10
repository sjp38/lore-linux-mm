Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 915546B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:17:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 24F133EE0B6
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:17:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEFB545DEBE
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:17:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1A2945DEB5
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:17:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C36EE1DB803E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:17:15 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70C6C1DB8038
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:17:15 +0900 (JST)
Message-ID: <516511DF.5020805@jp.fujitsu.com>
Date: Wed, 10 Apr 2013 16:16:47 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning requirements
 for kswapd
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <1365505625-9460-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(2013/04/09 20:06), Mel Gorman wrote:
> Simplistically, the anon and file LRU lists are scanned proportionally
> depending on the value of vm.swappiness although there are other factors
> taken into account by get_scan_count().  The patch "mm: vmscan: Limit
> the number of pages kswapd reclaims" limits the number of pages kswapd
> reclaims but it breaks this proportional scanning and may evenly shrink
> anon/file LRUs regardless of vm.swappiness.
> 
> This patch preserves the proportional scanning and reclaim. It does mean
> that kswapd will reclaim more than requested but the number of pages will
> be related to the high watermark.
> 
> [mhocko@suse.cz: Correct proportional reclaim for memcg and simplify]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>   mm/vmscan.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++--------
>   1 file changed, 46 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4835a7a..0742c45 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1825,13 +1825,21 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>   	enum lru_list lru;
>   	unsigned long nr_reclaimed = 0;
>   	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> +	unsigned long nr_anon_scantarget, nr_file_scantarget;
>   	struct blk_plug plug;
> +	bool scan_adjusted = false;
>   
>   	get_scan_count(lruvec, sc, nr);
>   
> +	/* Record the original scan target for proportional adjustments later */
> +	nr_file_scantarget = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1;
> +	nr_anon_scantarget = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1;
> +

I'm sorry I couldn't understand the calc...

Assume here
        nr_file_scantarget = 100
        nr_anon_file_target = 100.


>   	blk_start_plug(&plug);
>   	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>   					nr[LRU_INACTIVE_FILE]) {
> +		unsigned long nr_anon, nr_file, percentage;
> +
>   		for_each_evictable_lru(lru) {
>   			if (nr[lru]) {
>   				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
> @@ -1841,17 +1849,47 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>   							    lruvec, sc);
>   			}
>   		}
> +
> +		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> +			continue;
> +
>   		/*
> -		 * On large memory systems, scan >> priority can become
> -		 * really large. This is fine for the starting priority;
> -		 * we want to put equal scanning pressure on each zone.
> -		 * However, if the VM has a harder time of freeing pages,
> -		 * with multiple processes reclaiming pages, the total
> -		 * freeing target can get unreasonably large.
> +		 * For global direct reclaim, reclaim only the number of pages
> +		 * requested. Less care is taken to scan proportionally as it
> +		 * is more important to minimise direct reclaim stall latency
> +		 * than it is to properly age the LRU lists.
>   		 */
> -		if (nr_reclaimed >= nr_to_reclaim &&
> -		    sc->priority < DEF_PRIORITY)
> +		if (global_reclaim(sc) && !current_is_kswapd())
>   			break;
> +
> +		/*
> +		 * For kswapd and memcg, reclaim at least the number of pages
> +		 * requested. Ensure that the anon and file LRUs shrink
> +		 * proportionally what was requested by get_scan_count(). We
> +		 * stop reclaiming one LRU and reduce the amount scanning
> +		 * proportional to the original scan target.
> +		 */
> +		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
> +		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
> +
Then, nr_file = 80, nr_anon=70.


> +		if (nr_file > nr_anon) {
> +			lru = LRU_BASE;
> +			percentage = nr_anon * 100 / nr_anon_scantarget;
> +		} else {
> +			lru = LRU_FILE;
> +			percentage = nr_file * 100 / nr_file_scantarget;
> +		}

the percentage will be 70.

> +
> +		/* Stop scanning the smaller of the LRU */
> +		nr[lru] = 0;
> +		nr[lru + LRU_ACTIVE] = 0;
> +
this will stop anon scan.

> +		/* Reduce scanning of the other LRU proportionally */
> +		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
> +		nr[lru] = nr[lru] * percentage / 100;;
> +		nr[lru + LRU_ACTIVE] = nr[lru + LRU_ACTIVE] * percentage / 100;
> +

finally, in the next iteration,

              nr[file] = 80 * 0.7 = 56.
             
After loop, anon-scan is 30 pages , file-scan is 76(20+56) pages..

I think the calc here should be

   nr[lru] = nr_lru_scantarget * percentage / 100 - nr[lru]

   Here, 80-70=10 more pages to scan..should be proportional.

Am I misunderstanding ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
