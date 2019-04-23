Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B203C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B91820674
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 04:59:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DfRDcwz9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B91820674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 464F96B000A; Wed, 24 Apr 2019 00:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 414336B000C; Wed, 24 Apr 2019 00:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DD2A6B000D; Wed, 24 Apr 2019 00:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 048B56B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:59:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id o17so1825728ywd.22
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=VEdpMvj5kP5nuI6Ztt7mzIbqR1F5iJNOXyr/8yu0PUA=;
        b=FcFiQX+uAZgmAQIW6sdoD13yXpSTl3Gs/1kVAkgK2lxtpvbkUjcFF790d9q8REXSxX
         d508PDc1lqZDSvcsEfXRiYd8Q58hCZkyhRvlEvgRjK0gWbbE9liChp2UR4tkPW5HPIFX
         2RgmJeFbbbuXao4wIcPH9P5bf5zFX/9UrFJWStQzFHMtggIVEmMVxvzanpS9vdSWqQhM
         HS9a7tuOXIC7jXOQMGac8q+z545zrEm22THOgAs3Wrm7i5f1CoV2/o1ImvsOPbzPiR0T
         MZz319YQOpw8aDpFNB3VetbDyfC99wqJMvfaL/mDsyspHCXtySGIXZQd1oq5iwDvjYXN
         JZ8A==
X-Gm-Message-State: APjAAAUfMYdZNid3euXV3b9jcrImf0REgUFxNCwHOXmBLK5gfuH3FKz3
	3Ckk3IunIBWOEhiQeQL5Q4xbHQV1yYBUHomEhZrA4e3DG+Bbs2NGl8egZ9MxA5/Pcj3ZY/PLjPs
	N7t5j1QTHqMbJajkPKvBa3/Mr1Y2amfQzPEM6RLEzgWWZvsxLLf3jR3ZHWijFxGc7vA==
X-Received: by 2002:a25:2a13:: with SMTP id q19mr23091754ybq.243.1556081981737;
        Tue, 23 Apr 2019 21:59:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3xGyLR2STh4KYTB52c1HNTyBkPH9NvXwe7QthwUXV9wMuNlc2+zanAR3lG6EBN6xMPrJ9
X-Received: by 2002:a25:2a13:: with SMTP id q19mr23091720ybq.243.1556081980929;
        Tue, 23 Apr 2019 21:59:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556081980; cv=none;
        d=google.com; s=arc-20160816;
        b=MmtFxFe7klt2H2QipGDh/dZOU6uTp8/wC21GUcpCMi9s43eZBlG+ZHPxr3jPtVNtlt
         Qli9ycgPhcaZmsbkb7tH3YaiVCMh6+LbylQiIiQIK0nUByFo1/BWgHT5W5KFQwa35q2m
         OwMy34Fxt6eNbNbn/lxynZyxCK+jmvYmftpISfKS8sD0k4tKmCPniBmGTh5IlXqfPecJ
         JUjyeDVyOcOqYzEQCqUiDhYwEckJYL3ZvqDt6de87YDl01K4biFgtqC8NpPW4Q9E33aG
         96k2DQ7mrQxZnOX7aG9dA5Zo6GhjYuZ922dMnUUPC26tkdKgX7BN/Ru6C2m9pylLjiIU
         X4bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=VEdpMvj5kP5nuI6Ztt7mzIbqR1F5iJNOXyr/8yu0PUA=;
        b=qwO6EkrL1xxtZugIF2YVLCIRNBNPQGPUg3RoyW9xceTG1rSpaNgJe8L73MgswkpuY1
         xWhSg5FVCJ20c0d1JVZqmywfFP763nJp7a32MqltNa20jsHqWGo3tSL+K6rs4nZJpA7O
         PTbscsCxz4Mz0RHb++7PWaoaQ9hKbwGimoX9V2K0dD2RQ9xF0Kn1cwm56TCxIzqaMzG5
         sOhmIyrpWvAEuGp52W8rsE4EIsb3NF87aYtNBTGErnSeDilflpf9dU+fpt0F/M3uae+C
         FT7JP2OzByav+9MTom8bAEpkIyf7bOOzZbi0YDjUtZk2JqrDz41urskt3av9peWnFx3Y
         AZmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DfRDcwz9;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g129si3597461ywb.266.2019.04.23.21.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 21:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DfRDcwz9;
       spf=pass (google.com: domain of prvs=90171118fe=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90171118fe=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x3O4xNBR031269
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:59:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=VEdpMvj5kP5nuI6Ztt7mzIbqR1F5iJNOXyr/8yu0PUA=;
 b=DfRDcwz9GNFsTOvKcjdYUIClLw2lmbenktFncRuI/FTa8XUZ6VyjEodtAqNCMQl29Bhy
 1DALn7surcj2kJNETxq0jo4Hn5+pQ8NquZhMWHyKLNswPeUbmqeulLzItHee2hTbDMAc
 zeVPjI2V9zlLEp1iFsjjb8L51n0Wi8QqcKY= 
Authentication-Results: fb.com;
	spf=pass smtp.mailfrom=guro@fb.com
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2s2du18m6d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 21:59:40 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 23 Apr 2019 21:59:39 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id D5B971142D2EA; Tue, 23 Apr 2019 14:31:36 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Shakeel Butt
	<shakeelb@google.com>, Christoph Lameter <cl@linux.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2 6/6] mm: reparent slab memory on cgroup removal
