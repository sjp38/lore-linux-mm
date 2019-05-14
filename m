Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1E53C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A026B20873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:54:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="CtR8Hj6b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A026B20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38EB36B0005; Tue, 14 May 2019 17:54:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 318AF6B0006; Tue, 14 May 2019 17:54:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B8FC6B0007; Tue, 14 May 2019 17:54:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E84CC6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:54:57 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id i125so640100ywf.5
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=FtShZ2vB5fpsbZrZXegXCPM4YGPbu5mSBxgUC0FaF14=;
        b=SiwY5yBk8mSePd7PXtCqcvf6UHY063rzVlPNFHZ6aWcDMntg5yi1W7lFlwc+zyqgA8
         Ulwc6AWnTZ+ULD9iY+9taY2rlKVMvBj68i2OzK3rxbrGbEIm+sdF3hZGWVs2z6m9JKBX
         96KSbnoDaVfSLIGHwhL0UG+4X+A+moK/ChWryrcjppXzVImH0B61O8HCWvfoiikGBpc1
         35ryqHZbToK6U6XsVzxEQZQyaK1sykeXgRam43/vT6oGfTjLfLc0BiIngsqmZeKtcanS
         VZ7hCVeIlq/HOGV7kIzhiAFFtSj1rXKq+sDQOO4ZxSszb5x/EKVfRqQeuViI8omwimQa
         3/PQ==
X-Gm-Message-State: APjAAAXkdvw3V78viE6tKpQJ6gT4kuDENrhHPC9YBHt/APEFKGrlCefa
	BRRzA3XJ2XGHQSguWyE3Hj/sJ1xxDpGp7phmpFBGafmA5bM2lb2cL4svofj94lGkGCdQhsunVwm
	opLpK7yEgNdufxTttRHX4KVk2/do8UOqBDuC68dJVRGW89YLRZTPfjSxGLRj7JX7J3w==
X-Received: by 2002:a81:6cd2:: with SMTP id h201mr17958452ywc.484.1557870897692;
        Tue, 14 May 2019 14:54:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxF1n37Auw6LMvewHx+O1vktLxDhTghdFRjyUv6ZGc29P0JHAYQoCyQN3pKf6B90kc3anc2
X-Received: by 2002:a81:6cd2:: with SMTP id h201mr17958434ywc.484.1557870896869;
        Tue, 14 May 2019 14:54:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557870896; cv=none;
        d=google.com; s=arc-20160816;
        b=oibxGsfQ82UmV/p5R7WJJNuEvmfvOX75aDpEXHdw7LGEVWHx1QGMwJJQAc0POFwrWU
         W7ar6ZN4JprgvSLn8kz9Nz9kxrJ2542C/ubhua3GvuhS4Zr57Ntjcua5xrToV8hWHxap
         AmoatpgaS+YNWABGOIwJyvgsYOxgm2u/iigFTXMPUYpT6RJUhh0crpZor/yEXkJVd52+
         eyd8SJqWZ8maDnsnr4Xd7ZPsToU7mXlZ3Mxhh6IlkJ26K7s+4ZvFH40WoE0MkCamjZP7
         XQoRvblyKpEikh2aRpMC17+Lt6j/XIZ6GyZwftiUiDnOACINHaf9LZm9dPLhcZ/SZwTs
         jk5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=FtShZ2vB5fpsbZrZXegXCPM4YGPbu5mSBxgUC0FaF14=;
        b=eGNoZoHQy4anZyyN5HuY16TWebz6wd6prnjk5iFnKM1QSkMF/hFsNueLs/hJNfRF8Z
         /dcx5aUX6HAYQq368j8MEv39n0BvDTxUNDjomJzIHCB5HQ4sGcT8EUPos8ZoB83vb4k8
         Z1g+lkP6MZELoVZlAg6+UIZLOReIzuRmgpu0un+nCbnfisOICy+F0dS+GGBQ7DHoaCz7
         7bnkELq3nodbAP6HaDXfkTCtzaaqjLLe8fHC2rjCPHKvtihmU1sEyNlxpJN9svzU3pbA
         v/kPPAmq9Da5c1KTJvDKpvCvoqeJIT8nNMGiVeAqlfMhb1HMkQcJ7ozx8fI0vHNuBREV
         ZCKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CtR8Hj6b;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p70si5361590yba.232.2019.05.14.14.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:54:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CtR8Hj6b;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ELsD5r030310
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=FtShZ2vB5fpsbZrZXegXCPM4YGPbu5mSBxgUC0FaF14=;
 b=CtR8Hj6bWSgHnbETcMmphwyKWmZcyyxBu3VK/goj8IyuCRIk/0F3KCTuRPvjSTvlSFYe
 BLkttXobyzZ30JrGl8rXOvLsHngjFLqBFk9qIY/SDLiH9uIG53aVaGDtk8MUi2n+CsJi
 kAxoX8ydsvNyQgtxW/etx+lZZIyNeUq80/w= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg0pkhat8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:54:56 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 14 May 2019 14:54:55 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 8BE24120772AE; Tue, 14 May 2019 14:39:41 -0700 (PDT)
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
Subject: [PATCH v4 6/7] mm: reparent slab memory on cgroup removal
Date: Tue, 14 May 2019 14:39:39 -0700
Message-ID: <20190514213940.2405198-7-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514213940.2405198-1-guro@fb.com>
References: <20190514213940.2405198-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
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
 mm/slab.h            | 21 ++++++++++++++++-----
 mm/slab_common.c     | 21 ++++++++++++++++++---
 4 files changed, 44 insertions(+), 16 deletions(-)

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
index 413cef3d8369..0655639433ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3224,15 +3224,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
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
@@ -3265,7 +3265,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	if (memcg->kmem_state == KMEM_ALLOCATED) {
 		WARN_ON(!list_empty(&memcg->kmem_caches));
 		static_branch_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
 #else
@@ -4677,6 +4676,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	/* The following stuff does not apply to the root */
 	if (!parent) {
+#ifdef CONFIG_MEMCG_KMEM
+		INIT_LIST_HEAD(&memcg->kmem_caches);
+#endif
 		root_mem_cgroup = memcg;
 		return &memcg->css;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index b86744c58702..7ba50e526d82 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -268,10 +268,18 @@ static __always_inline int memcg_charge_slab(struct page *page,
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
@@ -279,8 +287,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
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
@@ -293,10 +302,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
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
index 1ee967b4805e..354762394162 100644
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
@@ -252,7 +252,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 	} else {
 		list_del(&s->memcg_params.children_node);
 		list_del(&s->memcg_params.kmem_caches_node);
-		css_put(&s->memcg_params.memcg->css);
+		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
+			lockdep_is_held(&slab_mutex)));
 	}
 }
 #else
@@ -776,11 +777,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
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
 
@@ -798,6 +801,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
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

