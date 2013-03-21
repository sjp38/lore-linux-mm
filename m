Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 907166B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 06:12:15 -0400 (EDT)
Date: Thu, 21 Mar 2013 10:12:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/10] mm: vmscan: Do not allow kswapd to scan at maximum
 priority
Message-ID: <20130321101210.GF1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-6-git-send-email-mgorman@suse.de>
 <514A604E.40303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <514A604E.40303@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 20, 2013 at 09:20:14PM -0400, Rik van Riel wrote:
> On 03/17/2013 09:04 AM, Mel Gorman wrote:
> >Page reclaim at priority 0 will scan the entire LRU as priority 0 is
> >considered to be a near OOM condition. Kswapd can reach priority 0 quite
> >easily if it is encountering a large number of pages it cannot reclaim
> >such as pages under writeback. When this happens, kswapd reclaims very
> >aggressively even though there may be no real risk of allocation failure
> >or OOM.
> >
> >This patch prevents kswapd reaching priority 0 and trying to reclaim
> >the world. Direct reclaimers will still reach priority 0 in the event
> >of an OOM situation.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> >---
> >  mm/vmscan.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 7513bd1..af3bb6f 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -2891,7 +2891,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  		 */
> >  		if (raise_priority || !this_reclaimed)
> >  			sc.priority--;
> >-	} while (sc.priority >= 0 &&
> >+	} while (sc.priority >= 1 &&
> >  		 !pgdat_balanced(pgdat, order, *classzone_idx));
> >
> >  out:
> >
> 
> If priority 0 is way way way way way too aggressive, what makes
> priority 1 safe?
> 

The fact that priority 1 selects a sensible number of pages to reclaim and
obeys swappiness makes it a lot safer. Priority 0 does this in get_scan_count

        /*
         * Do not apply any pressure balancing cleverness when the
         * system is close to OOM, scan both anon and file equally
         * (unless the swappiness setting disagrees with swapping).
         */
        if (!sc->priority && vmscan_swappiness(sc)) {
                scan_balance = SCAN_EQUAL;
                goto out;
        }

.....

                size = get_lru_size(lruvec, lru);
                scan = size >> sc->priority;

                if (!scan && force_scan)
                        scan = min(size, SWAP_CLUSTER_MAX);

                switch (scan_balance) {
                case SCAN_EQUAL:
                        /* Scan lists relative to size */
                        break;

.....
		}
		nr[lru] = scan;

That is saying -- at priority 0, scan everything in all LRUs. When put in
combination with patch 2 it effectively means reclaim everything in all LRUs.
It reclaims every file page it can and swaps as much as possible resulting
in major slowdowns.

> This makes me wonder, are the priorities useful at all to kswapd?
> 

They are not as useful as I'd like. Just a streaming writer will be
enough to ensure that the lower priorities will never reclaim enough
pages to move the zone from the min to high watermark making the low
priorities almost completely useless.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
