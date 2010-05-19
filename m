Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D7F136B0214
	for <linux-mm@kvack.org>; Tue, 18 May 2010 21:20:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4J1KvZ6029363
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 19 May 2010 10:20:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 945F745DE57
	for <linux-mm@kvack.org>; Wed, 19 May 2010 10:20:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 753CA45DE4F
	for <linux-mm@kvack.org>; Wed, 19 May 2010 10:20:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 588D21DB8040
	for <linux-mm@kvack.org>; Wed, 19 May 2010 10:20:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EB0D1DB803F
	for <linux-mm@kvack.org>; Wed, 19 May 2010 10:20:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove all rcu head initializations
In-Reply-To: <20100518190932.GA6982@linux.vnet.ibm.com>
References: <20100518190932.GA6982@linux.vnet.ibm.com>
Message-Id: <20100519101730.881B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 19 May 2010 10:20:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, mingo@elte.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mathieu.desnoyers@efficios.com
List-ID: <linux-mm.kvack.org>

Hi

> Hello!
> 
> Would you guys like to carry this patch, or should I push it up
> -tip?  If I don't hear otherwise from you, I will push it up -tip.
> The INIT_RCU_HEAD() primitive is going away in favor of debugobjects.
> 
> 							Thanx, Paul

Personally, I don't think this patch can make major conflict. So, I guess
-tip is best.

Thanks.


> 
> ------------------------------------------------------------------------
> 
> mm: remove all rcu head initializations
> 
> Remove all rcu head inits. We don't care about the RCU head state before passing
> it to call_rcu() anyway. Only leave the "on_stack" variants so debugobjects can
> keep track of objects on stack.
> 
> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 707d0dc..f03d8d6 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -663,7 +663,6 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->max_ratio = 100;
>  	bdi->max_prop_frac = PROP_FRAC_BASE;
>  	spin_lock_init(&bdi->wb_lock);
> -	INIT_RCU_HEAD(&bdi->rcu_head);
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  	INIT_LIST_HEAD(&bdi->wb_list);
>  	INIT_LIST_HEAD(&bdi->work_list);
> diff --git a/mm/slob.c b/mm/slob.c
> index 837ebd6..6de238d 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -647,7 +647,6 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
>  	if (unlikely(c->flags & SLAB_DESTROY_BY_RCU)) {
>  		struct slob_rcu *slob_rcu;
>  		slob_rcu = b + (c->size - sizeof(struct slob_rcu));
> -		INIT_RCU_HEAD(&slob_rcu->head);
>  		slob_rcu->size = c->size;
>  		call_rcu(&slob_rcu->head, kmem_rcu_free);
>  	} else {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
