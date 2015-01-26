Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 02D326B0073
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 05:01:39 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so11120706pdj.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 02:01:38 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id u1si11768041pdi.60.2015.01.26.02.01.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 02:01:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] slab: update_memcg_params: explicitly check that old array != NULL
Date: Mon, 26 Jan 2015 13:01:19 +0300
Message-ID: <1422266479-29098-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20150126085638.GA6507@mwanda>
References: <20150126085638.GA6507@mwanda>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   c64429bcc60a702f19f5cfdb5c39277863278a8c
commit: 5d06629c100b942a51f02b4d886c116ba3afb32a [200/417] slab: embed memcg_cache_params to kmem_cache

mm/slab_common.c:166 update_memcg_params() warn: variable dereferenced before check 'old' (see line 162)

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout 5d06629c100b942a51f02b4d886c116ba3afb32a
vim +/old +166 mm/slab_common.c

5d06629c Vladimir Davydov 2015-01-24  156                                       lockdep_is_held(&slab_mutex));
5d06629c Vladimir Davydov 2015-01-24  157       new = kzalloc(sizeof(struct memcg_cache_array) +
5d06629c Vladimir Davydov 2015-01-24  158                     new_array_size * sizeof(void *), GFP_KERNEL);
5d06629c Vladimir Davydov 2015-01-24  159       if (!new)
6f817f4c Vladimir Davydov 2014-10-09  160               return -ENOMEM;
6f817f4c Vladimir Davydov 2014-10-09  161
5d06629c Vladimir Davydov 2015-01-24 @162       memcpy(new->entries, old->entries,
88a0b848 Vladimir Davydov 2015-01-24  163              memcg_nr_cache_ids * sizeof(void *));
6f817f4c Vladimir Davydov 2014-10-09  164
5d06629c Vladimir Davydov 2015-01-24  165       rcu_assign_pointer(s->memcg_params.memcg_caches, new);
5d06629c Vladimir Davydov 2015-01-24 @166       if (old)
5d06629c Vladimir Davydov 2015-01-24  167               kfree_rcu(old, rcu);
6f817f4c Vladimir Davydov 2014-10-09  168       return 0;
6f817f4c Vladimir Davydov 2014-10-09  169  }

This warning is false-positive, because @old equals NULL iff
@memcg_nr_cache_ids equals 0. Moreover, this function had been acting in
exactly the same fashion before it was reworked by the culprit. Anyways,
let's add an explicit check if @old is not NULL before passing it to
@memcpy() to make static analysis tools happy.

fixes: slab-embed-memcg_cache_params-to-kmem_cache
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab_common.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index bf4a42b2c5ba..0dd9eb4e0f87 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -153,15 +153,16 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 	if (!is_root_cache(s))
 		return 0;
 
-	old = rcu_dereference_protected(s->memcg_params.memcg_caches,
-					lockdep_is_held(&slab_mutex));
 	new = kzalloc(sizeof(struct memcg_cache_array) +
 		      new_array_size * sizeof(void *), GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
 
-	memcpy(new->entries, old->entries,
-	       memcg_nr_cache_ids * sizeof(void *));
+	old = rcu_dereference_protected(s->memcg_params.memcg_caches,
+					lockdep_is_held(&slab_mutex));
+	if (old)
+		memcpy(new->entries, old->entries,
+		       memcg_nr_cache_ids * sizeof(void *));
 
 	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
 	if (old)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
