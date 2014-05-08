Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 904D76B00D0
	for <linux-mm@kvack.org>; Thu,  8 May 2014 03:09:04 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id q8so2959803lbi.27
        for <linux-mm@kvack.org>; Thu, 08 May 2014 00:09:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pc8si58163lbb.202.2014.05.08.00.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 May 2014 00:09:02 -0700 (PDT)
Date: Thu, 8 May 2014 11:08:54 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 1/2] memcg: get rid of memcg_create_cache_name
Message-ID: <20140508070853.GG4757@esperanza>
References: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
 <20140507095127.GC9489@dhcp22.suse.cz>
 <20140507104514.GC4757@esperanza>
 <20140507135352.3790c739ae331d1f6721f3de@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140507135352.3790c739ae331d1f6721f3de@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 07, 2014 at 01:53:52PM -0700, Andrew Morton wrote:
> On Wed, 7 May 2014 14:45:16 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > @@ -3164,6 +3141,7 @@ void memcg_free_cache_params(struct kmem_cache *s)
> >  static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
> >  				    struct kmem_cache *root_cache)
> >  {
> > +	static char *memcg_name_buf;	/* protected by memcg_slab_mutex */
> >  	struct kmem_cache *cachep;
> >  	int id;
> >  
> > @@ -3179,7 +3157,14 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
> >  	if (cache_from_memcg_idx(root_cache, id))
> >  		return;
> >  
> > -	cachep = kmem_cache_create_memcg(memcg, root_cache);
> > +	if (!memcg_name_buf) {
> > +		memcg_name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
> > +		if (!memcg_name_buf)
> > +			return;
> > +	}
> 
> Does this have any meaningful advantage over the simpler
> 
> 	static char memcg_name_buf[NAME_MAX + 1];
> 
> ?

Don't think so. In case nobody has objections, the patch is attached
below.

Thanks.
--

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: memcg_kmem_create_cache: make memcg_name_buf
 statically allocated

It isn't worth complicating the code by allocating it on the first
access, because it only takes 256 bytes.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ff3742f4154..01fda17a2566 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3141,7 +3141,8 @@ void memcg_free_cache_params(struct kmem_cache *s)
 static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 				    struct kmem_cache *root_cache)
 {
-	static char *memcg_name_buf;	/* protected by memcg_slab_mutex */
+	static char memcg_name_buf[NAME_MAX + 1]; /* protected by
+						     memcg_slab_mutex */
 	struct kmem_cache *cachep;
 	int id;
 
@@ -3157,12 +3158,6 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
-	if (!memcg_name_buf) {
-		memcg_name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
-		if (!memcg_name_buf)
-			return;
-	}
-
 	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
 	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name_buf);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
