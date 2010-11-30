Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 48DA96B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 03:13:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU8Didq021179
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 17:13:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6FE45DE56
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:13:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6303E45DE52
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:13:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D92E1DB805B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:13:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1231DB803C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:13:43 +0900 (JST)
Date: Tue, 30 Nov 2010 17:07:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
Message-Id: <20101130170753.dddf1121.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
	<20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 16:51:42 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
 
> > +		if (IS_ERR(thr))
> > +			printk(KERN_INFO "Failed to start kswapd on memcg %d\n",
> > +				0);
> > +		else
> > +			kswapd_p->kswapd_task = thr;
> > +	}
> 
> Hmm, ok, then, kswapd-for-memcg is created when someone go over watermark.
> Why this new kswapd will not exit() until memcg destroy ?
> 
> I think there are several approaches.
> 
>   1. create/destroy a thread at memcg create/destroy
>   2. create/destroy a thread at watermarks.
>   3. use thread pool for watermarks.
>   4. use workqueue for watermaks.
> 
> The good point of "1" is that we can control a-thread-for-kswapd by cpu
> controller but it will use some resource.
> The good point of "2" is that we can avoid unnecessary resource usage.
> 
> 3 and 4 is not very good, I think. 
> 
> I'd like to vote for "1"...I want to avoid "stealing" other container's cpu
> by bad application in a container uses up memory.
> 

One more point, one-thread-per-hierarchy is enough. So, please check
memory.use_hierarchy==1 or not at creating a thread.

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
