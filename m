Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B5A386B00B7
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 22:08:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n22383vO032472
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Mar 2009 12:08:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B33FD45DD82
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 12:08:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 84B0345DD7B
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 12:08:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D2031DB8038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 12:08:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 79AB61DB803F
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 12:08:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v3)
In-Reply-To: <20090301063041.31557.86588.sendpatchset@localhost.localdomain>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090301063041.31557.86588.sendpatchset@localhost.localdomain>
Message-Id: <20090302120052.6FEC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 Mar 2009 12:08:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

> @@ -2015,9 +2016,12 @@ static int kswapd(void *p)
>  		finish_wait(&pgdat->kswapd_wait, &wait);
>  
>  		if (!try_to_freeze()) {
> +			struct zonelist *zl = pgdat->node_zonelists;
>  			/* We can speed up thawing tasks if we don't call
>  			 * balance_pgdat after returning from the refrigerator
>  			 */
> +			if (!order)
> +				mem_cgroup_soft_limit_reclaim(zl, GFP_KERNEL);
>  			balance_pgdat(pgdat, order);
>  		}
>  	}

kswapd's roll is increasing free pages until zone->pages_high in "own node".
mem_cgroup_soft_limit_reclaim() free one (or more) exceed page in any node.

Oh, well.
I think it is not consistency.

if mem_cgroup_soft_limit_reclaim() is aware to target node and its pages_high,
I'm glad.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
