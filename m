Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 23D446B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:25:19 -0500 (EST)
Date: Tue, 6 Nov 2012 11:25:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 28/29] slub: slub-specific propagation changes.
Message-Id: <20121106112517.d20df74d.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-29-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-29-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu,  1 Nov 2012 16:07:44 +0400
Glauber Costa <glommer@parallels.com> wrote:

> SLUB allows us to tune a particular cache behavior with sysfs-based
> tunables.  When creating a new memcg cache copy, we'd like to preserve
> any tunables the parent cache already had.
> 
> This can be done by tapping into the store attribute function provided
> by the allocator. We of course don't need to mess with read-only
> fields. Since the attributes can have multiple types and are stored
> internally by sysfs, the best strategy is to issue a ->show() in the
> root cache, and then ->store() in the memcg cache.
> 
> The drawback of that, is that sysfs can allocate up to a page in
> buffering for show(), that we are likely not to need, but also can't
> guarantee. To avoid always allocating a page for that, we can update the
> caches at store time with the maximum attribute size ever stored to the
> root cache. We will then get a buffer big enough to hold it. The
> corolary to this, is that if no stores happened, nothing will be
> propagated.
> 
> It can also happen that a root cache has its tunables updated during
> normal system operation. In this case, we will propagate the change to
> all caches that are already active.
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3955,6 +3956,7 @@ int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
>  	if (err)
>  		return err;
>  
> +	memcg_propagate_slab_attrs(s);
>  	mutex_unlock(&slab_mutex);
>  	err = sysfs_slab_add(s);
>  	mutex_lock(&slab_mutex);
> @@ -5180,6 +5182,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
>  	struct slab_attribute *attribute;
>  	struct kmem_cache *s;
>  	int err;
> +	int i __maybe_unused;
>  
>  	attribute = to_slab_attr(attr);
>  	s = to_slab(kobj);
> @@ -5188,10 +5191,81 @@ static ssize_t slab_attr_store(struct kobject *kobj,
>  		return -EIO;
>  
>  	err = attribute->store(s, buf, len);
> +#ifdef CONFIG_MEMCG_KMEM
> +	if (slab_state < FULL)
> +		return err;
>  
> +	if ((err < 0) || !is_root_cache(s))
> +		return err;
> +
> +	mutex_lock(&slab_mutex);
> +	if (s->max_attr_size < len)
> +		s->max_attr_size = len;
> +
> +	for_each_memcg_cache_index(i) {
> +		struct kmem_cache *c = cache_from_memcg(s, i);
> +		if (c)
> +			/* return value determined by the parent cache only */
> +			attribute->store(c, buf, len);
> +	}
> +	mutex_unlock(&slab_mutex);
> +#endif
>  	return err;
>  }

hm, __maybe_unused is an ugly thing.  We can avoid it by tweaking the
code a bit:

diff -puN mm/slub.c~slub-slub-specific-propagation-changes-fix mm/slub.c
--- a/mm/slub.c~slub-slub-specific-propagation-changes-fix
+++ a/mm/slub.c
@@ -5175,7 +5175,6 @@ static ssize_t slab_attr_store(struct ko
 	struct slab_attribute *attribute;
 	struct kmem_cache *s;
 	int err;
-	int i __maybe_unused;
 
 	attribute = to_slab_attr(attr);
 	s = to_slab(kobj);
@@ -5185,23 +5184,24 @@ static ssize_t slab_attr_store(struct ko
 
 	err = attribute->store(s, buf, len);
 #ifdef CONFIG_MEMCG_KMEM
-	if (slab_state < FULL)
-		return err;
+	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
+		int i;
 
-	if ((err < 0) || !is_root_cache(s))
-		return err;
-
-	mutex_lock(&slab_mutex);
-	if (s->max_attr_size < len)
-		s->max_attr_size = len;
-
-	for_each_memcg_cache_index(i) {
-		struct kmem_cache *c = cache_from_memcg(s, i);
-		if (c)
-			/* return value determined by the parent cache only */
-			attribute->store(c, buf, len);
+		mutex_lock(&slab_mutex);
+		if (s->max_attr_size < len)
+			s->max_attr_size = len;
+
+		for_each_memcg_cache_index(i) {
+			struct kmem_cache *c = cache_from_memcg(s, i);
+			/*
+			 * This function's return value is determined by the
+			 * parent cache only
+			 */
+			if (c)
+				attribute->store(c, buf, len);
+		}
+		mutex_unlock(&slab_mutex);
 	}
-	mutex_unlock(&slab_mutex);
 #endif
 	return err;
 }

Also, the comment in there tells the reader *what the code does*, not
*why it does it*.  Why do we ignore the ->store return value for child
caches?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
