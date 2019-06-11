Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB1F3C31E47
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 890D42177E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Vy9ofn/a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 890D42177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21296B0276; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D82576B0273; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAF9D6B0275; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E296B0273
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l4so10660049pff.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=4a5S038n6rmjsorMyNQnK5HbJ3nnI0HE3O8xMf4e+Mg=;
        b=Rhszao5aL+aHzvKz067UVBS0GjZYnGREXYV8bQ2wfwcE/WIJdVYywfbOwBd4qsJuBe
         3CQzfiJOuGe7REOmi17N5Pk5hg/giO8ZzbMq0ED1uwseZTOJxPLlHH0u3ei3J7+Cunpb
         fPAntSQjAt55fYYQfumM62rFewPlvxNT8Lotij40wNgwikuOwnZZu8CM6hvaC7xaCFz2
         bofYfcxfByZt3//NSt9j7/o6XAwPanoR58wP9vKO5KLPZ+hy35VL3HxlfzFfPN59tJDd
         vP17Dyg5ecPX87+AM3ILx9wBwBMjD3yC1Oqlz2+wlBYXN3P2jPQhE8kwNdleq3PRVzyD
         4HWg==
X-Gm-Message-State: APjAAAVpdTjknZkb+CB1jP13nqAs8aY6myJWvlPGloS9Cv9m27rA0WYk
	i6LiKjY45UDbbxOJvJsoXnFc0OkEbP3/AxhlimhcDyQY1d0gkKu0QfdjOz0+GRpkHTDuvBcJBb+
	q9plYvudATuqcdC/tAzVAwxGoBhmjQMrlfsrqAHbku5BBhti62YWjqbChEAUTWqfOjg==
X-Received: by 2002:a17:902:934b:: with SMTP id g11mr66021972plp.245.1560295115115;
        Tue, 11 Jun 2019 16:18:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw91mnuV5frHUcISfPtOOfB6cB1W21YUrTCZlvXo/zc/bXyT6BEjyQgPpZmJsMJFpXFDXBC
X-Received: by 2002:a17:902:934b:: with SMTP id g11mr66021919plp.245.1560295114237;
        Tue, 11 Jun 2019 16:18:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295114; cv=none;
        d=google.com; s=arc-20160816;
        b=CHiXHgqm/238PJUkpfZzCeNbhdyWx5bjw85iwrXG7/aQ9ZN2GLObmTN06REGk41EG8
         hCh9dN3rcxPpP3zJV+V3EqAcdnd295oqPmfOFvZS+yL8oyt3GQ4tkROIEBTwaCuOPxOX
         Eg4p/w1xBRGm2jt/gYMXYDnMRYpJ5Qhm44aVqc2VL+AHq7GkXmBdc1l2Aaw1OOjny2MZ
         Yn2Plk5/R1KJWRGSjW4JEa1DVPWINO2qaPdfanO2EjwKiOLlFbck0hDNeVNHLC9wI9Lm
         Ocy/3cRmyT8uffKtOFlh3dVQUUMnl5NwnuFtno5w449NmK5P/uWq2TDfPNBdCEv3R95s
         ggag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=4a5S038n6rmjsorMyNQnK5HbJ3nnI0HE3O8xMf4e+Mg=;
        b=pSCkxRGNL9dAjb6Z2fdUSdPdLdtZiT2MDBI0ya4rgcBMItmbmifvRtUaS/VvtOCdhL
         ARo2S+mAvZuDO3tBUyetO4HS77to1FLn0lO8Bf4/2df2f/wrSnWbo2K0n6M07bOM295r
         OlcLGGgRQpWvphwAZa4ple4041fCDHLv6atnOO0jXGdOLhWn7Yms5mt4u3vK1J4vY9Jl
         x6Cbs3pZeKW4SsYfsyXCRmKgS68kgX6GobG9eKmYiE5wXFO4YF/wQg1OaVATTZlAO6QE
         gJMDfwrxHU/s05viU7hzCeFzxtMEep0soEcQXD8r65inelR/vnVzUUXpKhRVpEQ9dcHL
         0XsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Vy9ofn/a";
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v20si13859752pgk.58.2019.06.11.16.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Vy9ofn/a";
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BN9aF8031322
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=4a5S038n6rmjsorMyNQnK5HbJ3nnI0HE3O8xMf4e+Mg=;
 b=Vy9ofn/ahsuhhMv8Ehj9mot6wdzLhc9P9NBL7Qw9JOQoLAMg0ZqAPLjubeQNvHRDEn9s
 k8w6jVD/XV9NkNTAjp/eZQwWq+uaQGKLF7zdnc3oVoZYQgqlxziwSL1WLK+67XQLdMh0
 p5WXCS6kOSg8obpLnSTnX146VAaocR4Pz3Y= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t2ha1926c-9
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:33 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 11 Jun 2019 16:18:22 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 4EAFF130CBF79; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>, Waiman Long <longman@redhat.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v7 10/10] mm: reparent memcg kmem_caches on cgroup removal
Date: Tue, 11 Jun 2019 16:18:13 -0700
Message-ID: <20190611231813.3148843-11-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190611231813.3148843-1-guro@fb.com>
References: <20190611231813.3148843-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's reparent non-root kmem_caches on memcg offlining. This allows us
to release the memory cgroup without waiting for the last outstanding
kernel object (e.g. dentry used by another application).

