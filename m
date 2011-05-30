Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E45EB6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 19:45:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2BB913EE0AE
	for <linux-mm@kvack.org>; Tue, 31 May 2011 08:45:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F369B45DED9
	for <linux-mm@kvack.org>; Tue, 31 May 2011 08:45:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC01845DED6
	for <linux-mm@kvack.org>; Tue, 31 May 2011 08:45:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD34C1DB8041
	for <linux-mm@kvack.org>; Tue, 31 May 2011 08:45:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 939AB1DB8037
	for <linux-mm@kvack.org>; Tue, 31 May 2011 08:45:55 +0900 (JST)
Date: Tue, 31 May 2011 08:38:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
Message-Id: <20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1306774744.4061.5.camel@localhost.localdomain>
References: <1306774744.4061.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 30 May 2011 22:59:04 +0600
Rakib Mullick <rakib.mullick@gmail.com> wrote:

> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was to allow other threads to run in non-preemptive case. This patch, makes sure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preemptiable kernel we don't need to call cond_resched().
> 
> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>

Hmm, what benefit do we get by adding this extra #ifdef in the code directly ?
Other cond_resched() callers are not guilty in !CONFIG_PREEMPT ?

Thanks,
-Kame

> ---
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 20c18b7..72cf857 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -461,7 +461,11 @@ void refresh_cpu_vm_stats(int cpu)
>  				p->expire = 3;
>  #endif
>  			}
> +
> +#ifndef CONFIG_PREEMPT
>  		cond_resched();
> +#endif
> +
>  #ifdef CONFIG_NUMA
>  		/*
>  		 * Deal with draining the remote pageset of this
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
