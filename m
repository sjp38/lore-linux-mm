Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5EA56B0035
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 23:39:08 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id u14so2154393bkz.27
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 20:39:08 -0800 (PST)
Received: from mail-bk0-x231.google.com (mail-bk0-x231.google.com [2a00:1450:4008:c01::231])
        by mx.google.com with ESMTPS id om1si9142464bkb.131.2014.01.25.20.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Jan 2014 20:39:07 -0800 (PST)
Received: by mail-bk0-f49.google.com with SMTP id v15so2126609bkz.22
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 20:39:07 -0800 (PST)
Date: Sat, 25 Jan 2014 20:39:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: fix wrong retval on kmem_cache_create_memcg error
 path
In-Reply-To: <1390598126-4332-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1401252036410.10325@chino.kir.corp.google.com>
References: <1390598126-4332-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Sat, 25 Jan 2014, Vladimir Davydov wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 8e40321..499b53c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -249,7 +249,6 @@ out_unlock:
>  				name, err);
>  			dump_stack();
>  		}
> -		return NULL;
>  	}
>  	return s;
>  
> @@ -257,6 +256,7 @@ out_free_cache:
>  	memcg_free_cache_params(s);
>  	kfree(s->name);
>  	kmem_cache_free(kmem_cache, s);
> +	s = NULL;
>  	goto out_unlock;
>  }
>  

I thought I left spaghetti code back in my BASIC 2.0 days.  It should be 
much more readable to just do

diff --git a/mm/slab_common.c b/mm/slab_common.c
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -233,14 +233,15 @@ out_unlock:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
-	/*
-	 * There is no point in flooding logs with warnings or especially
-	 * crashing the system if we fail to create a cache for a memcg. In
-	 * this case we will be accounting the memcg allocation to the root
-	 * cgroup until we succeed to create its own cache, but it isn't that
-	 * critical.
-	 */
-	if (err && !memcg) {
+	if (err) {
+		/*
+		 * There is no point in flooding logs with warnings or
+		 * especially crashing the system if we fail to create a cache
+		 * for a memcg.
+		 */
+		if (memcg)
+			return NULL;
+
 		if (flags & SLAB_PANIC)
 			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
 				name, err);

and stop trying to remember what err, memcg, and s are in all possible 
contexts.  Sheesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
