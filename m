Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 107E56B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 12:02:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p53so2363645qtp.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 09:02:07 -0700 (PDT)
Received: from cmta16.telus.net (cmta16.telus.net. [209.171.16.89])
        by mx.google.com with ESMTP id a25si1467686qtc.51.2016.10.06.09.02.03
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 09:02:04 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: s238betearAHps239b0z1X
In-Reply-To: s238betearAHps239b0z1X
Subject: RE: [PATCH] mm/slab: fix kmemcg cache creation delayed issue
Date: Thu, 6 Oct 2016 09:02:00 -0700
Message-ID: <002b01d21fea$fb0bab60$f1230220$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

It was my (limited) understanding that the subsequent 2 patch set
superseded this patch. Indeed, the 2 patch set seems to solve
both the SLAB and SLUB bug reports.

References:

https://bugzilla.kernel.org/show_bug.cgi?id=172981
https://bugzilla.kernel.org/show_bug.cgi?id=172991
https://patchwork.kernel.org/patch/9361853
https://patchwork.kernel.org/patch/9359271
 
On 2016.10.05 23:21 Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> There is a bug report that SLAB makes extreme load average due to
> over 2000 kworker thread.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=172981
>
> This issue is caused by kmemcg feature that try to create new set of
> kmem_caches for each memcg. Recently, kmem_cache creation is slowed by
> synchronize_sched() and futher kmem_cache creation is also delayed
> since kmem_cache creation is synchronized by a global slab_mutex lock.
> So, the number of kworker that try to create kmem_cache increases quitely.
> synchronize_sched() is for lockless access to node's shared array but
> it's not needed when a new kmem_cache is created. So, this patch
> rules out that case.
>
> Fixes: 801faf0db894 ("mm/slab: lockless decision to grow cache")
> Cc: stable@vger.kernel.org
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Tested-by: Doug Smythies <dsmythies@telus.net>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
> mm/slab.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 6508b4d..3c83c29 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -961,7 +961,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> 	 * guaranteed to be valid until irq is re-enabled, because it will be
> 	 * freed after synchronize_sched().
> 	 */
> -	if (force_change)
> +	if (old_shared && force_change)
> 		synchronize_sched();
> 
> fail:
> -- 
> 1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
