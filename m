Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB9108D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:15:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C68123EE0C0
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:15:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC08445DE76
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:15:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85A7745DE92
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:15:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77516E08003
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:15:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F7E1E08005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:15:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
In-Reply-To: <1303752134-4856-3-git-send-email-yinghan@google.com>
References: <1303752134-4856-1-git-send-email-yinghan@google.com> <1303752134-4856-3-git-send-email-yinghan@google.com>
Message-Id: <20110426101631.F34C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 10:15:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7a2f657..abc13ea 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1137,16 +1137,19 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
>  struct shrink_control {
>  	unsigned long nr_scanned;
>  	gfp_t gfp_mask;
> +
> +	/* How many slab objects shrinker() should reclaim */
> +	unsigned long nr_slab_to_reclaim;

Wrong name. The original shrinker API is
	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);

ie, shrinker get scanning target. not reclaiming target.
You should have think folloing diff hunk is strange. 

>  {
>  	struct xfs_mount *mp;
>  	struct xfs_perag *pag;
>  	xfs_agnumber_t	ag;
>  	int		reclaimable;
> +	int nr_to_scan = sc->nr_slab_to_reclaim;
> +	gfp_t gfp_mask = sc->gfp_mask;

And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim
poped up new question.
Why don't we pass more clever slab shrinker target? Why do we need pass
similar two argument?


>  /*
>   * A callback you can register to apply pressure to ageable caches.
>   *
> - * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> - * look through the least-recently-used 'nr_to_scan' entries and
> - * attempt to free them up.  It should return the number of objects
> - * which remain in the cache.  If it returns -1, it means it cannot do
> - * any scanning at this time (eg. there is a risk of deadlock).
> + * 'sc' is passed shrink_control which includes a count 'nr_slab_to_reclaim'
> + * and a 'gfpmask'.  It should look through the least-recently-us

                                                                  us?


> + * 'nr_slab_to_reclaim' entries and attempt to free them up.  It should return
> + * the number of objects which remain in the cache.  If it returns -1, it means
> + * it cannot do any scanning at this time (eg. there is a risk of deadlock).
>   *




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
