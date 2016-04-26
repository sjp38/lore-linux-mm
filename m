Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B47DB6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 20:47:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so1019949pfy.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:47:07 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b68si1030009pfb.21.2016.04.25.17.47.06
        for <linux-mm@kvack.org>;
        Mon, 25 Apr 2016 17:47:06 -0700 (PDT)
Date: Tue, 26 Apr 2016 09:47:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 04/11] mm/slab: factor out kmem_cache_node
 initialization code
Message-ID: <20160426004704.GB2707@js1304-P5Q-DELUXE>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1460436666-20462-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460436666-20462-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 12, 2016 at 01:50:59PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> It can be reused on other place, so factor out it.  Following patch will
> use it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slab.c | 68 ++++++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 39 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 5451929..49af685 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -841,6 +841,40 @@ static inline gfp_t gfp_exact_node(gfp_t flags)
>  }
>  #endif
>  
> +static int init_cache_node(struct kmem_cache *cachep, int node, gfp_t gfp)
> +{
> +	struct kmem_cache_node *n;
> +
> +	/*
> +	 * Set up the kmem_cache_node for cpu before we can
> +	 * begin anything. Make sure some other cpu on this
> +	 * node has not already allocated this
> +	 */
> +	n = get_node(cachep, node);
> +	if (n)
> +		return 0;
> +
> +	n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
> +	if (!n)
> +		return -ENOMEM;
> +
> +	kmem_cache_node_init(n);
> +	n->next_reap = jiffies + REAPTIMEOUT_NODE +
> +		    ((unsigned long)cachep) % REAPTIMEOUT_NODE;
> +
> +	n->free_limit =
> +		(1 + nr_cpus_node(node)) * cachep->batchcount + cachep->num;
> +
> +	/*
> +	 * The kmem_cache_nodes don't come and go as CPUs
> +	 * come and go.  slab_mutex is sufficient
> +	 * protection here.
> +	 */
> +	cachep->node[node] = n;
> +
> +	return 0;
> +}
> +

Hello, Andrew.

Could you apply following fix for this patch to mmotm?

Thanks.

------>8-----------
Date: Thu, 14 Apr 2016 10:28:11 +0900
Subject: [PATCH] mm/slab: fix bug

n->free_limit is once set in boot-up process without enabling multiple
cpu so it could be very low value. If we don't re-set when another cpu
is up, it will stay too low. Fix it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

---
 mm/slab.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 13e74aa..59dd94a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -856,8 +856,14 @@ static int init_cache_node(struct kmem_cache *cachep, int node, gfp_t gfp)
 	 * node has not already allocated this
 	 */
 	n = get_node(cachep, node);
-	if (n)
+	if (n) {
+		spin_lock_irq(&n->list_lock);
+		n->free_limit = (1 + nr_cpus_node(node)) * cachep->batchcount +
+				cachep->num;
+		spin_unlock_irq(&n->list_lock);
+
 		return 0;
+	}
 
 	n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
 	if (!n)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
