Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B85A26B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:29:42 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3637027pad.13
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:29:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tq5si7914079pac.211.2014.01.30.13.29.41
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 13:29:41 -0800 (PST)
Date: Thu, 30 Jan 2014 13:29:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on
 memcg_create_kmem_cache fail path
Message-Id: <20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com>
	<20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org>
	<alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014 13:14:46 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Thu, 30 Jan 2014, Andrew Morton wrote:
> 
> > Well gee, how did that one get through?
> > 
> > What was the point in permanently allocating tmp_name, btw?  "This
> > static temporary buffer is used to prevent from pointless shortliving
> > allocation"?  That's daft - memcg_create_kmem_cache() is not a fastpath
> > and there are a million places in the kernel where we could permanently
> > leak memory because it is "pointless" to allocate on demand.
> > 
> > The allocation of PATH_MAX bytes is unfortunate - kasprintf() wouild
> > work well here, but cgroup_name()'s need for rcu_read_lock() screws us
> > up.
> > 
> 
> What's funnier is that tmp_name isn't required at all since 
> kmem_cache_create_memcg() is just going to do a kstrdup() on it anyway, so 
> you could easily just pass in the pointer to memory that has been 
> allocated for s->name rather than allocating memory twice.

We need a buffer to sprintf() into.

> > --- a/mm/memcontrol.c~mm-memcontrolc-memcg_create_kmem_cache-tweaks
> > +++ a/mm/memcontrol.c
> > @@ -3401,17 +3401,14 @@ static struct kmem_cache *memcg_create_k
> >  						  struct kmem_cache *s)
> >  {
> >  	struct kmem_cache *new = NULL;
> > -	static char *tmp_name = NULL;
> > +	static char *tmp_name;
> 
> You're keeping it static and the mutex so you're still keeping it global, 
> ok...

oop, I forgot to remove the `static'.

And I suppose the mutex now doesn't do anything, so...


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/memcontrol.c: memcg_create_kmem_cache() tweaks

Allocate tmp_name on demand rather than permanently consuming PATH_MAX
bytes of memory.  Remove the mutex which protected the static tmp_name.

Cc: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff -puN mm/memcontrol.c~mm-memcontrolc-memcg_create_kmem_cache-tweaks mm/memcontrol.c
--- a/mm/memcontrol.c~mm-memcontrolc-memcg_create_kmem_cache-tweaks
+++ a/mm/memcontrol.c
@@ -3400,24 +3400,18 @@ void mem_cgroup_destroy_cache(struct kme
 static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 						  struct kmem_cache *s)
 {
-	struct kmem_cache *new = NULL;
-	static char *tmp_name = NULL;
-	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
+	struct kmem_cache *new;
+	char *tmp_name;
 
 	BUG_ON(!memcg_can_account_kmem(memcg));
 
-	mutex_lock(&mutex);
 	/*
-	 * kmem_cache_create_memcg duplicates the given name and
-	 * cgroup_name for this name requires RCU context.
-	 * This static temporary buffer is used to prevent from
-	 * pointless shortliving allocation.
+	 * kmem_cache_create_memcg duplicates the given name and cgroup_name()
+	 * for this name requires rcu_read_lock().
 	 */
-	if (!tmp_name) {
-		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
-		if (!tmp_name)
-			goto out;
-	}
+	tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!tmp_name)
+		return NULL;
 
 	rcu_read_lock();
 	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
@@ -3430,8 +3424,7 @@ static struct kmem_cache *memcg_create_k
 		new->allocflags |= __GFP_KMEMCG;
 	else
 		new = s;
-out:
-	mutex_unlock(&mutex);
+	kfree(tmp_name);
 	return new;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
