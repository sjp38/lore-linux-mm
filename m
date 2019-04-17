Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B55C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:55:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1C8621850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bkJtX8C+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1C8621850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8EDB6B000A; Wed, 17 Apr 2019 17:54:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D41C26B000C; Wed, 17 Apr 2019 17:54:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9A8A6B000D; Wed, 17 Apr 2019 17:54:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 750676B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:54:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g11so957501pgs.12
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:54:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MtkthRXb9xr3Z6+sHE+ddzmShZROkNDy015XAdhrxgc=;
        b=XKHkS9oN6/Kw3VwFE0IYAkOY1wqqpu1M6kCPKNOaCh2ShkDMnfEWLDbJPveNsQ3BZP
         aXZeeaMEHYWN+tm7HfMO47Thwgs78PEPAfSSSSFx8qdTImnQV8TjR+lUpW7fkf9JILK+
         wC/W2dRLWSkoLXunUxdexZhkjXCBTwctjzv4oiTNOjDluMdJTr0JDSTZteYA7ROl7bJo
         H4MsJB44RMXSuJcn7pA1yugJe51xxIpKsSfKjP0gON/XORfJGpNRjuRl+aN/MaQrDlQa
         PqlseCsvHrejRZSBRoNGG8vVKKjgmEuwBINA9cqD9IbcocXW3a6+dWufH10z5k9Izxt+
         AqLA==
X-Gm-Message-State: APjAAAU9FwA71kvlRZ39OBCaXQcn5fYoQWsNEppvsbOo9O1aw+hM1N4F
	exNzNtB0rWv4EQcwL6ICwT5mLSYxwCvOkmfh+IT733mMgESIquQxRYgS1Kk/CG6gcmmMo4mbyRQ
	jHAp8PWrlqKWF6iVpY9Na+Az2gJdwnG8+DtbxBHo+Ycv/4bA0jxTWpA1rr0BYv1O1mQ==
X-Received: by 2002:a63:185a:: with SMTP id 26mr58430656pgy.337.1555538098079;
        Wed, 17 Apr 2019 14:54:58 -0700 (PDT)
X-Received: by 2002:a63:185a:: with SMTP id 26mr58430579pgy.337.1555538096633;
        Wed, 17 Apr 2019 14:54:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538096; cv=none;
        d=google.com; s=arc-20160816;
        b=FRRH77Lov4x8G6yDik5AQGoH7oYIcCZeRakeQbVkSdXSGhcuDO3rpeb56VUkuaxT5Y
         XUwK8RYwICORfV5pgJulymN+HlKvZK42t9uriNcHyTV5Vg+gIk9OOXMW2PtzDXCWA/R0
         hzpijl75B7FwaVGTaZqRRD1X00nHgpfaBZmbZmk2UOQpI9j6gXWNF8xe2gU+XoJAQKac
         7Atkr9zReKz/aAd93yJrY7dTs7FaO6l4CgxgA222Gx4vIr6PPtihl302mlpJ9U+qhPbQ
         TUJaG7/6HKXumLgAmzYm7Ya9GYF4w/yTM9f92tLAC+LatKTTW4k8PWw3yUf0QO0kk0Z5
         7Olg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MtkthRXb9xr3Z6+sHE+ddzmShZROkNDy015XAdhrxgc=;
        b=CYUDFChjbj9busCGN5Vj92mBQJjLNrqGcYRV+bUoEEp4aRnNtKd99VRH6aEBJuX1HS
         0WlGLyrnuMrJAh7bPiUmqV0Bd/fb1zEWRo28he1Q8vrhI3E5Vu36uueypt2ysPJ6PKly
         Qdi/w0TfU5U3BcOiIK/IQfG/t8rstQTMqGXtlAwPC4JxREo1cQO7584TUtxJKxLu7sDs
         zguytgkSS7qbe4xdxPghf2eFmxPVleSzeUqwG9syGu3YwSKjqbWe+ydUvQIBb6ZcECWq
         cMOkDVp7XfVdQwXxVMnjNV0rgAFZG0mW36ufc23yQnvuturAD6ZHWnBqncxCJmesa1NP
         Y9Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bkJtX8C+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g95sor23379plb.5.2019.04.17.14.54.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bkJtX8C+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MtkthRXb9xr3Z6+sHE+ddzmShZROkNDy015XAdhrxgc=;
        b=bkJtX8C+3fj0Tjhyg4vCVv/IFmBzbGBkiaDAvFLmDb8Lq2CSpvTCu0DpsxNBzVRZE6
         /KavKK6sZJp6q1on9j4P5GAND/bIlyXqkI64KWpz4q5A+ph+Wga2tCFOg5zBESw4qB6F
         0a8qx/VE5UXWEj/OfguZ1W6Acn8pwoIJDzZu71ecJg94TK4ni4QRK9oElJ9DPSm60c+g
         K0zyATOpmJW3pcoANLB3OTOt8dtYU0H7WgFn7PoNVvhHacgEQcsm7GTnMLHoclASVfe4
         LiW1YvyENbVaOxl0Qz3UxRV4EsfpG6OXUukFSX+jgB8C/tTLlnztGVBcSkJ+IPrW2RX7
         G1Xg==
