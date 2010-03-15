Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A07C66B01F6
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 18:00:26 -0400 (EDT)
Date: Mon, 15 Mar 2010 15:00:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] memcg: oom kill disable and oom status
Message-Id: <20100315150020.0cc28341.akpm@linux-foundation.org>
In-Reply-To: <20100312143753.420e7ae7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143435.e648e361.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143753.420e7ae7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 14:37:53 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> I haven't get enough comment to this patch itself. But works well.
> Feel free to request me if you want me to change some details.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This adds a feature to disable oom-killer for memcg, if disabled,
> of course, tasks under memcg will stop.
> 
> But now, we have oom-notifier for memcg. And the world around
> memcg is not under out-of-memory. memcg's out-of-memory just
> shows memcg hits limit. Then, administrator or
> management daemon can recover the situation by
> 	- kill some process
> 	- enlarge limit, add more swap.
> 	- migrate some tasks
> 	- remove file cache on tmps (difficult ?)
> 
> Unlike OOM-Kill by the kernel, the users can take snapshot or coredump
> of guilty process, cgroups.
> 

Looks complicated.

> --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> @@ -235,7 +235,8 @@ struct mem_cgroup {
>  	 * mem_cgroup ? And what type of charges should we move ?
>  	 */
>  	unsigned long 	move_charge_at_immigrate;
> -
> +	/* Disable OOM killer */
> +	unsigned long	oom_kill_disable;
>  	/*
>  	 * percpu counter.
>  	 */

Would have been better to make this `int' or `bool', and put it next to
some other 32-bit value in this struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
