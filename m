Date: Tue, 24 Jun 2008 09:28:24 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
Message-ID: <20080624092824.4f0440ca@bree.surriel.com>
In-Reply-To: <20080624171816.D835.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080624171816.D835.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jun 2008 17:31:54 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> if zone->recent_scanned parameter become inbalanceing anon and file,
> OOM killer can happened although swappable page exist.
> 
> So, if priority==0, We should try to reclaim all page for prevent OOM.

You are absolutely right.  Good catch.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

> ---
>  mm/vmscan.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1464,8 +1464,10 @@ static unsigned long shrink_zone(int pri
>  			 * kernel will slowly sift through each list.
>  			 */
>  			scan = zone_page_state(zone, NR_LRU_BASE + l);
> -			scan >>= priority;
> -			scan = (scan * percent[file]) / 100;
> +			if (priority) {
> +				scan >>= priority;
> +				scan = (scan * percent[file]) / 100;
> +			}
>  			zone->lru[l].nr_scan += scan + 1;
>  			nr[l] = zone->lru[l].nr_scan;
>  			if (nr[l] >= sc->swap_cluster_max)
> 


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