X-Google-Smtp-Source: APXvYqwg/PODrPNFlRfYDoK4DEAkGsveLbL3EEOb4pDRkT0d8MTv1g9F41Dfa37BfIh/CXJNuXPr9w==
X-Received: by 2002:a17:902:e382:: with SMTP id ch2mr89133541plb.94.1555538096288;
        Wed, 17 Apr 2019 14:54:56 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:54:55 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/5] mm: generalize postponed non-root kmem_cache deactivation
Date: Wed, 17 Apr 2019 14:54:31 -0700
Message-Id: <20190417215434.25897-3-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417215434.25897-1-guro@fb.com>
References: <20190417215434.25897-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB uses a work scheduled after an RCU grace period
to deactivate a non-root kmem_cache. This mechanism can be reused
for kmem_caches reparenting, but requires some generalization.

Let's decouple all infrastructure (rcu callback, work callback)
from the SLUB-specific code, so it can be used with SLAB as well.

Also, let's rename some functions to make the code look simpler.
All SLAB/SLUB-specific functions start with "__". Remove "deact_"
prefix from the corresponding struct fields.

Here is the graph of a new calling scheme:
kmemcg_cache_deactivate()
  __kmemcg_cache_deactivate()                  SLAB/SLUB-specific
  kmemcg_schedule_work_after_rcu()             rcu
    kmemcg_after_rcu_workfn()                  work
      kmemcg_cache_deactivate_after_rcu()
        __kmemcg_cache_deactivate_after_rcu()  SLAB/SLUB-specific

instead of:
__kmemcg_cache_deactivate()                    SLAB/SLUB-specific
  slab_deactivate_memcg_cache_rcu_sched()      SLUB-only
    kmemcg_deactivate_rcufn                    SLUB-only, rcu
      kmemcg_deactivate_workfn                 SLUB-only, work
        kmemcg_cache_deact_after_rcu()         SLUB-only

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  6 ++---
 mm/slab.c            |  4 +++
 mm/slab.h            |  3 ++-
 mm/slab_common.c     | 62 ++++++++++++++++++++------------------------
 mm/slub.c            |  8 +-----
 5 files changed, 38 insertions(+), 45 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..47923c173f30 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -642,10 +642,10 @@ struct memcg_cache_params {
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
 
-			void (*deact_fn)(struct kmem_cache *);
+			void (*work_fn)(struct kmem_cache *);
 			union {
-				struct rcu_head deact_rcu_head;
-				struct work_struct deact_work;
+				struct rcu_head rcu_head;
+				struct work_struct work;
 			};
 		};
 	};
diff --git a/mm/slab.c b/mm/slab.c
index 57a332f524cf..14466a73d057 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2317,6 +2317,10 @@ void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
 {
 	__kmem_cache_shrink(cachep);
 }
+
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
+{
+}
 #endif
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 6a562ca72bca..4a261c97c138 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -172,6 +172,7 @@ int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *);
 void __kmemcg_cache_deactivate(struct kmem_cache *s);
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
@@ -291,7 +292,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 extern void slab_init_memcg_params(struct kmem_cache *);
 extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-				void (*deact_fn)(struct kmem_cache *));
