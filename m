Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A63DC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:08:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE5D121849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE5D121849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826766B000A; Thu, 18 Jul 2019 14:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D7A98E0003; Thu, 18 Jul 2019 14:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C64B8E0001; Thu, 18 Jul 2019 14:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0AB6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:08:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z13so23912160qka.15
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:08:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=no5wYvyxtwLKrLRq0CbAjnkls1x3ROD3k3GES6y29rI=;
        b=ewrttDaZebMF1qjcMdg2Owvl/wQhrKiroOekiAqaKyvWdY3+zu7VHb08jGDna4bxDJ
         gypwoSlF91y0imkNeqn8u8uXoNhcQstXDUupmoHRJZKv95y6sFN8L5PpCT2gBk9hNmhc
         8QFv4H0C8PCk5Q8iO2lxu5UZNrbTakRobAROCpoxE10pHau5C2h970OmC8p6WwYNgyFk
         /K3ckIEKgWIjooY+6GtiLk9+RFW1NGKW8Ik//rB4UCseMjv9zntrRRrq3xkrHl3bsP/6
         WUll7ReDg5Wm9bHQAsmXP/I/NSwLLNlchpE53m8dn3tvbX/ooXRTLLiytimzyexMxNlc
         dCew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpEO41a4DxgikI0VHdq1x5YtNQiKrTjBct3wjuilqXioM3Zc9X
	9hUKXh9lCqlOUnqpi/ufK8OQMqVE3CJjBIXNn+WNBhyDB9P2iLKs/kXI2iDhamrSyKERQgIeWzr
	CNwIjz72Iz8gQUmD++Fd0/3G+xvJXa0jTyTcJUwC9LzAO8nelmfitpjzO541IJQ6qog==
X-Received: by 2002:a37:6650:: with SMTP id a77mr32862569qkc.452.1563473318082;
        Thu, 18 Jul 2019 11:08:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi9GzxVVzYQ4bzeHi1JLIWnL0XQ/1vX85ZkJLvqH5FXTVroF/N5IZ3tV0meuijnPuq6XEv
X-Received: by 2002:a37:6650:: with SMTP id a77mr32862505qkc.452.1563473317294;
        Thu, 18 Jul 2019 11:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563473317; cv=none;
        d=google.com; s=arc-20160816;
        b=eQRB6hTBhjTH9xAFJH9UgWE7e4QY1iGeth9ZpdLAXiY92Fmf/2Szr2UiP+0IGh4Tr5
         jeLsykIRt/uvELVr8M1XluBNN6VKDy3475y+jOdPefAwTEn3t0Po7nRToq+JQIlEKrg+
         N5ED1K4mhyvUweHVDWdkrXKq59jrVzLVXpNLPnm5DjZGspp9f7Oj7prLsI0/OBHC9UMU
         IDwsTivq+9dxDmgISzvsk3HLmvQfl+lO1y8JTBKUUMjI6GLxqhLtn4RlB8LkSiuK9C5o
         JpTgRz36xdWyl0KPhj+cuTsfeEQ3T7TpVH1YW4aJjO4seR/p6i01dSc59JtWIJmO2XyO
         nnfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=no5wYvyxtwLKrLRq0CbAjnkls1x3ROD3k3GES6y29rI=;
        b=c7dS46U1M12YVUmsrkYtVHJMgjaCV0+LOxy2HiekQWqWYpOeNXpwJgl7k9d5jPhiQq
         1ONjx0un0hmfxsUm4ZY0m3rHc7uoODZb21eYb6a/Gr9q10tE8v8v7y3kxywIx0IdrotN
         pQ3GGfeseO/Y4CE66NyQB90KBwWmISO/69kJXQ3apEW1CTGugcpmHZeS9Iv+AcTReJCf
         JUDQo00J27ZqixJs2TBmQcfldaY/zDEjJ9iqy4DcH0eTwPkl/56zhmEZ9iX7hBj9UP8r
         vJ1nxhN9w40eRfwnbdN5AzOA47fahN+NgKuzmHuA4RYUW1SphZnEl6mwcCzArsZskAOx
         BGlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 124si17313399qkh.244.2019.07.18.11.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 11:08:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 71A9381E00;
	Thu, 18 Jul 2019 18:08:36 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E3AFD19C65;
	Thu, 18 Jul 2019 18:08:32 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH] mm, slab: Move memcg_cache_params structure to mm/slab.h
Date: Thu, 18 Jul 2019 14:08:27 -0400
Message-Id: <20190718180827.18758-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 18 Jul 2019 18:08:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg_cache_params structure is only embedded into the kmem_cache
of slab and slub allocators as defined in slab_def.h and slub_def.h
and used internally by mm code. There is no needed to expose it in
a public header. So move it from include/linux/slab.h to mm/slab.h.
It is just a refactoring patch with no code change.

