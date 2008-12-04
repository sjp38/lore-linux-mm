Received: by yw-out-1718.google.com with SMTP id 5so1644247ywm.26
        for <linux-mm@kvack.org>; Wed, 03 Dec 2008 20:20:22 -0800 (PST)
Message-ID: <28c262360812032020k6259b71bx5609626db622a884@mail.gmail.com>
Date: Thu, 4 Dec 2008 13:20:21 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: improve reclaim throuput to bail out patch take2
In-Reply-To: <20081204102729.1D5C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <49368DAF.9060206@redhat.com>
	 <2f11576a0812030712t1131c9d2x4dd0fd32eafa66ae@mail.gmail.com>
	 <20081204102729.1D5C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Hi, Kosaki-san.

It's a great improvement with only one variable than I expected. :)
What is your test environment ? (CPU, L1, L2 cache size and so )
Just out of curiosity.


On Thu, Dec 4, 2008 at 10:28 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> The vmscan bail out patch move nr_reclaimed variable to struct scan_control.
> Unfortunately, indirect access can easily happen cache miss.
>
> if heavy memory pressure happend, that's ok.
> cache miss already plenty. it is not observable.
>
> but, if memory pressure is lite, performance degression is obserbable.
>
>
> I compared following three pattern (it was mesured 10 times each)
>
> hackbench 125 process 3000
> hackbench 130 process 3000
> hackbench 135 process 3000
>
>            2.6.28-rc6                       bail-out
>
>        125     130     135             125     130     135
>      ==============================================================
>        71.866  75.86   81.274          93.414  73.254  193.382
>        74.145  78.295  77.27           74.897  75.021  80.17
>        70.305  77.643  75.855          70.134  77.571  79.896
>        74.288  73.986  75.955          77.222  78.48   80.619
>        72.029  79.947  78.312          75.128  82.172  79.708
>        71.499  77.615  77.042          74.177  76.532  77.306
>        76.188  74.471  83.562          73.839  72.43   79.833
>        73.236  75.606  78.743          76.001  76.557  82.726
>        69.427  77.271  76.691          76.236  79.371  103.189
>        72.473  76.978  80.643          69.128  78.932  75.736
>
> avg     72.545  76.767  78.534          76.017  77.03   93.256
> std     1.89    1.71    2.41            6.29    2.79    34.16
> min     69.427  73.986  75.855          69.128  72.43   75.736
> max     76.188  79.947  83.562          93.414  82.172  193.382
>
>
> about 4-5% degression.
>
> Then, this patch introduce temporal local variable.
>
> result:
>
>            2.6.28-rc6                       this patch
>
> num     125     130     135             125     130     135
>      ==============================================================
>        71.866  75.86   81.274          67.302  68.269  77.161
>        74.145  78.295  77.27           72.616  72.712  79.06
>        70.305  77.643  75.855          72.475  75.712  77.735
>        74.288  73.986  75.955          69.229  73.062  78.814
>        72.029  79.947  78.312          71.551  74.392  78.564
>        71.499  77.615  77.042          69.227  74.31   78.837
>        76.188  74.471  83.562          70.759  75.256  76.6
>        73.236  75.606  78.743          69.966  76.001  78.464
>        69.427  77.271  76.691          69.068  75.218  80.321
>        72.473  76.978  80.643          72.057  77.151  79.068
>
> avg     72.545  76.767  78.534          70.425  74.2083 78.462
> std     1.89    1.71    2.41            1.66    2.34    1.00
> min     69.427  73.986  75.855          67.302  68.269  76.6
> max     76.188  79.947  83.562          72.616  77.151  80.321
>
>
> OK. the degression is disappeared.
>
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
>
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1418,6 +1418,8 @@ static void shrink_zone(int priority, st
>        unsigned long nr_to_scan;
>        unsigned long percent[2];       /* anon @ 0; file @ 1 */
>        enum lru_list l;
> +       unsigned long nr_reclaimed = sc->nr_reclaimed;
> +       unsigned long swap_cluster_max = sc->swap_cluster_max;
>
>        get_scan_ratio(zone, sc, percent);
>
> @@ -1433,7 +1435,7 @@ static void shrink_zone(int priority, st
>                        }
>                        zone->lru[l].nr_scan += scan;
>                        nr[l] = zone->lru[l].nr_scan;
> -                       if (nr[l] >= sc->swap_cluster_max)
> +                       if (nr[l] >= swap_cluster_max)
>                                zone->lru[l].nr_scan = 0;
>                        else
>                                nr[l] = 0;
> @@ -1452,12 +1454,11 @@ static void shrink_zone(int priority, st
>                                        nr[LRU_INACTIVE_FILE]) {
>                for_each_evictable_lru(l) {
>                        if (nr[l]) {
> -                               nr_to_scan = min(nr[l],
> -                                       (unsigned long)sc->swap_cluster_max);
> +                               nr_to_scan = min(nr[l], swap_cluster_max);
>                                nr[l] -= nr_to_scan;
>
> -                               sc->nr_reclaimed += shrink_list(l, nr_to_scan,
> -                                                       zone, sc, priority);
> +                               nr_reclaimed += shrink_list(l, nr_to_scan,
> +                                                           zone, sc, priority);
>                        }
>                }
>                /*
> @@ -1468,11 +1469,13 @@ static void shrink_zone(int priority, st
>                 * with multiple processes reclaiming pages, the total
>                 * freeing target can get unreasonably large.
>                 */
> -               if (sc->nr_reclaimed > sc->swap_cluster_max &&
> +               if (nr_reclaimed > swap_cluster_max &&
>                    priority < DEF_PRIORITY && !current_is_kswapd())
>                        break;
>        }
>
> +       sc->nr_reclaimed = nr_reclaimed;
> +
>        /*
>         * Even if we did not try to evict anon pages at all, we want to
>         * rebalance the anon lru active/inactive ratio.
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
