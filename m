Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43C47C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE79020851
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="B02auHbM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE79020851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B9006B0277; Tue,  4 Jun 2019 22:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86B3E6B0278; Tue,  4 Jun 2019 22:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 758EF6B0279; Tue,  4 Jun 2019 22:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F08D6B0277
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:11 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id w127so21464950ywe.6
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=0SHoOhFKuZcfsmJPpk99bY607h8QTF2wVdFhMuuvmaA=;
        b=NRn496YzqaL3o3JMBP81+6v4lh66wgieR/Oi96w+K92UUuNDBgPOMGYFCzLjbciyoW
         8aHzwEX75KXh1udVVAfou3P/lj1RaV6YQ3n0rF3sJjPBOdw6ttyZfiodQOg2qtAF1Z+J
         2tHjOrqRG8epq+Kn0+Xgehcr38dDJIL5nzLUB9zn9WsvW1xB7iuG2c58HTKPORNudnx8
         Dl1v6cg7BD/G9JUUyKumm/wxsh/zn9PpKpCxUGckuwgtwvx1LpUFxKTkET5yBNgzsm27
         qSmoCgpF+m+xvs6EFmIFKOTwG6+UNYiWD/x+MDszxjCRxW0DDF2YX+OmLSVIkEaNlHwV
         zeyQ==
X-Gm-Message-State: APjAAAVl8CwcvGKKUzNHzbhIZOzjyoqAmX6JGCWgH46v22/ZiyZNA0ug
	I88Qf0wZoVIhWeumLmXmiQTkDIsYW0gXtuLz8Nd6NZORBTihu8eVQFXbrMDGgl1WSyYeelLGe0W
	b/Bq2NP7mZl/xDB85oT0CYpqIjNRHqGQxVZDE62HiJNuW9kpm3sLtqp1SiqmI1dn+QQ==
X-Received: by 2002:a25:d4c5:: with SMTP id m188mr15712586ybf.60.1559702711063;
        Tue, 04 Jun 2019 19:45:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz1VrMTnwbJD/1P0t96s+BPKobgvIgoDC2EtaLmLw6JZfN4ZEneI+XQfo7gYPYGJ9joJp1
X-Received: by 2002:a25:d4c5:: with SMTP id m188mr15712545ybf.60.1559702710041;
        Tue, 04 Jun 2019 19:45:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702710; cv=none;
        d=google.com; s=arc-20160816;
        b=VSHFjwyM9/6KQLuBVEW/Gqo7gGurySZURN0u03ny4TSMuHr67EOR5OqlByb+tzaiOv
         4YOGltjK7S5ukHMnsHgX/ExUQ0p37YnIGu0djGjFSlOZNaWVeKTxL2nSlFFOy+1Ev7Q3
         46S2kVKZMTq3IF97yT+WHO61WsarU/vPnMhuaXT1ry0RCBPsHegKQGyCzMbfarPfqZ2Z
         5aolIJqjxdwQj1pWDgw0dtshOosLlJG3fOWPr4VHdPrxtoFQAsQscTkSG8sKtzFZDPrF
         afYdwFSq839RwdW3WbV1wMduq+rlPAAX7ApO0Ddapx8dOUM7qqtGgUx7o6lVkwxmOpJp
         T2YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=0SHoOhFKuZcfsmJPpk99bY607h8QTF2wVdFhMuuvmaA=;
        b=RTIvnFj6nyrGFq4gGvUWJkjSbpEhdRngD/qOqbxkw9OuXhv2rY0hTAqPg9psQ1MQKe
         ws24fg57F2bGTWzP/bEMR9dGvrFF2utlFttYzMA1Vqt//sa2hKQPlnQhpd8la05l26vn
         RB0MNgOTCnHofTYOH53UgFsuA+W6vXD9vRpG4dTiUmF4ZSQVMKV8IafcuHhWsS9BSNmN
         qbQzyMViSQkqWdTUI6u7PzfbQx1SBz/xMQzOe7SlQ+oEwrgjaFsovVXqtSKjP2GIOlXV
         gwzgHqINxe0h0rB2eR5bipMlGT0Hlx/aO80dzbfpAZe7KlWihzy+HVqotXwwy/bSsrdo
         ESjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=B02auHbM;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g185si1244688ywa.288.2019.06.04.19.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=B02auHbM;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552gIO8010888
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=0SHoOhFKuZcfsmJPpk99bY607h8QTF2wVdFhMuuvmaA=;
 b=B02auHbMGsowHj38Qm/IrhmwYpylRytVXJfuYYIB91fIK2dMBX9909eUYyEbzVKeDIzC
 Vy6cIv4IjBwS2DveCpUnjIS2iNrjz+t2TIJPO1Tol5Yzr/b9YK7hXFbQ9ibkyKwG8igm
 2TLMUF9dPEzcaBnQxf2MA19BrdAZaL1u3FQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2swxuq161e-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:09 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:45:00 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 9C91612C7FDD4; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v6 10/10] mm: reparent slab memory on cgroup removal