Date: Tue, 23 Apr 2019 14:31:33 -0700
Message-ID: <20190423213133.3551969-7-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423213133.3551969-1-guro@fb.com>
References: <20190423213133.3551969-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240042
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
 mm/memcontrol.c      | 14 ++++++++------
 mm/slab.h            | 14 +++++++++-----
 mm/slab_common.c     | 23 ++++++++++++++++++++---
 4 files changed, 39 insertions(+), 16 deletions(-)

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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c9896105d8d5..27ae253922da 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3201,15 +3201,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
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
@@ -3242,7 +3242,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4654,6 +4653,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 61110b3035e7..68c5fc6e557e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -289,10 +289,11 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	struct lruvec *lruvec;
 	int ret;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = rcu_dereference(s->memcg_params.memcg);
 	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	if (ret)
-		return ret;
+		goto out;
 
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
@@ -300,8 +301,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	/* transer try_charge() page references to kmem_cache */
 	percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
 	css_put_many(&memcg->css, 1 << order);
-
-	return 0;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
@@ -310,10 +312,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
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
index 995920222127..36673a43ed31 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -236,7 +236,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
 		list_add(&s->root_caches_node, &slab_root_caches);
 	} else {
 		css_get(&memcg->css);
-		s->memcg_params.memcg = memcg;
+		rcu_assign_pointer(s->memcg_params.memcg, memcg);
 		list_add(&s->memcg_params.children_node,
 			 &s->memcg_params.root_cache->memcg_params.children);
 		list_add(&s->memcg_params.kmem_caches_node,
@@ -251,7 +251,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
-		css_put(&s->memcg_params.memcg->css);
+		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
+			lockdep_is_held(&slab_mutex)));
 	}
 }
 #else
@@ -772,11 +773,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
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
 
@@ -794,6 +797,20 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
+	if (memcg != parent) {
+		nr_reparented = 0;
+		list_for_each_entry(s, &memcg->kmem_caches,
+				    memcg_params.kmem_caches_node) {
+			rcu_assign_pointer(s->memcg_params.memcg, parent);
+			css_put(&memcg->css);
+			nr_reparented++;
+		}
+		if (nr_reparented) {
+			list_splice_init(&memcg->kmem_caches,
+					 &parent->kmem_caches);
+			css_get_many(&parent->css, nr_reparented);
+		}
+	}
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
-- 
2.20.1

