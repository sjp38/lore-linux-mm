Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 39E576B004F
	for <linux-mm@kvack.org>; Sun, 15 Jan 2012 12:25:12 -0500 (EST)
Received: by wicr5 with SMTP id r5so1995241wic.14
        for <linux-mm@kvack.org>; Sun, 15 Jan 2012 09:25:10 -0800 (PST)
Message-ID: <1326648305.5287.78.camel@edumazet-laptop>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Jan 2012 18:25:05 +0100
In-Reply-To: <1326632384.11711.3.camel@lappy>
References: <1326558605.19951.7.camel@lappy>
	 <1326561043.5287.24.camel@edumazet-laptop> <1326632384.11711.3.camel@lappy>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

Le dimanche 15 janvier 2012 A  14:59 +0200, Sasha Levin a A(C)crit :
> On Sat, 2012-01-14 at 18:10 +0100, Eric Dumazet wrote:
> > Apparently SLUB calls sysfs_slab_add() from kmem_cache_create() while
> > still holding slub_lock.
> > 
> > So if the task launched needs to "cat /proc/slabinfo" or anything
> > needing slub_lock, its a deadlock.
> 
> I've made the following patch to test it, It doesn't look like it's
> the correct solution, but it verifies that the problem is there (it
> works well with the patch).
> 
> ---------------
> 
> From cc4874b491b8e5d9d1ea5bf2032413efdbddced8 Mon Sep 17 00:00:00 2001
> From: Sasha Levin <levinsasha928@gmail.com>
> Date: Sun, 15 Jan 2012 14:55:03 +0200
> Subject: [PATCH] slab: Fix hang when creating sysfs entries
> 
> This patch fixes the hang which happens when we create a sysfs entry and call
> back to userspace. If the usermode helper tries to do anything which involves
> slub_lock we will hang since slub_lock is already held.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/slub.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 4907563..6948327 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5283,7 +5283,9 @@ static int sysfs_slab_add(struct kmem_cache *s)
>  		kobject_put(&s->kobj);
>  		return err;
>  	}
> +	up_write(&slub_lock);
>  	kobject_uevent(&s->kobj, KOBJ_ADD);
> +	down_write(&slub_lock);
>  	if (!unmergeable) {
>  		/* Setup first alias */
>  		sysfs_slab_alias(s, s->name);
> -- 
> 1.7.8.3
> 
> 

Oh well, that cannot be right. Dont send official patches if you already
know "it's not the correct solution", we already know where is the
problem.

It's _never_ right to release a lock for a short time without any
additional checks. [ If it was right, the lock would be not needed ]

As soon as the slub_lock is released, another thread can come and find
the new kmem_cache.

For example, it can destroy it, and your thread is going to access s
while it was already freed.

	sysfs_slab_alias(s, s->name); // crash



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