+				void (*work_fn)(struct kmem_cache *));
 
 #else /* CONFIG_MEMCG_KMEM */
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6e00bdf8618d..4e5b4292a763 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -691,17 +691,18 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	put_online_cpus();
 }
 
-static void kmemcg_deactivate_workfn(struct work_struct *work)
+static void kmemcg_after_rcu_workfn(struct work_struct *work)
 {
 	struct kmem_cache *s = container_of(work, struct kmem_cache,
-					    memcg_params.deact_work);
+					    memcg_params.work);
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
-	s->memcg_params.deact_fn(s);
+	s->memcg_params.work_fn(s);
+	s->memcg_params.work_fn = NULL;
 
 	mutex_unlock(&slab_mutex);
 
@@ -712,37 +713,28 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
 	css_put(&s->memcg_params.memcg->css);
 }
 
-static void kmemcg_deactivate_rcufn(struct rcu_head *head)
+/*
+ * We need to grab blocking locks.  Bounce to ->work.  The
+ * work item shares the space with the RCU head and can't be
+ * initialized eariler.
+*/
+static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
 {
 	struct kmem_cache *s = container_of(head, struct kmem_cache,
-					    memcg_params.deact_rcu_head);
+					    memcg_params.rcu_head);
 
-	/*
-	 * We need to grab blocking locks.  Bounce to ->deact_work.  The
-	 * work item shares the space with the RCU head and can't be
-	 * initialized eariler.
-	 */
-	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
-	queue_work(memcg_kmem_cache_wq, &s->memcg_params.deact_work);
+	INIT_WORK(&s->memcg_params.work, kmemcg_after_rcu_workfn);
+	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
 }
 
-/**
- * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
- *					   sched RCU grace period
- * @s: target kmem_cache
- * @deact_fn: deactivation function to call
- *
- * Schedule @deact_fn to be invoked with online cpus, mems and slab_mutex
- * held after a sched RCU grace period.  The slab is guaranteed to stay
- * alive until @deact_fn is finished.  This is to be used from
- * __kmemcg_cache_deactivate().
- */
-void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
-					   void (*deact_fn)(struct kmem_cache *))
+static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
-	if (WARN_ON_ONCE(is_root_cache(s)) ||
-	    WARN_ON_ONCE(s->memcg_params.deact_fn))
-		return;
+	__kmemcg_cache_deactivate_after_rcu(s);
+}
+
+static void kmemcg_cache_deactivate(struct kmem_cache *s)
+{
+	__kmemcg_cache_deactivate(s);
 
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		return;
@@ -750,8 +742,9 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	/* pin memcg so that @s doesn't get destroyed in the middle */
 	css_get(&s->memcg_params.memcg->css);
 
-	s->memcg_params.deact_fn = deact_fn;
-	call_rcu(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
+	WARN_ON_ONCE(s->memcg_params.work_fn);
+	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
+	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
 }
 
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
@@ -773,7 +766,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		if (!c)
 			continue;
 
-		__kmemcg_cache_deactivate(c);
+		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
@@ -866,11 +859,12 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
 	mutex_unlock(&slab_mutex);
 
 	/*
-	 * SLUB deactivates the kmem_caches through call_rcu. Make
+	 * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
 	 * sure all registered rcu callbacks have been invoked.
 	 */
-	if (IS_ENABLED(CONFIG_SLUB))
-		rcu_barrier();
+#ifndef CONFIG_SLOB
+	rcu_barrier();
+#endif
 
 	/*
 	 * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
diff --git a/mm/slub.c b/mm/slub.c
index 2b9244529d76..195f61785c7d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4033,7 +4033,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 }
 
 #ifdef CONFIG_MEMCG
-static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
+void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
 {
 	/*
 	 * Called with all the locks held after a sched RCU grace period.
@@ -4059,12 +4059,6 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
 	 */
 	slub_set_cpu_partial(s, 0);
 	s->min_partial = 0;
-
-	/*
-	 * s->cpu_partial is checked locklessly (see put_cpu_partial), so
-	 * we have to make sure the change is visible before shrinking.
-	 */
-	slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
 }
 #endif	/* CONFIG_MEMCG */
 
-- 
2.20.1

