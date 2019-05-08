Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 057D9C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D78D2173C
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="haKVMOqt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D78D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28B226B0007; Wed,  8 May 2019 16:40:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EB876B000A; Wed,  8 May 2019 16:40:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D9FB6B000C; Wed,  8 May 2019 16:40:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5E746B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:40:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 17so13368374pfi.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LxIDu3UhYtNg1pn5UcXrVPh/HFhtDW9+IlbLZXygBUg=;
        b=bb/VlUe9K1JRKa27TfQWiWNU4G59ukuu55Am9Y3By9z/KQJ1rg1u1rzUXbHP3rYiXC
         R51P61RNTmweNcYebhpnOMlgS9/Q9CkEuGy76204bhcCDvviwUIv2X7TKn8JWqLyUNPF
         d4ny223hrzFI78vmOv5+ywvmSwOYnXw2gNG6VtUhTDSzr4MPQaajcjhQKCSo5Lps9PKH
         WIOf6HC1Sh6ItX9rsZ4JqYEwtJz9eOYj50Tr5craK7vdiU3n0XgYttMqmVM5ecOoPO6r
         i20byA+e+OcXAIbvSn0rK5ieEPS1xJU8qn7ay+roSlRHmV7H/a61ZCr48XiJ52eNI9b/
         tIUg==
X-Gm-Message-State: APjAAAWRdMjd1wJvahsmBDR9QCblYh165eZBLbi9ObWMIGlfMaRgl+Pk
	dAxb+KfE212dI28ELiLMtr0TkFndP34beEaWaHwIHKRwG8qVw58+vaVcT4PjDmAGRc2IJ+As4uL
	dMR/lTeIZHxv00OtArNeutFOVdz3fAKpyNeAc021pFs0gMv4MR+//SmLs5H27nnRWkQ==
X-Received: by 2002:a65:4183:: with SMTP id a3mr180561pgq.121.1557348051445;
        Wed, 08 May 2019 13:40:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznDAX6v6Ih1S0/DqNVw8MEyljOeRhRd46LGx2QikqgRubO4pbFQX6O3uV+uVzdtAurOw2U
X-Received: by 2002:a65:4183:: with SMTP id a3mr180482pgq.121.1557348050547;
        Wed, 08 May 2019 13:40:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557348050; cv=none;
        d=google.com; s=arc-20160816;
        b=YOO28x+Mc/foDkoXXMeFaQ984jiWBy4b1hVsl9GeImLnAVWr0XCRDVEVeZ6E/bjVik
         29lClmQCABSc1SJH4ZxeqEQHkddWfw2GYM1WxqW5UAIrcEsb/hUkBWbxVck2gmBP+8qp
         ICUvCqQ1iFBxvUx7BxYe8pFwwleisR/uHCFZ6wJccMBscxVYsEtn+v6IY1Gp1FFyiugC
         4VRXf8UtGfWQoHHHK0ugzfKVT36I39+vH3WHiXFtSR/9Due4T4YOBnN3Y9Sqp5suGlf+
         osNCSg9xnNnn708/ijD72XCDY7RpM/h+AqmrPV79GEV3nduDB4M2ou30jEsW3Auw9uHU
         /g0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LxIDu3UhYtNg1pn5UcXrVPh/HFhtDW9+IlbLZXygBUg=;
        b=TS6Bh1A4Q/T5M+wzyBUoa5PLmeKO+3vliLiREHdYt9XHM3gUOjILsbHM02zJTulkYK
         FW3pv3cDjqKYm5p8njDiThgwrofzeqLWPcSwWty13JbLaRdbwWayCe1cMv6Pbx4YfnQO
         K6JzXZU51qAoS+DndbEdioiIkr1ZY2UH5d7xApkhBlhGlphOiO2Hhy1kGPOebNjWohQx
         xSrqa6R6sGVx+ROb+wGX1g9qhRGQab7NHB/sWZiOurWN8aH9gu4+IFQUXhR5SHIoiR/0
         cDdJGdvHlISuP0AeEEdNfDseIjFrVz2zZXOZVZXfIA21r0LhXgBszHKZdgaBNOKff2RP
         3OBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=haKVMOqt;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v21si9826311pgb.560.2019.05.08.13.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:40:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=haKVMOqt;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KeVE7023320
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:40:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LxIDu3UhYtNg1pn5UcXrVPh/HFhtDW9+IlbLZXygBUg=;
 b=haKVMOqtENtB2naPd2I/8wNLXd8v7C/VNmMn/GDfmaPUEDmhBJpVnKreS5QCc8kjaXjP
 o8xbw2CCqAFXzMv/tbUKWEesVYHXn4iXR2HW1KrH8iin8xdr+4UtnxKbIcSdnT/Zy0Mq
 zGk1hL/cezUfH0h8qWHljiOJyzZlYIPEzTs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc0p91d9f-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:40:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 1895F11CDBD02; Wed,  8 May 2019 13:25:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 6/7] mm: reparent slab memory on cgroup removal
Date: Wed, 8 May 2019 13:24:57 -0700
Message-ID: <20190508202458.550808-7-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
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
index 9b27988c8969..6e4d9ed16069 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3220,15 +3220,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
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
@@ -3261,7 +3261,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4673,6 +4672,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 2acc68a7e0a0..acdc1810639d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -264,10 +264,11 @@ static __always_inline int memcg_charge_slab(struct page *page,
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
@@ -275,8 +276,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
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
@@ -285,10 +287,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
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

