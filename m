Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4ECE8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:39:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1AE8D3EE0C0
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:39:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F2D4645DE99
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:39:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D920F45DE94
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:39:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C817EE18002
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:39:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FCFE1DB8038
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:39:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
In-Reply-To: <1303446260-21333-5-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com> <1303446260-21333-5-git-send-email-yinghan@google.com>
Message-Id: <20110422143957.FA6D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 14:39:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> +bool mem_cgroup_kswapd_can_sleep(void)
> +{
> +	return list_empty(&memcg_kswapd_control.list);
> +}

and, 

> @@ -2583,40 +2585,46 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
>  	} else {
> +		/* For now, we just check the remaining works.*/
> +		if (mem_cgroup_kswapd_can_sleep())
> +			schedule();

has bad assumption. If freeable memory is very little and kswapds are
contended, memcg-kswap also have to give up and go into sleep as global
kswapd.

Otherwise, We are going to see kswapd cpu 100% consumption issue again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
