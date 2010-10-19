Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 43ED86B00B5
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 00:49:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J4nEcx032103
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 13:49:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B560F45DE4E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 738A245DE4D
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5227D1DB803E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 004EAE18004
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 03/35] mm: implement per-zone shrinker
In-Reply-To: <20101019034655.756353382@kernel.dk>
References: <20101019034216.319085068@kernel.dk> <20101019034655.756353382@kernel.dk>
Message-Id: <20101019134345.A1E9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 13:49:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: npiggin@kernel.dk
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2010-10-19 14:19:40.000000000 +1100
> +++ linux-2.6/include/linux/mm.h	2010-10-19 14:36:48.000000000 +1100
> @@ -997,6 +997,10 @@
>  /*
>   * A callback you can register to apply pressure to ageable caches.
>   *
> + * 'shrink_zone' is the new shrinker API. It is to be used in preference
> + * to 'shrink'. One must point to a shrinker function, the other must
> + * be NULL. See 'shrink_slab' for details about the shrink_zone API.
> + *
>   * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
>   * look through the least-recently-used 'nr_to_scan' entries and
>   * attempt to free them up.  It should return the number of objects
> @@ -1013,13 +1017,53 @@
>  	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
>  	int seeks;	/* seeks to recreate an obj */
>  
> +	/*
> +	 * shrink_zone - slab shrinker callback for reclaimable objects
> +	 * @shrink: this struct shrinker
> +	 * @zone: zone to scan
> +	 * @scanned: pagecache lru pages scanned in zone
> +	 * @total: total pagecache lru pages in zone
> +	 * @global: global pagecache lru pages (for zone-unaware shrinkers)
> +	 * @flags: shrinker flags
> +	 * @gfp_mask: gfp context we are operating within
> +	 *
> +	 * The shrinkers are responsible for calculating the appropriate
> +	 * pressure to apply, batching up scanning (and cond_resched,
> +	 * cond_resched_lock etc), and updating events counters including
> +	 * count_vm_event(SLABS_SCANNED, nr).
> +	 *
> +	 * This approach gives flexibility to the shrinkers. They know best how
> +	 * to do batching, how much time between cond_resched is appropriate,
> +	 * what statistics to increment, etc.
> +	 */
> +	void (*shrink_zone)(struct shrinker *shrink,
> +		struct zone *zone, unsigned long scanned,
> +		unsigned long total, unsigned long global,
> +		unsigned long flags, gfp_t gfp_mask);

Now we decided to don't remove old (*shrink)() interface and zone unaware
slab users continue to use it. so why do we need global argument?
If only zone aware shrinker user (*shrink_zone)(), we can remove it.

Personally I think we should remove it because a removing makes a clear
message that all shrinker need to implement zone awareness eventually.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
