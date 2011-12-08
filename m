Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D5DA06B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:07:15 -0500 (EST)
Received: by ghbg19 with SMTP id g19so1578614ghb.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:07:15 -0800 (PST)
Date: Wed, 7 Dec 2011 23:07:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] vmalloc: purge_fragmented_blocks: Acquire spinlock
 before reading vmap_block
In-Reply-To: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com>
Message-ID: <alpine.DEB.2.00.1112072304010.28419@chino.kir.corp.google.com>
References: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Dec 2011, Kautuk Consul wrote:

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 3231bf3..2228971 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -855,11 +855,14 @@ static void purge_fragmented_blocks(int cpu)
>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
> +		spin_lock(&vb->lock);
>  
> -		if (!(vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS))
> +		if (!(vb->free + vb->dirty == VMAP_BBMAP_BITS &&
> +			  vb->dirty != VMAP_BBMAP_BITS)) {
> +			spin_unlock(&vb->lock);
>  			continue;
> +		}
>  
> -		spin_lock(&vb->lock);
>  		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
>  			vb->free = 0; /* prevent further allocs after releasing lock */
>  			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */

Nack, this is wrong because the if-clause you're modifying isn't the 
criteria that is used to determine whether the purge occurs or not.  It's 
merely an optimization to prevent doing exactly what your patch is doing: 
taking vb->lock unnecessarily.

In the original code, if the if-clause fails, the lock is only then taken 
and the exact same test occurs again while protected.  If the test now 
fails, the lock is immediately dropped.  A branch here is faster than a 
contented spinlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
