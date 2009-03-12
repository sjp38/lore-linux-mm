Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F15426B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:10:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0A2Zm004173
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:10:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D26445DD85
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:10:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0087C45DD80
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:10:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD9DF1DB8043
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:10:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52706E08007
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:10:01 +0900 (JST)
Date: Thu, 12 Mar 2009 09:08:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] memcg: softlimit caller via kswapd
Message-Id: <20090312090839.b77f9560.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312090311.439B.A69D9226@jp.fujitsu.com>
References: <20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090310190242.GG26837@balbir.in.ibm.com>
	<20090312090311.439B.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:05:43 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Balbir-san,
> 
> > Looks like a dirty hack, replacing sc-> fields this way. I've
> > experimented a lot with per zone balancing and soft limits and it does
> > not work well. The reasons
> > 
> > 1. zone watermark balancing has a different goal than soft limit. Soft
> > limits are more of a mem cgroup feature rather than node/zone feature.
> > IIRC, you called reclaim as hot-path for soft limit reclaim, my
> > experimentation is beginning to show changed behaviour
> > 
> > On a system with 4 CPUs and 4 Nodes, I find all CPUs spending time
> > doing reclaim, putting the hook in the reclaim path, makes the reclaim
> > dependent on the number of tasks and contention.
> > 
> > What does your test data/experimentation show?
> 
> you pointed out mainline kernel bug, not kamezawa patch's bug ;-)
> Could you please try following patch?
> 
> sorry, this is definitly my fault.
> 
> 
Thank you!

-Kame


> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bfd853b..15f7737 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  		int file = is_file_lru(l);
>  		int scan;
>  
> -		scan = zone_page_state(zone, NR_LRU_BASE + l);
> +		scan = zone_nr_pages(zone, sc, l);
>  		if (priority) {
>  			scan >>= priority;
>  			scan = (scan * percent[file]) / 100;
> -- 
> 1.6.0.6
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
