Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DFBB66B00B9
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 04:14:44 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n259Egl2023478
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Mar 2009 18:14:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59EDA45DD7F
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36DCD45DD7B
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E65C1DB803C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C65381DB8037
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:41 +0900 (JST)
Date: Thu, 5 Mar 2009 18:13:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090305181323.19dbebf9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
	<20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302063649.GJ11421@balbir.in.ibm.com>
	<20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302124210.GK11421@balbir.in.ibm.com>
	<c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
	<20090302174156.GM11421@balbir.in.ibm.com>
	<20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090303111244.GP11421@balbir.in.ibm.com>
	<20090305180410.a44035e0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


I wrote almost all concerns are addressed but following part is a concern.

On Thu, 5 Mar 2009 18:04:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> @@ -1758,6 +1778,7 @@ static unsigned long balance_pgdat(pg_da
>  {
>  	int all_zones_ok;
>  	int priority;
> +	int nid = pgdat->node_id;
>  	int i;
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> @@ -1785,6 +1806,8 @@ loop_again:
>  	for (i = 0; i < pgdat->nr_zones; i++)
>  		temp_priority[i] = DEF_PRIORITY;
>  
> +	mem_cgroup_update_softlimit_hint(nid);
> +
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
>  		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  		unsigned long lru_pages = 0;
> @@ -1863,8 +1886,17 @@ loop_again:
>  			 * zone has way too many pages free already.
>  			 */
>  			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
> -						end_zone, 0))
> -				shrink_zone(priority, zone, &sc);
> +					       end_zone, 0)) {
> +				/*
> +				 * If priority is not so bad, try softlimit
> +				 * of memcg.
> +				 */
> +				if (!(priority < DEF_PRIORITY - 2))
> +					softlimit_shrink_zone(nid, i,
> +							 priority, zone, &sc);
> +				else
> +					shrink_zone(priority, zone, &sc);
> +			}
>  			reclaim_state->reclaimed_slab = 0;
>  			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
>  						lru_pages);

This may increase priority to unexpected level, So, insert softlimit_shrink_zone()
before diving into this priority loop of balance_pgdat() may be better.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
