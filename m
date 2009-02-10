Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1547B6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:43:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ABhZ7A007975
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 20:43:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C663745DD86
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:43:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59CE245DD7B
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:43:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7502B1DB8038
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:43:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 144FCE08003
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:43:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
In-Reply-To: <28c262360902100247x1d537dc2kfef3c4c0f769a259@mail.gmail.com>
References: <20090209222416.GA9758@cmpxchg.org> <28c262360902100247x1d537dc2kfef3c4c0f769a259@mail.gmail.com>
Message-Id: <20090210204210.6FEF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 20:43:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9a27c44..18406ee 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1699,6 +1699,7 @@ unsigned long try_to_free_pages(struct zonelist
> *zonelist, int order,
>                 .order = order,
>                 .mem_cgroup = NULL,
>                 .isolate_pages = isolate_pages_global,
> +               .nr_reclaimed = 0,
>         };
> 
>         return do_try_to_free_pages(zonelist, &sc);
> @@ -1719,6 +1720,7 @@ unsigned long
> try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>                 .order = 0,
>                 .mem_cgroup = mem_cont,
>                 .isolate_pages = mem_cgroup_isolate_pages,
> +               .nr_reclaimed = 0;
>         };
>         struct zonelist *zonelist;

I think this code is better.

and, I think we also need to 


static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
{
        /* Minimum pages needed in order to stay on node */
        const unsigned long nr_pages = 1 << order;
        struct task_struct *p = current;
        struct reclaim_state reclaim_state;
        int priority;
        struct scan_control sc = {
                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
                .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
                .swap_cluster_max = max_t(unsigned long, nr_pages,
                                        SWAP_CLUSTER_MAX),
                .gfp_mask = gfp_mask,
                .swappiness = vm_swappiness,
                .isolate_pages = isolate_pages_global,
+               .nr_reclaimed = 0;
        };




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
