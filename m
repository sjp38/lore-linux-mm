Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0D78D6B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 05:38:16 -0400 (EDT)
Received: by bwz17 with SMTP id 17so410937bwz.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 02:38:12 -0700 (PDT)
Date: Thu, 26 May 2011 11:38:08 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH v3 7/10] workqueue: add WQ_IDLEPRI
Message-ID: <20110526093808.GE9715@htj.dyndns.org>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
 <20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110526143024.7f66e797.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

Hello, KAMEZAWA.

On Thu, May 26, 2011 at 02:30:24PM +0900, KAMEZAWA Hiroyuki wrote:
> When this idea came to me, I wonder which is better to maintain
> memcg's thread pool or add support in workqueue for generic use. In
> genral, I feel enhancing genric one is better...so, wrote this one.

Sure, if it's something which can be useful for other users, it makes
sense to make it generic.

> Index: memcg_async/include/linux/workqueue.h
> ===================================================================
> --- memcg_async.orig/include/linux/workqueue.h
> +++ memcg_async/include/linux/workqueue.h
> @@ -56,7 +56,8 @@ enum {
>  
>  	/* special cpu IDs */
>  	WORK_CPU_UNBOUND	= NR_CPUS,
> -	WORK_CPU_NONE		= NR_CPUS + 1,
> +	WORK_CPU_IDLEPRI	= NR_CPUS + 1,
> +	WORK_CPU_NONE		= NR_CPUS + 2,
>  	WORK_CPU_LAST		= WORK_CPU_NONE,

Hmmm... so, you're defining another fake CPU a la unbound CPU.  I'm
not sure whether it's really necessary to create its own worker pool
tho.  The reason why SCHED_OTHER is necessary is because it may
consume large amount of CPU cycles.  Workqueue already has UNBOUND -
for an unbound one, workqueue code simply acts as generic worker pool
provider and everything other than work item dispatching and worker
management are deferred to scheduler and the workqueue user.

Is there any reason memcg can't just use UNBOUND workqueue and set
scheduling priority when the work item starts and restore it when it's
done?  If it's gonna be using UNBOUND at all, I don't think changing
scheduling policy would be a noticeable overhead and I find having
separate worker pools depending on scheduling priority somewhat silly.

We can add a mechanism to manage work item scheduler priority to
workqueue if necessary tho, I think.  But that would be per-workqueue
attribute which is applied during execution, not something per-gcwq.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