Since the parent cgroup is already charged, everything we need to do
is to splice the list of kmem_caches to the parent's kmem_caches list,
swap the memcg pointer, drop the css refcounter for each kmem_cache
and adjust the parent's css refcounter.

Please, note that kmem_cache->memcg_params.memcg isn't a stable
pointer anymore. It's safe to read it under rcu_read_lock(),
cgroup_mutex held, or any other way that protects the memory cgroup
from being released.

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
 include/linux/slab.h |  2 +-
 mm/memcontrol.c      | 14 ++++++++------
 mm/slab.h            | 26 ++++++++++++++++++++------
 mm/slab_common.c     | 19 +++++++++++++++++--
 4 files changed, 46 insertions(+), 15 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1b54e5f83342..fecf40b7be69 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -152,7 +152,7 @@ void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 
 void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
-void memcg_deactivate_kmem_caches(struct mem_cgroup *);
+void memcg_deactivate_kmem_caches(struct mem_cgroup *, struct mem_cgroup *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25e72779fd33..db46a9dc37ab 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3289,15 +3289,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
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
@@ -3330,7 +3330,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4777,6 +4776,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 7ead47cb9338..a4c9b9d042de 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -261,6 +261,9 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
  * which do not have slab_cache pointer set.
  * So this function assumes that the page can pass PageHead() and PageSlab()
  * checks.
+ *
+ * The kmem_cache can be reparented asynchronously. The caller must ensure
+ * the memcg lifetime, e.g. by taking rcu_read_lock() or cgroup_mutex.
  */
 static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
 {
@@ -268,7 +271,7 @@ static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
 
 	s = READ_ONCE(page->slab_cache);
 	if (s && !is_root_cache(s))
-		return s->memcg_params.memcg;
+		return READ_ONCE(s->memcg_params.memcg);
 
 	return NULL;
 }
@@ -285,10 +288,18 @@ static __always_inline int memcg_charge_slab(struct page *page,
 	struct lruvec *lruvec;
 	int ret;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = READ_ONCE(s->memcg_params.memcg);
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
@@ -296,8 +307,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
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
@@ -310,10 +322,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
-	memcg = s->memcg_params.memcg;
+	rcu_read_lock();
+	memcg = READ_ONCE(s->memcg_params.memcg);
 	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
 	memcg_kmem_uncharge_memcg(page, order, memcg);
+	rcu_read_unlock();
 
 	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6b7750f7ea33..91e8c739dc97 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -252,7 +252,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
-		css_put(&s->memcg_params.memcg->css);
+		mem_cgroup_put(s->memcg_params.memcg);
+		WRITE_ONCE(s->memcg_params.memcg, NULL);
 	}
 }
 #else
@@ -790,11 +791,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
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
 
@@ -812,6 +815,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 		kmemcg_cache_deactivate(c);
 		arr->entries[idx] = NULL;
 	}
+	nr_reparented = 0;
+	list_for_each_entry(s, &memcg->kmem_caches,
+			    memcg_params.kmem_caches_node) {
+		WRITE_ONCE(s->memcg_params.memcg, parent);
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
2.21.0

