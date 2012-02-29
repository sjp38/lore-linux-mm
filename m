Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9AF466B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:55:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 725803EE0B6
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:55:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C7F45DE5C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:55:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA26C45DE5A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:55:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C08EAEF8004
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:55:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 713AFE08002
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:55:56 +0900 (JST)
Date: Wed, 29 Feb 2012 14:54:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH next] memcg: remove PCG_CACHE page_cgroup flag fix
Message-Id: <20120229145425.df27eaec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202282128500.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
	<alpine.LSU.2.00.1202282128500.4875@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Feb 2012 21:30:17 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Swapping tmpfs loads show absurd wrapped rss and wrong cache in memcg's
> memory.stat statistics: __mem_cgroup_uncharge_common() is failing to
> distinguish the anon and tmpfs cases.
> 
I thought I tested this..maybe my test was wrong, sorry.


> Mostly we can decide between them by PageAnon, which is reliable once
> it has been set; but there are several callers who need to uncharge a
> MEM_CGROUP_CHARGE_TYPE_MAPPED page before it was fully initialized,
> so allow that case to override the PageAnon decision.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It seems I should revisit these and consinder some cleanup...

_OFF TOPIC_
To be honest, I don't like to have anon/rss counter in memory.stat because
we have LRU statistics. It seems enough.. If shmem counter is required,
I think we should have shmem counter rather than anon/rss.


> 
>  mm/memcontrol.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> --- 3.3-rc5-next/mm/memcontrol.c	2012-02-25 10:06:52.496035568 -0800
> +++ linux/mm/memcontrol.c	2012-02-26 10:44:32.146365398 -0800
> @@ -2944,13 +2944,16 @@ __mem_cgroup_uncharge_common(struct page
>  	if (!PageCgroupUsed(pc))
>  		goto unlock_out;
>  
> +	anon = PageAnon(page);
> +
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +		anon = true;
> +		/* fallthrough */
>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
>  		/* See mem_cgroup_prepare_migration() */
>  		if (page_mapped(page) || PageCgroupMigration(pc))
>  			goto unlock_out;
> -		anon = true;
>  		break;
>  	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
>  		if (!PageAnon(page)) {	/* Shared memory */
> @@ -2958,10 +2961,8 @@ __mem_cgroup_uncharge_common(struct page
>  				goto unlock_out;
>  		} else if (page_mapped(page)) /* Anon */
>  				goto unlock_out;
> -		anon = true;
>  		break;
>  	default:
> -		anon = false;
>  		break;
>  	}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