In fact both the slub_def.h and slab_def.h should be moved into the mm
directory as well, but that will probably cause many merge conflicts.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/slab.h | 62 -------------------------------------------
 mm/slab.h            | 63 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+), 62 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 56c9c7eed34e..ab2b98ad76e1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -595,68 +595,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 	return __kmalloc_node(size, flags, node);
 }
 
-struct memcg_cache_array {
-	struct rcu_head rcu;
-	struct kmem_cache *entries[0];
-};
-
-/*
- * This is the main placeholder for memcg-related information in kmem caches.
- * Both the root cache and the child caches will have it. For the root cache,
- * this will hold a dynamically allocated array large enough to hold
- * information about the currently limited memcgs in the system. To allow the
- * array to be accessed without taking any locks, on relocation we free the old
- * version only after a grace period.
- *
- * Root and child caches hold different metadata.
- *
- * @root_cache:	Common to root and child caches.  NULL for root, pointer to
- *		the root cache for children.
- *
- * The following fields are specific to root caches.
- *
- * @memcg_caches: kmemcg ID indexed table of child caches.  This table is
- *		used to index child cachces during allocation and cleared
- *		early during shutdown.
- *
- * @root_caches_node: List node for slab_root_caches list.
- *
- * @children:	List of all child caches.  While the child caches are also
- *		reachable through @memcg_caches, a child cache remains on
- *		this list until it is actually destroyed.
- *
- * The following fields are specific to child caches.
- *
- * @memcg:	Pointer to the memcg this cache belongs to.
- *
- * @children_node: List node for @root_cache->children list.
- *
- * @kmem_caches_node: List node for @memcg->kmem_caches list.
- */
-struct memcg_cache_params {
-	struct kmem_cache *root_cache;
-	union {
-		struct {
-			struct memcg_cache_array __rcu *memcg_caches;
-			struct list_head __root_caches_node;
-			struct list_head children;
-			bool dying;
-		};
-		struct {
-			struct mem_cgroup *memcg;
-			struct list_head children_node;
-			struct list_head kmem_caches_node;
-			struct percpu_ref refcnt;
-
-			void (*work_fn)(struct kmem_cache *);
-			union {
-				struct rcu_head rcu_head;
-				struct work_struct work;
-			};
-		};
-	};
-};
-
 int memcg_update_all_caches(int num_memcgs);
 
 /**
diff --git a/mm/slab.h b/mm/slab.h
index 5bf615cb3f99..68e455f2b698 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -30,6 +30,69 @@ struct kmem_cache {
 	struct list_head list;	/* List of all slab caches on the system */
 };
 
+#else /* !CONFIG_SLOB */
+
+struct memcg_cache_array {
+	struct rcu_head rcu;
+	struct kmem_cache *entries[0];
+};
+
+/*
+ * This is the main placeholder for memcg-related information in kmem caches.
+ * Both the root cache and the child caches will have it. For the root cache,
+ * this will hold a dynamically allocated array large enough to hold
+ * information about the currently limited memcgs in the system. To allow the
+ * array to be accessed without taking any locks, on relocation we free the old
+ * version only after a grace period.
+ *
+ * Root and child caches hold different metadata.
+ *
+ * @root_cache:	Common to root and child caches.  NULL for root, pointer to
+ *		the root cache for children.
+ *
+ * The following fields are specific to root caches.
+ *
+ * @memcg_caches: kmemcg ID indexed table of child caches.  This table is
+ *		used to index child cachces during allocation and cleared
+ *		early during shutdown.
+ *
+ * @root_caches_node: List node for slab_root_caches list.
+ *
+ * @children:	List of all child caches.  While the child caches are also
+ *		reachable through @memcg_caches, a child cache remains on
+ *		this list until it is actually destroyed.
+ *
+ * The following fields are specific to child caches.
+ *
+ * @memcg:	Pointer to the memcg this cache belongs to.
+ *
+ * @children_node: List node for @root_cache->children list.
+ *
+ * @kmem_caches_node: List node for @memcg->kmem_caches list.
+ */
+struct memcg_cache_params {
+	struct kmem_cache *root_cache;
+	union {
+		struct {
+			struct memcg_cache_array __rcu *memcg_caches;
+			struct list_head __root_caches_node;
+			struct list_head children;
+			bool dying;
+		};
+		struct {
+			struct mem_cgroup *memcg;
+			struct list_head children_node;
+			struct list_head kmem_caches_node;
+			struct percpu_ref refcnt;
+
+			void (*work_fn)(struct kmem_cache *);
+			union {
+				struct rcu_head rcu_head;
+				struct work_struct work;
+			};
+		};
+	};
+};
 #endif /* CONFIG_SLOB */
 
 #ifdef CONFIG_SLAB
-- 
2.18.1