Date: Tue, 4 Jun 2019 19:44:54 -0700
Message-ID: <20190605024454.1393507-11-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190605024454.1393507-1-guro@fb.com>
References: <20190605024454.1393507-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's reparent memcg slab memory on memcg offlining. This allows us
to release the memory cgroup without waiting for the last outstanding
kernel object (e.g. dentry used by another application).

So instead of reparenting all accounted slab pages, let's do reparent
a relatively small amount of kmem_caches. Reparenting is performed as
a part of the deactivation process.

Since the parent cgroup is already charged, everything we need to do
is to splice the list of kmem_caches to the parent's kmem_caches list,
swap the memcg pointer and drop the css refcounter for each kmem_cache
and adjust the parent's css refcounter. Quite simple.

Please, note that kmem_cache->memcg_params.memcg isn't a stable
pointer anymore. It's safe to read it under rcu_read_lock() or
with slab_mutex held.

We can race with the slab allocation and deallocation paths. It's not
a big problem: parent's charge and slab global stats are always
correct, and we don't care anymore about the child usage and global
stats. The child cgroup is already offline, so we don't use or show it
anywhere.

Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
aren't used anywhere except count_shadow_nodes(). But even there it
won't break anything: after reparenting "nodes" will be 0 on child
level (because we're already reparenting shrinker lists), and on
parent level page stats always were 0, and this patch won't change
anything.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h |  4 ++--
 mm/list_lru.c        |  8 +++++++-
 mm/memcontrol.c      | 14 ++++++++------
 mm/slab.h            | 23 +++++++++++++++++------
 mm/slab_common.c     | 22 +++++++++++++++++++---
 5 files changed, 53 insertions(+), 18 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1b54e5f83342..109cab2ad9b4 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -152,7 +152,7 @@ void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
-void memcg_deactivate_kmem_caches(struct mem_cgroup *);
+void memcg_deactivate_kmem_caches(struct mem_cgroup *, struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -638,7 +638,7 @@ struct memcg_cache_params {
 			bool dying;
 		};
 		struct {
-			struct mem_cgroup *memcg;
+			struct mem_cgroup __rcu *memcg;
 			struct list_head children_node;
 			struct list_head kmem_caches_node;
 			struct percpu_ref refcnt;
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0f1f6b06b7f3..0b2319897e86 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -77,11 +77,15 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr,
 	if (!nlru->memcg_lrus)
 		goto out;
 
+	rcu_read_lock();
 	memcg = mem_cgroup_from_kmem(ptr);
-	if (!memcg)
+	if (!memcg) {
+		rcu_read_unlock();
 		goto out;
+	}
 
 	l = list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
+	rcu_read_unlock();
 out:
 	if (memcg_ptr)
 		*memcg_ptr = memcg;
@@ -131,12 +135,14 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 
 	spin_lock(&nlru->lock);
 	if (list_empty(item)) {
+		rcu_read_lock();
 		l = list_lru_from_kmem(nlru, item, &memcg);
 		list_add_tail(item, &l->list);
 		/* Set shrinker bit if the first element was added */
 		if (!l->nr_items++)
 			memcg_set_shrinker_bit(memcg, nid,
 					       lru_shrinker_id(lru));
+		rcu_read_unlock();
 		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
 		return true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c097b1fc74ec..0f64a2c06803 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3209,15 +3209,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 	 */
 	memcg->kmem_state = KMEM_ALLOCATED;
 
-	memcg_deactivate_kmem_caches(memcg);
-
-	kmemcg_id = memcg->kmemcg_id;
-	BUG_ON(kmemcg_id < 0);
-
 	parent = parent_mem_cgroup(memcg);
 	if (!parent)
 		parent = root_mem_cgroup;
 
+	memcg_deactivate_kmem_caches(memcg, parent);
+
+	kmemcg_id = memcg->kmemcg_id;
+	BUG_ON(kmemcg_id < 0);
+
 	/*
 	 * Change kmemcg_id of this cgroup and all its descendants to the
 	 * parent's id, and then move all entries from this cgroup's list_lrus
@@ -3250,7 +3250,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4675,6 +4674,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 7ead47cb9338..34bf92382ecd 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -268,7 +268,7 @@ static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
 
 	s = READ_ONCE(page->slab_cache);
 	if (s && !is_root_cache(s))
-		return s->memcg_params.memcg;
+		return rcu_dereference(s->memcg_params.memcg);
 
 	return NULL;
 }
@@ -285,10 +285,18 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	struct lruvec *lruvec;
 	int ret;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = rcu_dereference(s->memcg_params.memcg);
+	while (memcg && !css_tryget_online(&memcg->css))
+		memcg = parent_mem_cgroup(memcg);
+	rcu_read_unlock();
+
+	if (unlikely(!memcg))
+		return true;
+
 	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	if (ret)
-		return ret;
+		goto out;
 
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
@@ -296,8 +304,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	/* transer try_charge() page references to kmem_cache */
 	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
 	css_put_many(&memcg->css, 1 << order);
-
-	return 0;
+out:
+	css_put(&memcg->css);
+	return ret;
 }
 
 /*
@@ -310,10 +319,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = rcu_dereference(s->memcg_params.memcg);
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
 	memcg_kmem_uncharge_memcg(page, order, memcg);
+	rcu_read_unlock();
 
 	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8255283025e3..00b380f5d467 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -237,7 +237,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
 		css_get(&memcg->css);
-		s->memcg_params.memcg = memcg;
+		rcu_assign_pointer(s->memcg_params.memcg, memcg);
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
 		list_add(&s->memcg_params.kmem_caches_node,
@@ -252,7 +252,9 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
-		css_put(&s->memcg_params.memcg->css);
+		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
+			lockdep_is_held(&slab_mutex)));
+		rcu_assign_pointer(s->memcg_params.memcg, NULL);
 	}
 }
 #else
@@ -793,11 +795,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	spin_unlock_irq(&memcg_kmem_wq_lock);
 }
 
-void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
+void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg,
+				  struct mem_cgroup *parent)
 {
 	int idx;
 	struct memcg_cache_array *arr;
 	struct kmem_cache *s, *c;
+	unsigned int nr_reparented;
 
 	idx = memcg_cache_id(memcg);
 
@@ -815,6 +819,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
+	nr_reparented = 0;
+	list_for_each_entry(s, &memcg->kmem_caches,
+			    memcg_params.kmem_caches_node) {
+		rcu_assign_pointer(s->memcg_params.memcg, parent);
+		css_put(&memcg->css);
+		nr_reparented++;
+	}
+	if (nr_reparented) {
+		list_splice_init(&memcg->kmem_caches,
+				 &parent->kmem_caches);
+		css_get_many(&parent->css, nr_reparented);
+	}
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
-- 
2.20.1

