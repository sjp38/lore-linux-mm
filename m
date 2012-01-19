Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E625A6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:33:25 -0500 (EST)
Received: by wicr5 with SMTP id r5so5827560wic.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 23:33:24 -0800 (PST)
Message-ID: <1326958401.1113.22.camel@edumazet-laptop>
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for
 next
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jan 2012 08:33:21 +0100
In-Reply-To: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Le mercredi 18 janvier 2012 A  22:05 -0800, Hugh Dickins a A(C)crit :

> 2. Make one small adjustment to idr_get_next(): take the height from
> the top layer (stable under RCU) instead of from the root (unprotected
> by RCU), as idr_find() does.
> 

> --- 3.2.0+/lib/idr.c	2012-01-04 15:55:44.000000000 -0800
> +++ linux/lib/idr.c	2012-01-18 21:25:36.947963342 -0800
> @@ -605,11 +605,11 @@ void *idr_get_next(struct idr *idp, int
>  	int n, max;
>  
>  	/* find first ent */
> -	n = idp->layers * IDR_BITS;
> -	max = 1 << n;
>  	p = rcu_dereference_raw(idp->top);
>  	if (!p)
>  		return NULL;
> +	n = (p->layer + 1) * IDR_BITS;
> +	max = 1 << n;
>  
>  	while (id < max) {
>  		while (n > 0 && p) {

Interesting, but should be a patch on its own.

Maybe other idr users can benefit from your idea as well, if patch is
labeled  "idr: allow idr_get_next() from rcu_read_lock" or something...

I suggest introducing idr_get_next_rcu() helper to make the check about
rcu cleaner.

idr_get_next_rcu(...)
{
	WARN_ON_ONCE(!rcu_read_lock_held());
	return idr_get_next(...);
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
